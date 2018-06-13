Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 46BCA6B0273
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:46:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g5-v6so1173811pgv.12
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:46:36 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a186-v6si2792090pgc.453.2018.06.13.11.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:46:35 -0700 (PDT)
Subject: Re: [PATCHv3 17/17] x86: Introduce CONFIG_X86_INTEL_MKTME
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-18-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <43ea6cea-b88c-e08a-3f4e-64c39b20ae59@intel.com>
Date: Wed, 13 Jun 2018 11:46:34 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-18-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> Add new config option to enabled/disable Multi-Key Total Memory
> Encryption support.
> 
> MKTME uses MEMORY_PHYSICAL_PADDING to reserve enough space in per-KeyID
> direct mappings for memory hotplug.

Isn't it really *the* direct mapping primarily?  We make all of them
larger, but the direct mapping is impacted too.  This makes it sound
like it applies only to the MKTME mappings.

> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 4fa2cf807321..d013495bb4ae 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1513,6 +1513,23 @@ config ARCH_USE_MEMREMAP_PROT
>  	def_bool y
>  	depends on AMD_MEM_ENCRYPT
>  
> +config X86_INTEL_MKTME
> +	bool "Intel Multi-Key Total Memory Encryption"
> +	select DYNAMIC_PHYSICAL_MASK
> +	select PAGE_EXTENSION
> +	depends on X86_64 && CPU_SUP_INTEL
> +	---help---
> +	  Say yes to enable support for Multi-Key Total Memory Encryption.
> +	  This requires Intel processor that has support of the feature.

"requires an Intel processor"...

> +	  Multikey Total Memory Encryption (MKTME) is a technology that allows
> +	  transparent memory encryption in upcoming Intel platforms.

"in an upcoming"

> +	  MKTME is built on top of TME. TME allows encryption of the entirety
> +	  of system memory using a single key. MKTME allows to have multiple

"allows having multiple"...

> +	  encryption domains, each having own key -- different memory pages can
> +	  be encrypted with different keys.
> +
>  # Common NUMA Features
>  config NUMA
>  	bool "Numa Memory Allocation and Scheduler Support"
> @@ -2189,7 +2206,7 @@ config RANDOMIZE_MEMORY
>  
>  config MEMORY_PHYSICAL_PADDING
>  	hex "Physical memory mapping padding" if EXPERT
> -	depends on RANDOMIZE_MEMORY
> +	depends on RANDOMIZE_MEMORY || X86_INTEL_MKTME
>  	default "0xa" if MEMORY_HOTPLUG
>  	default "0x0"
>  	range 0x1 0x40 if MEMORY_HOTPLUG
> 
