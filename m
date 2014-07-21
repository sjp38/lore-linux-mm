Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7F02F6B0092
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:57:46 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id c1so3094248igq.15
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:57:46 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id qf5si30965971igb.40.2014.07.21.10.57.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:57:45 -0700 (PDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 11:57:44 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C38ED3E4003F
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:57:41 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LHu8w263832254
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 19:56:08 +0200
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6LHveKu013480
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:57:41 -0600
Date: Mon, 21 Jul 2014 10:57:36 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140721175736.GG4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <20140721172331.GB4156@linux.vnet.ibm.com>
 <CA+8MBbK+ZdisT_yXh_jkWSd4hWEMisG614s4s0EyNV3j-7YOow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+8MBbK+ZdisT_yXh_jkWSd4hWEMisG614s4s0EyNV3j-7YOow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-hotplug@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 21.07.2014 [10:41:59 -0700], Tony Luck wrote:
> On Mon, Jul 21, 2014 at 10:23 AM, Nishanth Aravamudan
> <nacc@linux.vnet.ibm.com> wrote:
> > It seems like the issue is the order of onlining of resources on a
> > specific x86 platform?
> 
> Yes. When we online a node the BIOS hits us with some ACPI hotplug events:
> 
> First: Here are some new cpus

Ok, so during this period, you might get some remote allocations. Do you
know the topology of these CPUs? That is they belong to a
(soon-to-exist) NUMA node? Can you online that currently offline NUMA
node at this point (so that NODE_DATA()) resolves, etc.)?

> Next: Here is some new memory

And then update the NUMA topology at this point? That is,
set_cpu_numa_node/mem as appropriate so the underlying allocators do the
right thing?

> Last; Here are some new I/O things (PCIe root ports, PCIe devices,
> IOAPICs, IOMMUs, ...)
> 
> So there is a period where the node is memoryless - although that will
> generally be resolved when the memory hot plug event arrives ... that
> isn't guaranteed to occur (there might not be any memory on the node,
> or what memory there is may have failed self-test and been disabled).

Right, but the allocator(s) generally does the right thing already in
the face of memoryless nodes -- they fallback to the nearest node. That
leads to poor performance, but is functional. Based upon the previous
thread Jiang pointed to, it seems like the real issue here isn't that
the node is memoryless, but that it's not even online yet? So NODE_DATA
access crashes?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
