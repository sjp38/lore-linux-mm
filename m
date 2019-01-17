Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4E948E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 14:49:05 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r16so6811516pgr.15
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:49:05 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id t64si2495897pgd.202.2019.01.17.11.49.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 11:49:04 -0800 (PST)
Date: Thu, 17 Jan 2019 12:47:51 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv4 00/13] Heterogeneuos memory node attributes
Message-ID: <20190117194751.GE31543@localhost.localdomain>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190117181835.000034ab@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190117181835.000034ab@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "linuxarm@huawei.com" <linuxarm@huawei.com>

On Thu, Jan 17, 2019 at 10:18:35AM -0800, Jonathan Cameron wrote:
> I've been having a play with various hand constructed HMAT tables to allow
> me to try breaking them in all sorts of ways.
> 
> Mostly working as expected.
> 
> Two places I am so far unsure on...
> 
> 1. Concept of 'best' is not implemented in a consistent fashion.
> 
> I don't agree with the logic to match on 'best' because it can give some counter
> intuitive sets of target nodes.
> 
> For my simple test case we have both the latency and bandwidth specified (using
> access as I'm lazy and it saves typing).
> 
> Rather that matching when both are the best value, we match when _any_ of the
> measurements is the 'best' for the type of measurement.
> 
> A simple system with a high bandwidth interconnect between two SoCs
> might well have identical bandwidths to memory connected to each node, but
> much worse latency to the remote one.  Another simple case would be DDR and
> SCM on roughly the same memory controller.  Bandwidths likely to be equal,
> latencies very different.
> 
> Right now we get both nodes in the list of 'best' ones because the bandwidths
> are equal which is far from ideal.  It also means we are presenting one value
> for both latency and bandwidth, misrepresenting the ones where it doesn't apply.
> 
> If we aren't going to specify that both must be "best", then I think we should
> separate the bandwidth and latency classes, requiring userspace to check
> both if they want the best combination of latency and bandwidth. I'm also
> happy enough (having not thought about it much) to have one class where the 'best'
> is the value sorted first on best latency and then on best bandwidth.

Okay, I see what you mean. I must admit my test environment doesn't have
nodes with the same bandwith but different latency, so we may get the
wrong information with the HMAT parsing in this series. I'll look into
fixing that and consider your sugggestions.
 
> 2. Handling of memory only nodes - that might have a device attached - _PXM
> 
> This is a common situation in CCIX for example where you have an accelerator
> with coherent memory homed at it. Looks like a pci device in a domain with
> the memory.   Right now you can't actually do this as _PXM is processed
> for pci devices, but we'll get that fixed (broken threadripper firmwares
> meant it got reverted last cycle).
> 
> In my case I have 4 nodes with cpu and memory (0,1,2,3) and 2 memory only (4,5)
> Memory only are longer latency and lower bandwidth.
> 
> Now
> ls /sys/bus/nodes/devices/node0/class0/
> ...
> 
> initiator0
> target0
> target4
> target5
> 
> read_bandwidth = 15000
> read_latency = 10000
> 
> These two values (and their paired write values) are correct for initiator0 to target0
> but completely wrong for initiator0 to target4 or target5.

Hm, this wasn't intended to tell us performance for the initiator's
targets. The performance data here is when you access node0's memory
target from a node in its initiator_list, or one of the simlinked
initiatorX's.

If you want to see the performance attributes for accessing
initiator0->target4, you can check:

  /sys/devices/system/node/node0/class0/target4/class0/read_bandwidth

> This occurs because we loop over the targets looking for the best values and add
> set the relevant bit in t->p_nodes based on that.  These memory only nodes have
> a best value that happens to be equal from all the initiators.  The issue is it
> isn't the one reported in the node0/class0.
>
> Also if we look in
> /sys/bus/nodes/devices/node4/class0 there are no targets listed (there are the expected
> 4 initiators 0-3).
> 
> I'm not sure what the intended behavior would be in this case.

You mentioned that node 4 is a memory-only node, so it can't have any
targets, right?
