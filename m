Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD8C56B0389
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 15:04:45 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id e12so173145268ioj.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:04:45 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g98si9464742iod.106.2017.03.06.12.04.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 12:04:44 -0800 (PST)
Subject: Re: [PATCHv4 28/33] x86/mm: add support of additional page table
 level during early boot
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
 <20170306135357.3124-29-kirill.shutemov@linux.intel.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <7e78a76a-f5e8-bb60-e5be-a91a84faa1f9@oracle.com>
Date: Mon, 6 Mar 2017 15:05:49 -0500
MIME-Version: 1.0
In-Reply-To: <20170306135357.3124-29-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xen-devel <xen-devel@lists.xen.org>, Juergen Gross <jgross@suse.com>


> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/p=
gtable_64.h
> index 9991224f6238..c9e41f1599dd 100644
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -14,15 +14,17 @@
>  #include <linux/bitops.h>
>  #include <linux/threads.h>
> =20
> +extern p4d_t level4_kernel_pgt[512];
> +extern p4d_t level4_ident_pgt[512];
>  extern pud_t level3_kernel_pgt[512];
>  extern pud_t level3_ident_pgt[512];
>  extern pmd_t level2_kernel_pgt[512];
>  extern pmd_t level2_fixmap_pgt[512];
>  extern pmd_t level2_ident_pgt[512];
>  extern pte_t level1_fixmap_pgt[512];
> -extern pgd_t init_level4_pgt[];
> +extern pgd_t init_top_pgt[];
> =20
> -#define swapper_pg_dir init_level4_pgt
> +#define swapper_pg_dir init_top_pgt
> =20
>  extern void paging_init(void);
> =20


This means you also need


diff --git a/arch/x86/xen/xen-pvh.S b/arch/x86/xen/xen-pvh.S
index 5e24671..e1a5fbe 100644
--- a/arch/x86/xen/xen-pvh.S
+++ b/arch/x86/xen/xen-pvh.S
@@ -87,7 +87,7 @@ ENTRY(pvh_start_xen)
        wrmsr
=20
        /* Enable pre-constructed page tables. */
-       mov $_pa(init_level4_pgt), %eax
+       mov $_pa(init_top_pgt), %eax
        mov %eax, %cr3
        mov $(X86_CR0_PG | X86_CR0_PE), %eax
        mov %eax, %cr0


-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
