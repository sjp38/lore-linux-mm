Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7145C6B00A1
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 19:32:41 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id j5so4170941qga.15
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 16:32:41 -0700 (PDT)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id c74si13608569qgd.54.2014.07.24.16.32.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 16:32:40 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 24 Jul 2014 19:32:40 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8B3A838C8026
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 19:32:38 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6ONWcE155181428
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 23:32:38 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6ONWbP3013249
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 19:32:38 -0400
Date: Thu, 24 Jul 2014 16:32:30 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140724233230.GD24458@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <20140721172331.GB4156@linux.vnet.ibm.com>
 <CA+8MBbK+ZdisT_yXh_jkWSd4hWEMisG614s4s0EyNV3j-7YOow@mail.gmail.com>
 <20140721175736.GG4156@linux.vnet.ibm.com>
 <53CF7048.20302@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CF7048.20302@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-hotplug@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 23.07.2014 [16:20:24 +0800], Jiang Liu wrote:
> 
> 
> On 2014/7/22 1:57, Nishanth Aravamudan wrote:
> > On 21.07.2014 [10:41:59 -0700], Tony Luck wrote:
> >> On Mon, Jul 21, 2014 at 10:23 AM, Nishanth Aravamudan
> >> <nacc@linux.vnet.ibm.com> wrote:
> >>> It seems like the issue is the order of onlining of resources on a
> >>> specific x86 platform?
> >>
> >> Yes. When we online a node the BIOS hits us with some ACPI hotplug events:
> >>
> >> First: Here are some new cpus
> > 
> > Ok, so during this period, you might get some remote allocations. Do you
> > know the topology of these CPUs? That is they belong to a
> > (soon-to-exist) NUMA node? Can you online that currently offline NUMA
> > node at this point (so that NODE_DATA()) resolves, etc.)?
> Hi Nishanth,
> 	We have method to get the NUMA information about the CPU, and
> patch "[RFC Patch V1 30/30] x86, NUMA: Online node earlier when doing
> CPU hot-addition" tries to solve this issue by onlining NUMA node
> as early as possible. Actually we are trying to enable memoryless node
> as you have suggested.

Ok, it seems like you have two sets of patches then? One is to fix the
NUMA information timing (30/30 only). The rest of the patches are
general discussions about where cpu_to_mem() might be used instead of
cpu_to_node(). However, based upon Tejun's feedback, it seems like
rather than force all callers to use cpu_to_mem(), we should be looking
at the core VM to ensure fallback is occuring appropriately when
memoryless nodes are present. 

Do you have a specific situation, once you've applied 30/30, where
kmalloc_node() leads to an Oops?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
