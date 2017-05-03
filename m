Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4511A6B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 09:09:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y43so18495994wrc.11
        for <linux-mm@kvack.org>; Wed, 03 May 2017 06:09:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r41si23947300wrb.298.2017.05.03.06.09.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 May 2017 06:09:52 -0700 (PDT)
Date: Wed, 3 May 2017 15:09:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmalloc: properly track vmalloc users
Message-ID: <20170503130950.GK8836@dhcp22.suse.cz>
References: <20170502134657.12381-1-mhocko@kernel.org>
 <201705030806.pzzQRBiN%fengguang.wu@intel.com>
 <20170503063750.GC1236@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170503063750.GC1236@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 03-05-17 08:37:50, Michal Hocko wrote:
> On Wed 03-05-17 08:52:01, kbuild test robot wrote:
> > Hi Michal,
> > 
> > [auto build test ERROR on mmotm/master]
> > [also build test ERROR on next-20170502]
> > [cannot apply to v4.11]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-vmalloc-properly-track-vmalloc-users/20170503-065022
> > base:   git://git.cmpxchg.org/linux-mmotm.git master
> > config: m68k-m5475evb_defconfig (attached as .config)
> > compiler: m68k-linux-gcc (GCC) 4.9.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=m68k 
> > 
> > All error/warnings (new ones prefixed by >>):
> > 
> >    In file included from arch/m68k/include/asm/pgtable_mm.h:145:0,
> >                     from arch/m68k/include/asm/pgtable.h:4,
> >                     from include/linux/vmalloc.h:9,
> >                     from arch/m68k/kernel/module.c:9:
> 
> OK, I was little bit worried to pull pgtable.h include in, but my cross
> compile build test battery didn't show any issues. I do not have m68k
> there though. So let's just do this differently. The following updated
> patch hasn't passed the full build test battery but it should just work.

I assume that the silence from the kbuild robot means good to go here.
Andrew, could you replace the previous patch by the following one please?
 
> From 33a6239135cb444654f48d5e942e7f34898e24ea Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 2 May 2017 11:18:29 +0200
> Subject: [PATCH] mm, vmalloc: properly track vmalloc users
> 
> __vmalloc_node_flags used to be static inline but this has changed by
> "mm: introduce kv[mz]alloc helpers" because kvmalloc_node needs to use
> it as well and the code is outside of the vmalloc proper. I haven't
> realized that changing this will lead to a subtle bug though. The
> function is responsible to track the caller as well. This caller is
> then printed by /proc/vmallocinfo. If __vmalloc_node_flags is not inline
> then we would get only direct users of __vmalloc_node_flags as callers
> (e.g. v[mz]alloc) which reduces usefulness of this debugging feature
> considerably. It simply doesn't help to see that the given range belongs
> to vmalloc as a caller:
> 0xffffc90002c79000-0xffffc90002c7d000   16384 vmalloc+0x16/0x18 pages=3 vmalloc N0=3
> 0xffffc90002c81000-0xffffc90002c85000   16384 vmalloc+0x16/0x18 pages=3 vmalloc N1=3
> 0xffffc90002c8d000-0xffffc90002c91000   16384 vmalloc+0x16/0x18 pages=3 vmalloc N1=3
> 0xffffc90002c95000-0xffffc90002c99000   16384 vmalloc+0x16/0x18 pages=3 vmalloc N1=3
> 
> We really want to catch the _caller_ of the vmalloc function. Fix this
> issue by making __vmalloc_node_flags static inline again and export
> __vmalloc_node_flags_caller for kvmalloc_node().
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/vmalloc.h | 16 +++++++++++++++-
>  mm/util.c               |  3 ++-
>  mm/vmalloc.c            |  8 +++++++-
>  3 files changed, 24 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 46991ad3ddd5..4a0fabeb1e92 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -80,7 +80,21 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  			unsigned long start, unsigned long end, gfp_t gfp_mask,
>  			pgprot_t prot, unsigned long vm_flags, int node,
>  			const void *caller);
> -extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
> +#ifndef CONFIG_MMU
> +extern void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags);
> +static inline void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags, void* caller)
> +{
> +	return __vmalloc_node_flags(size, node, flags);
> +}
> +#else
> +/*
> + * We really want to have this inlined due to caller tracking. This
> + * function is used by the highlevel vmalloc apis and so we want to track
> + * their callers and inlining will achieve that.
> + */
> +extern void *__vmalloc_node_flags_caller(unsigned long size,
> +					int node, gfp_t flags, void* caller);
> +#endif
>  
>  extern void vfree(const void *addr);
>  extern void vfree_atomic(const void *addr);
> diff --git a/mm/util.c b/mm/util.c
> index 3022051da938..c35e5870921d 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -380,7 +380,8 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	if (ret || size <= PAGE_SIZE)
>  		return ret;
>  
> -	return __vmalloc_node_flags(size, node, flags);
> +	return __vmalloc_node_flags_caller(size, node, flags,
> +			__builtin_return_address(0));
>  }
>  EXPORT_SYMBOL(kvmalloc_node);
>  
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 65912eb93a2c..1a97d4a31406 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1809,13 +1809,19 @@ void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
>  }
>  EXPORT_SYMBOL(__vmalloc);
>  
> -void *__vmalloc_node_flags(unsigned long size,
> +static inline void *__vmalloc_node_flags(unsigned long size,
>  					int node, gfp_t flags)
>  {
>  	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
>  					node, __builtin_return_address(0));
>  }
>  
> +
> +void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags, void *caller)
> +{
> +	return __vmalloc_node(size, 1, flags, PAGE_KERNEL, node, caller);
> +}
> +
>  /**
>   *	vmalloc  -  allocate virtually contiguous memory
>   *	@size:		allocation size
> -- 
> 2.11.0
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
