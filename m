Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 214046B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 08:14:33 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id d63so4850153wma.4
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 05:14:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z73si6399366wrc.64.2018.01.29.05.14.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 05:14:31 -0800 (PST)
Date: Mon, 29 Jan 2018 14:14:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM ATTEND] Requests to attend MM Summit 2018
Message-ID: <20180129131428.GA21853@dhcp22.suse.cz>
References: <3cf31aa1-6886-a01c-57ff-143c165a74e3@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3cf31aa1-6886-a01c-57ff-143c165a74e3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Laura Abbott <labbott@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>

On Sun 28-01-18 18:22:01, Anshuman Khandual wrote:
[...]
> 1. Supporting hotplug memory as a CMA region
> 
> There are situations where a platform identified specific PFN range
> can only be used for some low level debug/tracing purpose. The same
> PFN range must be shared between multiple guests on a need basis,
> hence its logical to expect the range to be hot add/removable in
> each guest. But once available and online in the guest, it would
> require a sort of guarantee of a large order allocation (almost the
> entire range) into the memory to use it for aforesaid purpose.
> Plugging the memory as ZONE_MOVABLE with MIGRATE_CMA makes sense in
> this scenario but its not supported at the moment.

Isn't Joonsoo's[1] work doing exactly this?

[1] http://lkml.kernel.org/r/1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com

Anyway, declaring CMA regions to the hotplugable memory sounds like a
misconfiguration. Unless I've missed anything CMA memory is not
migratable and it is far from trivial to change that.

> This basically extends the idea of relaxing CMA reservation and
> declaration restrictions as pointed by Mike Kravetz.
> 
> 2. Adding NUMA
> 
> Adding NUMA tracking information to individual CMA areas and use it
> for alloc_cma() interface. In POWER8 KVM implementation, guest HPT
> (Hash Page Table) is allocated from a predefined CMA region. NUMA
> aligned allocation for HPT for any given guest VM can help improve
> performance.

With CMA using ZONE_MOVABLE this should be rather straightforward. We
just need a way to distribute CMA regions over nodes and make the core
CMA allocator to fallback between nodes in a the nodlist order.
 
> 3. Reducing CMA allocation failures
> 
> CMA allocation failures are primarily because of not being unable to
> isolate or migrate the given PFN range (Inside alloc_contig_range).
> Is there a way to reduce the failure chances ?
> 
> D. MAP_CONTIG (Mike Kravetz, Laura Abbott, Michal Hocko)
> 
> I understand that a recent RFC from Mike Kravetz got debated but without
> any conclusion about the viability to add MAP_CONTIG option for the user
> space to request large contiguous physical memory.

The conclusion was pretty clear AFAIR. Our allocator simply cannot
handle arbitrary sized large allocations so MAP_CONTIG is really hard to
provide to the userspace. If there are drivers (RDMA I suspect) which
would benefit from large allocations then they should use a custom mmap
implementation which preallocates the memory.

> I will be really
> interested to discuss any future plans on how kernel can help user space
> with large physical contiguous memory if need arises.
> 
> (MAP_CONTIG RFC https://lkml.org/lkml/2017/10/3/992)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
