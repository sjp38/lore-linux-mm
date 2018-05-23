Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE496B000C
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:32:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e15-v6so2590177wmh.6
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:32:01 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id n6-v6si1807916wma.183.2018.05.23.07.31.59
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 07:31:59 -0700 (PDT)
Date: Wed, 23 May 2018 16:31:59 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm/memory_hotplug: Fix leftover use of struct page
 during hotplug
Message-ID: <20180523143159.GA31117@techadventures.net>
References: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
 <20180504160844.GB23560@dhcp22.suse.cz>
 <20180504175051.000009e8@huawei.com>
 <20180510120200.GC5325@dhcp22.suse.cz>
 <20180523135403.GA30762@techadventures.net>
 <20180523141608.GR20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523141608.GR20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>, linux-mm <linux-mm@kvack.org>, linuxarm@huawei.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, May 23, 2018 at 04:16:08PM +0200, Michal Hocko wrote:
> On Wed 23-05-18 15:54:03, Oscar Salvador wrote:
> > On Thu, May 10, 2018 at 02:02:00PM +0200, Michal Hocko wrote:
> > > On Fri 04-05-18 17:50:51, Jonathan Cameron wrote:
> > > [...]
> > > > Exact path to the problem is as follows:
> > > > 
> > > > mm/memory_hotplug.c : add_memory_resource
> > > > The node is not online so we enter the
> > > > if (new_node) twice, on the second such block there is a call to
> > > > link_mem_sections which calls into
> > > > drivers/node.c: link_mem_sections which calls
> > > > drivers/node.c: register_mem_sect_under_node which calls
> > > > get_nid_for_pfn and keeps trying until the output of that matches
> > > > the expected node (passed all the way down from add_memory_resource)
> > > 
> > > I am sorry but I am still confused. Why don't we create sysfs files from
> > > __add_pages
> > >   __add_section
> > >     hotplug_memory_register
> > >       register_mem_sect_under_node
> > 
> > IIUC the problem is that at the point we are calling register_mem_sect_under_node(),
> > pages are not initialized yet.
> 
> Ahh, of course. I keep forgetting the latest hotplug optimizations that
> we do not initialize even nid for struct pages. Which is the whole point
> of this patch... Sigh.
> 
> I think the whole sysfs initialization needs to be refactored to be more
> sane. The way how we depend on things silently is just not maintainable.

I will try to work that out.
I also want to see if we can get rid of link_mem_sections() since it shares
almost all the code with walk_memory_range().
Maybe we can pass register_mem_sect_under_node() as a callback of walk_memory_range().

Oscar Salvador
