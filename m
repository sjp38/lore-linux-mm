Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 781896B021F
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 10:01:32 -0400 (EDT)
Date: Thu, 3 Jun 2010 16:00:08 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/12] oom: remove PF_EXITING check completely
Message-ID: <20100603140008.GA3548@redhat.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152436.7262.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006022332320.22441@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006022332320.22441@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/02, David Rientjes wrote:
>
> On Thu, 3 Jun 2010, KOSAKI Motohiro wrote:
>
> > Currently, PF_EXITING check is completely broken. because 1) It only
> > care main-thread and ignore sub-threads
>
> Then check the subthreads.
>
> > 2) If user enable core-dump
> > feature, it can makes deadlock because the task during coredump ignore
> > SIGKILL.
> >
>
> It may ignore SIGKILL, but does not ignore fatal_signal_pending() being
> true

Wrong.

Unless the oom victim is exactly the thread which dumps the core,
fatal_signal_pending() won't be true for the dumper. Even if the
victim and the dumper are from the same group, this thread group
already has SIGNAL_GROUP_EXIT. And if they do not belong to the
same group, SIGKILL has even less effect.

Even if we chose the right thread we can race with
clear_thread_flag(TIF_SIGPENDING), but fatal_signal_pending()
checks signal_pending().

> which gives it access to memory reserves with my patchset

__get_user_pages() already checks fatal_signal_pending(), this
is where the dumper allocates the memory (mostly).

And I am not sure I understand the "access to memory reserves",
the dumper should just stop if oom-kill decides it should die,
it can use a lot more memory if it doesn't stop.

> Nacked-by: David Rientjes <rientjes@google.com>

Kosaki removes the code which only pretends to work, but it doesn't
and leads to problems.

If you think we need this check, imho it is better to make the patch
which adds the "right" code with the nice changelog explaining how
this code works.


Just my opinion, I know very little about oom logic/needs/problems,
you can ignore me.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
