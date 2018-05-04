Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD576B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:51:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b192-v6so2268587wmb.1
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:51:24 -0700 (PDT)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id l76si1611021wmi.188.2018.05.04.09.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 09:51:22 -0700 (PDT)
Date: Fri, 4 May 2018 17:50:51 +0100
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH] mm/memory_hotplug: Fix leftover use of struct page
 during hotplug
Message-ID: <20180504175051.000009e8@huawei.com>
In-Reply-To: <20180504160844.GB23560@dhcp22.suse.cz>
References: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
	<20180504160844.GB23560@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, linuxarm@huawei.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 4 May 2018 18:08:45 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 04-05-18 09:53:11, Jonathan Cameron wrote:
> > The case of a new numa node got missed in avoiding using
> > the node info from page_struct during hotplug.  In this
> > path we have a call to register_mem_sect_under_node (which allows
> > us to specify it is hotplug so don't change the node),
> > via link_mem_sections which unfortunately does not.  
> 
> I have hard time to parse the problem description. Could you be more
> specific and describe the user visible effect along with steps to
> trigger the issue?

Hi Michal,

Sure, the result is that (with a new memory only node) we never
successfully call register_mem_sect_under_node so don't get the
memory associated with the node in sysfs and meminfo for the
node doesn't report it.

It came up whilst testing some arm64 hotplug patches, but appears
to be universal.  Whilst I'm triggering it by removing then reinserting
memory to a node with no other elements (thus making the node disappear
then appear again), it appears it would happen on hotplugging memory
where there was none before and it doesn't seem to be related the
arm64 patches.  These patches call __add_pages (where most of the issue was
fixed by Pavel's patch). If there is a node at the time of the __add_pages
call then all is well as it calls register_mem_sect_under_node from
there with check_nid set to false.  Without a node that function returns
having not done the sysfs related stuff as there is no node to use.
This is expected but it is the resulting path that fails...

Exact path to the problem is as follows:

mm/memory_hotplug.c : add_memory_resource
The node is not online so we enter the
if (new_node) twice, on the second such block there is a call to
link_mem_sections which calls into
drivers/node.c: link_mem_sections which calls
drivers/node.c: register_mem_sect_under_node which calls
get_nid_for_pfn and keeps trying until the output of that matches
the expected node (passed all the way down from add_memory_resource)

It is effectively the same fix as the one referred to in the fixes
tag just in the code path for a new node where the comments point
out we have to rerun the link creation because it will have failed
in register_new_memory (as there was no node at the time).
(actually that comment is wrong now as we don't have register_new_memory
any more it got renamed to hotplug_memory_register in Pavel's patch).

Jonathan
