Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E332D6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:13:54 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id x1so10168202plb.2
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 13:13:54 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id h5si12483353pgv.48.2017.12.20.13.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 13:13:53 -0800 (PST)
Date: Wed, 20 Dec 2017 14:13:50 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
Message-ID: <20171220211350.GA2688@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <20171214130032.GK16951@dhcp22.suse.cz>
 <20171218203547.GA2366@linux.intel.com>
 <20171220181937.GB12236@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171220181937.GB12236@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Dec 20, 2017 at 10:19:37AM -0800, Matthew Wilcox wrote:
> On Mon, Dec 18, 2017 at 01:35:47PM -0700, Ross Zwisler wrote:
> > What I'm hoping to do with this series is to just provide a sysfs
> > representation of the HMAT so that applications can know which NUMA nodes to
> > select with existing utilities like numactl.  This series does not currently
> > alter any kernel behavior, it only provides a sysfs interface.
> > 
> > Say for example you had a system with some high bandwidth memory (HBM), and
> > you wanted to use it for a specific application.  You could use the sysfs
> > representation of the HMAT to figure out which memory target held your HBM.
> > You could do this by looking at the local bandwidth values for the various
> > memory targets, so:
> > 
> > 	# grep . /sys/devices/system/hmat/mem_tgt*/local_init/write_bw_MBps
> > 	/sys/devices/system/hmat/mem_tgt2/local_init/write_bw_MBps:81920
> > 	/sys/devices/system/hmat/mem_tgt3/local_init/write_bw_MBps:40960
> > 	/sys/devices/system/hmat/mem_tgt4/local_init/write_bw_MBps:40960
> > 	/sys/devices/system/hmat/mem_tgt5/local_init/write_bw_MBps:40960
> > 
> > and look for the one that corresponds to your HBM speed. (These numbers are
> > made up, but you get the idea.)
> 
> Presumably ACPI-based platforms will not be the only ones who have the
> ability to expose different bandwidth memories in the future.  I think
> we need a platform-agnostic way ... right, PowerPC people?

Hey Matthew,

Yep, this is where I started as well.  My plan with my initial implementation
was to try and make the sysfs representation as platform agnostic as possible,
and just have the ACPI HMAT as one of the many places to gather the data
needed to populate sysfs.

However, as I began coding the implementation became very specific to the
HMAT, probably because I don't know of way that this type of info is
represented on another platform.  John Hubbard noticed the same thing and
asked me to s/HMEM/HMAT/ everywhere and just make it HMAT specific, and to
prevent it from being confused with the HMM work:

https://lkml.org/lkml/2017/7/7/33
https://lkml.org/lkml/2017/7/7/442

I'm open to making it more platform agnostic if I can get my hands on a
parallel effort in another platform and tease out the commonality, but trying
to do that without a second example hasn't worked out.  If we don't have a
good second example right now I think maybe we should put this in and then
merge it with the second example when it comes along.

> I don't know what the right interface is, but my laptop has a set of
> /sys/devices/system/memory/memoryN/ directories.  Perhaps this is the
> right place to expose write_bw (etc).
> 
> > Once you know the NUMA node of your HBM, you can figure out the NUMA node of
> > it's local initiator:
> > 
> > 	# ls -d /sys/devices/system/hmat/mem_tgt2/local_init/mem_init*
> > 	/sys/devices/system/hmat/mem_tgt2/local_init/mem_init0
> > 
> > So, in our made-up example our HBM is located in numa node 2, and the local
> > CPU for that HBM is at numa node 0.
> 
> initiator is a CPU?  I'd have expected you to expose a memory controller
> abstraction rather than re-use storage terminology.

Yea, I agree that at first blush it seems weird.  It turns out that looking at
it in sort of a storage initiator/target way is beneficial, though, because it
allows us to cut down on the number of data values we need to represent.

For example the SLIT, which doesn't differentiate between initiator and target
proximity domains (and thus nodes) always represents a system with N proximity
domains using a NxN distance table.  This makes sense if every node contains
both CPUs and memory.

With the introduction of the HMAT, though, we can have memory-only initiator
nodes and we can explicitly associate them with their local CPU.  This is
necessary so that we can separate memory with different performance
characteristics (HBM vs normal memory vs persistent memory, for example) that
are all attached to the same CPU.

So, say we now have a system with 4 CPUs, and each of those CPUs has 3
different types of memory attached to it.  We now have 16 total proximity
domains, 4 CPU and 12 memory.

If we represent this with the SLIT we end up with a 16 X 16 distance table
(256 entries), most of which don't matter because they are memory-to-memory
distances which don't make sense.

In the HMAT, though, we separate out the initiators and the targets and put
them into separate lists.  (See 5.2.27.4 System Locality Latency and Bandwidth
Information Structure in ACPI 6.2 for details.)  So, this same config in the
HMAT only has 4*12=48 performance values of each type, all of which convey
meaningful information.

The HMAT indeed even uses the storage "initiator" and "target" terminology. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
