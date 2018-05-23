Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15DCF6B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:54:05 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y9-v6so12994153wrg.22
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:54:05 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id z72-v6si1765281wmc.207.2018.05.23.06.54.03
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 06:54:03 -0700 (PDT)
Date: Wed, 23 May 2018 15:54:03 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm/memory_hotplug: Fix leftover use of struct page
 during hotplug
Message-ID: <20180523135403.GA30762@techadventures.net>
References: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
 <20180504160844.GB23560@dhcp22.suse.cz>
 <20180504175051.000009e8@huawei.com>
 <20180510120200.GC5325@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510120200.GC5325@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>, linux-mm <linux-mm@kvack.org>, linuxarm@huawei.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, May 10, 2018 at 02:02:00PM +0200, Michal Hocko wrote:
> On Fri 04-05-18 17:50:51, Jonathan Cameron wrote:
> [...]
> > Exact path to the problem is as follows:
> > 
> > mm/memory_hotplug.c : add_memory_resource
> > The node is not online so we enter the
> > if (new_node) twice, on the second such block there is a call to
> > link_mem_sections which calls into
> > drivers/node.c: link_mem_sections which calls
> > drivers/node.c: register_mem_sect_under_node which calls
> > get_nid_for_pfn and keeps trying until the output of that matches
> > the expected node (passed all the way down from add_memory_resource)
> 
> I am sorry but I am still confused. Why don't we create sysfs files from
> __add_pages
>   __add_section
>     hotplug_memory_register
>       register_mem_sect_under_node

IIUC the problem is that at the point we are calling register_mem_sect_under_node(),
pages are not initialized yet.

While walking the pfns in register_mem_sect_under_node(),
we might check for the node-id of the pfn if check_nid is true.

if (check_nid) {
	page_nid = get_nid_for_pfn(pfn);
	if (page_nid < 0)
		continue;
	if (page_nid != nid)
		continue;
}

I think the problem is in:

get_nid_for_pfn()->pfn_to_nid()->page_to_nid()

static inline int page_to_nid(const struct page *page)
{
	struct page *p = (struct page *)page;

	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
}

We access a field of the page, but these are not initialiazed, so it can
contain anything.
Because of that we can just get a wrong id, making the loop to not pass the
below check.

if (check_nid) {
        page_nid = get_nid_for_pfn(pfn);
        if (page_nid < 0)
                continue;
        if (page_nid != nid)
                continue;
}

create_sys_fs ...

and we do not carry on creating the sysfs.


Oscar Salvador
