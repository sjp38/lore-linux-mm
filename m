Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 799766B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 18:29:52 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id n82so2883904oig.22
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 15:29:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q10sor11018113qtk.10.2017.10.03.15.29.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 15:29:51 -0700 (PDT)
Date: Tue, 3 Oct 2017 18:29:49 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH] mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info
In-Reply-To: <20171003210540.GM3301751@devbig577.frc2.facebook.com>
Message-ID: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
References: <nycvar.YSQ.7.76.1710031638450.5407@knanqh.ubzr> <20171003210540.GM3301751@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 3 Oct 2017, Tejun Heo wrote:

> On Tue, Oct 03, 2017 at 04:57:44PM -0400, Nicolas Pitre wrote:
> > This can be much smaller than a page on very small memory systems. 
> > Always rounding up the size to a page is wasteful in that case, and 
> > required alignment is smaller than the memblock default. Let's round 
> > things up to a page size only when the actual size is >= page size, and 
> > then it makes sense to page-align for a nicer allocation pattern.
> 
> Isn't that a temporary area which gets freed later during boot?

Hmmm...

It may get freed through 3 different paths where 2 of them are error 
paths. What looks like a non-error path is in pcpu_embed_first_chunk() 
called from setup_per_cpu_areas(). But there are two versions of 
setup_per_cpu_areas(): one for SMP and one for !SMP. And the !SMP case 
never calls pcpu_free_alloc_info() currently.

I'm not sure i understand that code fully, but maybe the following patch 
could be a better fit:

----- >8
Subject: [PATCH] percpu: don't forget to free the temporary struct pcpu_alloc_info

Unlike the SMP case, the !SMP case does not free the memory for struct 
pcpu_alloc_info allocated in setup_per_cpu_areas(). And to give it a 
chance of being reused by the page allocator later, align it to a page 
boundary just like its size.

Signed-off-by: Nicolas Pitre <nico@linaro.org>

diff --git a/mm/percpu.c b/mm/percpu.c
index 434844415d..caab63375b 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1416,7 +1416,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
 			  __alignof__(ai->groups[0].cpu_map[0]));
 	ai_size = base_size + nr_units * sizeof(ai->groups[0].cpu_map[0]);
 
-	ptr = memblock_virt_alloc_nopanic(PFN_ALIGN(ai_size), 0);
+	ptr = memblock_virt_alloc_nopanic(PFN_ALIGN(ai_size), PAGE_SIZE);
 	if (!ptr)
 		return NULL;
 	ai = ptr;
@@ -2295,6 +2295,7 @@ void __init setup_per_cpu_areas(void)
 
 	if (pcpu_setup_first_chunk(ai, fc) < 0)
 		panic("Failed to initialize percpu areas.");
+	pcpu_free_alloc_info(ai);
 }
 
 #endif	/* CONFIG_SMP */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
