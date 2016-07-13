Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D07DD6B0263
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:19:41 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q83so94777193iod.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:19:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e199si2714204oic.48.2016.07.13.06.19.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 06:19:40 -0700 (PDT)
Subject: Re: System freezes after OOM
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
Date: Wed, 13 Jul 2016 22:19:23 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> On Tue, 12 Jul 2016, Michal Hocko wrote:
> 
>> On Mon 11-07-16 11:43:02, Mikulas Patocka wrote:
>> [...]
>>> The general problem is that the memory allocator does 16 retries to 
>>> allocate a page and then triggers the OOM killer (and it doesn't take into 
>>> account how much swap space is free or how many dirty pages were really 
>>> swapped out while it waited).
>>
>> Well, that is not how it works exactly. We retry as long as there is a
>> reclaim progress (at least one page freed) back off only if the
>> reclaimable memory can exceed watermks which is scaled down in 16
>> retries. The overal size of free swap is not really that important if we
>> cannot swap out like here due to complete memory reserves depletion:
>> https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/vmlog-1462458369-00000/sample-00011/dmesg:
>> [   90.491276] Node 0 DMA free:0kB min:60kB low:72kB high:84kB active_anon:4096kB inactive_anon:4636kB active_file:212kB inactive_file:280kB unevictable:488kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:488kB dirty:276kB writeback:4636kB mapped:476kB shmem:12kB slab_reclaimable:204kB slab_unreclaimable:4700kB kernel_stack:48kB pagetables:120kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:61132 all_unreclaimable? yes
>> [   90.491283] lowmem_reserve[]: 0 977 977 977
>> [   90.491286] Node 0 DMA32 free:0kB min:3828kB low:4824kB high:5820kB active_anon:423820kB inactive_anon:424916kB active_file:17996kB inactive_file:21800kB unevictable:20724kB isolated(anon):384kB isolated(file):0kB present:1032184kB managed:1001260kB mlocked:20724kB dirty:25236kB writeback:49972kB mapped:23076kB shmem:1364kB slab_reclaimable:13796kB slab_unreclaimable:43008kB kernel_stack:2816kB pagetables:7320kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:5635400 all_unreclaimable? yes
>>
>> Look at the amount of free memory. It is completely depleted. So it
>> smells like a process which has access to memory reserves has consumed
>> all of it. I suspect a __GFP_MEMALLOC resp. PF_MEMALLOC from softirq
>> context user which went off the leash.
> 
> It is caused by the commit f9054c70d28bc214b2857cf8db8269f4f45a5e23. Prior 
> to this commit, mempool allocations set __GFP_NOMEMALLOC, so they never 
> exhausted reserved memory. With this commit, mempool allocations drop 
> __GFP_NOMEMALLOC, so they can dig deeper (if the process has PF_MEMALLOC, 
> they can bypass all limits).

I wonder whether commit f9054c70d28bc214 ("mm, mempool: only set
__GFP_NOMEMALLOC if there are free elements") is doing correct thing.
It says

    If an oom killed thread calls mempool_alloc(), it is possible that it'll
    loop forever if there are no elements on the freelist since
    __GFP_NOMEMALLOC prevents it from accessing needed memory reserves in
    oom conditions.

but we can allow mempool_alloc(__GFP_NOMEMALLOC) requests to access
memory reserves via below change, can't we? The purpose of allowing
ALLOC_NO_WATERMARKS via TIF_MEMDIE is to make sure current allocation
request does not to loop forever inside the page allocator, isn't it?
Why we need to allow mempool_alloc(__GFP_NOMEMALLOC) requests to use
ALLOC_NO_WATERMARKS when TIF_MEMDIE is not set?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b69..e4e3700 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3439,14 +3439,14 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
-	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
+	if (!in_interrupt() && unlikely(test_thread_flag(TIF_MEMDIE)))
+		alloc_flags |= ALLOC_NO_WATERMARKS;
+	else if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
 		if (gfp_mask & __GFP_MEMALLOC)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (!in_interrupt() &&
-				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
+		else if (!in_interrupt() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 #ifdef CONFIG_CMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
