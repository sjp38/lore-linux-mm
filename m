Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1C58F8D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 17:36:14 -0400 (EDT)
Date: Sun, 13 Mar 2011 22:27:26 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/3] oom: TIF_MEMDIE/PF_EXITING fixes
Message-ID: <20110313212726.GA24530@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>

Hi Hugh,

On 03/12, Hugh Dickins wrote:
>
> On Sat, Mar 12, 2011 at 5:43 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >>
> >> Also. Could you please look at the patches I sent?
> >>
> >>       [PATCH 1/1] oom_kill_task: mark every thread as TIF_MEMDIE
> >>       [PATCH v2 1/1] select_bad_process: improve the PF_EXITING check
> >
> > Cough. And both were not right, while_each_thread(p, t) needs the properly
> > initialized "t". At least I warned they were not tested ;)
> >
> >> Note also the note about "p == current" check. it should be fixed too.
> >
> > I am resending the fixes above plus the new one.
>
> I've spent much of the week building up to join in, but the more I
> look around, the more I find to say or investigate, and therefore
> never quite get to write the mail.  Let this be a placeholder, that I
> probably disagree (in an amicable way!) with all of you, and maybe
> I'll finally manage to collect my thoughts into mail later today.

Thanks for looking into this!

Before I say anything else, I'd like to repeat that I am not going
to argue with the nack. The only reason I sent these patches is that
I can not understand David's patch at all. I mean, I can not even
understand the problems it should address. Yet I think the patch is
not right.

So I just tried to guess why this change helps, and suggest the
alternatives for review/testing.

> I guess my main point will be that TIF_MEMDIE serves a number of
> slightly different, even conflicting, purposes;

Yes. And let me repeat, I do not pretend understand it. However,
I bet the usage of TIF_MEMDIE is wrong.

> and one of those
> purposes, which present company seems to ignore repeatedly, is to
> serialize access to final reserves of memory

I don't quite understand "serialize" above. I hope you didn't mean
that only one thread can have TIF_MEMDIE to avoid the races...

But yes, I understand that "a lot" of TIF_MEMDIE thread can abuse
__alloc_pages_high_priority/etc. At least, I hope I understand ;)

- as a comment by Nick in
> select_bad_process() makes clear.

Oh. This comment is not clear at all.

		 * This task already has access to memory reserves and is
		 * being killed.

which task? it is quite possible that this task is already dead/released.
Or it is just exiting without memory allocations. This is group leader.
All we know is that it has task_struct, no more.

		 * Don't allow any other task access to the
		 * memory reserve.

Which other tasks? What about the sub-threads of the killed process?
It is quite possible that another thread triggered OOM and needs
TIF_MEMDIE to access the memory reserves.

And even this is not consistent. sysctl_oom_kill_allocating_task
does oom_kill_process(current) which may be non-leader.


oom_kill_process()->set_tsk_thread_flag(p, TIF_MEMDIE) is simply wrong.
The _trivial_ exploit (distinct from this one) can kill the system. And
worse! I showed this exploit many times (most probably off-list but all
were cc'ed). This was already fixed (iirc), and know I see we have it
again. This because almost every PF_EXITING check in oom_kill.c is wrong.
I'll return to this tomorrow.

> We _might_ choose to abandon that, but if so, it should be a decision,
> not an oversight.  So I cannot blindly agree with just setting
> TIF_MEMDIE on more and more tasks,

OK, lets not do this.

> wonder if use of your find_lock_task_mm() in   select_bad_process()
> might bring together my wish to continue serialization, David's wish
> to avoid stupid panics, and your wish to avoid deadlocks.

Hmm. Could you explain?

> but even after repeated skims of the ptrace manpage,  I'll admit to
> not having a clue, nor the inclination to run and then debug it to
> find out the answer.

Ahh, sorry. I didn't explain what this test-case does... Because we
discussed this many times before, iirc.

> I don't even know if the double pthread_create is
> a vital part of the scheme

it is,

> so I assume it leaves a PF_EXITING around
> forever,

More precisely, it creates the PF_EXITING thread with ->mm != NULL.
It never goes away (unless you kill the tracer, of course).

> but I couldn't quite see how (with PF_EXITING being set after
> the tracehook_report_exit).

Yes. But note that it creates 2 threads, and the second one hangs
in exit_mm() before clearing ->mm while the 3rd thread can waits
for the 1st one which should enter exit_mm() and participate.

But this is not important, you can ignore the actual details.

> And I wonder if a similar case can be
> constructed to deadlock the for_each_process version of
> select_bad_process().

Unfortunately yes. This is documented in the changelog of 2/2.
We should fix the problems with the coredumps. Hmm, we already
had some patches, but they were forgotten/ignored. But at least
we shouldn't move back and assume that "PF_EXITING && mm" means
"we will have more memory soon".

I'll return tomorrow. At first glance, the new patch from David
has the same problem, but I am not sure.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
