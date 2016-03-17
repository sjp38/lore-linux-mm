Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE2F6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:37:28 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id a36so41727072qge.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:37:28 -0700 (PDT)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id x143si7687037qka.122.2016.03.17.07.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 07:37:27 -0700 (PDT)
Received: by mail-qk0-x230.google.com with SMTP id s68so35919034qkh.3
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:37:27 -0700 (PDT)
Date: Thu, 17 Mar 2016 15:37:16 +0100
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH] mm: Export symbols unmapped_area() &
 unmapped_area_topdown()
Message-ID: <20160317143714.GA16297@gmail.com>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
 <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Wed, Mar 16, 2016 at 05:10:34PM +0000, Olu Ogunbowale wrote:
> From: Olujide Ogunbowale <Olu.Ogunbowale@imgtec.com>
> 
> Export the memory management functions, unmapped_area() &
> unmapped_area_topdown(), as GPL symbols; this allows the kernel to
> better support process address space mirroring on both CPU and device
> for out-of-tree drivers by allowing the use of vm_unmapped_area() in a
> driver's file operation get_unmapped_area().
> 
> This is required by drivers that want to control or limit a process VMA
> range into which shared-virtual-memory (SVM) buffers are mapped during
> an mmap() call in order to ensure that said SVM VMA does not collide
> with any pre-existing VMAs used by non-buffer regions on the device
> because SVM buffers must have identical VMAs on both CPU and device.
> 
> Exporting these functions is particularly useful for graphics devices as
> SVM support is required by the OpenCL & HSA specifications and also SVM
> support for 64-bit CPUs where the useable device SVM address range
> is/maybe a subset of the full 64-bit range of the CPU. Exporting also
> avoids the need to duplicate the VMA search code in such drivers.

What other driver do for non-buffer region is have the userspace side
of the device driver mmap the device driver file and use vma range you
get from that for those non-buffer region. On cpu access you can either
chose to fault or to return a dummy page. With that trick no need to
change kernel.

Note that i do not see how you can solve the issue of your GPU having
less bits then the cpu. For instance, lets assume that you have 46bits
for the GPU while the CPU have 48bits. Now an application start and do
bunch of allocation that end up above (1 << 46), then same application
load your driver and start using some API that allow to transparently
use previously allocated memory -> fails.

Unless you are in scheme were all allocation must go through some
special allocator but i thought this was not the case for HSA. I know
lower level of OpenCL allows that.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
