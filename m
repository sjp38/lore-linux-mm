Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 751689003C7
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 04:29:57 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so129002712wic.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 01:29:57 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id eq3si29504959wjd.142.2015.07.27.01.29.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 01:29:55 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so105341966wib.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 01:29:55 -0700 (PDT)
Message-ID: <1437985792.3838.21.camel@gmail.com>
Subject: Re: [PATCH] mm: add resched points to
 remap_pmd_range/ioremap_pmd_range
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Mon, 27 Jul 2015 10:29:52 +0200
In-Reply-To: <20150727070840.GB11317@dhcp22.suse.cz>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
	 <20150724070420.GF4103@dhcp22.suse.cz>
	 <20150724165627.GA3458@Sligo.logfs.org>
	 <20150727070840.GB11317@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Spencer Baugh <sbaugh@catern.com>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>

On Mon, 2015-07-27 at 09:08 +0200, Michal Hocko wrote:
> On Fri 24-07-15 09:56:27, JA?rn Engel wrote:
> > On Fri, Jul 24, 2015 at 09:04:21AM +0200, Michal Hocko wrote:
> > > On Thu 23-07-15 14:54:33, Spencer Baugh wrote:
> > > > From: Joern Engel <joern@logfs.org>
> > > > 
> > > > Mapping large memory spaces can be slow and prevent high-priority
> > > > realtime threads from preempting lower-priority threads for a long time.
> > > 
> > > How can a lower priority task block the high priority one? Do you have
> > > preemption disabled?
> > 
> > Yes.
> 
> Yes what? PREEMT enabled and still low priority task starving a high
> priority one? What is your exact setup?

There are other places that are pretty horrible too if you don't run a
PREEMPT kernel.  Spending milliseconds in kernel kinda takes the real
outta realtime, even for the most casual of users.

(ponder: preempt kernel for rt only, rt could have decent latency
without driving normal task throughput through the floor)

kbuild make -j8 + cyclictest -Smp99

PREEMPT_VOLUNTARY Before:
T: 0 ( 6459) P:99 I:1000 C: 286022 Min:      1 Act:    1 Avg:    5 Max:    1718
T: 1 ( 6460) P:99 I:1500 C: 190701 Min:      1 Act:    1 Avg:    5 Max:    1639
T: 2 ( 6461) P:99 I:2000 C: 143024 Min:      1 Act:    2 Avg:    5 Max:    2504
T: 3 ( 6462) P:99 I:2500 C: 114420 Min:      1 Act:    1 Avg:    5 Max:    1922
T: 4 ( 6463) P:99 I:3000 C:  95350 Min:      1 Act:    1 Avg:    5 Max:    1482
T: 5 ( 6464) P:99 I:3500 C:  81728 Min:      1 Act:    2 Avg:    5 Max:    1496
T: 6 ( 6465) P:99 I:4000 C:  71511 Min:      1 Act:    1 Avg:    5 Max:    1813
T: 7 ( 6466) P:99 I:4500 C:  63566 Min:      1 Act:    1 Avg:    5 Max:    1901

PREEMPT_VOLUNTARY After:
T: 0 ( 6997) P:99 I:1000 C: 286032 Min:      1 Act:    2 Avg:    3 Max:     125
T: 1 ( 6998) P:99 I:1500 C: 190687 Min:      1 Act:    1 Avg:    4 Max:     130
T: 2 ( 6999) P:99 I:2000 C: 143015 Min:      1 Act:    1 Avg:    4 Max:      97
T: 3 ( 7000) P:99 I:2500 C: 114411 Min:      1 Act:    2 Avg:    4 Max:      90
T: 4 ( 7001) P:99 I:3000 C:  95341 Min:      1 Act:    1 Avg:    4 Max:     139
T: 5 ( 7002) P:99 I:3500 C:  81722 Min:      1 Act:    2 Avg:    4 Max:     112
T: 6 ( 7003) P:99 I:4000 C:  71506 Min:      1 Act:    2 Avg:    4 Max:     137
T: 7 ( 7004) P:99 I:4500 C:  63561 Min:      1 Act:    2 Avg:    4 Max:     109

---
 mm/memory.c     |    8 ++++++--
 mm/page_alloc.c |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1174,8 +1174,10 @@ static unsigned long zap_pte_range(struc
 		force_flush = 0;
 		tlb_flush_mmu_free(tlb);
 
-		if (addr != end)
+		if (addr != end) {
+			cond_resched();
 			goto again;
+		}
 	}
 
 	return addr;
@@ -1336,8 +1338,10 @@ void unmap_vmas(struct mmu_gather *tlb,
 	struct mm_struct *mm = vma->vm_mm;
 
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
+	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
+		cond_resched();
+	}
 	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 }
 
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1934,6 +1934,7 @@ void free_hot_cold_page_list(struct list
 	list_for_each_entry_safe(page, next, list, lru) {
 		trace_mm_page_free_batched(page, cold);
 		free_hot_cold_page(page, cold);
+		cond_resched();
 	}
 }
 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
