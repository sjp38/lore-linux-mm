Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id AFC896B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 21:07:41 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so6294088pbc.30
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 18:07:41 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id mn6si24062116pbc.17.2014.06.23.18.07.39
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 18:07:40 -0700 (PDT)
Message-ID: <53A8CF4B.90300@cn.fujitsu.com>
Date: Tue, 24 Jun 2014 09:07:23 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 05/13] mm, compaction: report compaction as contended
 only due to lock contention
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz> <1403279383-5862-6-git-send-email-vbabka@suse.cz> <20140623013903.GA12413@bbox> <53A7EB9B.5000406@cn.fujitsu.com> <20140623233507.GF15594@bbox>
In-Reply-To: <20140623233507.GF15594@bbox>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

Hello Minchan

Thank you for your explain. Actually, I read the kernel with an old
version. The latest upstream kernel has the behaviour like you described
below. Oops, how long didn't I follow the buddy allocator change.

Thanks.

On 06/24/2014 07:35 AM, Minchan Kim wrote:
>>> Anyway, most big concern is that you are changing current behavior as
>>> > > I said earlier.
>>> > > 
>>> > > Old behavior in THP page fault when it consumes own timeslot was just
>>> > > abort and fallback 4K page but with your patch, new behavior is
>>> > > take a rest when it founds need_resched and goes to another round with
>>> > > async, not sync compaction. I'm not sure we need another round with
>>> > > async compaction at the cost of increasing latency rather than fallback
>>> > > 4 page.
>> > 
>> > I don't see the new behavior works like what you said. If need_resched
>> > is true, it calls cond_resched() and after a rest it just breaks the loop.
>> > Why there is another round with async compact?
> One example goes
> 
> Old:
> page fault
> huge page allocation
> __alloc_pages_slowpath
> __alloc_pages_direct_compact
> compact_zone_order
>         isolate_migratepages
>         compact_checklock_irqsave
>                 need_resched is true
>                 cc->contended = true;
>         return ISOLATE_ABORT
> return COMPACT_PARTIAL with *contented = cc.contended;
> COMPACTFAIL
> if (contended_compaction && gfp_mask & __GFP_NO_KSWAPD)
>         goto nopage;
> 
> New:
> 
> page fault
> huge page allocation
> __alloc_pages_slowpath
> __alloc_pages_direct_compact
> compact_zone_order
>         isolate_migratepages
>         compact_unlock_should_abort
>                 need_resched is true
>                 cc->contended = COMPACT_CONTENDED_SCHED;
>                 return true;
>         return ISOLATE_ABORT
> return COMPACT_PARTIAL with *contended = cc.contended == COMPACT_CONTENDED_LOCK (1)
> COMPACTFAIL
> if (contended_compaction && gfp_mask & __GFP_NO_KSWAPD)
>         no goto nopage because contended_compaction was false by (1)
> 
> __alloc_pages_direct_reclaim
> if (should_alloc_retry)
> else
>         __alloc_pages_direct_compact again with ASYNC_MODE
>                         
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
