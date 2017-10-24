Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6686B0253
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 03:19:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b6so16767591pff.18
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 00:19:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y128si6573036pfy.408.2017.10.24.00.19.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 00:19:10 -0700 (PDT)
Date: Tue, 24 Oct 2017 09:19:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171024071906.64ikc733x53zmgzu@dhcp22.suse.cz>
References: <20171023172008.kr6dzpe63nfpgps7@dhcp22.suse.cz>
 <20171023173544.GA12198@linux.intel.com>
 <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
 <20171023184852.GB12198@linux.intel.com>
 <20171023190459.odyu26rqhuja4trj@dhcp22.suse.cz>
 <20171023192524.GC12198@linux.intel.com>
 <20171023193536.c7yptc4tpesa4ffl@dhcp22.suse.cz>
 <20171023195637.GE12198@linux.intel.com>
 <0ed8144f-4447-e2de-47f7-ea1fc16f0b25@intel.com>
 <20171024010633.GA2723@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024010633.GA2723@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon 23-10-17 18:06:33, Sharath Kumar Bhat wrote:
> On Mon, Oct 23, 2017 at 02:52:04PM -0700, Dave Hansen wrote:
> > On 10/23/2017 12:56 PM, Sharath Kumar Bhat wrote:
> > >> I am sorry for being dense here but why cannot you mark that memory
> > >> hotplugable? I assume you are under the control to set attributes of the
> > >> memory to the guest.
> > > When I said two OS's I meant multi-kernel environment sharing the same
> > > hardware and not VMs. So we do not have the control to mark the memory
> > > hotpluggable as done by BIOS through SRAT.
> > 
> > If you are going as far as to pass in custom kernel command-line
> > arguments, there's a bunch of other fun stuff you can do.  ACPI table
> > overrides come to mind.

absolutely agreed!

> > > This facility can be used by platform/BIOS vendors to provide a Linux
> > > compatible environment without modifying the underlying platform firmware.
> > 
> > https://www.kernel.org/doc/Documentation/acpi/initrd_table_override.txt
> 
> I think ACPI table override won't be a generic solution to this problem and
> instead would be a platform/architecture dependent solution which may not
> be flexible for the users on different architectures.

Do you have any specific architecture in mind?

> And moreover
> 'movable_node' is implemented with an assumption to provide the entire
> hotpluggable memory as movable zone. This ACPI override would be against
> that assumption.

This is true and in fact movable_node should become movable_memory over
time and only ranges marked as movable would become really movable. This
is a rather non-trivial change to do and there is not a great demand for
the feature so it is low on my TODO list.

> Also ACPI override would introduce additional topology
> changes. Again this would have to change every time the total movable
> memory requirement changes and the whole system and apps have to be
> re-tuned (for job launch ex: numactl etc) to comphrehend this change.

This is something you have to do anyway when the topology of the system
changes each boot.

That being said, I would really prefer to actually _remove_ kernel_core
parameter altogether. It is messy (just look at find_zone_movable_pfns_for_nodes
at al.) and the original usecase it has been added for [1] does not hold
anymore. Adding more stuff to workaround issues which can be handled
more cleanly is definitely not a right way to go.

[1] note that MOVABLE_ZONE has been originally added to help the
fragmentation avoidance.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
