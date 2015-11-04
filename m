Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DC2886B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 09:55:04 -0500 (EST)
Received: by padhx2 with SMTP id hx2so47219928pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 06:55:04 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ba4si2715258pbb.20.2015.11.04.06.54.51
        for <linux-mm@kvack.org>;
        Wed, 04 Nov 2015 06:54:51 -0800 (PST)
Date: Wed, 4 Nov 2015 14:54:46 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: Increase the max granular size
Message-ID: <20151104145445.GL7637@e104818-lin.cambridge.arm.com>
References: <1442944788-17254-1-git-send-email-rric@kernel.org>
 <20151028190948.GJ8899@e104818-lin.cambridge.arm.com>
 <CAMuHMdWQygbxMXoOsbwek6DzZcr7J-C23VCK4ubbgUr+zj=giw@mail.gmail.com>
 <20151103120504.GF7637@e104818-lin.cambridge.arm.com>
 <20151103143858.GI7637@e104818-lin.cambridge.arm.com>
 <CAMuHMdWk0fPzTSKhoCuS4wsOU1iddhKJb2SOpjo=a_9vCm_KXQ@mail.gmail.com>
 <20151103185050.GJ7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511031724010.8178@east.gentwo.org>
 <20151104123640.GK7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511040748590.17248@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511040748590.17248@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Robert Richter <rric@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Linux-sh list <linux-sh@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Robert Richter <rrichter@cavium.com>, linux-mm@kvack.org, Tirumalesh Chalamarla <tchalamarla@cavium.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Nov 04, 2015 at 07:53:50AM -0600, Christoph Lameter wrote:
> On Wed, 4 Nov 2015, Catalin Marinas wrote:
> 
> > The simplest option would be to make sure that off slab isn't allowed
> > for caches of KMALLOC_MIN_SIZE or smaller, with the drawback that not
> > only "kmalloc-128" but any other such caches will be on slab.
> 
> The reason for an off slab configuration is denser object packing.
> 
> > I think a better option would be to first check that there is a
> > kmalloc_caches[] entry for freelist_size before deciding to go off-slab.
> 
> Hmmm.. Yes seems to be an option.
> 
> Maybe we simply revert commit 8fc9cf420b36 instead?

I'm fine with this. Also note that the arm64 commit changing
L1_CACHE_BYTES to 128 hasn't been pushed yet (it's queued for 4.4).

> That does not seem to make too much sense to me and the goal of the
> commit cannot be accomplished on ARM. Your patch essentially reverts
> the effect anyways.

In theory it only reverts the effect for the first kmalloc_cache
("kmalloc-128" in the arm64 case). Any other bigger cache which would
not be mergeable with an existing one still has the potential of
off-slab management.

> Smaller slabs really do not need off slab management anyways since they
> will only loose a few objects per slab page.

IIUC, starting with 128 slab size for a 4KB page, you have 32 objects
per page. The freelist takes 32 bytes (or 31), therefore you waste a
single slab object. However, only 1/4 of it is used for freelist and the
waste gets bigger with 256 slab size, hence the original commit.

BTW, assuming L1_CACHE_BYTES is 512 (I don't ever see this happening but
just in theory), we potentially have the same issue. What would save us
is that INDEX_NODE would match the first "kmalloc-512" cache, so we have
it pre-populated.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
