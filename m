Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 42E9682F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:08:46 -0500 (EST)
Received: by pasz6 with SMTP id z6so94866297pas.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:08:46 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id fk4si7374786pab.123.2015.11.05.08.08.44
        for <linux-mm@kvack.org>;
        Thu, 05 Nov 2015 08:08:44 -0800 (PST)
Date: Thu, 5 Nov 2015 16:08:40 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: slab: Only move management objects off-slab for
 sizes larger than KMALLOC_MIN_SIZE
Message-ID: <20151105160839.GR7637@e104818-lin.cambridge.arm.com>
References: <20151105043155.GA20374@js1304-P5Q-DELUXE>
 <1446724235-31400-1-git-send-email-catalin.marinas@arm.com>
 <20151105053139.e38214a9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105053139.e38214a9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Thu, Nov 05, 2015 at 05:31:39AM -0800, Andrew Morton wrote:
> On Thu,  5 Nov 2015 11:50:35 +0000 Catalin Marinas <catalin.marinas@arm.com> wrote:
> 
> > Commit 8fc9cf420b36 ("slab: make more slab management structure off the
> > slab") enables off-slab management objects for sizes starting with
> > PAGE_SIZE >> 5. This means 128 bytes for a 4KB page configuration.
> > However, on systems with a KMALLOC_MIN_SIZE of 128 (arm64 in 4.4), such
> > optimisation does not make sense since the slab management allocation
> > would take 128 bytes anyway (even though freelist_size is 32) with the
> > additional overhead of another allocation.
> > 
> > This patch introduces an OFF_SLAB_MIN_SIZE macro which takes
> > KMALLOC_MIN_SIZE into account. It also solves a slab bug on arm64 where
> > the first kmalloc_cache to be initialised after slab_early_init = 0,
> > "kmalloc-128", fails to allocate off-slab management objects from the
> > same "kmalloc-128" cache.
> 
> That all seems to be quite minor stuff.

Apart from "it also solves a bug on arm64...". But I agree, the initial
commit log doesn't give any justification for cc stable.

> > Fixes: 8fc9cf420b36 ("slab: make more slab management structure off the slab")
> > Cc: <stable@vger.kernel.org> # 3.15+
> 
> Yet you believe the fix should be backported.
> 
> So, the usual refrain: when fixing a bug, please describe the end-user
> visible effects of that bug.

What about (unless you prefer this slightly more intrusive fix:
http://article.gmane.org/gmane.linux.ports.sh.devel/50303):

------------------8<--------------------------
