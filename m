Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 27DA56B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 06:15:50 -0500 (EST)
Date: Wed, 24 Nov 2010 12:09:15 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
Message-ID: <20101124110915.GA20452@redhat.com>
References: <20101025122914.9173.A69D9226@jp.fujitsu.com> <20101123143427.GA30941@redhat.com> <20101124085022.7BDF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101124085022.7BDF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 11/24, KOSAKI Motohiro wrote:
>
> Hi
>
> > On 10/25, KOSAKI Motohiro wrote:
> > >
> > > Because execve() makes new mm struct and setup stack and
> > > copy argv. It mean the task have two mm while execve() temporary.
> > > Unfortunately this nascent mm is not pointed any tasks, then
> > > OOM-killer can't detect this memory usage. therefore OOM-killer
> > > may kill incorrect task.
> > >
> > > Thus, this patch added signal->in_exec_mm member and track
> > > nascent mm usage.
> >
> > Stupid question.
> >
> > Can't we just account these allocations in the old -mm temporary?
> >
> > IOW. Please look at the "patch" below. It is of course incomplete
> > and wrong (to the point inc_mm_counter() is not safe without
> > SPLIT_RSS_COUNTING), and copy_strings/flush_old_exec are not the
> > best places to play with mm-counters, just to explain what I mean.
> >
> > It is very simple. copy_strings() increments MM_ANONPAGES every
> > time we add a new page into bprm->vma. This makes this memory
> > visible to select_bad_process().
> >
> > When exec changes ->mm (or if it fails), we change MM_ANONPAGES
> > counter back.
> >
> > Most probably I missed something, but what do you think?
>
> Because, If the pages of argv is swapping out when processing execve,
> This accouing doesn't work.

Why?

If copy_strings() inserts the new page into bprm->vma and then
this page is swapped out, inc_mm_counter(current->mm, MM_ANONPAGES)
becomes incorrect, yes. And we can't turn it into MM_SWAPENTS.

But does this really matter? oom_badness() counts MM_ANONPAGES +
MM_SWAPENTS, and result is the same.

> Is this enough explanation? Please don't hesitate say "no". If people
> don't like my approach, I don't hesitate change my thinking.

Well, certainly I can't say no ;)

But it would be nice to find a more simple fix (if it can work,
of course).


And. I need a simple solution for the older kernels.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
