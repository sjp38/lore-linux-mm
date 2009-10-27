Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id ACC7E6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:44:14 -0400 (EDT)
Date: Tue, 27 Oct 2009 20:44:16 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Memory overcommit
In-Reply-To: <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910271843510.11372@sister.anvils>
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
 <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
 <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, rientjes@google.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009, KAMEZAWA Hiroyuki wrote:
> Sigh, gnome-session has twice value of mmap(1G).
> Of course, gnome-session only uses 6M bytes of anon.
> I wonder this is because gnome-session has many children..but need to
> dig more. Does anyone has idea ?

When preparing KSM unmerge to handle OOM, I looked at how the precedent
was handled by running a little program which mmaps an anonymous region
of the same size as physical memory, then tries to mlock it.  The
program was such an obvious candidate to be killed, I was shocked
by the poor decisions the OOM killer made.  Usually I ran it with
mem=512M, with gnome and firefox active.  Often the OOM killer killed
it right the first time, but went wrong when I tried it a second time
(I think that's because of what's already swapped out the first time).

I built up a patchset of fixes, but once I came to split them up for
submission, not one of them seemed entirely satisfactory; and Andrea's
fix to the KSM/mlock deadlock forced me to abandon even the first of
the patches (we've since then fixed the way munlocking behaves, so
in theory could revisit that; but Andrea disliked what I was trying
to do there in KSM for other reasons, so I've not touched it since).
I had to get on with KSM, so I set it all aside: none of the issues
was a recent regression.

I did briefly wonder about the reliance on total_vm which you're now
looking into, but didn't touch that at all.  Let me describe those
issues which I did try but fail to fix - I've no more time to deal
with them now than then, but ought at least to mention them to you.

1.  select_bad_process() tries to avoid killing another process while
there's still a TIF_MEMDIE, but its loop starts by skipping !p->mm
processes.  However, p->mm is set to NULL well before p reaches
exit_mmap() to actually free the memory, and there may be significant
delays in between (I think exit_robust_list() gave me a hang at one
stage).  So in practice, even when the OOM killer selects the right
process to kill, there can be lots of collateral damage from it not
waiting long enough for that process to give up its memory.

I tried to deal with that by moving the TIF_MEMDIE test up before
the p->mm test, but adding in a check on p->exit_state:
		if (test_tsk_thread_flag(p, TIF_MEMDIE) &&
		    !p->exit_state)
			return ERR_PTR(-1UL);
But this is then liable to hang the system if there's some reason
why the selected process cannot proceed to free its memory (e.g.
the current KSM unmerge case).  It needs to wait "a while", but
give up if no progress is made, instead of hanging: originally
I thought that setting PF_MEMALLOC more widely in page_alloc.c,
and giving up on the TIF_MEMDIE if it was waiting in PF_MEMALLOC,
would deal with that; but we cannot be sure that waiting of memory
is the only reason for a holdup there (in the KSM unmerge case it's
waiting for an mmap_sem, and there may well be other such cases).

2.  I started out running my mlock test program as root (later
switched to use "ulimit -l unlimited" first).  But badness() reckons
CAP_SYS_ADMIN or CAP_SYS_RESOURCE is a reason to quarter your points;
and CAP_SYS_RAWIO another reason to quarter your points: so running
as root makes you sixteen times less likely to be killed.  Quartering
is anyway debatable, but sixteenthing seems utterly excessive to me.

I moved the CAP_SYS_RAWIO test in with the others, so it does no
more than quartering; but is quartering appropriate anyway?  I did
wonder if I was right to be "subverting" the fine-grained CAPs in
this way, but have since seen unrelated mail from one who knows
better, implying they're something of a fantasy, that su and sudo
are indeed what's used in the real world.  Maybe this patch was okay.

3.  badness() has a comment above it which says:  
 * 5) we try to kill the process the user expects us to kill, this
 *    algorithm has been meticulously tuned to meet the principle
 *    of least surprise ... (be careful when you change it)
But Andrea's 2.6.11 86a4c6d9e2e43796bb362debd3f73c0e3b198efa (later
refined by Kurt's 2.6.16 9827b781f20828e5ceb911b879f268f78fe90815)
adds plenty of surprise there, by trying to factor children into the
calculation.  Intended to deal with forkbombs, but any reasonable
process whose purpose is to fork children (e.g. gnome-session)
becomes very vulnerable.  And whereas badness() itself goes on to
refine the total_vm points by various adjustments peculiar to the
process in question, those refinements have been ignored when
adding the child's total_vm/2.  (Andrea does remark that he'd
rather have rewritten badness() from scratch.)

I tried to fix this by moving the PF_OOM_ORIGIN (was PF_SWAPOFF)
part of the calculation up to select_bad_process(), making a
solo_badness() function which makes all those adjustments to
total_vm, then badness() itself a simple function adding half
the children's solo_badness()es to the process' own solo_badness().
But probably lots more needs doing - Andrea's rewrite?

4.  In some cases those children are sharing exactly the same mm,
yet its total_vm is being added again and again to the points:
I had a nasty inner loop searching back to see if we'd already
counted this mm (but then, what if the different tasks sharing
the mm deserved different adjustments to the total_vm?).


I hope these notes help someone towards a better solution
(and be prepared to discover more on the way).  I agree with
Vedran that the present behaviour is pretty unimpressive, and
I'm puzzled as to how people can have been tinkering with
oom_kill.c down the years without seeing any of this.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
