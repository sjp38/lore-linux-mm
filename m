Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 56DD76B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 11:46:45 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id p65so123365895wmp.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:46:45 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id t65si37563739wmd.90.2016.03.17.08.46.44
        for <linux-mm@kvack.org>;
        Thu, 17 Mar 2016 08:46:44 -0700 (PDT)
Date: Thu, 17 Mar 2016 15:46:35 +0000
From: Olu Ogunbowale <olu.ogunbowale@imgtec.com>
Subject: Re: [PATCH] mm: Export symbols unmapped_area() &
 unmapped_area_topdown()
Message-ID: <20160317154635.GA31608@imgtec.com>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
 <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
 <20160317143714.GA16297@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
In-Reply-To: <20160317143714.GA16297@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S.
 Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Jackson DSouza <Jackson.DSouza@imgtec.com>

On Thu, Mar 17, 2016 at 03:37:16PM +0100, Jerome Glisse wrote:
> What other driver do for non-buffer region is have the userspace side
> of the device driver mmap the device driver file and use vma range you
> get from that for those non-buffer region. On cpu access you can either
> chose to fault or to return a dummy page. With that trick no need to
> change kernel.

Yes, this approach works for some designs however arbitrary VMA ranges 
for non-buffer regions is not a feature of all mobile gpu designs for 
performance, power, and area (PPA) reasons.

> Note that i do not see how you can solve the issue of your GPU having
> less bits then the cpu. For instance, lets assume that you have 46bits
> for the GPU while the CPU have 48bits. Now an application start and do
> bunch of allocation that end up above (1 << 46), then same application
> load your driver and start using some API that allow to transparently
> use previously allocated memory -> fails.

Yes, you are correct however for mobile SoC(s) though current top-end 
specifications have 4GB/8GB of installed ram so the usable SVM range is 
upper bound by this giving a fixed base hence the need for driver control
of VMA range.

> Unless you are in scheme were all allocation must go through some
> special allocator but i thought this was not the case for HSA. I know
> lower level of OpenCL allows that.

Subsets of both specifications allows for restricted implementation AFAIK,
this proposed changes are for HSA and OpenCL up to phase 2, where all SVM
allocations go via special user mode allocator.

Regards,
Olu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
