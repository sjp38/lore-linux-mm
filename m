Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF596B70E6
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 16:57:40 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s70so18254285qks.4
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 13:57:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m123si8737276qkc.180.2018.12.04.13.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 13:57:39 -0800 (PST)
Date: Tue, 4 Dec 2018 16:57:12 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181204215711.GP2937@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <9d745b99-22e3-c1b5-bf4f-d3e83113f57b@intel.com>
 <20181204184919.GD2937@redhat.com>
 <20163c1e-00f1-7e02-82c0-7730ceabb9f2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20163c1e-00f1-7e02-82c0-7730ceabb9f2@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Tue, Dec 04, 2018 at 01:37:56PM -0800, Dave Hansen wrote:
> On 12/4/18 10:49 AM, Jerome Glisse wrote:
> >> Also, could you add a simple, example program for how someone might use
> >> this?  I got lost in all the new sysfs and ioctl gunk.  Can you
> >> characterize how this would work with the *exiting* NUMA interfaces that
> >> we have?
> > That is the issue i can not expose device memory as NUMA node as
> > device memory is not cache coherent on AMD and Intel platform today.
> > 
> > More over in some case that memory is not visible at all by the CPU
> > which is not something you can express in the current NUMA node.
> 
> Yeah, our NUMA mechanisms are for managing memory that the kernel itself
> manages in the "normal" allocator and supports a full feature set on.
> That has a bunch of implications, like that the memory is cache coherent
> and accessible from everywhere.
> 
> The HMAT patches only comprehend this "normal" memory, which is why
> we're extending the existing /sys/devices/system/node infrastructure.
> 
> This series has a much more aggressive goal, which is comprehending the
> connections of every memory-target to every memory-initiator, no matter
> who is managing the memory, who can access it, or what it can be used for.
> 
> Theoretically, HMS could be used for everything that we're doing with
> /sys/devices/system/node, as long as it's tied back into the existing
> NUMA infrastructure _somehow_.
> 
> Right?

Fully correct mind if i steal that perfect summary description next time
i post ? I am so bad at explaining thing :)

Intention is to allow program to do everything they do with mbind() today
and tomorrow with the HMAT patchset and on top of that to also be able to
do what they do today through API like OpenCL, ROCm, CUDA ... So it is one
kernel API to rule them all ;)

Also at first i intend to special case vma alloc page when they are HMS
policy, long term i would like to merge code path inside the kernel. But
i do not want to disrupt existing code path today, i rather grow to that
organicaly. Step by step. The mbind() would still work un-affected in
the end just the plumbing would be slightly different.

Cheers,
J�r�me
