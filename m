Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8A95B6B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 23:42:56 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id k129so282420269yke.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 20:42:56 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id b137si58644638ywe.363.2016.01.05.20.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 20:42:55 -0800 (PST)
Received: by mail-yk0-x22f.google.com with SMTP id x67so304722719ykd.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 20:42:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5b0243c5df825ad0841f4bb5584cd15d3f013f09.1451952351.git.tony.luck@intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
	<5b0243c5df825ad0841f4bb5584cd15d3f013f09.1451952351.git.tony.luck@intel.com>
Date: Tue, 5 Jan 2016 20:42:55 -0800
Message-ID: <CAPcyv4jjWT3Od_XvGpVb+O7MT95mBRXviPXi1zUfM5o+kN4CUA@mail.gmail.com>
Subject: Re: [PATCH v7 3/3] x86, mce: Add __mcsafe_copy()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Thu, Dec 31, 2015 at 11:43 AM, Tony Luck <tony.luck@intel.com> wrote:
> Make use of the EXTABLE_FAULT exception table entries. This routine
> returns a structure to indicate the result of the copy:
>
> struct mcsafe_ret {
>         u64 trapnr;
>         u64 remain;
> };
>
> If the copy is successful, then both 'trapnr' and 'remain' are zero.
>
> If we faulted during the copy, then 'trapnr' will say which type
> of trap (X86_TRAP_PF or X86_TRAP_MC) and 'remain' says how many
> bytes were not copied.
>
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/Kconfig                 |  10 +++
>  arch/x86/include/asm/string_64.h |  10 +++
>  arch/x86/kernel/x8664_ksyms_64.c |   4 ++
>  arch/x86/lib/memcpy_64.S         | 136 +++++++++++++++++++++++++++++++++++++++
>  4 files changed, 160 insertions(+)
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 96d058a87100..42d26b4d1ec4 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1001,6 +1001,16 @@ config X86_MCE_INJECT
>           If you don't know what a machine check is and you don't do kernel
>           QA it is safe to say n.
>
> +config MCE_KERNEL_RECOVERY
> +       bool "Recovery from machine checks in special kernel memory copy functions"
> +       default n
> +       depends on X86_MCE && X86_64
> +       ---help---
> +         This option provides a new memory copy function mcsafe_memcpy()
> +         that is annotated to allow the machine check handler to return
> +         to an alternate code path to return an error to the caller instead
> +         of crashing the system. Say yes if you have a driver that uses this.
> +
>  config X86_THERMAL_VECTOR
>         def_bool y
>         depends on X86_MCE_INTEL
> diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
> index ff8b9a17dc4b..16a8f0e56e4a 100644
> --- a/arch/x86/include/asm/string_64.h
> +++ b/arch/x86/include/asm/string_64.h
> @@ -78,6 +78,16 @@ int strcmp(const char *cs, const char *ct);
>  #define memset(s, c, n) __memset(s, c, n)
>  #endif
>
> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +struct mcsafe_ret {
> +       u64 trapnr;
> +       u64 remain;
> +};

Can we move this definition outside of the CONFIG_MCE_KERNEL_RECOVERY
ifdef guard?  On a test integration branch the kbuild robot caught the
following:

   In file included from include/linux/pmem.h:21:0,
                    from drivers/acpi/nfit.c:22:
   arch/x86/include/asm/pmem.h: In function 'arch_memcpy_from_pmem':
>> arch/x86/include/asm/pmem.h:55:21: error: storage size of 'ret' isn't known
      struct mcsafe_ret ret;
                        ^
>> arch/x86/include/asm/pmem.h:57:9: error: implicit declaration of function '__mcsafe_copy' [-Werror=implicit-function-declaration]
      ret = __mcsafe_copy(dst, (void __force *) src, n);
            ^
>> arch/x86/include/asm/pmem.h:55:21: warning: unused variable 'ret' [-Wunused-variable]
      struct mcsafe_ret ret;
                        ^
   cc1: some warnings being treated as errors

vim +55 arch/x86/include/asm/pmem.h

    49  }
    50
    51  static inline int arch_memcpy_from_pmem(void *dst, const void
__pmem *src,
    52                  size_t n)
    53  {
    54          if (IS_ENABLED(CONFIG_MCE_KERNEL_RECOVERY)) {
  > 55                  struct mcsafe_ret ret;
    56
  > 57                  ret = __mcsafe_copy(dst, (void __force *) src, n);
    58                  if (ret.remain)
    59                          return -EIO;
    60                  return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
