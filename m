Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 765336B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:16:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b13so161652712pgn.4
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 19:16:55 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 89si1319703pfr.232.2017.06.20.19.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 19:16:54 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Date: Wed, 21 Jun 2017 02:12:27 +0000
Message-ID: <20170621021226.GA18024@hori1.linux.bs1.fc.nec.co.jp>
References: <20170616190200.6210-1-tony.luck@intel.com>
In-Reply-To: <20170616190200.6210-1-tony.luck@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <703F58796A775E4D9E4833B6EE7B71B9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Borislav Petkov <bp@suse.de>, Dave Hansen <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

(drop stable from CC)

On Fri, Jun 16, 2017 at 12:02:00PM -0700, Luck, Tony wrote:
> From: Tony Luck <tony.luck@intel.com>
>=20
> Speculative processor accesses may reference any memory that has a
> valid page table entry.  While a speculative access won't generate
> a machine check, it will log the error in a machine check bank. That
> could cause escalation of a subsequent error since the overflow bit
> will be then set in the machine check bank status register.
>=20
> Code has to be double-plus-tricky to avoid mentioning the 1:1 virtual
> address of the page we want to map out otherwise we may trigger the
> very problem we are trying to avoid.  We use a non-canonical address
> that passes through the usual Linux table walking code to get to the
> same "pte".
>=20
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: x86@kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
> Thanks to Dave Hansen for reviewing several iterations of this.
>=20
>  arch/x86/include/asm/page_64.h   |  4 ++++
>  arch/x86/kernel/cpu/mcheck/mce.c | 35 ++++++++++++++++++++++++++++++++++=
+
>  include/linux/mm_inline.h        |  6 ++++++
>  mm/memory-failure.c              |  2 ++
>  4 files changed, 47 insertions(+)
>=20
> diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_6=
4.h
> index b4a0d43248cf..b50df06ad251 100644
> --- a/arch/x86/include/asm/page_64.h
> +++ b/arch/x86/include/asm/page_64.h
> @@ -51,6 +51,10 @@ static inline void clear_page(void *page)
> =20
>  void copy_page(void *to, void *from);
> =20
> +#ifdef CONFIG_X86_MCE
> +#define arch_unmap_kpfn arch_unmap_kpfn
> +#endif
> +
>  #endif	/* !__ASSEMBLY__ */
> =20
>  #ifdef CONFIG_X86_VSYSCALL_EMULATION
> diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mchec=
k/mce.c
> index 5cfbaeb6529a..56563db0b2be 100644
> --- a/arch/x86/kernel/cpu/mcheck/mce.c
> +++ b/arch/x86/kernel/cpu/mcheck/mce.c
> @@ -51,6 +51,7 @@
>  #include <asm/mce.h>
>  #include <asm/msr.h>
>  #include <asm/reboot.h>
> +#include <asm/set_memory.h>
> =20
>  #include "mce-internal.h"
> =20
> @@ -1056,6 +1057,40 @@ static int do_memory_failure(struct mce *m)
>  	return ret;
>  }
> =20
> +#ifdef CONFIG_X86_64
> +
> +void arch_unmap_kpfn(unsigned long pfn)
> +{
> +	unsigned long decoy_addr;
> +
> +	/*
> +	 * Unmap this page from the kernel 1:1 mappings to make sure
> +	 * we don't log more errors because of speculative access to
> +	 * the page.
> +	 * We would like to just call:
> +	 *	set_memory_np((unsigned long)pfn_to_kaddr(pfn), 1);
> +	 * but doing that would radically increase the odds of a
> +	 * speculative access to the posion page because we'd have
> +	 * the virtual address of the kernel 1:1 mapping sitting
> +	 * around in registers.
> +	 * Instead we get tricky.  We create a non-canonical address
> +	 * that looks just like the one we want, but has bit 63 flipped.
> +	 * This relies on set_memory_np() not checking whether we passed
> +	 * a legal address.
> +	 */
> +
> +#if PGDIR_SHIFT + 9 < 63 /* 9 because cpp doesn't grok ilog2(PTRS_PER_PG=
D) */
> +	decoy_addr =3D (pfn << PAGE_SHIFT) + (PAGE_OFFSET ^ BIT(63));
> +#else
> +#error "no unused virtual bit available"
> +#endif
> +
> +	if (set_memory_np(decoy_addr, 1))
> +		pr_warn("Could not invalidate pfn=3D0x%lx from 1:1 map \n", pfn);
> +
> +}
> +#endif
> +
>  /*
>   * The actual machine check handler. This only handles real
>   * exceptions when something got corrupted coming in through int 18.
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index e030a68ead7e..25438b2b6f22 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -126,4 +126,10 @@ static __always_inline enum lru_list page_lru(struct=
 page *page)
> =20
>  #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
> =20
> +#ifdef arch_unmap_kpfn
> +extern void arch_unmap_kpfn(unsigned long pfn);
> +#else
> +static __always_inline void arch_unmap_kpfn(unsigned long pfn) { }
> +#endif
> +
>  #endif
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 342fac9ba89b..9479e190dcbd 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1071,6 +1071,8 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  		return 0;
>  	}
> =20
> +	arch_unmap_kpfn(pfn);
> +

We had better have a reverse operation of this to cancel the unmapping
when unpoisoning?

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
