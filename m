Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C95D56B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 15:35:51 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y2so11347250pgv.8
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 12:35:51 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l19si8985848pgn.98.2017.12.18.12.35.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 12:35:50 -0800 (PST)
Date: Mon, 18 Dec 2017 13:35:47 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
Message-ID: <20171218203547.GA2366@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <20171214130032.GK16951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214130032.GK16951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org

On Thu, Dec 14, 2017 at 02:00:32PM +0100, Michal Hocko wrote:
> [CC linix-api]

Oh, thanks.  I'll add them to my CC list for sysfs related changes in the
future.

> On Wed 13-12-17 19:10:16, Ross Zwisler wrote:
> > This is the third revision of my patches adding a sysfs representation
> > of the ACPI Heterogeneous Memory Attribute Table (HMAT).  These patches
> > are based on v4.15-rc3 and a working tree can be found here:
> > 
> > https://git.kernel.org/pub/scm/linux/kernel/git/zwisler/linux.git/log/?h=hmat_v3
> > 
> > My goal is to get these patches merged for v4.16.
> 
> Has actually reviewed the overal design already for this to be 4.16
> thing? I do not see any acks/reviewed-bys in any of the patches...
> 
> > Changes from previous version (https://lkml.org/lkml/2017/7/6/749):
> 
> ... comments on this last posting are touching the surface rather than
> really discuss the overal design.

Yep, that's a fair assessment.  I would love a more in-depth review of the
code so far. :)

What I'm hoping to do with this series is to just provide a sysfs
representation of the HMAT so that applications can know which NUMA nodes to
select with existing utilities like numactl.  This series does not currently
alter any kernel behavior, it only provides a sysfs interface.

Say for example you had a system with some high bandwidth memory (HBM), and
you wanted to use it for a specific application.  You could use the sysfs
representation of the HMAT to figure out which memory target held your HBM.
You could do this by looking at the local bandwidth values for the various
memory targets, so:

	# grep . /sys/devices/system/hmat/mem_tgt*/local_init/write_bw_MBps
	/sys/devices/system/hmat/mem_tgt2/local_init/write_bw_MBps:81920
	/sys/devices/system/hmat/mem_tgt3/local_init/write_bw_MBps:40960
	/sys/devices/system/hmat/mem_tgt4/local_init/write_bw_MBps:40960
	/sys/devices/system/hmat/mem_tgt5/local_init/write_bw_MBps:40960

and look for the one that corresponds to your HBM speed. (These numbers are
made up, but you get the idea.)

Alternatively if you knew the physical addresses of your HBM you could look
for it by finding the numa node that owns the appropriate memory sections, so:

	# ls -d /sys/devices/system/hmat/mem_tgt2/node2/memory*
	/sys/devices/system/hmat/mem_tgt2/node2/memory0
	/sys/devices/system/hmat/mem_tgt2/node2/memory1
etc.

Once you know the NUMA node of your HBM, you can figure out the NUMA node of
it's local initiator:

	# ls -d /sys/devices/system/hmat/mem_tgt2/local_init/mem_init*
	/sys/devices/system/hmat/mem_tgt2/local_init/mem_init0

So, in our made-up example our HBM is located in numa node 2, and the local
CPU for that HBM is at numa node 0.

You would then use numactl to bind your app to those numa nodes:

	numactl --membind=2 --cpunodebind=0 ./my_application

Does that make sense?

Eventually we can enhance numactl so it can automatically choose memory with
higher bandwidth, etc., but I think just this bit of kernel enabling gets us
started in the right direction.

> >  - Changed "HMEM" to "HMAT" and "hmem" to "hmat" throughout to make sure
> >    that this effort doesn't get confused with Jerome's HMM work and to
> >    make it clear that this enabling is tightly tied to the ACPI HMAT
> >    table.  (John Hubbard)
> > 
> >  - Moved the link in the initiator (i.e. mem_init0/mem_tgt2) from
> >    pointing to the "mem_tgt2/local_init" attribute group to instead
> >    point at the mem_tgt2 target itself.  (Brice Goglin)
> > 
> >  - Simplified the contents of both the initiators and the targets so
> >    that we just symlink to the NUMA node and don't duplicate
> >    information.  For initiators this means that we no longer enumerate
> >    CPUs, and for targets this means that we don't provide physical
> >    address start and length information.  All of this is already
> >    available in the NUMA node directory itself (i.e.
> >    /sys/devices/system/node/node0), and it already accounts for the fact
> >    that both multiple CPUs and multiple memory regions can be owned by a
> >    given NUMA node.  Also removed some extra attributes (is_enabled,
> >    is_isolated) which I don't think are useful at this point in time.
> > 
> > I have tested this against many different configs that I implemented
> > using qemu.
> 
> What is the testing procedure? How can I setup qemu to simlate such HW?

Well, the QEMU table simulation is gross, so I'd rather not get everyone
testing with that.  Injecting custom HMAT and SRAT tables via initrd/initramfs
is a much better way:

https://www.kernel.org/doc/Documentation/acpi/initrd_table_override.txt

Dan recently posted a patch that lets this happen for the HMAT:

https://lists.01.org/pipermail/linux-nvdimm/2017-December/013545.html

I'm working right now on getting an easier way to generate HMAT tables - I'll
let you know when I have something working.

> [Keeping the rest of the email for linux-api reference]
> 
> > ---
> > 
> > ==== Quick Summary ====
> > 
> > Platforms exist today which have multiple types of memory attached to a
> > single CPU.  These disparate memory ranges have some characteristics in
> > common, such as CPU cache coherence, but they can have wide ranges of
> > performance both in terms of latency and bandwidth.
> > 
> > For example, consider a system that contains persistent memory, standard
> > DDR memory and High Bandwidth Memory (HBM), all attached to the same CPU.
> > There could potentially be an order of magnitude or more difference in
> > performance between the slowest and fastest memory attached to that CPU.
> > 
> > With the current Linux code NUMA nodes are CPU-centric, so all the memory
> > attached to a given CPU will be lumped into the same NUMA node.  This makes
> > it very difficult for userspace applications to understand the performance
> > of different memory ranges on a given CPU.
> > 
> > We solve this issue by providing userspace with performance information on
> > individual memory ranges.  This performance information is exposed via
> > sysfs:
> > 
> >   # grep . mem_tgt2/* mem_tgt2/local_init/* 2>/dev/null
> >   mem_tgt2/firmware_id:1
> >   mem_tgt2/is_cached:0
> >   mem_tgt2/local_init/read_bw_MBps:40960
> >   mem_tgt2/local_init/read_lat_nsec:50
> >   mem_tgt2/local_init/write_bw_MBps:40960
> >   mem_tgt2/local_init/write_lat_nsec:50
> > 
> > This allows applications to easily find the memory that they want to use.
> > We expect that the existing NUMA APIs will be enhanced to use this new
> > information so that applications can continue to use them to select their
> > desired memory.
> 
> How? Could you provide some examples?

I think I answered this above, but please let me know if you still have
questions or have any ideas for improvement.

Thank you for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
