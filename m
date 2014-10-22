Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA0A6B007B
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:17:52 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so3824793pad.3
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:17:51 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id mq9si14374838pdb.91.2014.10.22.07.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 22 Oct 2014 07:17:51 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDU004J2NPP5D40@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Oct 2014 23:17:49 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH v2 2/2] fs: proc: Include cma info in proc/meminfo
Date: Wed, 22 Oct 2014 19:36:35 +0530
Message-id: <1413986796-19732-2-git-send-email-pintu.k@samsung.com>
In-reply-to: <1413986796-19732-1-git-send-email-pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
 <1413986796-19732-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, pintu.k@samsung.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mina86@mina86.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

This patch include CMA info (CMATotal, CMAFree) in /proc/meminfo.
Currently, in a CMA enabled system, if somebody wants to know the
total CMA size declared, there is no way to tell, other than the dmesg
or /var/log/messages logs.
With this patch we are showing the CMA info as part of meminfo, so that
it can be determined at any point of time.
This will be populated only when CMA is enabled.

Below is the sample output from a ARM based device with RAM:512MB and CMA:16MB.

MemTotal:         471172 kB
MemFree:          111712 kB
MemAvailable:     271172 kB
.
.
.
CmaTotal:          16384 kB
CmaFree:            6144 kB

This patch also fix below checkpatch errors that were found during these changes.

ERROR: space required after that ',' (ctx:ExV)
199: FILE: fs/proc/meminfo.c:199:
+       ,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
        ^

ERROR: space required after that ',' (ctx:ExV)
202: FILE: fs/proc/meminfo.c:202:
+       ,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
        ^

ERROR: space required after that ',' (ctx:ExV)
206: FILE: fs/proc/meminfo.c:206:
+       ,K(totalcma_pages)
        ^

total: 3 errors, 0 warnings, 2 checks, 236 lines checked

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
Signed-off-by: Vishnu Pratap Singh <vishnu.ps@samsung.com>
---
 fs/proc/meminfo.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index aa1eee0..d3ebf2e 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -12,6 +12,9 @@
 #include <linux/vmstat.h>
 #include <linux/atomic.h>
 #include <linux/vmalloc.h>
+#ifdef CONFIG_CMA
+#include <linux/cma.h>
+#endif
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include "internal.h"
@@ -138,6 +141,10 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		"AnonHugePages:  %8lu kB\n"
 #endif
+#ifdef CONFIG_CMA
+		"CmaTotal:       %8lu kB\n"
+		"CmaFree:        %8lu kB\n"
+#endif
 		,
 		K(i.totalram),
 		K(i.freeram),
@@ -187,12 +194,16 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		vmi.used >> 10,
 		vmi.largest_chunk >> 10
 #ifdef CONFIG_MEMORY_FAILURE
-		,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
+		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
+		, K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
 		   HPAGE_PMD_NR)
 #endif
+#ifdef CONFIG_CMA
+		, K(totalcma_pages)
+		, K(global_page_state(NR_FREE_CMA_PAGES))
+#endif
 		);
 
 	hugetlb_report_meminfo(m);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
