Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 041F26B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:29:37 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i12so135617010ywa.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:29:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u197si896892ywu.234.2016.07.14.05.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 05:29:36 -0700 (PDT)
Date: Thu, 14 Jul 2016 08:29:32 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <201607142001.BJD07258.SMOHFOJVtLFOQF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.LRH.2.02.1607140827330.15554@file01.intranet.prod.int.rdu2.redhat.com>
References: <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com> <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com> <201607142001.BJD07258.SMOHFOJVtLFOQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, mhocko@kernel.org, okozina@redhat.com, jmarchan@redhat.com, skozina@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com



On Thu, 14 Jul 2016, Tetsuo Handa wrote:

> Michal Hocko wrote:
> > OK, this is the part I have missed. I didn't realize that the swapout
> > path, which is indeed PF_MEMALLOC, can get down to blk code which uses
> > mempools. A quick code travers shows that at least
> > 	make_request_fn = blk_queue_bio
> > 	blk_queue_bio
> > 	  get_request
> > 	    __get_request
> > 
> > might do that. And in that case I agree that the above mentioned patch
> > has unintentional side effects and should be re-evaluated. David, what
> > do you think? An obvious fixup would be considering TIF_MEMDIE in
> > mempool_alloc explicitly.
> 
> TIF_MEMDIE is racy. Since the OOM killer sets TIF_MEMDIE on only one thread,
> there is no guarantee that TIF_MEMDIE is set to the thread which is looping
> inside mempool_alloc().

If the device mapper subsystem is not returning objects to the mempool, it 
should be investigated as a bug in the device mapper.

There is no need to add workarounds to mempool_alloc to work around that 
bug.

Mikulas

> And since __GFP_NORETRY is used (regardless of
> f9054c70d28bc214), out_of_memory() is not called via __alloc_pages_may_oom().
> This means that the thread which is looping inside mempool_alloc() can't
> get TIF_MEMDIE unless TIF_MEMDIE is set by the OOM killer.
> 
> Maybe set __GFP_NOMEMALLOC by default at mempool_alloc() and remove it
> at mempool_alloc() when fatal_signal_pending() is true? But that behavior
> can OOM-kill somebody else when current was not OOM-killed. Sigh...
> 
> David Rientjes wrote:
> > On Wed, 13 Jul 2016, Mikulas Patocka wrote:
> > 
> > > What are the real problems that f9054c70d28bc214b2857cf8db8269f4f45a5e23 
> > > tries to fix?
> > > 
> > 
> > It prevents the whole system from livelocking due to an oom killed process 
> > stalling forever waiting for mempool_alloc() to return.  No other threads 
> > may be oom killed while waiting for it to exit.
> 
> Is that concern still valid? We have the OOM reaper for CONFIG_MMU=y case.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
