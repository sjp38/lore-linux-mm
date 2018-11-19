Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1868E6B1B1D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:49:24 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y8so20744058pgq.12
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 07:49:24 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d9si37681148pgb.105.2018.11.19.07.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 07:49:22 -0800 (PST)
Date: Mon, 19 Nov 2018 08:46:05 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 2/7] node: Add heterogenous memory performance
Message-ID: <20181119154604.GC23062@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-3-keith.busch@intel.com>
 <91369e94-d389-7cb9-6274-f46c9ec779d3@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91369e94-d389-7cb9-6274-f46c9ec779d3@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Mon, Nov 19, 2018 at 09:05:07AM +0530, Anshuman Khandual wrote:
> On 11/15/2018 04:19 AM, Keith Busch wrote:
> > Heterogeneous memory systems provide memory nodes with latency
> > and bandwidth performance attributes that are different from other
> > nodes. Create an interface for the kernel to register these attributes
> 
> There are other properties like power consumption, reliability which can
> be associated with a particular PA range. Also the set of properties has
> to be extensible for the future.

Sure, I'm just starting with the attributes available from HMAT, 
If there are additional possible attributes that make sense to add, I
don't see why we can't continue appending them if this patch is okay.
 
> > under the node that provides the memory. If the system provides this
> > information, applications can query the node attributes when deciding
> > which node to request memory.
> 
> Right but each (memory initiator, memory target) should have these above
> mentioned properties enumerated to have an 'property as seen' from kind
> of semantics.
> 
> > 
> > When multiple memory initiators exist, accessing the same memory target
> > from each may not perform the same as the other. The highest performing
> > initiator to a given target is considered to be a local initiator for
> > that target. The kernel provides performance attributes only for the
> > local initiators.
> 
> As mentioned above the interface must enumerate a future extensible set
> of properties for each (memory initiator, memory target) pair available
> on the system.

That seems less friendly to use if forces the application to figure out
which CPU is the best for a given memory node rather than just provide
that answer directly.

> > The memory's compute node should be symlinked in sysfs as one of the
> > node's initiators.
> 
> Right. IIUC the first patch skips the linking process of for two nodes A
> and B if (A == B) preventing association to local memory initiator.

Right, CPUs and memory sharing a proximity domain are assumed to be
local to each other, so not going to set up those links to itself.
