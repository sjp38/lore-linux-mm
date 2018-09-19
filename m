Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF4AA8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 05:05:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m3-v6so2287749plt.9
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 02:05:13 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id e6-v6si24896486pln.265.2018.09.19.02.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 02:05:12 -0700 (PDT)
Date: Wed, 19 Sep 2018 10:04:49 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [RFC PATCH 03/29] mm: remove CONFIG_HAVE_MEMBLOCK
Message-ID: <20180919100449.00006df9@huawei.com>
In-Reply-To: <1536163184-26356-4-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1536163184-26356-4-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David
 S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael
 Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linuxarm@huawei.com

On Wed, 5 Sep 2018 18:59:18 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> All architecures use memblock for early memory management. There is no need
> for the CONFIG_HAVE_MEMBLOCK configuration option.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi Mike,

A minor editing issue in here that is stopping boot on arm64 platforms with latest
version of the mm tree.

> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index 76c83c1..bd841bb 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -1115,13 +1115,11 @@ int __init early_init_dt_scan_chosen(unsigned long node, const char *uname,
>  	return 1;
>  }
>  
> -#ifdef CONFIG_HAVE_MEMBLOCK
>  #ifndef MIN_MEMBLOCK_ADDR
>  #define MIN_MEMBLOCK_ADDR	__pa(PAGE_OFFSET)
>  #endif
>  #ifndef MAX_MEMBLOCK_ADDR
>  #define MAX_MEMBLOCK_ADDR	((phys_addr_t)~0)
> -#endif

This isn't the right #endif. It is matching with the #ifndef MAX_MEMBLOCK_ADDR
not the intented #ifdef CONFIG_HAVE_MEMBLOCK.

Now I haven't chased through the exact reason this is causing my acpi
arm64 system not to boot on the basis it is obviously miss-matched anyway
and I'm inherently lazy.  It's resulting in stubs replacing the following weak
functions.

early_init_dt_add_memory_arch
(this is defined elsewhere for some architectures but not arm)

early_init_dt_mark_hotplug_memory_arch
(there is only one definition of this in the kernel so it doesn't
 need to be weak or in the header etc).

early_init_dt_reserve_memory_arch
(defined on mips but nothing else)

Taking out the right endif also lets you drop an #else removing some stub
functions further down in here.

Nice cleanup in general btw.

Thanks,

Jonathan
>  
>  void __init __weak early_init_dt_add_memory_arch(u64 base, u64 size)
>  {
