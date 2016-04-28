Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA8356B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 14:58:10 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x7so208392681qkd.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:58:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q205si5651289qhq.67.2016.04.28.11.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 11:58:09 -0700 (PDT)
Date: Thu, 28 Apr 2016 12:58:08 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160428125808.29ad59e5@t450s.home>
In-Reply-To: <20160428181726.GA2847@node.shutemov.name>
References: <20160428102051.17d1c728@t450s.home>
	<20160428181726.GA2847@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kirill.shutemov@linux.intel.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 28 Apr 2016 21:17:26 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Thu, Apr 28, 2016 at 10:20:51AM -0600, Alex Williamson wrote:
> > Hi,
> > 
> > vfio-based device assignment makes use of get_user_pages_fast() in order
> > to pin pages for mapping through the iommu for userspace drivers.
> > Until the recent redesign of THP reference counting in the v4.5 kernel,
> > this all worked well.  Now we're seeing cases where a sanity test
> > before we release our "pinned" mapping results in a different page
> > address than what we programmed into the iommu.  So something is
> > occurring which pretty much negates the pinning we're trying to do.
> > 
> > The test program I'm using is here:
> > 
> > https://github.com/awilliam/tests/blob/master/vfio-iommu-map-unmap.c
> > 
> > Apologies for lack of makefile, simply build with gcc -o <out> <in.c>.
> > 
> > To run this, enable the IOMMU on your system - enable in BIOS plus add
> > intel_iommu=on to the kernel commandline (only Intel x86_64 tested).
> > 
> > Pick a target PCI device, it doesn't matter what it is, the test only
> > needs a device for the purpose of creating an iommu domain, the device
> > is never actually touched.  In my case I use a spare NIC at 00:19.0.
> > libvirt tools are useful for setting this up, simply run 'virsh
> > nodedev-detach pci_0000_00_19_0'.  Otherwise bind the device manually
> > to vfio-pci using the standard new_id bind (ask, I can provide
> > instructions).
> > 
> > I also tweak THP scanning to make sure it is actively trying to
> > collapse pages:
> > 
> > echo always > /sys/kernel/mm/transparent_hugepage/defrag
> > echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
> > echo 65536 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
> > 
> > Run the test with 'vfio-iommu-map-unmap 0000:00:19.0', or your chosen
> > target device.
> > 
> > Of course to see that the mappings are moving, we need additional
> > sanity testing in the vfio iommu driver.  For that:
> > 
> > https://github.com/awilliam/linux-vfio/commit/379f324e3629349a7486018ad1cc5d4877228d1e
> > 
> > When we map memory for vfio, we use get_user_pages_fast() on the
> > process vaddr to give us a page.  page_to_pfn() then gives us the
> > physical memory address which we program into the iommu.  Obviously we
> > expect this mapping to be stable so long as we hold the page
> > reference.  On unmap we generally retrieve the physical memory address
> > from the iommu, convert it back to a page, and release our reference to
> > it.  The debug code above adds an additional sanity test where on unmap
> > we also call get_user_pages_fast() again before we're released the
> > mapping reference and compare whether the physical page address still
> > matches what we previously stored in the iommu.  On a v4.4 kernel this
> > works every time.  On v4.5+, we get mismatches in dmesg within a few
> > lines of output from the test program.
> > 
> > It's difficult to bisect around the THP reference counting redesign
> > since THP becomes disabled for much of it.  I have discovered that this
> > commit is a significant contributor:
> > 
> > 1f25fe2 mm, thp: adjust conditions when we can reuse the page on WP fault
> > 
> > Particularly the middle chunk in huge_memory.c.  Reverting this change
> > alone significantly improves the problem, but does not lead to a stable
> > system.
> > 
> > I'm not an mm expert, so I'm looking for help debugging this.  As shown
> > above this issue is reproducible without KVM, so Andrea's previous KVM
> > specific fix to this code is not applicable.  It also still occurs on
> > kernels as recent as v4.6-rc5, so the issue hasn't been silently fixed
> > yet.  I'm able to reproduce this fairly quickly with the above test,
> > but it's not hard to imagine a test w/o any iommu dependencies which
> > simply does a user directed get_user_pages_fast() on a set of userspace
> > addresses, retains the reference, and at some point later rechecks that
> > a new get_user_pages_fast() results in the same page address.  It
> > appears that any sort of device assignment, either vfio or legacy kvm,
> > should be susceptible to this issue and therefore unsafe to use on v4.5+
> > kernels without using explicit hugepages or disabling THP.  Thanks,  
> 
> I'm not able to reproduce it so far. How long does it usually take?

Generally within the first line of output from the test program.
 
> How much memory your system has? Could you share your kernel config?

24G, dual-socket Ivy Brdige EP.

Config:
https://paste.fedoraproject.org/360803/14618689/
 
> I've modified your instrumentation slightly to provide more info.
> Could you try this:

Thanks!  Results in:

[   83.429809] page:ffffea0010e57fc0 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.439696] flags: 0x2fffff80000000()
[   83.443408] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.454001] flags: 0x2fffff80044048(uptodate|active|head|swapbacked)
[   83.460456] page:ffffea0018a67fc0 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.470298] flags: 0x6fffff80000000()
[   83.473973] page dumped because: 1
[   83.477412] page:ffffea0010e57f80 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.487283] flags: 0x2fffff80000000()
[   83.490969] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.501502] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.508915] page:ffffea0018a67f80 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.518758] flags: 0x6fffff80000000()
[   83.522443] page dumped because: 1
[   83.525874] page:ffffea0010e57f40 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.535737] flags: 0x2fffff80000000()
[   83.539434] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.549979] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.557412] page:ffffea0018a67f40 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.567260] flags: 0x6fffff80000000()
[   83.570943] page dumped because: 1
[   83.574366] page:ffffea0010e57f00 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.584211] flags: 0x2fffff80000000()
[   83.587878] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.598413] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.605862] page:ffffea0018a67f00 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.615722] flags: 0x6fffff80000000()
[   83.619399] page dumped because: 1
[   83.622835] page:ffffea0010e57ec0 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.632673] flags: 0x2fffff80000000()
[   83.636363] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.646893] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.654302] page:ffffea0018a67ec0 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.664150] flags: 0x6fffff80000000()
[   83.667840] page dumped because: 1
[   83.671255] page:ffffea0010e57e80 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.681108] flags: 0x2fffff80000000()
[   83.684783] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.695335] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.702773] page:ffffea0018a67e80 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.712640] flags: 0x6fffff80000000()
[   83.716335] page dumped because: 1
[   83.719746] page:ffffea0010e57e40 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.729591] flags: 0x2fffff80000000()
[   83.733279] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.743843] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.751268] page:ffffea0018a67e40 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.761108] flags: 0x6fffff80000000()
[   83.764784] page dumped because: 1
[   83.768206] page:ffffea0010e57e00 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.778076] flags: 0x2fffff80000000()
[   83.781754] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.792283] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.799712] page:ffffea0018a67e00 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.809559] flags: 0x6fffff80000000()
[   83.813257] page dumped because: 1
[   83.816722] page:ffffea0010e57dc0 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.826605] flags: 0x2fffff80000000()
[   83.830285] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.840877] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.848321] page:ffffea0018a67dc0 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.858214] flags: 0x6fffff80000000()
[   83.861899] page dumped because: 1
[   83.865355] page:ffffea0010e57d80 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.875246] flags: 0x2fffff80000000()
[   83.878930] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.889525] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.896970] page:ffffea0018a67d80 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.906883] flags: 0x6fffff80000000()
[   83.910563] page dumped because: 1
[   83.914018] page:ffffea0010e57d40 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.923862] flags: 0x2fffff80000000()
[   83.927540] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.938079] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.945493] page:ffffea0018a67d40 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   83.955341] flags: 0x6fffff80000000()
[   83.959022] page dumped because: 1
[   83.962446] page:ffffea0010e57d00 count:0 mapcount:1 mapping:dead000000000400 index:0x1 compound_mapcount: 1
[   83.972296] flags: 0x2fffff80000000()
[   83.975980] page:ffffea0010e50000 count:3 mapcount:1 mapping:ffff88044c0fa8a1 index:0x7f8ae1400 compound_mapcount: 1
[   83.986516] flags: 0x2fffff8004404c(referenced|uptodate|active|head|swapbacked)
[   83.993932] page:ffffea0018a67d00 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[   84.003778] flags: 0x6fffff80000000()
[   84.007456] page dumped because: 1
...

As you can see by the kernel timestamp, this happened almost
immediately for me.  Thanks for taking a look at this,

Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
