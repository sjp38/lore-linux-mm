Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE2F26B7529
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:09:40 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id x125so20167891qka.17
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:09:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j25si4270357qtp.145.2018.12.05.08.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 08:09:39 -0800 (PST)
Date: Wed, 5 Dec 2018 11:09:32 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181205160932.GB3536@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <9d745b99-22e3-c1b5-bf4f-d3e83113f57b@intel.com>
 <20181204184919.GD2937@redhat.com>
 <d90b88f6-b414-a0f9-d572-35c4d2bb1579@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d90b88f6-b414-a0f9-d572-35c4d2bb1579@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Wed, Dec 05, 2018 at 04:57:17PM +0530, Aneesh Kumar K.V wrote:
> On 12/5/18 12:19 AM, Jerome Glisse wrote:
> 
> > Above example is for migrate. Here is an example for how the
> > topology is use today:
> > 
> >      Application knows that the platform is running on have 16
> >      GPU split into 2 group of 8 GPUs each. GPU in each group can
> >      access each other memory with dedicated mesh links between
> >      each others. Full speed no traffic bottleneck.
> > 
> >      Application splits its GPU computation in 2 so that each
> >      partition runs on a group of interconnected GPU allowing
> >      them to share the dataset.
> > 
> > With HMS:
> >      Application can query the kernel to discover the topology of
> >      system it is running on and use it to partition and balance
> >      its workload accordingly. Same application should now be able
> >      to run on new platform without having to adapt it to it.
> > 
> 
> Will the kernel be ever involved in decision making here? Like the scheduler
> will we ever want to control how there computation units get scheduled onto
> GPU groups or GPU?

I don;t think you will ever see fine control in software because it
would go against what GPU are fundamentaly. GPU have 1000 of cores
and usualy 10 times more thread in flight than core (depends on the
number of register use by the program or size of their thread local
storage). By having many more thread in flight the GPU always have
some threads that are not waiting for memory access and thus always
have something to schedule next on the core. This scheduling is all
done in real time and i do not see that as a good fit for any kernel
CPU code.

That being said higher level and more coarse directive can be given
to the GPU hardware scheduler like giving priorities to group of
thread so that they always get schedule first if ready. There is
a cgroup proposal that goes into the direction of exposing high
level control over GPU resource like that. I think this is a better
venue to discuss such topics.

> 
> > This is kind of naive i expect topology to be hard to use but maybe
> > it is just me being pesimistics. In any case today we have a chicken
> > and egg problem. We do not have a standard way to expose topology so
> > program that can leverage topology are only done for HPC where the
> > platform is standard for few years. If we had a standard way to expose
> > the topology then maybe we would see more program using it. At very
> > least we could convert existing user.
> > 
> > 
> 
> I am wondering whether we should consider HMAT as a subset of the ideas
> mentioned in this thread and see whether we can first achieve HMAT
> representation with your patch series?

I do not want to block HMAT on that. What i am trying to do really
does not fit in the existing NUMA node this is what i have been trying
to show even if not everyone is convince by that. Some bulets points
of why:
    - memory i care about is not accessible by everyone (backed in
      assumption in NUMA node)
    - memory i care about might not be cache coherent (again backed
      in assumption in NUMA node)
    - topology matter so that userspace knows what inter-connect is
      share and what have dedicated links to memory
    - their can be multiple path between one device and one target
      memory and each path have different numa distance (or rather
      properties like bandwidth, latency, ...) again this is does
      not fit with the NUMA distance thing
    - memory is not manage by core kernel for reasons i hav explained
    - ...

The HMAT proposal does not deal with such memory, it is much more
close to what the current model can describe.

Cheers,
J�r�me
