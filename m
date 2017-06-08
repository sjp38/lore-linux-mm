Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4EFF6B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 12:15:15 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z125so13271311itc.12
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 09:15:15 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id 145si5995179itj.14.2017.06.08.09.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 09:15:14 -0700 (PDT)
Received: by mail-io0-x22e.google.com with SMTP id y77so22296364ioe.3
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 09:15:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170608160644.GM4902@n2100.armlinux.org.uk>
References: <20170607182052.31447-1-ard.biesheuvel@linaro.org> <20170608160644.GM4902@n2100.armlinux.org.uk>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 8 Jun 2017 16:15:13 +0000
Message-ID: <CAKv+Gu93O7_BmfFa-5yPr18GoRu=24JOEX3-c4bu3kmUhKrd7w@mail.gmail.com>
Subject: Re: [PATCH] mm: vmalloc: simplify vread/vwrite to use existing mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Zhong Jiang <zhongjiang@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Laura Abbott <labbott@fedoraproject.org>

On 8 June 2017 at 16:06, Russell King - ARM Linux <linux@armlinux.org.uk> wrote:
> On Wed, Jun 07, 2017 at 06:20:52PM +0000, Ard Biesheuvel wrote:
>> The current safe path iterates over each mapping page by page, and
>> kmap()'s each one individually, which is expensive and unnecessary.
>> Instead, let's use kern_addr_valid() to establish on a per-VMA basis
>> whether we may safely derefence them, and do so via its mapping in
>> the VMALLOC region. This can be done safely due to the fact that we
>> are holding the vmap_area_lock spinlock.
>
> This doesn't sound correct if you look at the definition of
> kern_addr_valid().  For example, x86-32 has:
>
> /*
>  * kern_addr_valid() is (1) for FLATMEM and (0) for
>  * SPARSEMEM and DISCONTIGMEM
>  */
> #ifdef CONFIG_FLATMEM
> #define kern_addr_valid(addr)   (1)
> #else
> #define kern_addr_valid(kaddr)  (0)
> #endif
>
> The majority of architectures simply do:
>
> #define kern_addr_valid(addr)   (1)
>

That is interesting, thanks for pointing it out.

The function read_kcore() [which is where the issue I am trying to fix
originates] currently has this logic:

  if (kern_addr_valid(start)) {
          unsigned long n;

          /*
           * Using bounce buffer to bypass the
           * hardened user copy kernel text checks.
           */
          memcpy(buf, (char *) start, tsz);
          n = copy_to_user(buffer, buf, tsz);
          /*
           * We cannot distinguish between fault on source
           * and fault on destination. When this happens
           * we clear too and hope it will trigger the
           * EFAULT again.
           */
          if (n) {
                  if (clear_user(buffer + tsz - n,
                                          n))
                          return -EFAULT;
          }
  } else {
          if (clear_user(buffer, tsz))
                  return -EFAULT;
  }

and the implementation I looked at [on arm64] happens to be the only
one that does something non-trivial.

> So, the result is that on the majority of architectures, we're now
> going to simply dereference 'addr' with very little in the way of
> checks.
>

Indeed.

> I think this makes these functions racy - the point at which the
> entry is placed onto the vmalloc list is quite different from the
> point where the page table entries for it are populated (which
> happens with the lock dropped.)  So, I think this is asking for
> an oops.
>

Fair enough. I will try to find a different approach then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
