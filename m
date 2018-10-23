Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 49EB46B000D
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 21:05:24 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x30so22100120ota.7
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 18:05:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i203-v6sor366564oia.24.2018.10.22.18.05.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 18:05:23 -0700 (PDT)
MIME-Version: 1.0
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 Oct 2018 18:05:11 -0700
Message-ID: <CAPcyv4hxs-GnmwQU1wPZyg5aydCY5K09-YpSrrLpvU1v_8dbBw@mail.gmail.com>
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, Vishal L Verma <vishal.l.verma@intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, "Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, Oct 22, 2018 at 1:18 PM Dave Hansen <dave.hansen@linux.intel.com> wrote:
>
> Persistent memory is cool.  But, currently, you have to rewrite
> your applications to use it.  Wouldn't it be cool if you could
> just have it show up in your system like normal RAM and get to
> it like a slow blob of memory?  Well... have I got the patch
> series for you!
>
> This series adds a new "driver" to which pmem devices can be
> attached.  Once attached, the memory "owned" by the device is
> hot-added to the kernel and managed like any other memory.  On
> systems with an HMAT (a new ACPI table), each socket (roughly)
> will have a separate NUMA node for its persistent memory so
> this newly-added memory can be selected by its unique NUMA
> node.
>
> This is highly RFC, and I really want the feedback from the
> nvdimm/pmem folks about whether this is a viable long-term
> perversion of their code and device mode.  It's insufficiently
> documented and probably not bisectable either.
>
> Todo:
> 1. The device re-binding hacks are ham-fisted at best.  We
>    need a better way of doing this, especially so the kmem
>    driver does not get in the way of normal pmem devices.
> 2. When the device has no proper node, we default it to
>    NUMA node 0.  Is that OK?
> 3. We muck with the 'struct resource' code quite a bit. It
>    definitely needs a once-over from folks more familiar
>    with it than I.
> 4. Is there a better way to do this than starting with a
>    copy of pmem.c?

So I don't think we want to do patch 2, 3, or 5. Just jump to patch 7
and remove all the devm_memremap_pages() infrastructure and dax_region
infrastructure.

The driver should be a dead simple turn around to call add_memory()
for the passed in range. The hard part is, as you say, arranging for
the kmem driver to not stand in the way of typical range / device
claims by the dax_pmem device.

To me this looks like teaching the nvdimm-bus and this dax_kmem driver
to require explicit matching based on 'id'. The attachment scheme
would look like this:

modprobe dax_kmem
echo dax0.0 > /sys/bus/nd/drivers/dax_kmem/new_id
echo dax0.0 > /sys/bus/nd/drivers/dax_pmem/unbind
echo dax0.0 > /sys/bus/nd/drivers/dax_kmem/bind

At step1 the dax_kmem drivers will match no devices and stays out of
the way of dax_pmem. It learns about devices it cares about by being
explicitly told about them. Then unbind from the typical dax_pmem
driver and attach to dax_kmem to perform the one way hotplug.

I expect udev can automate this by setting up a rule to watch for
device-dax instances by UUID and call a script to do the detach /
reattach dance.
