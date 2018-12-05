Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8B5F6B71E5
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 21:13:44 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id m37so19284797qte.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 18:13:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a67si3115719qkg.137.2018.12.04.18.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 18:13:43 -0800 (PST)
Date: Tue, 4 Dec 2018 21:13:35 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181205021334.GB3045@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <6e2a1dba-80a8-42bf-127c-2f5c2441c248@intel.com>
 <20181205001544.GR2937@redhat.com>
 <42006749-7912-1e97-8ccd-945e82cebdde@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <42006749-7912-1e97-8ccd-945e82cebdde@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Tue, Dec 04, 2018 at 05:06:49PM -0800, Dave Hansen wrote:
> On 12/4/18 4:15 PM, Jerome Glisse wrote:
> > On Tue, Dec 04, 2018 at 03:54:22PM -0800, Dave Hansen wrote:
> >> Basically, is sysfs the right place to even expose this much data?
> > 
> > I definitly want to avoid the memoryX mistake. So i do not want to
> > see one link directory per device. Taking my simple laptop as an
> > example with 4 CPUs, a wifi and 2 GPU (the integrated one and a
> > discret one):
> > 
> > link0: cpu0 cpu1 cpu2 cpu3
> > link1: wifi (2 pcie lane)
> > link2: gpu0 (unknown number of lane but i believe it has higher
> >              bandwidth to main memory)
> > link3: gpu1 (16 pcie lane)
> > link4: gpu1 and gpu memory
> > 
> > So one link directory per number of pcie lane your device have
> > so that you can differentiate on bandwidth. The main memory is
> > symlinked inside all the link directory except link4. The GPU
> > discret memory is only in link4 directory as it is only
> > accessible by the GPU (we could add it under link3 too with the
> > non cache coherent property attach to it).
> 
> I'm actually really interested in how this proposal scales.  It's quite
> easy to represent a laptop, but can this scale to the largest systems
> that we expect to encounter over the next 20 years that this ABI will live?
> 
> > The issue then becomes how to convert down the HMAT over verbose
> > information to populate some reasonable layout for HMS. For that
> > i would say that create a link directory for each different
> > matrix cell. As an example let say that each entry in the matrix
> > has bandwidth and latency then we create a link directory for
> > each combination of bandwidth and latency. On simple system that
> > should boils down to a handfull of combination roughly speaking
> > mirroring the example above of one link directory per number of
> > PCIE lane for instance.
> 
> OK, but there are 1024*1024 matrix cells on a systems with 1024
> proximity domains (ACPI term for NUMA node).  So it sounds like you are
> proposing a million-directory approach.

No, pseudo code:
    struct list links;

    for (unsigned r = 0; r < nrows; r++) {
        for (unsigned c = 0; c < ncolumns; c++) {
            if (!link_find(links, hmat[r][c].bandwidth,
                           hmat[r][c].latency)) {
                link = link_new(hmat[r][c].bandwidth,
                                hmat[r][c].latency);
                // add initiator and target correspond to that row
                // and columns to this new link
                list_add(&link, links);
            }
        }
    }

So all cells that have same property are under the same link. Do you
expect all the cell to always have different properties ? On today
platform it should not be the case. I do expect we will keep seeing
many initiator/target pair that share same properties as other pair.

But yes if you have system where no initiator/target pair have the
same properties than you in the worst case you are describing. But
hey that is the hardware you have then :)

Note that userspace can parse all this once during its initialization
and create pools of target to use.


> We also can't simply say that two CPUs with the same connection to two
> other CPUs (think a 4-socket QPI-connected system) share the same "link"
> because they share the same combination of bandwidth and latency.  We
> need to know that *each* has its own, unique link and do not share link
> resources.

That is the purpose of the bridge object to inter-connect link.
To be more exact link is like saying you have 2 arrows with the
same properties between every node listed in the link. While
bridge allow to define arrow in just one direction. Maybe i
should define arrow and node instead of trying to match some of
the ACPI terminology. This might be easier for people to follow
than first having to understand the terminology.

The fear i have with HMAT culling is that HMAT does not have the
information to avoid such culling.

> > I don't think i have a system with an HMAT table if you have one
> > HMAT table to provide i could show up the end result.
> 
> It is new enough (ACPI 6.2) that no publicly-available hardware that
> exists that implements one (that I know of).  Keith Busch can probably
> extract one and send it to you or show you how we're faking them with QEMU.
> 
> > Note i believe the ACPI HMAT matrix is a bad design for that
> > reasons ie there is lot of commonality in many of the matrix
> > entry and many entry also do not make sense (ie initiator not
> > being able to access all the targets). I feel that link/bridge
> > is much more compact and allow to represent any directed graph
> > with multiple arrows from one node to another same node.
> 
> I don't disagree.  But, folks are building systems with them and we need
> to either deal with it, or make its data manageable.  You saw our
> approach: we cull the data and only expose the bare minimum in sysfs.

Yeah and i intend to cull data too inside HMS.

Cheers,
J�r�me
