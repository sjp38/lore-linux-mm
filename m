Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 173BE8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:45:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k18-v6so2382546pls.12
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:45:33 -0700 (PDT)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id p14-v6si20752089plo.363.2018.09.19.03.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 03:45:31 -0700 (PDT)
Date: Wed, 19 Sep 2018 11:45:07 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [RFC PATCH 03/29] mm: remove CONFIG_HAVE_MEMBLOCK
Message-ID: <20180919114507.000059f3@huawei.com>
In-Reply-To: <20180919103457.GA20545@rapoport-lnx>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1536163184-26356-4-git-send-email-rppt@linux.vnet.ibm.com>
	<20180919100449.00006df9@huawei.com>
	<20180919103457.GA20545@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David
 S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael
 Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linuxarm@huawei.com

On Wed, 19 Sep 2018 13:34:57 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> Hi Jonathan,
> 
> On Wed, Sep 19, 2018 at 10:04:49AM +0100, Jonathan Cameron wrote:
> > On Wed, 5 Sep 2018 18:59:18 +0300
> > Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> >   
> > > All architecures use memblock for early memory management. There is no need
> > > for the CONFIG_HAVE_MEMBLOCK configuration option.
> > > 
> > > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>  
> > 
> > Hi Mike,
> > 
> > A minor editing issue in here that is stopping boot on arm64 platforms with latest
> > version of the mm tree.  
> 
> Can you please try the following patch:
> 
> 
> From 079bd5d24a01df3df9500d0a33d89cb9f7da4588 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Date: Wed, 19 Sep 2018 13:29:27 +0300
> Subject: [PATCH] of/fdt: fixup #ifdefs after removal of HAVE_MEMBLOCK config
>  option
> 
> The removal of HAVE_MEMBLOCK configuration option, mistakenly dropped the
> wrong #endif. This patch restores that #endif and removes the part that
> should have been actually removed, starting from #else and up to the
> correct #endif
> 
> Reported-by: Jonathan Cameron <jonathan.cameron@huawei.com>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi Mike,

That's identical to the local patch I'm carrying to fix this so looks good to me.

For what it's worth given you'll probably fold this into the larger patch.

Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Thanks for the quick reply.

Jonathan

> ---
>  drivers/of/fdt.c | 21 +--------------------
>  1 file changed, 1 insertion(+), 20 deletions(-)
> 
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index 48314e9..bb532aa 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -1119,6 +1119,7 @@ int __init early_init_dt_scan_chosen(unsigned long node, const char *uname,
>  #endif
>  #ifndef MAX_MEMBLOCK_ADDR
>  #define MAX_MEMBLOCK_ADDR	((phys_addr_t)~0)
> +#endif
>  
>  void __init __weak early_init_dt_add_memory_arch(u64 base, u64 size)
>  {
> @@ -1175,26 +1176,6 @@ int __init __weak early_init_dt_reserve_memory_arch(phys_addr_t base,
>  	return memblock_reserve(base, size);
>  }
>  
> -#else
> -void __init __weak early_init_dt_add_memory_arch(u64 base, u64 size)
> -{
> -	WARN_ON(1);
> -}
> -
> -int __init __weak early_init_dt_mark_hotplug_memory_arch(u64 base, u64 size)
> -{
> -	return -ENOSYS;
> -}
> -
> -int __init __weak early_init_dt_reserve_memory_arch(phys_addr_t base,
> -					phys_addr_t size, bool nomap)
> -{
> -	pr_err("Reserved memory not supported, ignoring range %pa - %pa%s\n",
> -		  &base, &size, nomap ? " (nomap)" : "");
> -	return -ENOSYS;
> -}
> -#endif
> -
>  static void * __init early_init_dt_alloc_memory_arch(u64 size, u64 align)
>  {
>  	return memblock_alloc(size, align);
