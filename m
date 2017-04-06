Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF9416B040C
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 07:07:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a80so3080825wrc.19
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 04:07:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2si2112736wrc.183.2017.04.06.04.07.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 04:07:51 -0700 (PDT)
Date: Thu, 6 Apr 2017 13:07:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170406110747.GJ5497@dhcp22.suse.cz>
References: <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
 <20170405064239.GB6035@dhcp22.suse.cz>
 <20170405092427.GG6035@dhcp22.suse.cz>
 <20170405145304.wxzfavqxnyqtrlru@arbab-laptop>
 <20170405154258.GR6035@dhcp22.suse.cz>
 <20170405173248.4vtdgk2kolbzztya@arbab-laptop>
 <20170405181502.GU6035@dhcp22.suse.cz>
 <20170405210214.GX6035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405210214.GX6035@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed 05-04-17 23:02:14, Michal Hocko wrote:
[...]
> OK, I was staring into the code and I guess I finally understand what is
> going on here. Looking at arch_add_memory->...->register_mem_sect_under_node
> was just misleading. I am still not 100% sure why but we try to do the
> same thing later from register_one_node->link_mem_sections for nodes
> which were offline. I should have noticed this path before. And here
> is the difference from the previous code. We are past arch_add_memory
> and that path used to do __add_zone which among other things will also
> resize node boundaries. I am not doing that anymore because I postpone
> that to the onlining phase. Jeez this code is so convoluted my head
> spins.
> 
> I am not really sure how to fix this. I suspect register_mem_sect_under_node
> should just ignore the online state of the node. But I wouldn't
> be all that surprised if this had some subtle reason as well. An
> alternative would be to actually move register_mem_sect_under_node out
> of register_new_memory and move it up the call stack, most probably to
> add_memory_resource. We have the range and can map it to the memblock
> and so will not rely on the node range. I will sleep over it and
> hopefully come up with something tomorrow.

OK, so this is the most sensible way I was able to come up with. I
didn't get to test it yet but from the above analysis it should work.
---
