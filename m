Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A65E6B025F
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 07:26:02 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id l125so194871618ywb.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 04:26:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a129si4942398qkd.213.2016.07.15.04.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 04:26:01 -0700 (PDT)
Date: Fri, 15 Jul 2016 07:25:59 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <alpine.DEB.2.10.1607141324290.68666@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1607150722460.5034@file01.intranet.prod.int.rdu2.redhat.com>
References: <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com> <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com> <201607142001.BJD07258.SMOHFOJVtLFOQF@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1607141324290.68666@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mhocko@kernel.org, okozina@redhat.com, jmarchan@redhat.com, skozina@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Thu, 14 Jul 2016, David Rientjes wrote:

> On Thu, 14 Jul 2016, Tetsuo Handa wrote:
> 
> > David Rientjes wrote:
> > > On Wed, 13 Jul 2016, Mikulas Patocka wrote:
> > > 
> > > > What are the real problems that f9054c70d28bc214b2857cf8db8269f4f45a5e23 
> > > > tries to fix?
> > > > 
> > > 
> > > It prevents the whole system from livelocking due to an oom killed process 
> > > stalling forever waiting for mempool_alloc() to return.  No other threads 
> > > may be oom killed while waiting for it to exit.
> > 
> > Is that concern still valid? We have the OOM reaper for CONFIG_MMU=y case.
> > 
> 
> Umm, show me an explicit guarantee where the oom reaper will free memory 
> such that other threads may return memory to this process's mempool so it 
> can make forward progress in mempool_alloc() without the need of utilizing 
> memory reserves.  First, it might be helpful to show that the oom reaper 
> is ever guaranteed to free any memory for a selected oom victim.

The function mempool_alloc sleeps with "io_schedule_timeout(5*HZ);"

So, if the oom reaper frees some memory into the page allocator, the 
process that is stuck in mempoo_alloc will sleep for up to 5 seconds, then 
it will retry the allocation with "element = pool->alloc(gfp_temp, 
pool->pool_data)" (that will allocate from the page allocator) and succed.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
