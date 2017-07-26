Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9D176B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 05:52:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v31so31225602wrc.7
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 02:52:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9si16171175wrc.14.2017.07.26.02.52.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 02:52:30 -0700 (PDT)
Date: Wed, 26 Jul 2017 11:52:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/3] mm: arch: Use new hugetlb size encoding
 definitions
Message-ID: <20170726095227.GE2981@dhcp22.suse.cz>
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
 <1500330481-28476-3-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500330481-28476-3-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com

On Mon 17-07-17 15:28:00, Mike Kravetz wrote:
> Use the common definitions from hugetlb_encode.h header file for
> encoding hugetlb size definitions in mmap system call flags.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

with s@HUGETLB_FLAG_ENCODE__16GB@HUGETLB_FLAG_ENCODE_16GB@

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/alpha/include/uapi/asm/mman.h     | 14 ++++++--------
>  arch/mips/include/uapi/asm/mman.h      | 14 ++++++--------
>  arch/parisc/include/uapi/asm/mman.h    | 14 ++++++--------
>  arch/powerpc/include/uapi/asm/mman.h   | 23 ++++++++++-------------
>  arch/x86/include/uapi/asm/mman.h       | 10 ++++++++--
>  arch/xtensa/include/uapi/asm/mman.h    | 14 ++++++--------
>  include/uapi/asm-generic/mman-common.h |  6 ++++--
>  7 files changed, 46 insertions(+), 49 deletions(-)
> 
> diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
> index 02760f6..bfa5828 100644
> --- a/arch/alpha/include/uapi/asm/mman.h
> +++ b/arch/alpha/include/uapi/asm/mman.h
> @@ -1,6 +1,8 @@
>  #ifndef __ALPHA_MMAN_H__
>  #define __ALPHA_MMAN_H__
>  
> +#include <asm-generic/hugetlb_encode.h>
> +
>  #define PROT_READ	0x1		/* page can be read */
>  #define PROT_WRITE	0x2		/* page can be written */
>  #define PROT_EXEC	0x4		/* page can be executed */
> @@ -68,15 +70,11 @@
>  #define MAP_FILE	0
>  
>  /*
> - * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
> - * This gives us 6 bits, which is enough until someone invents 128 bit address
> - * spaces.
> - *
> - * Assume these are all power of twos.
> - * When 0 use the default page size.
> + * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
> + * size other than the default is desired.  See hugetlb_encode.h
>   */
> -#define MAP_HUGE_SHIFT	26
> -#define MAP_HUGE_MASK	0x3f
> +#define MAP_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
> +#define MAP_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
>  
>  #define PKEY_DISABLE_ACCESS	0x1
>  #define PKEY_DISABLE_WRITE	0x2
> diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
> index 655e2fb..9e55284 100644
> --- a/arch/mips/include/uapi/asm/mman.h
> +++ b/arch/mips/include/uapi/asm/mman.h
> @@ -8,6 +8,8 @@
>  #ifndef _ASM_MMAN_H
>  #define _ASM_MMAN_H
>  
> +#include <asm-generic/hugetlb_encode.h>
> +
>  /*
>   * Protections are chosen from these bits, OR'd together.  The
>   * implementation does not necessarily support PROT_EXEC or PROT_WRITE
> @@ -95,15 +97,11 @@
>  #define MAP_FILE	0
>  
>  /*
> - * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
> - * This gives us 6 bits, which is enough until someone invents 128 bit address
> - * spaces.
> - *
> - * Assume these are all power of twos.
> - * When 0 use the default page size.
> + * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
> + * size other than the default is desired.  See hugetlb_encode.h
>   */
> -#define MAP_HUGE_SHIFT	26
> -#define MAP_HUGE_MASK	0x3f
> +#define MAP_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
> +#define MAP_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
>  
>  #define PKEY_DISABLE_ACCESS	0x1
>  #define PKEY_DISABLE_WRITE	0x2
> diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
> index 5979745..11c6d86 100644
> --- a/arch/parisc/include/uapi/asm/mman.h
> +++ b/arch/parisc/include/uapi/asm/mman.h
> @@ -1,6 +1,8 @@
>  #ifndef __PARISC_MMAN_H__
>  #define __PARISC_MMAN_H__
>  
> +#include <asm-generic/hugetlb_encode.h>
> +
>  #define PROT_READ	0x1		/* page can be read */
>  #define PROT_WRITE	0x2		/* page can be written */
>  #define PROT_EXEC	0x4		/* page can be executed */
> @@ -65,15 +67,11 @@
>  #define MAP_VARIABLE	0
>  
>  /*
> - * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
> - * This gives us 6 bits, which is enough until someone invents 128 bit address
> - * spaces.
> - *
> - * Assume these are all power of twos.
> - * When 0 use the default page size.
> + * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
> + * size other than the default is desired.  See hugetlb_encode.h
>   */
> -#define MAP_HUGE_SHIFT	26
> -#define MAP_HUGE_MASK	0x3f
> +#define MAP_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
> +#define MAP_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
>  
>  #define PKEY_DISABLE_ACCESS	0x1
>  #define PKEY_DISABLE_WRITE	0x2
> diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
> index ab45cc2..80fd56c 100644
> --- a/arch/powerpc/include/uapi/asm/mman.h
> +++ b/arch/powerpc/include/uapi/asm/mman.h
> @@ -8,6 +8,7 @@
>  #define _UAPI_ASM_POWERPC_MMAN_H
>  
>  #include <asm-generic/mman-common.h>
> +#include <asm-generic/hugetlb_encode.h>
>  
>  
>  #define PROT_SAO	0x10		/* Strong Access Ordering */
> @@ -30,19 +31,15 @@
>  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
>  
>  /*
> - * When MAP_HUGETLB is set, bits [26:31] of the flags argument to mmap(2),
> - * encode the log2 of the huge page size. A value of zero indicates that the
> - * default huge page size should be used. To use a non-default huge page size,
> - * one of these defines can be used, or the size can be encoded by hand. Note
> - * that on most systems only a subset, or possibly none, of these sizes will be
> - * available.
> + * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
> + * size other than the default is desired.  See hugetlb_encode.h
>   */
> -#define MAP_HUGE_512KB	(19 << MAP_HUGE_SHIFT)	/* 512KB HugeTLB Page */
> -#define MAP_HUGE_1MB	(20 << MAP_HUGE_SHIFT)	/* 1MB   HugeTLB Page */
> -#define MAP_HUGE_2MB	(21 << MAP_HUGE_SHIFT)	/* 2MB   HugeTLB Page */
> -#define MAP_HUGE_8MB	(23 << MAP_HUGE_SHIFT)	/* 8MB   HugeTLB Page */
> -#define MAP_HUGE_16MB	(24 << MAP_HUGE_SHIFT)	/* 16MB  HugeTLB Page */
> -#define MAP_HUGE_1GB	(30 << MAP_HUGE_SHIFT)	/* 1GB   HugeTLB Page */
> -#define MAP_HUGE_16GB	(34 << MAP_HUGE_SHIFT)	/* 16GB  HugeTLB Page */
> +#define MAP_HUGE_512KB	HUGETLB_FLAG_ENCODE_512KB	/* 512KB HugeTLB Page */
> +#define MAP_HUGE_1MB	HUGETLB_FLAG_ENCODE_1MB		/* 1MB   HugeTLB Page */
> +#define MAP_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB		/* 2MB   HugeTLB Page */
> +#define MAP_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB		/* 8MB   HugeTLB Page */
> +#define MAP_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB	/* 16MB  HugeTLB Page */
> +#define MAP_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB		/* 1GB   HugeTLB Page */
> +#define MAP_HUGE_16GB	HUGETLB_FLAG_ENCODE__16GB	/* 16GB  HugeTLB Page */
>  
>  #endif /* _UAPI_ASM_POWERPC_MMAN_H */
> diff --git a/arch/x86/include/uapi/asm/mman.h b/arch/x86/include/uapi/asm/mman.h
> index 39bca7f..5a67293 100644
> --- a/arch/x86/include/uapi/asm/mman.h
> +++ b/arch/x86/include/uapi/asm/mman.h
> @@ -1,10 +1,16 @@
>  #ifndef _ASM_X86_MMAN_H
>  #define _ASM_X86_MMAN_H
>  
> +#include <asm-generic/hugetlb_encode.h>
> +
>  #define MAP_32BIT	0x40		/* only give out 32bit addresses */
>  
> -#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
> -#define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)
> +/*
> + * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
> + * size other than the default is desired.  See hugetlb_encode.h
> + */
> +#define MAP_HUGE_2MB    HUGETLB_FLAG_ENCODE_2MB
> +#define MAP_HUGE_1GB    HUGETLB_FLAG_ENCODE_1GB
>  
>  #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>  /*
> diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
> index 24365b3..5deb5e4 100644
> --- a/arch/xtensa/include/uapi/asm/mman.h
> +++ b/arch/xtensa/include/uapi/asm/mman.h
> @@ -14,6 +14,8 @@
>  #ifndef _XTENSA_MMAN_H
>  #define _XTENSA_MMAN_H
>  
> +#include <asm-generic/hugetlb_encode.h>
> +
>  /*
>   * Protections are chosen from these bits, OR'd together.  The
>   * implementation does not necessarily support PROT_EXEC or PROT_WRITE
> @@ -107,15 +109,11 @@
>  #define MAP_FILE	0
>  
>  /*
> - * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
> - * This gives us 6 bits, which is enough until someone invents 128 bit address
> - * spaces.
> - *
> - * Assume these are all power of twos.
> - * When 0 use the default page size.
> + * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
> + * size other than the default is desired.  See hugetlb_encode.h
>   */
> -#define MAP_HUGE_SHIFT	26
> -#define MAP_HUGE_MASK	0x3f
> +#define MAP_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
> +#define MAP_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
>  
>  #define PKEY_DISABLE_ACCESS	0x1
>  #define PKEY_DISABLE_WRITE	0x2
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index 8c27db0..00d56b8 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -1,6 +1,8 @@
>  #ifndef __ASM_GENERIC_MMAN_COMMON_H
>  #define __ASM_GENERIC_MMAN_COMMON_H
>  
> +#include <asm-generic/hugetlb_encode.h>
> +
>  /*
>   Author: Michael S. Tsirkin <mst@mellanox.co.il>, Mellanox Technologies Ltd.
>   Based on: asm-xxx/mman.h
> @@ -69,8 +71,8 @@
>   * Assume these are all power of twos.
>   * When 0 use the default page size.
>   */
> -#define MAP_HUGE_SHIFT	26
> -#define MAP_HUGE_MASK	0x3f
> +#define MAP_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
> +#define MAP_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
>  
>  #define PKEY_DISABLE_ACCESS	0x1
>  #define PKEY_DISABLE_WRITE	0x2
> -- 
> 2.7.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
