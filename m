Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 935506B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 07:56:47 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id y19so38521337wgg.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 04:56:46 -0800 (PST)
Received: from cpsmtpb-ews02.kpnxchange.com (cpsmtpb-ews02.kpnxchange.com. [213.75.39.5])
        by mx.google.com with ESMTP id i4si23273247wic.32.2015.02.02.04.56.45
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 04:56:45 -0800 (PST)
Message-ID: <1422881799.19005.31.camel@x220>
Subject: Re: [PATCHv2 05/19] ia64: expose number of page table levels on
 Kconfig level
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 02 Feb 2015 13:56:39 +0100
In-Reply-To: <1422663426-220551-1-git-send-email-kirill.shutemov@linux.intel.com>
References: 
	<1422629008-13689-6-git-send-email-kirill.shutemov@linux.intel.com>
	 <1422663426-220551-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Sat, 2015-01-31 at 02:17 +0200, Kirill A. Shutemov wrote:
> We would want to use number of page table level to define mm_struct.
> Let's expose it as CONFIG_PGTABLE_LEVELS.
> 
> We need to define PGTABLE_LEVELS before sourcing init/Kconfig:
> arch/Kconfig will define default value and it's sourced from init/Kconfig.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> ---
>  v2: fix default for IA64_PAGE_SIZE_64KB
> ---
>  arch/ia64/Kconfig                | 18 +++++-------------
>  arch/ia64/include/asm/page.h     |  4 ++--
>  arch/ia64/include/asm/pgalloc.h  |  4 ++--
>  arch/ia64/include/asm/pgtable.h  | 12 ++++++------
>  arch/ia64/kernel/ivt.S           | 12 ++++++------
>  arch/ia64/kernel/machine_kexec.c |  4 ++--
>  6 files changed, 23 insertions(+), 31 deletions(-)
> 
> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index 074e52bf815c..4f9a6661491b 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -1,3 +1,8 @@
> +config PGTABLE_LEVELS
> +	int "Page Table Levels" if !IA64_PAGE_SIZE_64KB
> +	range 3 4 if !IA64_PAGE_SIZE_64KB
> +	default 3
> +

Why didn't you choose to make this something like
    config PGTABLE_LEVELS
	int
	default 3 if PGTABLE_3
	default 4 if PGTABLE_4

>  source "init/Kconfig"
>  
>  source "kernel/Kconfig.freezer"
> @@ -286,19 +291,6 @@ config IA64_PAGE_SIZE_64KB
>  
>  endchoice
>  
> -choice
> -	prompt "Page Table Levels"
> -	default PGTABLE_3
> -
> -config PGTABLE_3
> -	bool "3 Levels"
> -
> -config PGTABLE_4
> -	depends on !IA64_PAGE_SIZE_64KB
> -	bool "4 Levels"
> -
> -endchoice
> -
>  if IA64_HP_SIM
>  config HZ
>  	default 32

... and drop this hunk (ie, keep this choice as it is)? That would make
upgrading to a release that uses PGTABLE_LEVELS do the right thing
automagically, wouldn't it? As currently in the !IA64_PAGE_SIZE_64KB
case people need to reconfigure their "Page Table Levels".


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
