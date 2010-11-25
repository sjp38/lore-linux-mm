Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D1D8D6B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 09:56:31 -0500 (EST)
Date: Thu, 25 Nov 2010 15:02:53 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
Message-ID: <20101125140253.GA29371@redhat.com>
References: <20101124085022.7BDF.A69D9226@jp.fujitsu.com> <20101124110915.GA20452@redhat.com> <20101125092237.F43A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101125092237.F43A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 11/25, KOSAKI Motohiro wrote:
>
> > > > It is very simple. copy_strings() increments MM_ANONPAGES every
> > > > time we add a new page into bprm->vma. This makes this memory
> > > > visible to select_bad_process().
> > > >
> > > > When exec changes ->mm (or if it fails), we change MM_ANONPAGES
> > > > counter back.
> > > >
> > > > Most probably I missed something, but what do you think?
> > >
> > > Because, If the pages of argv is swapping out when processing execve,
> > > This accouing doesn't work.
> >
> > Why?
> >
> > If copy_strings() inserts the new page into bprm->vma and then
> > this page is swapped out, inc_mm_counter(current->mm, MM_ANONPAGES)
> > becomes incorrect, yes. And we can't turn it into MM_SWAPENTS.
> >
> > But does this really matter? oom_badness() counts MM_ANONPAGES +
> > MM_SWAPENTS, and result is the same.
>
> Ah, I got it. I did too strongly get stucked correct accounting. but
> you mean it's not must.

Yes. In fact, I _think_ this patch makes accounting better, even if
the extra MM_ANONPAGES numbers are not 100% correct.

Even if we add signal->in_exec_mm, nobody except oom_badness() will
look at it.

With this patch, say, /proc/pid/statm or /proc/pid/status will report
the memory allocated by the execing task. Even if technically this is
not correct (and 'swap' part may be wrong), this makes sense imho.
Otherwise, there is no way to see that this task allocates (may be
a lot) of memory.

This can "confuse" update_hiwater_rss(), but imho this is fine too.


> > > Is this enough explanation? Please don't hesitate say "no". If people
> > > don't like my approach, I don't hesitate change my thinking.
> >
> > Well, certainly I can't say no ;)
> >
> > But it would be nice to find a more simple fix (if it can work,
> > of course).
> >
> >
> > And. I need a simple solution for the older kernels.
>
> Alright. It is certinally considerable one.

Great! I'll send the patch tomorrow.

Even if you prefer another fix for 2.6.37/stable, I'd like to see
your review to know if it is correct or not (for backporting).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
