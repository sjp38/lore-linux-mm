Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 291726B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 12:06:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k30so5355011wrc.9
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 09:06:59 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id l29si5425030wrb.307.2017.06.08.09.06.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 09:06:57 -0700 (PDT)
Date: Thu, 8 Jun 2017 17:06:44 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] mm: vmalloc: simplify vread/vwrite to use existing
 mappings
Message-ID: <20170608160644.GM4902@n2100.armlinux.org.uk>
References: <20170607182052.31447-1-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170607182052.31447-1-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-mm@kvack.org, mark.rutland@arm.com, mhocko@suse.com, akpm@linux-foundation.org, zhongjiang@huawei.com, linux-arm-kernel@lists.infradead.org, labbott@fedoraproject.org

On Wed, Jun 07, 2017 at 06:20:52PM +0000, Ard Biesheuvel wrote:
> The current safe path iterates over each mapping page by page, and
> kmap()'s each one individually, which is expensive and unnecessary.
> Instead, let's use kern_addr_valid() to establish on a per-VMA basis
> whether we may safely derefence them, and do so via its mapping in
> the VMALLOC region. This can be done safely due to the fact that we
> are holding the vmap_area_lock spinlock.

This doesn't sound correct if you look at the definition of
kern_addr_valid().  For example, x86-32 has:

/*
 * kern_addr_valid() is (1) for FLATMEM and (0) for
 * SPARSEMEM and DISCONTIGMEM
 */
#ifdef CONFIG_FLATMEM
#define kern_addr_valid(addr)   (1)
#else
#define kern_addr_valid(kaddr)  (0)
#endif

The majority of architectures simply do:

#define kern_addr_valid(addr)   (1)

So, the result is that on the majority of architectures, we're now
going to simply dereference 'addr' with very little in the way of
checks.

I think this makes these functions racy - the point at which the
entry is placed onto the vmalloc list is quite different from the
point where the page table entries for it are populated (which
happens with the lock dropped.)  So, I think this is asking for
an oops.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
