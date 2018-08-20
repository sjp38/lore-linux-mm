Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7786B17B7
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 02:46:33 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j6-v6so12279798wrr.15
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 23:46:33 -0700 (PDT)
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id z9-v6si6525757wra.207.2018.08.19.23.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 19 Aug 2018 23:46:31 -0700 (PDT)
Subject: Re: [PATCH v6 00/11] hugetlb: Factorize hugetlb architecture
 primitives
References: <20180806175711.24438-1-alex@ghiti.fr>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <81078a7f-09cf-7f19-f6bb-8a1f4968d6fb@ghiti.fr>
Date: Mon, 20 Aug 2018 08:45:10 +0200
MIME-Version: 1.0
In-Reply-To: <20180806175711.24438-1-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

Hi Michal,

This patchset got acked, tested and reviewed by quite a few people, and 
it has been suggested
that it should be included in -mm tree: could you tell me if something 
else needs to be done for
its inclusion ?

Thanks for your time,

Alex


On 08/06/2018 07:57 PM, Alexandre Ghiti wrote:
> [CC linux-mm for inclusion in -mm tree]
>                                                                                   
> In order to reduce copy/paste of functions across architectures and then
> make riscv hugetlb port (and future ports) simpler and smaller, this
> patchset intends to factorize the numerous hugetlb primitives that are
> defined across all the architectures.
>                                                                                   
> Except for prepare_hugepage_range, this patchset moves the versions that
> are just pass-through to standard pte primitives into
> asm-generic/hugetlb.h by using the same #ifdef semantic that can be
> found in asm-generic/pgtable.h, i.e. __HAVE_ARCH_***.
>                                                                                   
> s390 architecture has not been tackled in this serie since it does not
> use asm-generic/hugetlb.h at all.
>                                                                                   
> This patchset has been compiled on all addressed architectures with
> success (except for parisc, but the problem does not come from this
> series).
>                                                                                   
> v6:
>    - Remove nohash/32 and book3s/32 powerpc specific implementations in
>      order to use the generic ones.
>    - Add all the Reviewed-by, Acked-by and Tested-by in the commits,
>      thanks to everyone.
>                                                                                   
> v5:
>    As suggested by Mike Kravetz, no need to move the #include
>    <asm-generic/hugetlb.h> for arm and x86 architectures, let it live at
>    the top of the file.
>                                                                                   
> v4:
>    Fix powerpc build error due to misplacing of #include
>    <asm-generic/hugetlb.h> outside of #ifdef CONFIG_HUGETLB_PAGE, as
>    pointed by Christophe Leroy.
>                                                                                   
> v1, v2, v3:
>    Same version, just problems with email provider and misuse of
>    --batch-size option of git send-email
>
> Alexandre Ghiti (11):
>    hugetlb: Harmonize hugetlb.h arch specific defines with pgtable.h
>    hugetlb: Introduce generic version of hugetlb_free_pgd_range
>    hugetlb: Introduce generic version of set_huge_pte_at
>    hugetlb: Introduce generic version of huge_ptep_get_and_clear
>    hugetlb: Introduce generic version of huge_ptep_clear_flush
>    hugetlb: Introduce generic version of huge_pte_none
>    hugetlb: Introduce generic version of huge_pte_wrprotect
>    hugetlb: Introduce generic version of prepare_hugepage_range
>    hugetlb: Introduce generic version of huge_ptep_set_wrprotect
>    hugetlb: Introduce generic version of huge_ptep_set_access_flags
>    hugetlb: Introduce generic version of huge_ptep_get
>
>   arch/arm/include/asm/hugetlb-3level.h        | 32 +---------
>   arch/arm/include/asm/hugetlb.h               | 30 ----------
>   arch/arm64/include/asm/hugetlb.h             | 39 +++---------
>   arch/ia64/include/asm/hugetlb.h              | 47 ++-------------
>   arch/mips/include/asm/hugetlb.h              | 40 +++----------
>   arch/parisc/include/asm/hugetlb.h            | 33 +++--------
>   arch/powerpc/include/asm/book3s/32/pgtable.h |  6 --
>   arch/powerpc/include/asm/book3s/64/pgtable.h |  1 +
>   arch/powerpc/include/asm/hugetlb.h           | 43 ++------------
>   arch/powerpc/include/asm/nohash/32/pgtable.h |  6 --
>   arch/powerpc/include/asm/nohash/64/pgtable.h |  1 +
>   arch/sh/include/asm/hugetlb.h                | 54 ++---------------
>   arch/sparc/include/asm/hugetlb.h             | 40 +++----------
>   arch/x86/include/asm/hugetlb.h               | 69 ----------------------
>   include/asm-generic/hugetlb.h                | 88 +++++++++++++++++++++++++++-
>   15 files changed, 135 insertions(+), 394 deletions(-)
>
