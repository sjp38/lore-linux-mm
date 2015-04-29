Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7146B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:41:36 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so131485663wic.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 06:41:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sa4si43929928wjb.60.2015.04.29.06.41.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 06:41:34 -0700 (PDT)
Date: Wed, 29 Apr 2015 14:41:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [mm/meminit] PANIC: early exception 06 rip 10:ffffffff811bfa9a
 error 0 cr2 ffff88000fbff000
Message-ID: <20150429134131.GR2449@suse.de>
References: <20150429132817.GA10479@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150429132817.GA10479@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 29, 2015 at 09:28:17PM +0800, Fengguang Wu wrote:
> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma mm-deferred-meminit-v6r1
> 
> commit 285c36ab5b3e59865a0f4d79f4c1758455e684f7
> Author:     Mel Gorman <mgorman@suse.de>
> AuthorDate: Mon Sep 29 14:54:01 2014 +0100
> Commit:     Mel Gorman <mgorman@suse.de>
> CommitDate: Wed Apr 22 19:48:15 2015 +0100
> 
>     mm: meminit: Reduce number of times pageblocks are set during struct page init
>     
>     During parallel sturct page initialisation, ranges are checked for every
>     PFN unnecessarily which increases boot times. This patch alters when the
>     ranges are checked.
>     
>     Signed-off-by: Mel Gorman <mgorman@suse.de>
> 

The series is old but I think it's still relevant. Can you try this
please?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9c8f2a72263d..19543f708642 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4489,8 +4489,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		if (!(pfn & (pageblock_nr_pages - 1))) {
 			struct page *page = pfn_to_page(pfn);
 
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 			__init_single_page(page, pfn, zone, nid);
+			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 		} else {
 			__init_single_pfn(pfn, zone, nid);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
