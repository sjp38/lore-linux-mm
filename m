Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F0CE2600385
	for <linux-mm@kvack.org>; Fri, 21 May 2010 06:11:34 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id o4LA8SuV029650
	for <linux-mm@kvack.org>; Fri, 21 May 2010 15:38:28 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4LA8QrF3293388
	for <linux-mm@kvack.org>; Fri, 21 May 2010 15:38:28 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4LA8P1f010295
	for <linux-mm@kvack.org>; Fri, 21 May 2010 20:08:26 +1000
Date: Fri, 21 May 2010 15:38:16 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [RFC, 3/7] NUMA hotplug emulator
Message-ID: <20100521100816.GA7906@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <20100513114835.GD2169@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513114835.GD2169@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Greg Kroah-Hartman <gregkh@suse.de>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
Cc: Balbir Singh <balbir@in.ibm.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 13, 2010 at 07:48:35PM +0800, Shaohui Zheng wrote:
> Userland interface to hotplug-add fake offlined nodes.
> 
> Add a sysfs entry "probe" under /sys/devices/system/node/:
> 
>  - to show all fake offlined nodes:
>     $ cat /sys/devices/system/node/probe
> 
>  - to hotadd a fake offlined node, e.g. nodeid is N:
>     $ echo N > /sys/devices/system/node/probe
> 
> Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> ---
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 9458685..2c078c8 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1214,6 +1214,20 @@ config NUMA_EMU
>  	  into virtual nodes when booted with "numa=fake=N", where N is the
>  	  number of nodes. This is only useful for debugging.
> 
> +config NUMA_HOTPLUG_EMU
> +	bool "NUMA hotplug emulator"
> +	depends on X86_64 && NUMA && HOTPLUG
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

The above dependencies do not work as expected. I could configure
NUMA_HOTPLUG_EMU & NODE_HOTPLUG_EMU without having MEMORY_HOTPLUG
turned on. By pushing the above definition below SPARSEMEM and memory
hot add and remove, the dependencies could be sorted out.

-- 
Regards,                                                                        
Ankita Garg (ankita@in.ibm.com)                                                 
Linux Technology Center                                                         
IBM India Systems & Technology Labs,                                            
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
