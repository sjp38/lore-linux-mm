Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC2C6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:18:38 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j9-v6so27750468plt.3
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:18:38 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id m16-v6si35901816pgd.48.2018.10.22.13.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 13:18:36 -0700 (PDT)
Subject: [PATCH 0/9] Allow persistent memory to be used like normal RAM
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 22 Oct 2018 13:13:17 -0700
Message-Id: <20181022201317.8558C1D8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com

Persistent memory is cool.  But, currently, you have to rewrite
your applications to use it.  Wouldn't it be cool if you could
just have it show up in your system like normal RAM and get to
it like a slow blob of memory?  Well... have I got the patch
series for you!

This series adds a new "driver" to which pmem devices can be
attached.  Once attached, the memory "owned" by the device is
hot-added to the kernel and managed like any other memory.  On
systems with an HMAT (a new ACPI table), each socket (roughly)
will have a separate NUMA node for its persistent memory so
this newly-added memory can be selected by its unique NUMA
node.

This is highly RFC, and I really want the feedback from the
nvdimm/pmem folks about whether this is a viable long-term
perversion of their code and device mode.  It's insufficiently
documented and probably not bisectable either.

Todo:
1. The device re-binding hacks are ham-fisted at best.  We
   need a better way of doing this, especially so the kmem
   driver does not get in the way of normal pmem devices.
2. When the device has no proper node, we default it to
   NUMA node 0.  Is that OK?
3. We muck with the 'struct resource' code quite a bit. It
   definitely needs a once-over from folks more familiar
   with it than I.
4. Is there a better way to do this than starting with a
   copy of pmem.c?

Here's how I set up a system to test this thing:

1. Boot qemu with lots of memory: "-m 4096", for instance
2. Reserve 512MB of physical memory.  Reserving a spot a 2GB
   physical seems to work: memmap=512M!0x0000000080000000
   This will end up looking like a pmem device at boot.
3. When booted, convert fsdax device to "device dax":
	ndctl create-namespace -fe namespace0.0 -m dax
4. In the background, the kmem driver will probably bind to the
   new device.
5. Now, online the new memory sections.  Perhaps:

grep ^MemTotal /proc/meminfo
for f in `grep -vl online /sys/devices/system/memory/*/state`; do
	echo $f: `cat $f`
	echo online > $f
	grep ^MemTotal /proc/meminfo
done

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
