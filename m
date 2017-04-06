Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C10836B03F2
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 02:41:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y77so4756567wrb.22
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 23:41:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o22si1123291wra.147.2017.04.05.23.41.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 23:41:24 -0700 (PDT)
Date: Thu, 6 Apr 2017 08:41:22 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, memory_hotplug: fix devm_memremap_pages() after
 memory_hotplug rework
Message-ID: <20170406064122.GA5497@dhcp22.suse.cz>
References: <20170404165144.29791-1-jglisse@redhat.com>
 <a9d6e8d2-7bd9-abf1-9323-d175f10f7559@linux.vnet.ibm.com>
 <20170405104958.GI6035@dhcp22.suse.cz>
 <12d241cc-b992-4576-c420-860bd5fd59d4@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <12d241cc-b992-4576-c420-860bd5fd59d4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>

On Thu 06-04-17 11:04:20, Anshuman Khandual wrote:
> On 04/05/2017 04:19 PM, Michal Hocko wrote:
> > On Wed 05-04-17 16:05:23, Anshuman Khandual wrote:
> >> On 04/04/2017 10:21 PM, Jerome Glisse wrote:
> >>> Just a trivial fix.
> >>>
> >>> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> >>> Cc: Michal Hocko <mhocko@suse.com>
> >>> Cc: Dan Williams <dan.j.williams@intel.com>
> >>> ---
> >>>  kernel/memremap.c | 3 ++-
> >>>  1 file changed, 2 insertions(+), 1 deletion(-)
> >>>
> >>> diff --git a/kernel/memremap.c b/kernel/memremap.c
> >>> index faa9276..bbbe646 100644
> >>> --- a/kernel/memremap.c
> >>> +++ b/kernel/memremap.c
> >>> @@ -366,7 +366,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
> >>>  	error = arch_add_memory(nid, align_start, align_size);
> >>>  	if (!error)
> >>>  		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
> >>> -				align_start, align_size);
> >>> +					align_start >> PAGE_SHIFT,
> >>> +					align_size >> PAGE_SHIFT);
> >>
> >> All this while it was taking up addresses instead of PFNs ? Then
> >> how it was working correctly before ?
> > 
> > Because this code was embeded inside the arch_add_memory which did the
> > translation properly. See arch_add_memory implementations.
> 
> Got your point. Checked both mainline kernel and mmotm branch
> v4.11-rc5-mmotm-2017-04-04-15-00, in both the places the code
> snippet seems to be different than here. For example arch_add
> _memory has the following signature instead.
> 
> arch_add_memory(nid, align_start, align_size, true);
> 
> and I dont see move_pfn_range_to_zone() at all. Which tree/
> branch this patch is against ?

See http://lkml.kernel.org/r/20170330115454.32154-1-mhocko@kernel.org
this is a follow up fix for patch 5
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
