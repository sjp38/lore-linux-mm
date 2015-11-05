Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3238E82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 03:46:53 -0500 (EST)
Received: by wmnn186 with SMTP id n186so7640307wmn.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 00:46:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14si5098481wmg.115.2015.11.05.00.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 00:46:52 -0800 (PST)
Subject: Re: Newbie's question: memory allocation when reclaiming memory
References: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
 <20151002123639.GA13914@dhcp22.suse.cz>
 <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
 <201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
 <201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
 <201510262044.BAI43236.FOMSFFOtOVLJQH@I-love.SAKURA.ne.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563B1777.5090008@suse.cz>
Date: Thu, 5 Nov 2015 09:46:47 +0100
MIME-Version: 1.0
In-Reply-To: <201510262044.BAI43236.FOMSFFOtOVLJQH@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On 10/26/2015 12:44 PM, Tetsuo Handa wrote:
> May I ask a newbie question? Say, there is some amount of memory pages
> which can be reclaimed if they are flushed to storage. And lower layer
> might issue memory allocation request in a way which won't cause reclaim
> deadlock (e.g. using GFP_NOFS or GFP_NOIO) when flushing to storage,
> isn't it?
> 
> What I'm worrying is a dependency that __GFP_FS allocation requests think
> that there are reclaimable pages and therefore there is no need to call
> out_of_memory(); and GFP_NOFS allocation requests which the __GFP_FS
> allocation requests depend on (in order to flush to storage) is waiting
> for GFP_NOIO allocation requests; and the GFP_NOIO allocation requests
> which the GFP_NOFS allocation requests depend on (in order to flush to
> storage) are waiting for memory pages to be reclaimed without calling
> out_of_memory(); because gfp_to_alloc_flags() does not favor GFP_NOIO over
> GFP_NOFS nor GFP_NOFS over __GFP_FS which will throttle all allocations
> at the same watermark level.
> 
> How do we guarantee that GFP_NOFS/GFP_NOIO allocations make forward
> progress? What mechanism guarantees that memory pages which __GFP_FS
> allocation requests are waiting for are reclaimed? I assume that there
> is some mechanism; otherwise we can hit silent livelock, can't we?

I've never studied the code myself, but IIRC in all the debates LSF/MM I've
heard it said that GFP_NOIO allocations have mempools that guarantee forward
progress, so when they allocate from this mempool, there should be nothing else
to block the request other than waiting for the actual hardware to finish the
I/O request, and then the memory is returned to mempool and another request can
use it. So there shouldn't be waiting for reclaim at that level, breaking the
livelock you described?

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
