Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9EDD46B597A
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:00:02 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so3234874edc.6
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 10:00:02 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130058.outbound.protection.outlook.com. [40.107.13.58])
        by mx.google.com with ESMTPS id k10-v6si2350866ejh.260.2018.11.30.10.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 10:00:01 -0800 (PST)
From: Catalin Marinas <Catalin.Marinas@arm.com>
Subject: Re: [PATCH V3 4/5] arm64: mm: introduce 52-bit userspace support
Date: Fri, 30 Nov 2018 17:59:59 +0000
Message-ID: <20181130175956.GJ43329@arrakis.emea.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-5-steve.capper@arm.com>
In-Reply-To: <20181114133920.7134-5-steve.capper@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3BA8EACF337C7D42AD098D6042E872A6@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <Steve.Capper@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>

On Wed, Nov 14, 2018 at 01:39:19PM +0000, Steve Capper wrote:
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pg=
table.h
> index 50b1ef8584c0..19736520b724 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -616,11 +616,21 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
>  #define pgd_ERROR(pgd)__pgd_error(__FILE__, __LINE__, pgd_val(pgd))
>
>  /* to find an entry in a page-table-directory */
> -#define pgd_index(addr)(((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1))
> +#define pgd_index(addr, ptrs)(((addr) >> PGDIR_SHIFT) & ((ptrs) - 1))
> +#define _pgd_offset_raw(pgd, addr, ptrs) ((pgd) + pgd_index(addr, ptrs))
> +#define pgd_offset_raw(pgd, addr)(_pgd_offset_raw(pgd, addr, PTRS_PER_PG=
D))
>
> -#define pgd_offset_raw(pgd, addr)((pgd) + pgd_index(addr))
> +static inline pgd_t *pgd_offset(const struct mm_struct *mm, unsigned lon=
g addr)
> +{
> +pgd_t *ret;
> +
> +if (IS_ENABLED(CONFIG_ARM64_52BIT_VA) && (mm !=3D &init_mm))
> +ret =3D _pgd_offset_raw(mm->pgd, addr, 1ULL << (vabits_user - PGDIR_SHIF=
T));

I think we can make this a constant since the additional 4 bits of the
user address should be 0 on a 48-bit VA. Once we get the 52-bit kernel
VA supported, we can probably revert back to a single macro.

Another option is to change  PTRS_PER_PGD etc. to cover the whole
52-bit, including the swapper_pg_dir, but with offsetting the TTBR1_EL1
setting to keep the 48-bit kernel VA (for the time being).

--
Catalin
IMPORTANT NOTICE: The contents of this email and any attachments are confid=
ential and may also be privileged. If you are not the intended recipient, p=
lease notify the sender immediately and do not disclose the contents to any=
 other person, use it for any purpose, or store or copy the information in =
any medium. Thank you.
