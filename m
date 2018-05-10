Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 957B56B05F9
	for <linux-mm@kvack.org>; Thu, 10 May 2018 08:02:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s7-v6so731185pgp.15
        for <linux-mm@kvack.org>; Thu, 10 May 2018 05:02:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 92-v6si633368plw.299.2018.05.10.05.02.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 05:02:05 -0700 (PDT)
Date: Thu, 10 May 2018 14:02:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: Fix leftover use of struct page
 during hotplug
Message-ID: <20180510120200.GC5325@dhcp22.suse.cz>
References: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
 <20180504160844.GB23560@dhcp22.suse.cz>
 <20180504175051.000009e8@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504175051.000009e8@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: linux-mm <linux-mm@kvack.org>, linuxarm@huawei.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri 04-05-18 17:50:51, Jonathan Cameron wrote:
[...]
> Exact path to the problem is as follows:
> 
> mm/memory_hotplug.c : add_memory_resource
> The node is not online so we enter the
> if (new_node) twice, on the second such block there is a call to
> link_mem_sections which calls into
> drivers/node.c: link_mem_sections which calls
> drivers/node.c: register_mem_sect_under_node which calls
> get_nid_for_pfn and keeps trying until the output of that matches
> the expected node (passed all the way down from add_memory_resource)

I am sorry but I am still confused. Why don't we create sysfs files from
__add_pages
  __add_section
    hotplug_memory_register
      register_mem_sect_under_node

The whole sysfs mess just deserves to die and be reworked completely.
Creating different pieces here and there is just a recipe for bugs
and unreviewable code </rant>
-- 
Michal Hocko
SUSE Labs
