Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBB576B0005
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 01:11:43 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d12-v6so15892043qtj.2
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 22:11:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7-v6sor30058057qtp.59.2018.10.30.22.11.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Oct 2018 22:11:42 -0700 (PDT)
MIME-Version: 1.0
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 30 Oct 2018 22:11:30 -0700
Message-ID: <CAHbLzkqhX-=Zs=XdR4crHYBHOdgR1zsAL+o3b8YUfe+7PB7PPw@mail.gmail.com>
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, Linux MM <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, fengguang.wu@intel.com

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

Could you please elaborate this? I'm supposed you mean the pmem will
be a separate NUMA node, right?

I would like to try the patches on real hardware, any prerequisite is needed?

Thanks,
Yang

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
>
> Here's how I set up a system to test this thing:
>
> 1. Boot qemu with lots of memory: "-m 4096", for instance
> 2. Reserve 512MB of physical memory.  Reserving a spot a 2GB
>    physical seems to work: memmap=512M!0x0000000080000000
>    This will end up looking like a pmem device at boot.
> 3. When booted, convert fsdax device to "device dax":
>         ndctl create-namespace -fe namespace0.0 -m dax
> 4. In the background, the kmem driver will probably bind to the
>    new device.
> 5. Now, online the new memory sections.  Perhaps:
>
> grep ^MemTotal /proc/meminfo
> for f in `grep -vl online /sys/devices/system/memory/*/state`; do
>         echo $f: `cat $f`
>         echo online > $f
>         grep ^MemTotal /proc/meminfo
> done
>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-nvdimm@lists.01.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
>
