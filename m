Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 426726B0006
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 04:52:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k18-v6so12399157wrn.8
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 01:52:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t46-v6si1224864edm.33.2018.06.11.01.52.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jun 2018 01:52:41 -0700 (PDT)
Date: Mon, 11 Jun 2018 10:52:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
Message-ID: <20180611085237.GI13364@dhcp22.suse.cz>
References: <1527768879-88161-1-git-send-email-xiexiuqi@huawei.com>
 <1527768879-88161-2-git-send-email-xiexiuqi@huawei.com>
 <20180606154516.GL6631@arm.com>
 <CAErSpo6S0qtR42tjGZrFu4aMFFyThx1hkHTSowTt6t3XerpHnA@mail.gmail.com>
 <20180607105514.GA13139@dhcp22.suse.cz>
 <5ed798a0-6c9c-086e-e5e8-906f593ca33e@huawei.com>
 <20180607122152.GP32433@dhcp22.suse.cz>
 <a880df29-b656-d98d-3037-b04761c7ed78@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a880df29-b656-d98d-3037-b04761c7ed78@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: Hanjun Guo <guohanjun@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, wanghuiqiang@huawei.com, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, zhongjiang <zhongjiang@huawei.com>

On Mon 11-06-18 11:23:18, Xie XiuQi wrote:
> Hi Michal,
> 
> On 2018/6/7 20:21, Michal Hocko wrote:
> > On Thu 07-06-18 19:55:53, Hanjun Guo wrote:
> >> On 2018/6/7 18:55, Michal Hocko wrote:
> > [...]
> >>> I am not sure I have the full context but pci_acpi_scan_root calls
> >>> kzalloc_node(sizeof(*info), GFP_KERNEL, node)
> >>> and that should fall back to whatever node that is online. Offline node
> >>> shouldn't keep any pages behind. So there must be something else going
> >>> on here and the patch is not the right way to handle it. What does
> >>> faddr2line __alloc_pages_nodemask+0xf0 tells on this kernel?
> >>
> >> The whole context is:
> >>
> >> The system is booted with a NUMA node has no memory attaching to it
> >> (memory-less NUMA node), also with NR_CPUS less than CPUs presented
> >> in MADT, so CPUs on this memory-less node are not brought up, and
> >> this NUMA node will not be online (but SRAT presents this NUMA node);
> >>
> >> Devices attaching to this NUMA node such as PCI host bridge still
> >> return the valid NUMA node via _PXM, but actually that valid NUMA node
> >> is not online which lead to this issue.
> > 
> > But we should have other numa nodes on the zonelists so the allocator
> > should fall back to other node. If the zonelist is not intiailized
> > properly, though, then this can indeed show up as a problem. Knowing
> > which exact place has blown up would help get a better picture...
> > 
> 
> I specific a non-exist node to allocate memory using kzalloc_node,
> and got this following error message.
>
> And I found out there is just a VM_WARN, but it does not prevent the memory
> allocation continue.
> 
> This nid would be use to access NODE_DADA(nid), so if nid is invalid,
> it would cause oops here.
> 
> 459 /*
> 460  * Allocate pages, preferring the node given as nid. The node must be valid and
> 461  * online. For more general interface, see alloc_pages_node().
> 462  */
> 463 static inline struct page *
> 464 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
> 465 {
> 466         VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> 467         VM_WARN_ON(!node_online(nid));
> 468
> 469         return __alloc_pages(gfp_mask, order, nid);
> 470 }
> 471
> 
> (I wrote a ko, to allocate memory on a non-exist node using kzalloc_node().)

OK, so this is an artificialy broken code, right. You shouldn't get a
non-existent node via standard APIs AFAICS. The original report was
about an existing node which is offline AFAIU. That would be a different
case. If I am missing something and there are legitimate users that try
to allocate from non-existing nodes then we should handle that in
node_zonelist.

[...]
-- 
Michal Hocko
SUSE Labs
