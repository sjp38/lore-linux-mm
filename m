Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB71C6B0437
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 10:52:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z109so6496022wrb.1
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 07:52:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g26si2417880wrc.30.2017.04.06.07.52.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 07:52:13 -0700 (PDT)
Subject: Re: [PATCH 7/8] x86: Enable 5-level paging support
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-8-kirill.shutemov@linux.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <469e1232-617c-daaa-90a6-a90d6f80059f@suse.com>
Date: Thu, 6 Apr 2017 16:52:11 +0200
MIME-Version: 1.0
In-Reply-To: <20170406140106.78087-8-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/04/17 16:01, Kirill A. Shutemov wrote:
> Most of things are in place and we can enable support of 5-level paging.
> 
> Enabling XEN with 5-level paging requires more work. The patch makes XEN
> dependent on !X86_5LEVEL.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/Kconfig     | 5 +++++
>  arch/x86/xen/Kconfig | 1 +
>  2 files changed, 6 insertions(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 4e153e93273f..7a76dcac357e 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -318,6 +318,7 @@ config FIX_EARLYCON_MEM
>  
>  config PGTABLE_LEVELS
>  	int
> +	default 5 if X86_5LEVEL
>  	default 4 if X86_64
>  	default 3 if X86_PAE
>  	default 2
> @@ -1390,6 +1391,10 @@ config X86_PAE
>  	  has the cost of more pagetable lookup overhead, and also
>  	  consumes more pagetable space per process.
>  
> +config X86_5LEVEL
> +	bool "Enable 5-level page tables support"
> +	depends on X86_64
> +
>  config ARCH_PHYS_ADDR_T_64BIT
>  	def_bool y
>  	depends on X86_64 || X86_PAE
> diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
> index 76b6dbd627df..b90d481ce5a1 100644
> --- a/arch/x86/xen/Kconfig
> +++ b/arch/x86/xen/Kconfig
> @@ -5,6 +5,7 @@
>  config XEN
>  	bool "Xen guest support"
>  	depends on PARAVIRT
> +	depends on !X86_5LEVEL
>  	select PARAVIRT_CLOCK
>  	select XEN_HAVE_PVMMU
>  	select XEN_HAVE_VPMU
> 

Just a heads up: this last change will conflict with the Xen tree.

Can't we just ignore the additional level in Xen pv mode and run with
4 levels instead?


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
