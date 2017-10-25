Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDB186B0253
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 20:53:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b79so19654998pfk.9
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 17:53:17 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q1si818306plb.368.2017.10.24.17.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 17:53:16 -0700 (PDT)
Date: Tue, 24 Oct 2017 17:53:14 -0700
From: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171025005314.GA2636@linux.intel.com>
Reply-To: sharath.k.bhat@linux.intel.com
References: <20171023173544.GA12198@linux.intel.com>
 <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
 <20171023184852.GB12198@linux.intel.com>
 <20171023190459.odyu26rqhuja4trj@dhcp22.suse.cz>
 <20171023192524.GC12198@linux.intel.com>
 <20171023193536.c7yptc4tpesa4ffl@dhcp22.suse.cz>
 <20171023195637.GE12198@linux.intel.com>
 <0ed8144f-4447-e2de-47f7-ea1fc16f0b25@intel.com>
 <20171024010633.GA2723@linux.intel.com>
 <20171024071906.64ikc733x53zmgzu@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024071906.64ikc733x53zmgzu@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Tue, Oct 24, 2017 at 09:19:06AM +0200, Michal Hocko wrote:
> On Mon 23-10-17 18:06:33, Sharath Kumar Bhat wrote:
> > On Mon, Oct 23, 2017 at 02:52:04PM -0700, Dave Hansen wrote:
> > > On 10/23/2017 12:56 PM, Sharath Kumar Bhat wrote:
> > > >> I am sorry for being dense here but why cannot you mark that memory
> > > >> hotplugable? I assume you are under the control to set attributes of the
> > > >> memory to the guest.
> > > > When I said two OS's I meant multi-kernel environment sharing the same
> > > > hardware and not VMs. So we do not have the control to mark the memory
> > > > hotpluggable as done by BIOS through SRAT.
> > > 
> > > If you are going as far as to pass in custom kernel command-line
> > > arguments, there's a bunch of other fun stuff you can do.  ACPI table
> > > overrides come to mind.
> 
> absolutely agreed!
> 
> > > > This facility can be used by platform/BIOS vendors to provide a Linux
> > > > compatible environment without modifying the underlying platform firmware.
> > > 
> > > https://www.kernel.org/doc/Documentation/acpi/initrd_table_override.txt
> > 
> > I think ACPI table override won't be a generic solution to this problem and
> > instead would be a platform/architecture dependent solution which may not
> > be flexible for the users on different architectures.
> 
> Do you have any specific architecture in mind?

There are no such restrictions related to architectures that we can run on
though we are currently testing on KNL, Xeon.

> 
> > And moreover
> > 'movable_node' is implemented with an assumption to provide the entire
> > hotpluggable memory as movable zone. This ACPI override would be against
> > that assumption.
> 
> This is true and in fact movable_node should become movable_memory over
> time and only ranges marked as movable would become really movable. This
> is a rather non-trivial change to do and there is not a great demand for
> the feature so it is low on my TODO list.

Do you mean to have a single kernel command-line 'movable_memory=' for this
purpose and remove all other kernel command-line parameters such as
'kernelcore=', 'movablecore=' and 'movable_node'? because after the kernel
boots up we can not gurantee that a contig memory range can be made zone
movable since any kernel allocations could pre-exist.

> 
> > Also ACPI override would introduce additional topology
> > changes. Again this would have to change every time the total movable
> > memory requirement changes and the whole system and apps have to be
> > re-tuned (for job launch ex: numactl etc) to comphrehend this change.
> 
> This is something you have to do anyway when the topology of the system
> changes each boot.

No, this is a manual tuning for job-launch, mem policy handling code etc.
which would be done once for a platform. But in this case based on the
application need the amount of movable memory will change so it is really
unfair to ask user to re-work their job launch and apps for every such
changes.

> 
> That being said, I would really prefer to actually _remove_ kernel_core
> parameter altogether. It is messy (just look at find_zone_movable_pfns_for_nodes
> at al.) and the original usecase it has been added for [1] does not hold
> anymore. Adding more stuff to workaround issues which can be handled
> more cleanly is definitely not a right way to go.

I agree that kernelcore handling is non-trivial in that function. But the
changes introduced by this patch are under 'movable_node' case handling in
find_zone_movable_pfns_for_nodes() and it does not cause any change to the
existing kernelcore behavior of the code. Also this enables all
multi-kernel users to make use of this functionality untill later when
new interface would be available for the same purpose.

> 
> [1] note that MOVABLE_ZONE has been originally added to help the
> fragmentation avoidance.

Isn't this true even now since ZONE_MOVABLE will populate only
MIGRATE_MOVABLE free list of pages? and other zones could have
MIGRATE_UNMOVABLE pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
