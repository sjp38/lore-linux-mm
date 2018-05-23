Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A46F6B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:16:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v12-v6so2477076wmc.1
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:16:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x25-v6si28977eda.69.2018.05.23.07.16.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 07:16:12 -0700 (PDT)
Date: Wed, 23 May 2018 16:16:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: Fix leftover use of struct page
 during hotplug
Message-ID: <20180523141608.GR20441@dhcp22.suse.cz>
References: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
 <20180504160844.GB23560@dhcp22.suse.cz>
 <20180504175051.000009e8@huawei.com>
 <20180510120200.GC5325@dhcp22.suse.cz>
 <20180523135403.GA30762@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523135403.GA30762@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>, linux-mm <linux-mm@kvack.org>, linuxarm@huawei.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 23-05-18 15:54:03, Oscar Salvador wrote:
> On Thu, May 10, 2018 at 02:02:00PM +0200, Michal Hocko wrote:
> > On Fri 04-05-18 17:50:51, Jonathan Cameron wrote:
> > [...]
> > > Exact path to the problem is as follows:
> > > 
> > > mm/memory_hotplug.c : add_memory_resource
> > > The node is not online so we enter the
> > > if (new_node) twice, on the second such block there is a call to
> > > link_mem_sections which calls into
> > > drivers/node.c: link_mem_sections which calls
> > > drivers/node.c: register_mem_sect_under_node which calls
> > > get_nid_for_pfn and keeps trying until the output of that matches
> > > the expected node (passed all the way down from add_memory_resource)
> > 
> > I am sorry but I am still confused. Why don't we create sysfs files from
> > __add_pages
> >   __add_section
> >     hotplug_memory_register
> >       register_mem_sect_under_node
> 
> IIUC the problem is that at the point we are calling register_mem_sect_under_node(),
> pages are not initialized yet.

Ahh, of course. I keep forgetting the latest hotplug optimizations that
we do not initialize even nid for struct pages. Which is the whole point
of this patch... Sigh.

I think the whole sysfs initialization needs to be refactored to be more
sane. The way how we depend on things silently is just not maintainable.

Thanks!
-- 
Michal Hocko
SUSE Labs
