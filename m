Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EECFA6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:25:01 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id oAILOw6Q015868
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:24:58 -0800
Received: from gyf2 (gyf2.prod.google.com [10.243.50.66])
	by hpaq1.eem.corp.google.com with ESMTP id oAILOMuM006454
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:24:56 -0800
Received: by gyf2 with SMTP id 2so2353592gyf.21
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:24:56 -0800 (PST)
Date: Thu, 18 Nov 2010 13:24:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
In-Reply-To: <20101118052750.GD2408@shaohui>
Message-ID: <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.568681101@intel.com> <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com> <20101117075128.GA30254@shaohui> <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
 <20101118041407.GA2408@shaohui> <20101118062715.GD17539@linux-sh.org> <20101118052750.GD2408@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010, Shaohui Zheng wrote:

> in our draft patch, we re-setup nr_node_ids when CONFIG_ARCH_MEMORY_PROBE enabled 
> and mem=XXX was specified in grub. we set nr_node_ids as MAX_NUMNODES + 1, because
>  we do not know how many nodes will be hot-added through memory/probe interface. 
>  it might be a little wasting of memory.
> 

nr_node_ids need not be set to anything different at boot, the 
MEM_GOING_ONLINE callback should be used for anything (like the slab 
allocators) where a new node is introduced and needs to be dealt with 
accordingly; this is how regular memory hotplug works, we need no 
additional code in this regard because it's emulated.  If a subsystem 
needs to change in response to a new node going online and doesn't as a 
result of using your emulator, that's a bug and either needs to be fixed 
or prohibited from use with CONFIG_MEMORY_HOTPLUG.

(See the MEM_GOING_ONLINE callback in mm/slub.c, for instance, which deals 
only with the case of node hotplug.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
