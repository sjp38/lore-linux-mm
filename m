Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52BDB2806E8
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 08:13:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l44so5415869wrc.11
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:13:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7si8831518wrf.191.2017.04.20.05.13.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 05:13:57 -0700 (PDT)
Date: Thu, 20 Apr 2017 14:13:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: your mail
Message-ID: <20170420121354.GE15781@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
 <20170420084930.GC15781@dhcp22.suse.cz>
 <b9ff52f3-836e-db1e-2a2b-b60d71c53f69@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b9ff52f3-836e-db1e-2a2b-b60d71c53f69@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 20-04-17 13:56:34, Vlastimil Babka wrote:
> On 04/20/2017 10:49 AM, Michal Hocko wrote:
> > On Thu 20-04-17 09:28:20, Michal Hocko wrote:
> >> On Thu 20-04-17 10:27:55, Joonsoo Kim wrote:
> > [...]
> >>> Your patch try to add PageReserved() to __pageblock_pfn_to_page(). It
> >>> woule make that zone->contiguous usually returns false since memory
> >>> used by memblock API is marked as PageReserved() and your patch regard
> >>> it as a hole. It invalidates set_zone_contiguous() optimization and I
> >>> worry about it.
> >>
> >> OK, fair enough. I did't consider memblock allocations. I will rethink
> >> this patch but there are essentially 3 options
> >> 	- use a different criterion for the offline holes dection. I
> >> 	  have just realized we might do it by storing the online
> >> 	  information into the mem sections
> >> 	- drop this patch
> >> 	- move the PageReferenced check down the chain into
> >> 	  isolate_freepages_block resp. isolate_migratepages_block
> >>
> >> I would prefer 3 over 2 over 1. I definitely want to make this more
> >> robust so 1 is preferable long term but I do not want this to be a
> >> roadblock to the rest of the rework. Does that sound acceptable to you?
> > 
> > So I've played with all three options just to see how the outcome would
> > look like and it turned out that going with 1 will be easiest in the
> > end. What do you think about the following? It should be free of any 
> > false positives. I have only compile tested it yet.
> 
> That looks fine, can't say immediately if fully correct. I think you'll
> need to bump SECTION_NID_SHIFT as well and make sure things still fit?
> Otherwise looks like nobody needed a new section bit since 2005, so we
> should be fine.

You are absolutely right. Thanks for spotting this! I have folded this
in

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 611ff869fa4d..c412e6a3a1e9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1166,7 +1166,7 @@ extern unsigned long usemap_size(void);
 #define SECTION_IS_ONLINE	(1UL<<2)
 #define SECTION_MAP_LAST_BIT	(1UL<<3)
 #define SECTION_MAP_MASK	(~(SECTION_MAP_LAST_BIT-1))
-#define SECTION_NID_SHIFT	2
+#define SECTION_NID_SHIFT	3
 
 static inline struct page *__section_mem_map_addr(struct mem_section *section)
 {
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
