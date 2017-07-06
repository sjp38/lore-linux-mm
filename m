Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B42116B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 12:27:49 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u126so2926821qka.9
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:27:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c2si589892qtd.114.2017.07.06.09.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 09:27:48 -0700 (PDT)
Date: Thu, 6 Jul 2017 12:27:43 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/3] Protectable memory support
Message-ID: <20170706162742.GA2919@redhat.com>
References: <20170705134628.3803-1-igor.stoppa@huawei.com>
 <20170705134628.3803-2-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170705134628.3803-2-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com, hch@infradead.org, penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Jul 05, 2017 at 04:46:26PM +0300, Igor Stoppa wrote:
> The MMU available in many systems running Linux can often provide R/O
> protection to the memory pages it handles.
> 
> However, the MMU-based protection works efficiently only when said pages
> contain exclusively data that will not need further modifications.
> 
> Statically allocated variables can be segregated into a dedicated
> section, but this does not sit very well with dynamically allocated ones.
> 
> Dynamic allocation does not provide, currently, any means for grouping
> variables in memory pages that would contain exclusively data suitable
> for conversion to read only access mode.
> 
> The allocator here provided (pmalloc - protectable memory allocator)
> introduces the concept of pools of protectable memory.
> 
> A module can request a pool and then refer any allocation request to the
> pool handler it has received.
> 
> Once all the chunks of memory associated to a specific pool are
> initialized, the pool can be protected.
> 
> After this point, the pool can only be destroyed (it is up to the module
> to avoid any further references to the memory from the pool, after
> the destruction is invoked).
> 
> The latter case is mainly meant for releasing memory, when a module is
> unloaded.
> 
> A module can have as many pools as needed, for example to support the
> protection of data that is initialized in sufficiently distinct phases.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  arch/Kconfig                   |   1 +
>  include/linux/page-flags.h     |   2 +
>  include/linux/pmalloc.h        | 127 +++++++++++++++
>  include/trace/events/mmflags.h |   1 +
>  lib/Kconfig                    |   1 +
>  mm/Makefile                    |   1 +
>  mm/pmalloc.c                   | 356 +++++++++++++++++++++++++++++++++++++++++
>  mm/usercopy.c                  |  24 +--
>  8 files changed, 504 insertions(+), 9 deletions(-)
>  create mode 100644 include/linux/pmalloc.h
>  create mode 100644 mm/pmalloc.c
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 6c00e5b..9d16b51 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -228,6 +228,7 @@ config GENERIC_IDLE_POLL_SETUP
>  
>  # Select if arch has all set_memory_ro/rw/x/nx() functions in asm/cacheflush.h
>  config ARCH_HAS_SET_MEMORY
> +	select GENERIC_ALLOCATOR
>  	bool
>  
>  # Select if arch init_task initializer is different to init/init_task.c
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 6b5818d..acc0723 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -81,6 +81,7 @@ enum pageflags {
>  	PG_active,
>  	PG_waiters,		/* Page has waiters, check its waitqueue. Must be bit #7 and in the same byte as "PG_locked" */
>  	PG_slab,
> +	PG_pmalloc,
>  	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
>  	PG_arch_1,
>  	PG_reserved,
> @@ -274,6 +275,7 @@ PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
>  	TESTCLEARFLAG(Active, active, PF_HEAD)
>  __PAGEFLAG(Slab, slab, PF_NO_TAIL)
>  __PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
> +__PAGEFLAG(Pmalloc, pmalloc, PF_NO_TAIL)
>  PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
>  
>  /* Xen */


So i don't think we want to waste a page flag on this. The struct 
page flags field is already full AFAIK (see page-flags-layout.h)

Moreover there is easier way to tag such page. So my understanding
is that pmalloc() is always suppose to be in vmalloc area. From
the look of it all you do is check that there is a valid page behind
the vmalloc vaddr and you check for the PG_malloc flag of that page.

Why do you need to check the PG_malloc flag for the page ? Isn't the
fact that there is a page behind the vmalloc vaddr enough ? If not
enough wouldn't checking the pte flags of the page enough ? ie if
the page is read only inside vmalloc than it would be for sure some
pmalloc area.

Other way to distinguish between regular vmalloc and pmalloc can be
to carveout a region of vmalloc for pmalloc purpose. Issue is that
it might be hard to find right size for such carveout.

Yet another way is to use some of the free struct page fields ie
when a page is allocated for vmalloc i think most of struct page
fields are unuse (mapping, index, lru, ...). It would be better
to use those rather than adding a page flag.


Everything else looks good to me, thought i am unsure on how much
useful such feature is but i am not familiar too much with security
side of thing.


Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
