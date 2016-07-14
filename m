Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 149456B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 07:01:35 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q83so147717439iod.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 04:01:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k51si1994489otb.181.2016.07.14.04.01.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 04:01:34 -0700 (PDT)
Subject: Re: System freezes after OOM
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160713133955.GK28723@dhcp22.suse.cz>
	<alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
	<20160713145638.GM28723@dhcp22.suse.cz>
	<alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
Message-Id: <201607142001.BJD07258.SMOHFOJVtLFOQF@I-love.SAKURA.ne.jp>
Date: Thu, 14 Jul 2016 20:01:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, mpatocka@redhat.com
Cc: mhocko@kernel.org, okozina@redhat.com, jmarchan@redhat.com, skozina@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> OK, this is the part I have missed. I didn't realize that the swapout
> path, which is indeed PF_MEMALLOC, can get down to blk code which uses
> mempools. A quick code travers shows that at least
> 	make_request_fn = blk_queue_bio
> 	blk_queue_bio
> 	  get_request
> 	    __get_request
> 
> might do that. And in that case I agree that the above mentioned patch
> has unintentional side effects and should be re-evaluated. David, what
> do you think? An obvious fixup would be considering TIF_MEMDIE in
> mempool_alloc explicitly.

TIF_MEMDIE is racy. Since the OOM killer sets TIF_MEMDIE on only one thread,
there is no guarantee that TIF_MEMDIE is set to the thread which is looping
inside mempool_alloc(). And since __GFP_NORETRY is used (regardless of
f9054c70d28bc214), out_of_memory() is not called via __alloc_pages_may_oom().
This means that the thread which is looping inside mempool_alloc() can't
get TIF_MEMDIE unless TIF_MEMDIE is set by the OOM killer.

Maybe set __GFP_NOMEMALLOC by default at mempool_alloc() and remove it
at mempool_alloc() when fatal_signal_pending() is true? But that behavior
can OOM-kill somebody else when current was not OOM-killed. Sigh...

David Rientjes wrote:
> On Wed, 13 Jul 2016, Mikulas Patocka wrote:
> 
> > What are the real problems that f9054c70d28bc214b2857cf8db8269f4f45a5e23 
> > tries to fix?
> > 
> 
> It prevents the whole system from livelocking due to an oom killed process 
> stalling forever waiting for mempool_alloc() to return.  No other threads 
> may be oom killed while waiting for it to exit.

Is that concern still valid? We have the OOM reaper for CONFIG_MMU=y case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
