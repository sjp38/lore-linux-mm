Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 274086B0038
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 20:29:36 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so76656942pdb.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 17:29:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ca15si5717069pdb.31.2015.04.30.17.29.34
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 17:29:35 -0700 (PDT)
Date: Fri, 1 May 2015 08:29:32 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mm/meminit] PANIC: early exception 06 rip 10:ffffffff811bfa9a
 error 0 cr2 ffff88000fbff000
Message-ID: <20150501002932.GA13087@wfg-t540p.sh.intel.com>
References: <20150429132817.GA10479@wfg-t540p.sh.intel.com>
 <20150429134131.GR2449@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150429134131.GR2449@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mel,

On Wed, Apr 29, 2015 at 02:41:31PM +0100, Mel Gorman wrote:
> On Wed, Apr 29, 2015 at 09:28:17PM +0800, Fengguang Wu wrote:
> > Greetings,
> > 
> > 0day kernel testing robot got the below dmesg and the first bad commit is
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma mm-deferred-meminit-v6r1
> > 
> > commit 285c36ab5b3e59865a0f4d79f4c1758455e684f7
> > Author:     Mel Gorman <mgorman@suse.de>
> > AuthorDate: Mon Sep 29 14:54:01 2014 +0100
> > Commit:     Mel Gorman <mgorman@suse.de>
> > CommitDate: Wed Apr 22 19:48:15 2015 +0100
> > 
> >     mm: meminit: Reduce number of times pageblocks are set during struct page init
> >     
> >     During parallel sturct page initialisation, ranges are checked for every
> >     PFN unnecessarily which increases boot times. This patch alters when the
> >     ranges are checked.
> >     
> >     Signed-off-by: Mel Gorman <mgorman@suse.de>
> > 
> 
> The series is old but I think it's still relevant. Can you try this
> please?

Yes it fixed the problem.

Tested-by: Fengguang Wu <fengguang.wu@intel.com>

Thanks,
Fengguang

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9c8f2a72263d..19543f708642 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4489,8 +4489,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		if (!(pfn & (pageblock_nr_pages - 1))) {
>  			struct page *page = pfn_to_page(pfn);
>  
> -			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>  			__init_single_page(page, pfn, zone, nid);
> +			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>  		} else {
>  			__init_single_pfn(pfn, zone, nid);
>  		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
