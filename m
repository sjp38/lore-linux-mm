Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A6ADF8D0080
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 03:17:00 -0500 (EST)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id oAH8GvOk020416
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:58 -0800
Received: from iwn9 (iwn9.prod.google.com [10.241.68.73])
	by hpaq7.eem.corp.google.com with ESMTP id oAH8Gta2031954
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:56 -0800
Received: by iwn9 with SMTP id 9so1963337iwn.28
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:55 -0800 (PST)
Date: Wed, 17 Nov 2010 00:16:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3/8,v3] NUMA Hotplug Emulator: Userland interface to hotplug-add
 fake offlined nodes.
In-Reply-To: <20101117021000.638336620@intel.com>
Message-ID: <alpine.DEB.2.00.1011170010430.17408@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.638336620@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Dave Hansen <haveblue@us.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, shaohui.zheng@intel.com wrote:

> From: Haicheng Li <haicheng.li@intel.com>
> 
> Add a sysfs entry "probe" under /sys/devices/system/node/:
> 
>  - to show all fake offlined nodes:
>     $ cat /sys/devices/system/node/probe
> 
>  - to hotadd a fake offlined node, e.g. nodeid is N:
>     $ echo N > /sys/devices/system/node/probe
> 

This would be much more powerful if we just reserved an amount of memory 
at boot and then allowed users to hot-add a given amount with an 
non-online node id.  Then we can test nodes of various sizes rather than 
being statically committed at boot.

This should be fairly straight-forward by faking 
ACPI_SRAT_MEM_HOT_PLUGGABLE entries, for example.

> Index: linux-hpe4/mm/Kconfig
> ===================================================================
> --- linux-hpe4.orig/mm/Kconfig	2010-11-15 17:13:02.443461606 +0800
> +++ linux-hpe4/mm/Kconfig	2010-11-15 17:21:05.535335091 +0800
> @@ -147,6 +147,21 @@
>  	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>  	depends on MIGRATION
>  
> +config NUMA_HOTPLUG_EMU
> +	bool "NUMA hotplug emulator"
> +	depends on X86_64 && NUMA && MEMORY_HOTPLUG
> +
> +	---help---
> +
> +config NODE_HOTPLUG_EMU
> +	bool "Node hotplug emulation"
> +	depends on NUMA_HOTPLUG_EMU && MEMORY_HOTPLUG
> +	---help---
> +	  Enable Node hotplug emulation. The machine will be setup with
> +	  hidden virtual nodes when booted with "numa=hide=N*size", where
> +	  N is the number of hidden nodes, size is the memory size per
> +	  hidden node. This is only useful for debugging.
> +

That's clearly wrong, but I don't see why this needs to be a new Kconfig 
option to begin with, can't we enable all of this functionality by default 
under CONFIG_NUMA_EMU && CONFIG_MEMORY_HOTPLUG?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
