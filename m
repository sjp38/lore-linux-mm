Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63B636B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:36:30 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ao6so12611947pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:36:30 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id m66si1662970pfa.107.2016.06.08.07.36.29
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 07:36:29 -0700 (PDT)
From: Lukasz Odzioba <lukasz.odzioba@intel.com>
Subject: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page arrival
Date: Wed,  8 Jun 2016 16:35:37 +0200
Message-Id: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, aarcange@redhat.com, vdavydov@parallels.com, mingli199x@qq.com, minchan@kernel.org
Cc: dave.hansen@intel.com, lukasz.anaczkowski@intel.com, lukasz.odzioba@intel.com

When the application does not exit cleanly (i.e. SIGTERM) we might
end up with some pages in lru_add_pvec, which is ok. With THP
enabled huge pages may also end up on per cpu lru_add_pvecs.
In the systems with a lot of processors we end up with quite a lot
of memory pending for addition to LRU cache - in the worst case
scenario up to CPUS * PAGE_SIZE * PAGEVEC_SIZE, which on machine
with 200+CPUs means GBs in practice.

We are able to reproduce this problem with the following program:

void main() {
{
	size_t size = 55 * 1000 * 1000; // smaller than  MEM/CPUS
	void *p = mmap(NULL, size, PROT_READ | PROT_WRITE,
		MAP_PRIVATE | MAP_ANONYMOUS , -1, 0);
	if (p != MAP_FAILED)
		memset(p, 0, size);
	//munmap(p, size); // uncomment to make the problem go away
}
}

When we run it it will leave significant amount of memory on pvecs.
This memory will be not reclaimed if we hit OOM, so when we run
above program in a loop:
	$ for i in `seq 100`; do ./a.out; done
many processes (95% in my case) will be killed by OOM.

This patch flushes lru_add_pvecs on compound page arrival making
the problem less severe - kill rate drops to 0%.

Suggested-by: Michal Hocko <mhocko@suse.com>
Tested-by: Lukasz Odzioba <lukasz.odzioba@intel.com>
Signed-off-by: Lukasz Odzioba <lukasz.odzioba@intel.com>
---
 mm/swap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 9591614..3fe4f18 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -391,9 +391,8 @@ static void __lru_cache_add(struct page *page)
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
 
 	get_page(page);
-	if (!pagevec_space(pvec))
+	if (!pagevec_add(pvec, page) || PageCompound(page))
 		__pagevec_lru_add(pvec);
-	pagevec_add(pvec, page);
 	put_cpu_var(lru_add_pvec);
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
