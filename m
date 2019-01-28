Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCA498E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:31:39 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w4so6107899otj.2
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 03:31:39 -0800 (PST)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id w13si4820560oiw.238.2019.01.28.03.31.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 03:31:35 -0800 (PST)
Date: Mon, 28 Jan 2019 11:31:08 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [PATCH V2] x86: Fix an issue with invalid ACPI NUMA config
Message-ID: <20190128112904.0000461a@huawei.com>
In-Reply-To: <20181220195714.GE183878@google.com>
References: <20181211094737.71554-1-Jonathan.Cameron@huawei.com>
	<a5a938d3-ecc9-028a-3b28-610feda8f3f8@intel.com>
	<20181212093914.00002aed@huawei.com>
	<20181220151225.GB183878@google.com>
	<65f5bb93-b6be-d6dd-6976-e2761f6f2a7b@intel.com>
	<20181220195714.GE183878@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-pci@vger.kernel.org, x86@kernel.org, linuxarm@huawei.com, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, martin@geanix.com, Linux Memory Management List <linux-mm@kvack.org>, ACPI Devel   Maling List <linux-acpi@vger.kernel.org>

On Thu, 20 Dec 2018 13:57:14 -0600
Bjorn Helgaas <helgaas@kernel.org> wrote:

> On Thu, Dec 20, 2018 at 09:13:12AM -0800, Dave Hansen wrote:
> > On 12/20/18 7:12 AM, Bjorn Helgaas wrote:  
> > >> Other than the error we might be able to use acpi_map_pxm_to_online_node
> > >> for this, or call both acpi_map_pxm_to_node and acpi_map_pxm_to_online_node
> > >> and compare the answers to verify we are getting the node we want?  
> > > Where are we at with this?  It'd be nice to resolve it for v4.21, but
> > > it's a little out of my comfort zone, so I don't want to apply it
> > > unless there's clear consensus that this is the right fix.  
> > 
> > I still think the fix in this patch sweeps the problem under the rug too
> > much.  But, it just might be the best single fix for backports, for
> > instance.  
> 
> Sounds like we should first find the best fix, then worry about how to
> backport it.  So I think we have a little more noodling to do, and
> I'll defer this for now.
> 
> Bjorn

Hi All,

I'd definitely appreciate some guidance on what the 'right' fix is.
We are starting to get real performance issues reported as a result of not
being able to use this patch on mainline.

5-10% performance drop on some networking benchmarks.

As a brief summary (having added linux-mm / linux-acpi) the issue is:

1) ACPI allows _PXM to be applied to pci devices (including root ports for
   example, but any device is fine).
2) Due to the ordering of when the fw node was set for PCI devices this wasn't
   taking effect. Easy to solve by just adding the numa node if provided in
   pci_acpi_setup (which is late enough)
3) A patch to fix that was applied to the PCIe tree
  https://patchwork.kernel.org/patch/10597777/
   but we got non booting regressions on some threadripper platforms.
   That turned out to be because they don't have SRAT, but do have PXM entries.
  (i.e. broken firmware).  Naturally Bjorn reverted this very quickly!

I proposed this fix which was to do the same as on Arm and clearly mark numa as
off when SRAT isn't present on an ACPI system.
https://elixir.bootlin.com/linux/latest/source/arch/arm64/mm/numa.c#L460
https://elixir.bootlin.com/linux/latest/source/arch/x86/mm/numa.c#L688

Dave's response was that we needed to fix the underlying issue of trying to
allocate from non existent NUMA nodes.

Whilst I agree with that in principle (having managed to provide tables doing
exactly that during development a few times!), I'm not sure the path to doing so is
clear and so this has been stalled for a few months.  There is to my mind
still a strong argument, even with such protection in place, that we
should still be short cutting it so that you get the same paths if you deliberately
disable numa, and if you have no SRAT and hence can't have NUMA.

So given I have some 'mild for now' screaming going on, I'd definitely
appreciate input on how to move forward!

There are lots of places this could be worked around, e.g. we could sanity
check in the acpi_get_pxm call.  I'm not sure what side effects that would have
and also what cases it wouldn't cover.

Thanks,

Jonathan
