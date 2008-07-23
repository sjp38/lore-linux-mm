Date: Wed, 23 Jul 2008 06:06:44 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] hugetlb: override default huge page size non-const fix
Message-ID: <20080723040644.GA18119@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Adam Litke <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I revisited the multi-size hugetlb patches, and realised I forgot one small
outstanding issue. Your
hugetlb-override-default-huge-page-size-ia64-build.patch
fix basically disallows overriding of the default hugetlb size, because we
always set the default back to HPAGE_SIZE.

A better fix I think is just to initialize the default_hstate_size to an
invalid value, which the init code checks for and reverts to HPAGE_SIZE
anyway. So please replace that patch with this one.

Overriding of the default hugepage size is not of major importance, but it
can allow legacy code (providing it is well written), including the hugetlb
regression suite to be run with different hugepage sizes (so actually it is
quite important for developers at least).

I don't have access to such a machine, but I hope (with this patch), the
powerpc developers can run the libhugetlb regression suite one last time
against a range of page sizes and ensure the results look reasonable.

Thanks,
Nick

--

If HPAGE_SIZE is not constant (eg. on ia64), then the initialiser does not
work. Fix this by making default_hstate_size == 0, then if it isn't set
from the cmdline, hugetlb_init will still do the right thing and set up the
default hstate as (the now initialized) HPAGE_SIZE.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -34,7 +34,7 @@ struct hstate hstates[HUGE_MAX_HSTATE];
 /* for command line parsing */
 static struct hstate * __initdata parsed_hstate;
 static unsigned long __initdata default_hstate_max_huge_pages;
-static unsigned long __initdata default_hstate_size = HPAGE_SIZE;
+static unsigned long __initdata default_hstate_size = 0;
 
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
