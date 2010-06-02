Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EE1D36B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:46:41 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o52Lkbau007378
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:46:37 -0700
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by wpaz13.hot.corp.google.com with ESMTP id o52LkYx9022222
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:46:35 -0700
Received: by pvc7 with SMTP id 7so1150813pvc.15
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 14:46:34 -0700 (PDT)
Date: Wed, 2 Jun 2010 14:46:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
 of !mm to skip kthreads
In-Reply-To: <20100602213331.GA31949@redhat.com>
Message-ID: <alpine.DEB.2.00.1006021437010.4765@chino.kir.corp.google.com>
References: <20100601212023.GA24917@redhat.com> <alpine.DEB.2.00.1006011424200.16725@chino.kir.corp.google.com> <20100602223612.F52D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021405280.32666@chino.kir.corp.google.com>
 <20100602213331.GA31949@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010, Oleg Nesterov wrote:

> > This isn't a bugfix, it simply prevents a recall to the oom killer after
> > the kthread has called unuse_mm().  Please show where any side effects of
> > oom killing a kthread, which cannot exit, as a result of use_mm() causes a
> > problem _anywhere_.
> 
> I already showed you the side effects, but you removed this part in your
> reply.
> 
> From http://marc.info/?l=linux-kernel&m=127542732121077
> 
> 	It can't die but force_sig() does bad things which shouldn't be done
> 	with workqueue thread. Note that it removes SIG_IGN, sets
> 	SIGNAL_GROUP_EXIT, makes signal_pending/fatal_signal_pedning true, etc.
> 
> A workqueue thread must not run with SIGNAL_GROUP_EXIT set, SIGKILL
> must be ignored, signal_pending() must not be true.
> 
> This is bug. It is minor, agreed, currently use_mm() is only used by aio.
> 

It's a problem that would probably never happen in practice because you're 
talking about a race between select_bad_process() and __oom_kill_task() 
which is wide since it iterates the entire tasklist, which workqueue 
threads will be near the beginning of, and there is an extremely small 
chance that the badness score for the mm that it assumed would be 
considered the ideal task to kill.  If you think this is rc material, then 
push it to Andrew and say that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
