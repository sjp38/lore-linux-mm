Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 018586B0253
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 13:11:41 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id p65so82188366wmp.0
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 10:11:40 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id l10si5152333wjx.231.2016.03.16.10.11.39
        for <linux-mm@kvack.org>;
        Wed, 16 Mar 2016 10:11:40 -0700 (PDT)
From: Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>
Subject: [PATCH] mm: Export symbols unmapped_area() & unmapped_area_topdown()
Date: Wed, 16 Mar 2016 17:10:34 +0000
Message-ID: <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
In-Reply-To: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S.
 Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Olujide Ogunbowale <Olu.Ogunbowale@imgtec.com>

From: Olujide Ogunbowale <Olu.Ogunbowale@imgtec.com>

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

Signed-off-by: Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>
---
 mm/mmap.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 76d1ec2..c08b518 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1804,6 +1804,8 @@ found:
 	return gap_start;
 }
 
+EXPORT_SYMBOL_GPL(unmapped_area);
+
 unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
 {
 	struct mm_struct *mm = current->mm;
@@ -1902,6 +1904,8 @@ found_highest:
 	return gap_end;
 }
 
+EXPORT_SYMBOL_GPL(unmapped_area_topdown);
+
 /* Get an address range which is currently unmapped.
  * For shmat() with addr=0.
  *
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
