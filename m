Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E097F6B7D44
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 19:16:04 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id j5so2103634qtk.11
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 16:16:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 38si1217584qvi.108.2018.12.06.16.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 16:16:03 -0800 (PST)
Date: Thu, 6 Dec 2018 19:15:55 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181207001554.GH3544@redhat.com>
References: <20181205021334.GB3045@redhat.com>
 <b3122fdf-02c3-2e9c-1da6-fb873b824d59@intel.com>
 <20181205175357.GG3536@redhat.com>
 <b8fab9a7-62ed-5d8d-3cb1-aea6aacf77fe@intel.com>
 <20181206192050.GC3544@redhat.com>
 <d6508932-377c-a4d1-d4d8-01d0f55b9190@intel.com>
 <c583be1b-17db-1ed3-0f5a-bd119edc8bfe@deltatee.com>
 <f7eb9939-d550-706a-946d-acbb7383172e@intel.com>
 <20181206223935.GG3544@redhat.com>
 <c1126d60-95c0-ed34-6314-fcec17ac1c29@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c1126d60-95c0-ed34-6314-fcec17ac1c29@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Thu, Dec 06, 2018 at 03:09:21PM -0800, Dave Hansen wrote:
> On 12/6/18 2:39 PM, Jerome Glisse wrote:
> > No if the 4 sockets are connect in a ring fashion ie:
> >         Socket0 - Socket1
> >            |         |
> >         Socket3 - Socket2
> > 
> > Then you have 4 links:
> > link0: socket0 socket1
> > link1: socket1 socket2
> > link3: socket2 socket3
> > link4: socket3 socket0
> > 
> > I do not see how their can be an explosion of link directory, worse
> > case is as many link directories as they are bus for a CPU/device/
> > target.
> 
> This looks great.  But, we don't _have_ this kind of information for any
> system that I know about or any system available in the near future.

We do not have it in any standard way, it is out there in either
device driver database, application data base, special platform
OEM blob burried somewhere in the firmware ...

I want to solve the kernel side of the problem ie how to expose
this to userspace. How the kernel get that information is an
orthogonal problem. For now my intention is to have device driver
register and create the links and bridges that are not enumerated
by standard firmware.

> 
> We basically have two different world views:
> 1. The system is described point-to-point.  A connects to B @
>    100GB/s.  B connects to C at 50GB/s.  Thus, C->A should be
>    50GB/s.
>    * Less information to convey
>    * Potentially less precise if the properties are not perfectly
>      additive.  If A->B=10ns and B->C=20ns, A->C might be >30ns.
>    * Costs must be calculated instead of being explicitly specified
> 2. The system is described endpoint-to-endpoint.  A->B @ 100GB/s
>    B->C @ 50GB/s, A->C @ 50GB/s.
>    * A *lot* more information to convey O(N^2)?
>    * Potentially more precise.
>    * Costs are explicitly specified, not calculated
> 
> These patches are really tied to world view #1.  But, the HMAT is really
> tied to world view #1.
                      ^#2

Note that they are also the bridge object in my proposal. So in my
proposal you in #1 you have:
link0: A <-> B with 100GB/s and 10ns latency
link1: B <-> C with 50GB/s and 20ns latency

Now if A can reach C through B then you have bridges (bridge are uni-
directional unlike link that are bi-directional thought that finer
point can be discuss this is what allow any kind of directed graph to
be represented):
bridge2: link0 -> link1
bridge3: link1 -> link0

You can also associated properties to bridge (but it is not mandatory).
So you can say that bridge2 and bridge3 have a latency of 50ns and if
the addition of latency is enough then you do not specificy it in bridge.
It is a rule that a path latency is the sum of its individual link
latency. For bandwidth it is the minimum bandwidth ie what ever is the
bottleneck for the path.


> I know you're not a fan of the HMAT.  But it is the firmware reality
> that we are stuck with, until something better shows up.  I just don't
> see a way to convert it into what you have described here.

Like i said i am not targetting HMAT system i am targeting system that
rely today on database spread between driver and application. I want to
move that knowledge in driver first so that they can teach the core
kernel and register thing in the core. Providing a standard firmware
way to provide this information is a different problem (they are some
loose standard on non ACPI platform AFAIK).

> I'm starting to think that, no matter if the HMAT or some other approach
> gets adopted, we shouldn't be exposing this level of gunk to userspace
> at *all* since it requires adopting one of the world views.

I do not see this as exclusive. Yes they are HMAT system "soon" to arrive
but we already have the more extended view which is just buried under a
pile of different pieces. I do not see any exclusion between the 2. If
HMAT is good enough for a whole class of system fine but there is also
a whole class of system and users that do not fit in that paradigm hence
my proposal.

Cheers,
J�r�me
