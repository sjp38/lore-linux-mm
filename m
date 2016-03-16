Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 543416B007E
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 13:11:31 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so199796268wml.0
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 10:11:31 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id f72si31852698wmi.104.2016.03.16.10.11.30
        for <linux-mm@kvack.org>;
        Wed, 16 Mar 2016 10:11:30 -0700 (PDT)
From: Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>
Subject: Mirroring process address space on device
Date: Wed, 16 Mar 2016 17:10:33 +0000
Message-ID: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S.
 Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>

In a nutshell:

Export the memory management functions, unmapped_area() &
unmapped_area_topdown(), as GPL symbols; this allows the kernel to
better support process address space mirroring on both CPU and device
for out-of-tree drivers by allowing the use of vm_unmapped_area() in a
driver's file operation get_unmapped_area().

This is required by drivers that want to control or limit a process VMA
range into which shared-virtual-memory (SVM) buffers are mapped during
an mmap() call in order to ensure that said SVM VMA does not collide
with any pre-existing VMAs used by non-buffer regions on the device
because SVM buffers must have identical VMAs on both CPU and device.

Exporting these functions is particularly useful for graphics devices as
SVM support is required by the OpenCL & HSA specifications and also SVM
support for 64-bit CPUs where the useable device SVM address range
is/maybe a subset of the full 64-bit range of the CPU. Exporting also
avoids the need to duplicate the VMA search code in such drivers.

Why do this:

The OpenCL API & Heterogeneous System Architecture (HSA) specifications
requires mirroring a process address space on both the CPU and GPU, a so
called shared-virtual-memory (SVM) support wherein the same virtual
address is used to address the same content on both the CPU and GPU.

There are different levels of support from coarse to fine-grained with
slightly different semantics (1: coarse-grained buffer SVM, 2:
fine-grained buffer SVM & 3: fine-grained system SVM); furthermore
support for the highest level, fine-grained system SVM, is optional and
this fact is central to the need for this requirement as explained
below.

For hardware & drivers implementing support for SVM up to the second
level only, i.e. fine-grained buffer SVM level, this mirroring is
effectively at a buffer allocation level and therefore excludes the need
for any heterogeneous memory management (HMM) like functionality which
is required to support SVM up to the highest level, i.e. fine-grained
system SVM (see http://lwn.net/Articles/597289/ for details). In this
case, drivers would benefit from being able to specify/control the SVM
VMA range during a mmap() call especially if the device SVM VMA range is
a subset of the full 32-bit/64-bit CPU (process/mmap) range.

As the kernel already provides a char driver
file->f_op->get_unmapped_area() entry point for this, the backend of
such a call would require a constrained search for an unmapped address
range using vm_unmapped_area() which currently calls into either
unmapped_area() or  unmapped_area_topdown() both of which are not
currently exported symbols. Therefore, exporting these symbols allows
the kerne to provide better support this type of process address space
and it also avoids duplicating the VMA search code in these drivers.

As always, comments are welcome and many thanks in advance for
consideration.

Olu Ogunbowale (1):
  mm: Export symbols unmapped_area() & unmapped_area_topdown()

 mm/mmap.c | 4 ++++
 1 file changed, 4 insertions(+)

-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
