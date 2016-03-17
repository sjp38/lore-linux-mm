Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 502A26B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 11:39:23 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l68so122814749wml.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:39:23 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id ku4si10479585wjc.49.2016.03.17.08.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 08:39:22 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id p65so15831410wmp.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:39:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160317143714.GA16297@gmail.com>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
 <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com> <20160317143714.GA16297@gmail.com>
From: Oded Gabbay <oded.gabbay@gmail.com>
Date: Thu, 17 Mar 2016 17:38:52 +0200
Message-ID: <CAFCwf11pk_umjO7TirPPJCf6gpMvGg3bXHsDj707Dfr07xkgZg@mail.gmail.com>
Subject: Re: [PATCH] mm: Export symbols unmapped_area() & unmapped_area_topdown()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>, linux-mm <linux-mm@kvack.org>, "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Thu, Mar 17, 2016 at 4:37 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> On Wed, Mar 16, 2016 at 05:10:34PM +0000, Olu Ogunbowale wrote:
>> From: Olujide Ogunbowale <Olu.Ogunbowale@imgtec.com>
>>
>> Export the memory management functions, unmapped_area() &
>> unmapped_area_topdown(), as GPL symbols; this allows the kernel to
>> better support process address space mirroring on both CPU and device
>> for out-of-tree drivers by allowing the use of vm_unmapped_area() in a
>> driver's file operation get_unmapped_area().
>>
>> This is required by drivers that want to control or limit a process VMA
>> range into which shared-virtual-memory (SVM) buffers are mapped during
>> an mmap() call in order to ensure that said SVM VMA does not collide
>> with any pre-existing VMAs used by non-buffer regions on the device
>> because SVM buffers must have identical VMAs on both CPU and device.
>>
>> Exporting these functions is particularly useful for graphics devices as
>> SVM support is required by the OpenCL & HSA specifications and also SVM
>> support for 64-bit CPUs where the useable device SVM address range
>> is/maybe a subset of the full 64-bit range of the CPU. Exporting also
>> avoids the need to duplicate the VMA search code in such drivers.
>
> What other driver do for non-buffer region is have the userspace side
> of the device driver mmap the device driver file and use vma range you
> get from that for those non-buffer region. On cpu access you can either
> chose to fault or to return a dummy page. With that trick no need to
> change kernel.
>
> Note that i do not see how you can solve the issue of your GPU having
> less bits then the cpu. For instance, lets assume that you have 46bits
> for the GPU while the CPU have 48bits. Now an application start and do
> bunch of allocation that end up above (1 << 46), then same application
> load your driver and start using some API that allow to transparently
> use previously allocated memory -> fails.
>
> Unless you are in scheme were all allocation must go through some
> special allocator but i thought this was not the case for HSA. I know
> lower level of OpenCL allows that.
>
> Cheers,
> J=C3=A9r=C3=B4me

In amdkfd (AMD HSA kernel driver), for APU's where the CPU and GPU sit
on the same die, we don't need this as the GPU cores use the AMD IOMMU
(v2) to access the system memory. i.e. we don't need to use vram (gpu
memory) at all and we don't need to mirror address spaces.

For dGPU, it's a different story. On GPUs where there is only 40-bit
memory space, for example, GCN 1.0 and 1.1, I would assume a pass
through a special allocator is a must, while memory addresses below
the 40-bit limit will need to be reserved for HSA. Note that amdkfd
doesn't support dGPU at this time.

Thanks,
    Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
