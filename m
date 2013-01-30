Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 4CA006B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 04:45:48 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id wz12so866694pbc.3
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 01:45:47 -0800 (PST)
Date: Wed, 30 Jan 2013 01:45:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH Bug fix] acpi, movablemem_map: node0 should always be
 unhotpluggable when using SRAT.
In-Reply-To: <5108E245.9060501@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1301300139070.25371@chino.kir.corp.google.com>
References: <1359532470-28874-1-git-send-email-tangchen@cn.fujitsu.com> <alpine.DEB.2.00.1301300049100.19679@chino.kir.corp.google.com> <5108E245.9060501@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 30 Jan 2013, Tang Chen wrote:

> The failure I'm trying to fix is that if all the memory is hotpluggable, and
> user
> specified movablemem_map, my code will set all the memory as ZONE_MOVABLE, and
> kernel
> will fail to allocate any memory, and it will fail to boot.
> 

I'm curious, do you have a dmesg of the failure?

Historically I've seen this panic as late as build_sched_domains() 
because of a bad mapping between pxms and apicids that assumes node 0 is 
online and results in node_distance() being inaccurate.  I'm not sure if 
you're even getting that far in boot?

> Are you saying your memory is not on node0, and your physical address
> 0x0 is not on node0 ? And your /sys fs don't have a node0 interface, it is
> node1 or something else ?
> 

Exactly, there is a node 0 but it includes no online memory (and that 
should be the case as if it was solely hotpluggable memory) at the time of 
boot.  The sysfs interfaces only get added if the memory is onlined later.

> If so, I think I'd better find another way to fix this problem because node0
> may not be
> the first node on the system.
> 

I haven't tried it over the past year or so, but this used to work in the 
past.  I think if we had some more information we'd be able to see if we 
really need to treat node 0 in a special way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
