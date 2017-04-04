Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A49386B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 04:23:09 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y77so27364327wrb.22
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 01:23:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o191si18746639wme.129.2017.04.04.01.23.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 01:23:07 -0700 (PDT)
Date: Tue, 4 Apr 2017 10:23:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170404082302.GE15132@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170403115545.GK24661@dhcp22.suse.cz>
 <20170403195830.64libncet5l6vuvb@arbab-laptop>
 <20170403202337.GA12482@dhcp22.suse.cz>
 <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
 <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404073412.GC15132@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue 04-04-17 09:34:12, Michal Hocko wrote:
> On Tue 04-04-17 09:23:29, Michal Hocko wrote:
> > [Let's add Gary who as introduced this code c04fc586c1a48]
> 
> OK, so Gary's email doesn't exist anymore. Does anybody can comment on
> this? I suspect this code is just-in-case... Mel?
>  
> > On Mon 03-04-17 15:42:13, Reza Arbab wrote:
> [...]
> > > Almost there. I'm seeing the memory in the correct node now, but the
> > > /sys/devices/system/node/nodeX/memoryY links are not being created.
> > > 
> > > I think it's tripping up here, in register_mem_sect_under_node():
> > > 
> > > 		page_nid = get_nid_for_pfn(pfn);
> > > 		if (page_nid < 0)
> > > 			continue;
> > 
> > Huh, this code is confusing. How can we have a memblock spanning more
> > nodes? If not then the loop over all sections in the memblock seem
> > pointless as well.  Also why do we require page_initialized() in
> > get_nid_for_pfn? The changelog doesn't explain that and there are no
> > comments that would help either.

OK, so I've been thinkin about that and I believe that page_initialized
check in get_nid_for_pfn is just bogus. There is nothing to rely on the
page::lru to be already initialized. So I will go with the following as
a separate preparatory patch.

I believe the whole code should be revisited and I have put that on my
ever growing todo list because I suspect that it is more complex than
necessary. I suspect that memblock do not span more nodes and all this
is just-in-case code (e.g. the onlining code assumes a single zone aka
node. But let's do that later.

---
