Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 972646B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 02:55:43 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l14-v6so8314823oii.9
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 23:55:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g129-v6sor5302388oic.57.2018.08.09.23.55.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 23:55:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180809181224.0b7417e51215565dbda9f665@linux-foundation.org>
References: <20180809025409.31552-1-rashmica.g@gmail.com> <20180809181224.0b7417e51215565dbda9f665@linux-foundation.org>
From: Rashmica Gupta <rashmica.g@gmail.com>
Date: Fri, 10 Aug 2018 16:55:40 +1000
Message-ID: <CAC6rBs=yYYZw-c02yp6rx-+TN2oUGgrp=uuLhZ=Kc_nnjmTRqA@mail.gmail.com>
Subject: Re: [PATCH v3] resource: Merge resources on a node when hot-adding memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: toshi.kani@hpe.com, tglx@linutronix.de, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, Vlastimil Babka <vbabka@suse.cz>, malat@debian.org, Bjorn Helgaas <bhelgaas@google.com>, osalvador@techadventures.net, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Fri, Aug 10, 2018 at 11:12 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu,  9 Aug 2018 12:54:09 +1000 Rashmica Gupta <rashmica.g@gmail.com> wrote:
>
>> When hot-removing memory release_mem_region_adjustable() splits
>> iomem resources if they are not the exact size of the memory being
>> hot-deleted. Adding this memory back to the kernel adds a new
>> resource.
>>
>> Eg a node has memory 0x0 - 0xfffffffff. Offlining and hot-removing
>> 1GB from 0xf40000000 results in the single resource 0x0-0xfffffffff being
>> split into two resources: 0x0-0xf3fffffff and 0xf80000000-0xfffffffff.
>>
>> When we hot-add the memory back we now have three resources:
>> 0x0-0xf3fffffff, 0xf40000000-0xf7fffffff, and 0xf80000000-0xfffffffff.
>>
>> Now if we try to remove some memory that overlaps these resources,
>> like 2GB from 0xf40000000, release_mem_region_adjustable() fails as it
>> expects the chunk of memory to be within the boundaries of a single
>> resource.
>>
>> This patch adds a function request_resource_and_merge(). This is called
>> instead of request_resource_conflict() when registering a resource in
>> add_memory(). It calls request_resource_conflict() and if hot-removing is
>> enabled (if it isn't we won't get resource fragmentation) we attempt to
>> merge contiguous resources on the node.
>
> What is the end-user impact of this patch?
>

Only architectures/setups that allow the user to remove and add memory of
different sizes or different start addresses from the kernel at runtime will
potentially encounter the resource fragmentation.

Trying to remove memory that overlaps iomem resources the first time
gives us this warning: "Unable to release resource <%pa-%pa>".

Attempting a second time results in a kernel oops (on ppc at least).

With this patch the user will not be restricted, by resource fragmentation
caused by previous hotremove/hotplug attempts, to what chunks of memory
they can remove.



> Do you believe the fix should be merged into 4.18?  Backporting into
> -stable kernels?  If so, why?


I hit this when adding hot-add code to memtrace on ppc.

Most memory hotplug/hotremove seems to be block or section based, and
always adds and removes memory at the same place.

Memtrace on ppc is different in that given a size (aligned to a block size),
it scans each node and finds a chunk of memory of that size that we can offline
and then removes it.

As this is possibly only as issue for memtrace on ppc with a patch that is not
in 4.18, I don't think this code needs to go in 4.18.


>
> Thanks.
