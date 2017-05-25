Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72B906B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:27:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 44so18972343wry.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:27:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14si27074813edu.184.2017.05.24.23.27.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 23:27:25 -0700 (PDT)
Date: Thu, 25 May 2017 08:27:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, memory_hotplug: drop CONFIG_MOVABLE_NODE
Message-ID: <20170525062722.GD12721@dhcp22.suse.cz>
References: <20170524122411.25212-1-mhocko@kernel.org>
 <20170524122411.25212-3-mhocko@kernel.org>
 <3a85146e-2f31-8a9e-26da-6051119586fe@suse.cz>
 <20170524134237.GH14733@dhcp22.suse.cz>
 <6a0bd7c7-8beb-d599-ed31-caca68cd8b30@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6a0bd7c7-8beb-d599-ed31-caca68cd8b30@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 24-05-17 17:17:08, Vlastimil Babka wrote:
> On 05/24/2017 03:42 PM, Michal Hocko wrote:
[...]
> >>> --- a/mm/Kconfig
> >>> +++ b/mm/Kconfig
> >>> @@ -149,32 +149,6 @@ config NO_BOOTMEM
> >>>  config MEMORY_ISOLATION
> >>>  	bool
> >>>  
> >>> -config MOVABLE_NODE
> >>> -	bool "Enable to assign a node which has only movable memory"
> >>> -	depends on HAVE_MEMBLOCK
> >>> -	depends on NO_BOOTMEM
> >>> -	depends on X86_64 || OF_EARLY_FLATTREE || MEMORY_HOTPLUG
> >>> -	depends on NUMA
> >>
> >> That's a lot of depends. What happens if some of them are not met and
> >> the movable_node bootparam is used?
> > 
> > Good question. I haven't explored that, to be honest. Now that I am looking closer
> > I am not even sure why all those dependencies are thre. MEMORY_HOTPLUG
> > is clear and OF_EARLY_FLATTREE is explained by 41a9ada3e6b4 ("of/fdt:
> > mark hotpluggable memory"). NUMA is less clear to me because
> > MEMORY_HOTPLUG doesn't really depend on NUMA systems. Dependency on
> > NO_BOOTMEM is also not clear to me because zones layout
> > doesn't really depend on the specific boot time allocator.
> > 
> > So we are left with HAVE_MEMBLOCK which seems to be there because
> > movable_node_enabled is defined there while the parameter handling is in
> > the hotplug proper. But there is no real reason to have it like that.
> > This compiles but I will have to put throw my full compile battery on it
> > to be sure. I will make it a separate patch.
> 
> I'd expect stuff might compile and work (run without crash), just in
> some cases the boot option could be effectively ignored? In that case
> it's just a matter of documenting the option, possibly also some warning
> when used, e.g. "node_movable was ignored because CONFIG_FOO is not
> enabled"?

Hmm, I can make the cmd parameter available only when
CONFIG_HAVE_MEMBLOCK_NODE_MAP but I am not sure how helpful it would be.
AFAIR unrecognized options are just ignored. On the other hand debugging
why the parameter doesn't do anything might be really frustrating. Here
is the patch I will put on top of the two posted. Strictly speaking it
breaks the bisection but swithing the order would be kind of pointless
ifdefery game and I do not see it would matter all that much. I can
rework if you guys think otherwise though.
---
