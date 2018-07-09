Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 580526B02B0
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:37:05 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id r10-v6so16939299ioh.7
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:37:05 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k130-v6si10756557ita.16.2018.07.09.11.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:37:04 -0700 (PDT)
Date: Mon, 9 Jul 2018 14:36:56 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv4 18/18] x86: Introduce CONFIG_X86_INTEL_MKTME
Message-ID: <20180709183656.GK6873@char.US.ORACLE.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 26, 2018 at 05:22:45PM +0300, Kirill A. Shutemov wrote:
> Add new config option to enabled/disable Multi-Key Total Memory
> Encryption support.
> 
> MKTME uses MEMORY_PHYSICAL_PADDING to reserve enough space in per-KeyID
> direct mappings for memory hotplug.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/Kconfig | 19 ++++++++++++++++++-
>  1 file changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index fa5e1ec09247..9a843bd63108 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1523,6 +1523,23 @@ config ARCH_USE_MEMREMAP_PROT
>  	def_bool y
>  	depends on AMD_MEM_ENCRYPT
>  
> +config X86_INTEL_MKTME

Rip out the X86?
> +	bool "Intel Multi-Key Total Memory Encryption"
> +	select DYNAMIC_PHYSICAL_MASK
> +	select PAGE_EXTENSION

And maybe select 5-page?
> +	depends on X86_64 && CPU_SUP_INTEL
> +	---help---
> +	  Say yes to enable support for Multi-Key Total Memory Encryption.
> +	  This requires an Intel processor that has support of the feature.
> +
> +	  Multikey Total Memory Encryption (MKTME) is a technology that allows
> +	  transparent memory encryption in and upcoming Intel platforms.

How about saying which CPUs? Or just dropping this?
> +
> +	  MKTME is built on top of TME. TME allows encryption of the entirety
> +	  of system memory using a single key. MKTME allows having multiple
> +	  encryption domains, each having own key -- different memory pages can
> +	  be encrypted with different keys.
> +
>  # Common NUMA Features
>  config NUMA
>  	bool "Numa Memory Allocation and Scheduler Support"
> @@ -2199,7 +2216,7 @@ config RANDOMIZE_MEMORY
>  
>  config MEMORY_PHYSICAL_PADDING
>  	hex "Physical memory mapping padding" if EXPERT
> -	depends on RANDOMIZE_MEMORY
> +	depends on RANDOMIZE_MEMORY || X86_INTEL_MKTME
>  	default "0xa" if MEMORY_HOTPLUG
>  	default "0x0"
>  	range 0x1 0x40 if MEMORY_HOTPLUG
> -- 
> 2.18.0
> 
