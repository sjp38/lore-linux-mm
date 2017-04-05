Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 696A46B039F
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 12:34:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u18so2470108wrc.17
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 09:34:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j67si25044089wmd.101.2017.04.05.09.34.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 09:34:43 -0700 (PDT)
Date: Wed, 5 Apr 2017 18:34:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170405163439.GS6035@dhcp22.suse.cz>
References: <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
 <20170405064239.GB6035@dhcp22.suse.cz>
 <20170405154852.kdkwuudjv2jwvj5g@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405154852.kdkwuudjv2jwvj5g@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed 05-04-17 10:48:52, Reza Arbab wrote:
> On Wed, Apr 05, 2017 at 08:42:39AM +0200, Michal Hocko wrote:
> >On Tue 04-04-17 16:43:39, Reza Arbab wrote:
> >>Okay, getting further. With this I can again repeatedly add and remove,
> >>but now I'm seeing a weird variation of that earlier issue:
> >>
> >>1. add_memory(), online_movable
> >>  /sys/devices/system/node/nodeX/memoryY symlinks are created.
> >>
> >>2. offline, remove_memory()
> >>  The node is offlined, since all memory has been removed, so all of
> >>  /sys/devices/system/node/nodeX is gone. This is normal.
> >>
> >>3. add_memory(), online_movable
> >>  The node is onlined, so /sys/devices/system/node/nodeX is recreated,
> >>  and the memory is added, but just like earlier in this email thread,
> >>  the memoryY links are not there.
> >
> >Could you add some printks to see why the sysfs creation failed please?
> 
> Ah, simple enough. It's this, right at the top of
> register_mem_sect_under_node():
> 
> 	if (!node_online(nid))
> 		return 0;
> 
> That being the case, I really don't understand why your patches make any
> difference. Is node_set_online() being called later than before somehow?

This is really interesting. Because add_memory_resource does the
following
	/* call arch's memory hotadd */
	ret = arch_add_memory(nid, start, size);

	if (ret < 0)
		goto error;

	/* we online node here. we can't roll back from here. */
	node_set_online(nid);

so we are setting the node online _after_ arch_add_memory but the code
which adds those sysfs file is called from

arch_add_memory
  __add_pages
    __add_section
      register_new_memory
        register_mem_sect_under_node
          node_online check

I haven't touched this part. What is the point of this check anyway? We
have already associated all the pages with a node (and with a zone prior
to my patches) so we _know_ how to create those links. The check goes
back to the initial submissions. Gary is not available anymore so we
cannot ask. But I completely fail to see how my changes could have made
any difference.

I assume that things start working after you remove that check? Btw. if
you put printk to the original kernel does it see the node online? I
would be also interested whether you see try_offline_node setting the
node offline in the original code.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
