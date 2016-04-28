Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C750D6B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 12:20:54 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a66so176528930qkg.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:20:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p64si5255556qkc.92.2016.04.28.09.20.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 09:20:53 -0700 (PDT)
Date: Thu, 28 Apr 2016 10:20:51 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160428102051.17d1c728@t450s.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

vfio-based device assignment makes use of get_user_pages_fast() in order
to pin pages for mapping through the iommu for userspace drivers.
Until the recent redesign of THP reference counting in the v4.5 kernel,
this all worked well.  Now we're seeing cases where a sanity test
before we release our "pinned" mapping results in a different page
address than what we programmed into the iommu.  So something is
occurring which pretty much negates the pinning we're trying to do.

The test program I'm using is here:

https://github.com/awilliam/tests/blob/master/vfio-iommu-map-unmap.c

Apologies for lack of makefile, simply build with gcc -o <out> <in.c>.

To run this, enable the IOMMU on your system - enable in BIOS plus add
intel_iommu=on to the kernel commandline (only Intel x86_64 tested).

Pick a target PCI device, it doesn't matter what it is, the test only
needs a device for the purpose of creating an iommu domain, the device
is never actually touched.  In my case I use a spare NIC at 00:19.0.
libvirt tools are useful for setting this up, simply run 'virsh
nodedev-detach pci_0000_00_19_0'.  Otherwise bind the device manually
to vfio-pci using the standard new_id bind (ask, I can provide
instructions).

I also tweak THP scanning to make sure it is actively trying to
collapse pages:

echo always > /sys/kernel/mm/transparent_hugepage/defrag
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
echo 65536 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan

Run the test with 'vfio-iommu-map-unmap 0000:00:19.0', or your chosen
target device.

Of course to see that the mappings are moving, we need additional
sanity testing in the vfio iommu driver.  For that:

https://github.com/awilliam/linux-vfio/commit/379f324e3629349a7486018ad1cc5d4877228d1e

When we map memory for vfio, we use get_user_pages_fast() on the
process vaddr to give us a page.  page_to_pfn() then gives us the
physical memory address which we program into the iommu.  Obviously we
expect this mapping to be stable so long as we hold the page
reference.  On unmap we generally retrieve the physical memory address
from the iommu, convert it back to a page, and release our reference to
it.  The debug code above adds an additional sanity test where on unmap
we also call get_user_pages_fast() again before we're released the
mapping reference and compare whether the physical page address still
matches what we previously stored in the iommu.  On a v4.4 kernel this
works every time.  On v4.5+, we get mismatches in dmesg within a few
lines of output from the test program.

It's difficult to bisect around the THP reference counting redesign
since THP becomes disabled for much of it.  I have discovered that this
commit is a significant contributor:

1f25fe2 mm, thp: adjust conditions when we can reuse the page on WP fault

Particularly the middle chunk in huge_memory.c.  Reverting this change
alone significantly improves the problem, but does not lead to a stable
system.

I'm not an mm expert, so I'm looking for help debugging this.  As shown
above this issue is reproducible without KVM, so Andrea's previous KVM
specific fix to this code is not applicable.  It also still occurs on
kernels as recent as v4.6-rc5, so the issue hasn't been silently fixed
yet.  I'm able to reproduce this fairly quickly with the above test,
but it's not hard to imagine a test w/o any iommu dependencies which
simply does a user directed get_user_pages_fast() on a set of userspace
addresses, retains the reference, and at some point later rechecks that
a new get_user_pages_fast() results in the same page address.  It
appears that any sort of device assignment, either vfio or legacy kvm,
should be susceptible to this issue and therefore unsafe to use on v4.5+
kernels without using explicit hugepages or disabling THP.  Thanks,

Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
