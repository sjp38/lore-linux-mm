Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F1C266B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:34:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r18so897361wmd.1
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:34:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si5972142wmy.33.2017.02.13.07.34.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 07:34:52 -0800 (PST)
Subject: Re: [PATCH V2 0/3] Define coherent device memory node
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b67ad176-80b6-66ca-3b65-f5b8ae07e92f@suse.cz>
Date: Mon, 13 Feb 2017 16:34:50 +0100
MIME-Version: 1.0
In-Reply-To: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/10/2017 11:06 AM, Anshuman Khandual wrote:
> 	This three patches define CDM node with HugeTLB & Buddy allocation
> isolation. Please refer to the last RFC posting mentioned here for details.
> The series has been split for easier review process. The next part of the
> work like VM flags, auto NUMA and KSM interactions with tagged VMAs will
> follow later.

Hi,

I'm not sure if the splitting to smaller series and focusing on partial
implementations is helpful at this point, until there's some consensus
about the whole approach from a big picture perspective.

Note that it's also confusing that v1 of this partial patchset mentioned
some alternative implementations, but only as git branches, and the
discussion about their differences is linked elsewhere. That further
makes meaningful review harder IMHO.

Going back to the bigger picture, I've read the comments on previous
postings and I think Jerome makes many good points in this subthread [1]
against the idea of representing the device memory as generic memory
nodes and expecting userspace to mbind() to them. So if I make a program
that uses mbind() to back some mmapped area with memory of "devices like
accelerators, GPU cards, network cards, FPGA cards, PLD cards etc which
might contain on board memory", then it will get such memory... and then
what? How will it benefit from it? I will also need to tell some driver
to make the device do some operations with this memory, right? And that
most likely won't be a generic operation. In that case I can also ask
the driver to give me that memory in the first place, and it can apply
whatever policies are best for the device in question? And it's also the
driver that can detect if the device memory is being wasted by a process
that isn't currently performing the interesting operations, while
another process that does them had to fallback its allocations to system
memory and thus runs slower. I expect the NUMA balancing can't catch
that for device memory (and you also disable it anyway?) So I don't
really see how a generic solution would work, without having a full
concrete example, and thus it's really hard to say that this approach is
the right way to go and should be merged.

The only examples I've noticed that don't require any special operations
to benefit from placement in the "device memory", were fast memories
like MCDRAM, which differentiate by performance of generic CPU
operations, so it's not really a "device memory" by your terminology.
And I would expect policing access to such performance differentiated
memory is already possible with e.g. cpusets?

Thanks,
Vlastimil

[1] https://lkml.kernel.org/r/20161025153256.GB6131@gmail.com

> https://lkml.org/lkml/2017/1/29/198
> 
> Changes in V2:
> 
> * Removed redundant nodemask_has_cdm() check from zonelist iterator
> * Dropped the nodemask_had_cdm() function itself
> * Added node_set/clear_state_cdm() functions and removed bunch of #ifdefs
> * Moved CDM helper functions into nodemask.h from node.h header file
> * Fixed the build failure by additional CONFIG_NEED_MULTIPLE_NODES check
> 
> Previous V1: (https://lkml.org/lkml/2017/2/8/329)
> 
> Anshuman Khandual (3):
>   mm: Define coherent device memory (CDM) node
>   mm: Enable HugeTLB allocation isolation for CDM nodes
>   mm: Enable Buddy allocation isolation for CDM nodes
> 
>  Documentation/ABI/stable/sysfs-devices-node |  7 ++++
>  arch/powerpc/Kconfig                        |  1 +
>  arch/powerpc/mm/numa.c                      |  7 ++++
>  drivers/base/node.c                         |  6 +++
>  include/linux/nodemask.h                    | 58 ++++++++++++++++++++++++++++-
>  mm/Kconfig                                  |  4 ++
>  mm/hugetlb.c                                | 25 ++++++++-----
>  mm/memory_hotplug.c                         |  3 ++
>  mm/page_alloc.c                             | 24 +++++++++++-
>  9 files changed, 123 insertions(+), 12 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
