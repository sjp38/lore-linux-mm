Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00D416B0405
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 05:25:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v44so5326693wrc.9
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 02:25:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7si1738239wrz.25.2017.04.06.02.25.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 02:25:20 -0700 (PDT)
Date: Thu, 6 Apr 2017 11:25:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170406092516.GG5497@dhcp22.suse.cz>
References: <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
 <20170405064239.GB6035@dhcp22.suse.cz>
 <20170405154852.kdkwuudjv2jwvj5g@arbab-laptop>
 <20170405163439.GS6035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405163439.GS6035@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed 05-04-17 18:34:39, Michal Hocko wrote:
> On Wed 05-04-17 10:48:52, Reza Arbab wrote:
> > On Wed, Apr 05, 2017 at 08:42:39AM +0200, Michal Hocko wrote:
> > >On Tue 04-04-17 16:43:39, Reza Arbab wrote:
> > >>Okay, getting further. With this I can again repeatedly add and remove,
> > >>but now I'm seeing a weird variation of that earlier issue:
> > >>
> > >>1. add_memory(), online_movable
> > >>  /sys/devices/system/node/nodeX/memoryY symlinks are created.
> > >>
> > >>2. offline, remove_memory()
> > >>  The node is offlined, since all memory has been removed, so all of
> > >>  /sys/devices/system/node/nodeX is gone. This is normal.
> > >>
> > >>3. add_memory(), online_movable
> > >>  The node is onlined, so /sys/devices/system/node/nodeX is recreated,
> > >>  and the memory is added, but just like earlier in this email thread,
> > >>  the memoryY links are not there.
> > >
> > >Could you add some printks to see why the sysfs creation failed please?
> > 
> > Ah, simple enough. It's this, right at the top of
> > register_mem_sect_under_node():
> > 
> > 	if (!node_online(nid))
> > 		return 0;
> > 
> > That being the case, I really don't understand why your patches make any
> > difference. Is node_set_online() being called later than before somehow?
> 
> This is really interesting. Because add_memory_resource does the
> following
> 	/* call arch's memory hotadd */
> 	ret = arch_add_memory(nid, start, size);
> 
> 	if (ret < 0)
> 		goto error;
> 
> 	/* we online node here. we can't roll back from here. */
> 	node_set_online(nid);
> 
> so we are setting the node online _after_ arch_add_memory but the code
> which adds those sysfs file is called from
> 
> arch_add_memory
>   __add_pages
>     __add_section
>       register_new_memory
>         register_mem_sect_under_node
>           node_online check
> 
> I haven't touched this part. What is the point of this check anyway? We
> have already associated all the pages with a node (and with a zone prior
> to my patches) so we _know_ how to create those links. The check goes
> back to the initial submissions. Gary is not available anymore so we
> cannot ask. But I completely fail to see how my changes could have made
> any difference.

I wasn't able to undestand that from the code so I've just tried to
remove the check and it blown up
	BUG: unable to handle kernel NULL pointer dereference at
	0000000000000040
	IP: sysfs_create_link_nowarn+0x13/0x32

	if (!kobj)
		parent = sysfs_root_kn;
	else
		parent = kobj->sd;
		^^^^^^^^^^^^^^^^^^

when creating the link
register_mem_sect_under_node:
		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
					&mem_blk->dev.kobj,
					kobject_name(&mem_blk->dev.kobj));

which means that node_devices[nid]->dev.kobj is NULL. This happens later
in register_one_node->register_node. This really _screems_ for a clean up!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
