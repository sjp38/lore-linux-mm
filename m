Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC846B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 13:03:57 -0400 (EDT)
Received: by mail-qk0-f174.google.com with SMTP id s68so37855901qkh.3
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:03:57 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id v65si8096277qka.89.2016.03.17.10.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 10:03:56 -0700 (PDT)
Received: by mail-qg0-x22d.google.com with SMTP id u110so77181243qge.3
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:03:56 -0700 (PDT)
Date: Thu, 17 Mar 2016 18:03:50 +0100
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH] mm: Export symbols unmapped_area() &
 unmapped_area_topdown()
Message-ID: <20160317170348.GB16297@gmail.com>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
 <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
 <20160317143714.GA16297@gmail.com>
 <20160317154635.GA31608@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160317154635.GA31608@imgtec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olu Ogunbowale <olu.ogunbowale@imgtec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Jackson DSouza <Jackson.DSouza@imgtec.com>

On Thu, Mar 17, 2016 at 03:46:35PM +0000, Olu Ogunbowale wrote:
> On Thu, Mar 17, 2016 at 03:37:16PM +0100, Jerome Glisse wrote:
> > What other driver do for non-buffer region is have the userspace side
> > of the device driver mmap the device driver file and use vma range you
> > get from that for those non-buffer region. On cpu access you can either
> > chose to fault or to return a dummy page. With that trick no need to
> > change kernel.
> 
> Yes, this approach works for some designs however arbitrary VMA ranges 
> for non-buffer regions is not a feature of all mobile gpu designs for 
> performance, power, and area (PPA) reasons.

Well trick still works, if driver is loaded early during userspace program
initialization then you force mmap to specific range inside the driver
userspace code. If driver is loaded after and program is already using those
range then you can register a notifier to track when those range. If they
get release by the program you can have the userspace driver force creation
of new reserve vma again.


> 
> > Note that i do not see how you can solve the issue of your GPU having
> > less bits then the cpu. For instance, lets assume that you have 46bits
> > for the GPU while the CPU have 48bits. Now an application start and do
> > bunch of allocation that end up above (1 << 46), then same application
> > load your driver and start using some API that allow to transparently
> > use previously allocated memory -> fails.
> 
> Yes, you are correct however for mobile SoC(s) though current top-end 
> specifications have 4GB/8GB of installed ram so the usable SVM range is 
> upper bound by this giving a fixed base hence the need for driver control
> of VMA range.

Well controling range into which VMA can be allocated is not something that
you should do lightly (thing like address space randomization would be
impacted). And no the SVM range is not upper bound by the amount of memory
but by the physical bus size if it is 48bits nothing forbid to put all the
program memory above 8GB and nothing below. We are talking virtual address
here. By the way i think most 64 bit ARM are 40 bits and it seems a shame
for GPU to not go as high as the CPU.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
