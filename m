Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68F416B7594
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 12:54:12 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n95so21377868qte.16
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 09:54:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si6691263qtm.381.2018.12.05.09.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 09:54:11 -0800 (PST)
Date: Wed, 5 Dec 2018 12:53:57 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181205175357.GG3536@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <6e2a1dba-80a8-42bf-127c-2f5c2441c248@intel.com>
 <20181205001544.GR2937@redhat.com>
 <42006749-7912-1e97-8ccd-945e82cebdde@intel.com>
 <20181205021334.GB3045@redhat.com>
 <b3122fdf-02c3-2e9c-1da6-fb873b824d59@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b3122fdf-02c3-2e9c-1da6-fb873b824d59@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Wed, Dec 05, 2018 at 09:27:09AM -0800, Dave Hansen wrote:
> On 12/4/18 6:13 PM, Jerome Glisse wrote:
> > On Tue, Dec 04, 2018 at 05:06:49PM -0800, Dave Hansen wrote:
> >> OK, but there are 1024*1024 matrix cells on a systems with 1024
> >> proximity domains (ACPI term for NUMA node).  So it sounds like you are
> >> proposing a million-directory approach.
> > 
> > No, pseudo code:
> >     struct list links;
> > 
> >     for (unsigned r = 0; r < nrows; r++) {
> >         for (unsigned c = 0; c < ncolumns; c++) {
> >             if (!link_find(links, hmat[r][c].bandwidth,
> >                            hmat[r][c].latency)) {
> >                 link = link_new(hmat[r][c].bandwidth,
> >                                 hmat[r][c].latency);
> >                 // add initiator and target correspond to that row
> >                 // and columns to this new link
> >                 list_add(&link, links);
> >             }
> >         }
> >     }
> > 
> > So all cells that have same property are under the same link. 
> 
> OK, so the "link" here is like a cable.  It's like saying, "we have a
> network and everything is connected with an ethernet cable that can do
> 1gbit/sec".
> 
> But, what actually connects an initiator to a target?  I assume we still
> need to know which link is used for each target/initiator pair.  Where
> is that enumerated?

ls /sys/bus/hms/devices/v0-0-link/
node0           power           subsystem       uevent
uid             bandwidth       latency         v0-1-target
v0-15-initiator v0-21-target    v0-4-initiator  v0-7-initiator
v0-10-initiator v0-13-initiator v0-16-initiator v0-2-initiator
v0-11-initiator v0-14-initiator v0-17-initiator v0-3-initiator
v0-5-initiator  v0-8-initiator  v0-6-initiator  v0-9-initiator
v0-12-initiator v0-10-initiator

So above is 16 CPUs (initiators*) and 2 targets all connected
through a common link. This means that all the initiators
connected to this link can access all the target connected to
this link. The bandwidth and latency is best case scenario
for instance when only one initiator is accessing the target.

Initiator can only access target they share a link with or
an extended path through a bridge. So if you have an initiator
connected to link0 and a target connected to link1 and there
is a bridge link0 to link1 then the initiator can access the
target memory in link1 but the bandwidth and latency will be
min(link0.bandwidth, link1.bandwidth, bridge.bandwidth)
min(link0.latency, link1.latency, bridge.latency)

You can really match one to one a link with bus in your
system. For instance with PCIE if you only have 16lanes
PCIE devices you only devince one link directory for all
your PCIE devices (ignore the PCIE peer to peer scenario
here). You add a bride between your PCIE link to your
NUMA node link (the node to which this PCIE root complex
belongs), this means that PCIE device can access the local
node memory with given bandwidth and latency (best case).


> 
> I think this just means we need a million symlinks to a "link" instead
> of a million link directories.  Still not great.
> 
> > Note that userspace can parse all this once during its initialization
> > and create pools of target to use.
> 
> It sounds like you're agreeing that there is too much data in this
> interface for applications to _regularly_ parse it.  We need some
> central thing that parses it all and caches the results.

No so there is 2 kinds of applications:
    1) average one: i am using device {1, 3, 9} give me best memory for
       those devices
    2) advance one: what is the topology of this system ? Parse the
       topology and partition its workload accordingly

For case 1 you can pre-parse stuff but this can be done by helper library
but for case 2 there is no amount of pre-parsing you can do in kernel, only
the application knows its own architecture and thus only the application
knows what matter in the topology. Is the application looking for big
chunk of memory even if it is slow ? Is it also looking for fast memory
close to X and Y ? ...

Each application will care about different thing and there is no telling
what its gonna be.

So what i am saying is that this information is likely to be parse once
by the application during startup ie the sysfs is not something that
is continuously read and parse by the application (unless application
also care about hotplug and then we are talking about the 1% of the 1%).

Cheers,
J�r�me
