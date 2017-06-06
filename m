Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 525826B0350
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 15:03:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t30so70848932pgo.0
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 12:03:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t127si33032545pfd.377.2017.06.06.12.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 12:03:52 -0700 (PDT)
Date: Tue, 6 Jun 2017 12:03:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170606190350.GA20010@bombadil.infradead.org>
References: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
 <20170605153819.9c86969a73926e4269e77976@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170605153819.9c86969a73926e4269e77976@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Liam R. Howlett" <Liam.Howlett@Oracle.com>, linux-mm@kvack.org, mike.kravetz@Oracle.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com--dry-run

On Mon, Jun 05, 2017 at 03:38:19PM -0700, Andrew Morton wrote:
> It's better to just move memfmt() to the right place.  After all, you
> have revealed that it was in the wrong place, no?
> 
> (Am a bit surprised that something as general as memfmt is private to
> hugetlb.c)

Oh, hey, look, memory management people and storage people have
their own ideas about "general" code.  Storage people have been using
string_get_size() for a while.  It feels a bit over-engineered to me,
but since we already have it, we should use it.

---- 8< ----

Subject: [PATCH] Replace memfmt with string_get_size

The hugetlb code has its own function to report human-readable sizes.
Convert it to use the shared string_get_size function.  This will lead
to a minor difference in user visible output (MiB/GiB instead of MB/GB),
but some would argue that's desirable anyway.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e5828875f7bb..7f2b7d9f1f45 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -20,6 +20,7 @@
 #include <linux/slab.h>
 #include <linux/sched/signal.h>
 #include <linux/rmap.h>
+#include <linux/string_helpers.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/page-isolation.h>
@@ -2207,26 +2208,15 @@ static void __init hugetlb_init_hstates(void)
 	VM_BUG_ON(minimum_order == UINT_MAX);
 }
 
-static char * __init memfmt(char *buf, unsigned long n)
-{
-	if (n >= (1UL << 30))
-		sprintf(buf, "%lu GB", n >> 30);
-	else if (n >= (1UL << 20))
-		sprintf(buf, "%lu MB", n >> 20);
-	else
-		sprintf(buf, "%lu KB", n >> 10);
-	return buf;
-}
-
 static void __init report_hugepages(void)
 {
 	struct hstate *h;
 
 	for_each_hstate(h) {
 		char buf[32];
+		string_get_size(huge_page_size(h), 1, STRING_UNITS_2, buf, 32);
 		pr_info("HugeTLB registered %s page size, pre-allocated %ld pages\n",
-			memfmt(buf, huge_page_size(h)),
-			h->free_huge_pages);
+			buf, h->free_huge_pages);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
