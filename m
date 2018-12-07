Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95DB96B7FE4
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 04:48:24 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id c33so1568021otb.18
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 01:48:24 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h64si1218576oif.143.2018.12.07.01.48.23
        for <linux-mm@kvack.org>;
        Fri, 07 Dec 2018 01:48:23 -0800 (PST)
Date: Fri, 7 Dec 2018 09:48:19 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm, kmemleak: Little optimization while scanning
Message-ID: <20181207094819.GA23085@arrakis.emea.arm.com>
References: <20181206131918.25099-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181206131918.25099-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 06, 2018 at 02:19:18PM +0100, Oscar Salvador wrote:
> kmemleak_scan() goes through all online nodes and tries
> to scan all used pages.
> We can do better and use pfn_to_online_page(), so in case we have
> CONFIG_MEMORY_HOTPLUG, offlined pages will be skiped automatically.
> For boxes where CONFIG_MEMORY_HOTPLUG is not present, pfn_to_online_page()
> will fallback to pfn_valid().
> 
> Another little optimization is to check if the page belongs to the node
> we are currently checking, so in case we have nodes interleaved we will
> not check the same pfn multiple times.
> 
> I ran some tests:
> 
> Add some memory to node1 and node2 making it interleaved:
> 
> (qemu) object_add memory-backend-ram,id=ram0,size=1G
> (qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1
> (qemu) object_add memory-backend-ram,id=ram1,size=1G
> (qemu) device_add pc-dimm,id=dimm1,memdev=ram1,node=2
> (qemu) object_add memory-backend-ram,id=ram2,size=1G
> (qemu) device_add pc-dimm,id=dimm2,memdev=ram2,node=1
> 
> Then, we offline that memory:
>  # for i in {32..39} ; do echo "offline" > /sys/devices/system/node/node1/memory$i/state;done
>  # for i in {48..55} ; do echo "offline" > /sys/devices/system/node/node1/memory$i/state;don
>  # for i in {40..47} ; do echo "offline" > /sys/devices/system/node/node2/memory$i/state;done
> 
> And we run kmemleak_scan:
> 
>  # echo "scan" > /sys/kernel/debug/kmemleak
> 
> before the patch:
> 
> kmemleak: time spend: 41596 us
> 
> after the patch:
> 
> kmemleak: time spend: 34899 us
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
