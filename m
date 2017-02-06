Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 889216B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 05:34:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so18468513wmv.5
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 02:34:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si7510969wmb.160.2017.02.06.02.34.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 02:34:30 -0800 (PST)
Date: Mon, 6 Feb 2017 11:34:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170206103424.GC3097@dhcp22.suse.cz>
References: <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
 <20170203145548.GC19325@dhcp22.suse.cz>
 <201702051943.CFB35412.OOSJVtLFOFQHMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201702051943.CFB35412.OOSJVtLFOFQHMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, peterz@infradead.org

On Sun 05-02-17 19:43:07, Tetsuo Handa wrote:
[...]
> Below one is also a loop. Maybe we can add __GFP_NOMEMALLOC to GFP_NOWAIT ?

No, GFP_NOWAIT is just too generic to use this flag.

> [  257.781715] Out of memory: Kill process 5171 (a.out) score 842 or sacrifice child
> [  257.784726] Killed process 5171 (a.out) total-vm:2177096kB, anon-rss:1476488kB, file-rss:4kB, shmem-rss:0kB
> [  257.787691] a.out(5171): TIF_MEMDIE allocation: order=0 mode=0x1000200(GFP_NOWAIT|__GFP_NOWARN)
> [  257.789789] CPU: 3 PID: 5171 Comm: a.out Not tainted 4.10.0-rc6-next-20170202+ #500
> [  257.791784] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> [  257.794700] Call Trace:
> [  257.795690]  dump_stack+0x85/0xc9
> [  257.797224]  __alloc_pages_slowpath+0xacb/0xe36
> [  257.798612]  __alloc_pages_nodemask+0x382/0x3d0
> [  257.799942]  alloc_pages_current+0x97/0x1b0
> [  257.801236]  __get_free_pages+0x14/0x50
> [  257.802546]  __tlb_remove_page_size+0x70/0xd0

This is bound to MAX_GATHER_BATCH_COUNT which shouldn't be a lot of
pages (20 or so). We could add __GFP_NOMEMALLOC into tlb_next_batch
but I am not entirely convinced it is really necessary.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
