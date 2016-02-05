Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6B65A4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 07:02:12 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p63so23379384wmp.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 04:02:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh8si13939941wjb.102.2016.02.05.04.02.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 04:02:11 -0800 (PST)
Subject: Re: [PATCH] mm, hugetlb: don't require CMA for runtime gigantic pages
References: <1454521811-11409-1-git-send-email-vbabka@suse.cz>
 <20160204060221.GA14877@js1304-P5Q-DELUXE> <56B31A31.3070406@suse.cz>
 <56B324D4.6030703@suse.cz> <20160205001459.GA24412@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56B48F40.1060205@suse.cz>
Date: Fri, 5 Feb 2016 13:02:08 +0100
MIME-Version: 1.0
In-Reply-To: <20160205001459.GA24412@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Davidlohr Bueso <dave@stgolabs.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>

On 02/05/2016 01:14 AM, Kirill A. Shutemov wrote:
>>  include/linux/gfp.h | 6 +++---
>>  mm/hugetlb.c        | 2 +-
>>  mm/page_alloc.c     | 2 +-
>>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> One more place missed: gigantic_pages_init() in arch/x86/mm/hugetlbpage.c
> Could you relax the check there as well?

Crap, thanks. This file was hidden in different commit and didn't cause
compilation failure. Patch below, tested that 1gb pages are available
with COMPACTION+ISOLATION.

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 5 Feb 2016 10:59:38 +0100
Subject: [PATCH 2/2] 
 mm-hugetlb-dont-require-cma-for-runtime-gigantic-pages-fix2

Update also arch-specific code as Kirill pointed out.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 arch/x86/mm/hugetlbpage.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 42982b26e32b..740d7ac03a55 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -173,10 +173,10 @@ static __init int setup_hugepagesz(char *opt)
 }
 __setup("hugepagesz=", setup_hugepagesz);
 
-#ifdef CONFIG_CMA
+#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
 static __init int gigantic_pages_init(void)
 {
-	/* With CMA we can allocate gigantic pages at runtime */
+	/* With compaction or CMA we can allocate gigantic pages at runtime */
 	if (cpu_has_gbpages && !size_to_hstate(1UL << PUD_SHIFT))
 		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
 	return 0;
-- 
2.7.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
