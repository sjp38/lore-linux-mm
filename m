Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 402356B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 08:21:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id j18-v6so4553097wme.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 05:21:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5-v6si254265edi.160.2018.06.07.05.21.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 05:21:53 -0700 (PDT)
Date: Thu, 7 Jun 2018 14:21:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
Message-ID: <20180607122152.GP32433@dhcp22.suse.cz>
References: <1527768879-88161-1-git-send-email-xiexiuqi@huawei.com>
 <1527768879-88161-2-git-send-email-xiexiuqi@huawei.com>
 <20180606154516.GL6631@arm.com>
 <CAErSpo6S0qtR42tjGZrFu4aMFFyThx1hkHTSowTt6t3XerpHnA@mail.gmail.com>
 <20180607105514.GA13139@dhcp22.suse.cz>
 <5ed798a0-6c9c-086e-e5e8-906f593ca33e@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ed798a0-6c9c-086e-e5e8-906f593ca33e@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Will Deacon <will.deacon@arm.com>, xiexiuqi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, wanghuiqiang@huawei.com, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 07-06-18 19:55:53, Hanjun Guo wrote:
> On 2018/6/7 18:55, Michal Hocko wrote:
[...]
> > I am not sure I have the full context but pci_acpi_scan_root calls
> > kzalloc_node(sizeof(*info), GFP_KERNEL, node)
> > and that should fall back to whatever node that is online. Offline node
> > shouldn't keep any pages behind. So there must be something else going
> > on here and the patch is not the right way to handle it. What does
> > faddr2line __alloc_pages_nodemask+0xf0 tells on this kernel?
> 
> The whole context is:
> 
> The system is booted with a NUMA node has no memory attaching to it
> (memory-less NUMA node), also with NR_CPUS less than CPUs presented
> in MADT, so CPUs on this memory-less node are not brought up, and
> this NUMA node will not be online (but SRAT presents this NUMA node);
> 
> Devices attaching to this NUMA node such as PCI host bridge still
> return the valid NUMA node via _PXM, but actually that valid NUMA node
> is not online which lead to this issue.

But we should have other numa nodes on the zonelists so the allocator
should fall back to other node. If the zonelist is not intiailized
properly, though, then this can indeed show up as a problem. Knowing
which exact place has blown up would help get a better picture...

-- 
Michal Hocko
SUSE Labs
