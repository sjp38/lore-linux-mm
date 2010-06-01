Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3CE526B01D7
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 17:21:45 -0400 (EDT)
Date: Tue, 1 Jun 2010 23:20:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
	of !mm to skip kthreads
Message-ID: <20100601212023.GA24917@redhat.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011333470.13136@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006011333470.13136@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/01, David Rientjes wrote:
>
> On Mon, 31 May 2010, KOSAKI Motohiro wrote:
>
> > select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
> > is not true due to use_mm().
> >
> > Change the code to check PF_KTHREAD.
>
> This is already pushed in my oom killer rewrite as patch 14/18 "check
> PF_KTHREAD instead of !mm to skip kthreads".
>
> This does not need to be merged immediately since it's not vital: use_mm()
> is only temporary state and these kthreads will once again be excluded
> when they call unuse_mm().  The worst case scenario here is that the oom
> killer will erroneously select one of these kthreads which cannot die

It can't die but force_sig() does bad things which shouldn't be done
with workqueue thread. Note that it removes SIG_IGN, sets
SIGNAL_GROUP_EXIT, makes signal_pending/fatal_signal_pedning true, etc.

But yes, I agree, the problem is minor. But nevertheless it is bug,
the longstanding bug with the simple fix. Why should we "hide" this fix
inside the long series of non-trivial patches which rewrite oom-killer?
And it is completely orthogonal to other changes.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
