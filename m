Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BA27560021B
	for <linux-mm@kvack.org>; Sat,  2 Jan 2010 19:31:35 -0500 (EST)
Received: by ywh5 with SMTP id 5so26151450ywh.11
        for <linux-mm@kvack.org>; Sat, 02 Jan 2010 16:31:34 -0800 (PST)
Message-ID: <4B3FE3A4.6030401@vflare.org>
Date: Sun, 03 Jan 2010 05:54:04 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: [RFC] vswap: virtio based swap device
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: tmem-devel@oss.oracle.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

virtio_vswap driver[1] creates /dev/vswap device which can
be used (only) as a swap disk. Pages swapped to this device
are send directly to host/hypervisor. The host, depending on
various policies, can fail this request in which case the driver
writes the page to guest controlled swap partition (backing_swap
module parameter provides this partition). The size of this
device is set equal to that of backing_swap.

This driver provides an alternate approach for "preswap"
introduced as part of "tmem" patches posted earlier:
http://lwn.net/Articles/338098/
These patches used Xen specific interfaces and made some
intrusive changes to swap code. However, I found the concept
interesting, so developed this virtio based driver which does
not require any kernel changes.

It uses virtio to create a virtual PCI device and also creates
a virtual block device (/dev/vswap) whose only job is to send
pages to host and if that fails, forward request to backing_swap.
It also requires changes to qemu-kvm[2] to expose this virtual
PCI device to guest and is enabled with '-vswap virtio' option.

In current state, it does everything except actually storing
incoming guest pages in host memory :)  Also, it uses a single
virtqueue which sends each page to host synchronously.  Its just
a proof of concept code to show how virtio framework can be used
to drive such a device. Perhaps a more interesting application would
be an FS-cache backend that sends pages to host as clean pagecache
usually occupies a vast majority of memory and ballooning is too slow
to deal quickly with such large caches when the host is running into
memory pressure.

[1] vswap kernel driver:
http://code.google.com/p/compcache/source/browse/sub-projects/vswap/

[2] qemu-kvm patch to expose vswap PCI device:
http://code.google.com/p/compcache/source/browse/sub-projects/vswap/qemu_kvm_vswap_support.patch

[3] Transcendent Memory (tmem) project page:
http://oss.oracle.com/projects/tmem/

(I intend to merge vswap with ramzswap driver which is already
in mainline, so I did not integrate it with kernel build system.
So, provided just the link to code instead of diff against /dev/null)

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
