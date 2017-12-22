Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 45DA76B025F
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 16:46:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g8so17951416pgs.14
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 13:46:18 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x7si17346280plo.375.2017.12.22.13.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 13:46:17 -0800 (PST)
Date: Fri, 22 Dec 2017 14:46:13 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
Message-ID: <20171222214613.GA25711@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <20171214130032.GK16951@dhcp22.suse.cz>
 <20171218203547.GA2366@linux.intel.com>
 <20171220181937.GB12236@bombadil.infradead.org>
 <20171220211350.GA2688@linux.intel.com>
 <AT5PR8401MB0387011EAD8858CC99548ED2AB0D0@AT5PR8401MB0387.NAMPRD84.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AT5PR8401MB0387011EAD8858CC99548ED2AB0D0@AT5PR8401MB0387.NAMPRD84.PROD.OUTLOOK.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, "Box, David E" <david.e.box@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Schmauss, Erik" <erik.schmauss@intel.com>, Len Brown <lenb@kernel.org>, John Hubbard <jhubbard@nvidia.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Jerome Glisse <jglisse@redhat.com>, "devel@acpica.org" <devel@acpica.org>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Koss, Marcin" <marcin.koss@intel.com>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Brice Goglin <brice.goglin@gmail.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

On Thu, Dec 21, 2017 at 01:41:15AM +0000, Elliott, Robert (Persistent Memory) wrote:
> 
> 
> > -----Original Message-----
> > From: Linux-nvdimm [mailto:linux-nvdimm-bounces@lists.01.org] On Behalf Of
> > Ross Zwisler
> ...
> > 
> > On Wed, Dec 20, 2017 at 10:19:37AM -0800, Matthew Wilcox wrote:
> ...
> > > initiator is a CPU?  I'd have expected you to expose a memory controller
> > > abstraction rather than re-use storage terminology.
> > 
> > Yea, I agree that at first blush it seems weird.  It turns out that
> > looking at it in sort of a storage initiator/target way is beneficial,
> > though, because it allows us to cut down on the number of data values
> > we need to represent.
> > 
> > For example the SLIT, which doesn't differentiate between initiator and
> > target proximity domains (and thus nodes) always represents a system
> > with N proximity domains using a NxN distance table.  This makes sense
> > if every node contains both CPUs and memory.
> > 
> > With the introduction of the HMAT, though, we can have memory-only
> > initiator nodes and we can explicitly associate them with their local 
> > CPU.  This is necessary so that we can separate memory with different
> > performance characteristics (HBM vs normal memory vs persistent memory,
> > for example) that are all attached to the same CPU.
> > 
> > So, say we now have a system with 4 CPUs, and each of those CPUs has 3
> > different types of memory attached to it.  We now have 16 total proximity
> > domains, 4 CPU and 12 memory.
> 
> The CPU cores that make up a node can have performance restrictions of
> their own; for example, they might max out at 10 GB/s even though the
> memory controller supports 120 GB/s (meaning you need to use 12 cores
> on the node to fully exercise memory).  It'd be helpful to report this,
> so software can decide how many cores to use for bandwidth-intensive work.
> 
> > If we represent this with the SLIT we end up with a 16 X 16 distance table
> > (256 entries), most of which don't matter because they are memory-to-
> > memory distances which don't make sense.
> > 
> > In the HMAT, though, we separate out the initiators and the targets and
> > put them into separate lists.  (See 5.2.27.4 System Locality Latency and
> > Bandwidth Information Structure in ACPI 6.2 for details.)  So, this same
> > config in the HMAT only has 4*12=48 performance values of each type, all
> > of which convey meaningful information.
> > 
> > The HMAT indeed even uses the storage "initiator" and "target"
> > terminology. :)
> 
> Centralized DMA engines (e.g., as used by the "DMA based blk-mq pmem
> driver") have performance differences too.  A CPU might include
> CPU cores that reach 10 GB/s, DMA engines that reach 60 GB/s, and
> memory controllers that reach 120 GB/s.  I guess these would be
> represented as extra initiators on the node?

For both of your comments I think all of this comes down to how you want to
represent your platform in the HMAT.  The sysfs representation just shows you
what is in the HMAT.

Each initiator node is just a single NUMA node (think of it as a NUMA node
which has the characteristic that it can initiate memory requests), so I don't
think there is a way to have "extra initiators on the node".  I think what
you're talking about is separating the DMA engines and CPU cores into separate
NUMA nodes, both of which are initiators.  I think this is probably fine as it
conveys useful info.

I don't think the HMAT has a concept of increasing bandwidth for number of CPU
cores used - it just has a single bandwidth number (well, one for read and one
for write) per initiator/target pair.  I don't think we want to add this,
either - the HMAT is already very complex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
