Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61D78C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 23:01:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CFC8206C0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 23:01:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="eM24BRUA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CFC8206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C998E0145; Fri, 22 Feb 2019 18:01:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DC698E0141; Fri, 22 Feb 2019 18:01:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A4998E0145; Fri, 22 Feb 2019 18:01:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6193C8E0141
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 18:01:20 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 187so2459154ybv.0
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 15:01:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=g0xRp3ILeOxeOjpu2zVdwE+YAA0zoG6o4Ccb2GVxlZo=;
        b=ui540FemYofRqpCrk4mSkymX/HovR6/T046MmjSCpCFaPEpjzWKwlHaQnPZgxRYhFt
         rl3dL4HBaV668QnjFXpu1f/7O5kepOyLaw0ayob+Uu8xWnReLLpR5Wt/Sg9sCwXLk4BO
         aZjRTMMLB/JA/Sth9gcii2axgj/563RbdlnNKucT2mRyur534kSk9K5B7ZwdR3pTYrme
         G0B5MVoNgLJPEVrGCJ/IkBhH02YIaondbtVBfQykGgc1gLS3jISxXw2uNRXyW3zYAE/T
         aUL4fZiMKYKt/F7VbwydcwaRL4FHMNGZjCkooFGUDJf/maVaVCy/FtFocvY0T/QuMiMi
         UdOA==
X-Gm-Message-State: AHQUAuYb1qv7A4OL5y1g6yAlvTl+gsPh2rVsDfvSjjiVhM4eseJuNGjz
	sbne2Ovg56wZX6iZqsJywlGdPI7Z8EAASj4K82Jcp07bHRuCgg9RVtnWxvwtUqTC08u2KVKME+M
	8aPnVlxAqIvneZb7jN3cySMfBlq55vvc8sdeBelE6/Y7EBRGHk/CjNXOMZn7i0EgCpg==
X-Received: by 2002:a81:4907:: with SMTP id w7mr5490819ywa.150.1550876480050;
        Fri, 22 Feb 2019 15:01:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia0KD2gYYpEIBE+U/NqExiRuRKAv3oLINeAD9qPGJ3HnlKbRa45xbc0iVnkCXzMqQqA2q+y
X-Received: by 2002:a81:4907:: with SMTP id w7mr5490738ywa.150.1550876479090;
        Fri, 22 Feb 2019 15:01:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550876479; cv=none;
        d=google.com; s=arc-20160816;
        b=BGtZqThtBnML3fxTix8mlbBA+kmaegtml7+HtNI3vhGnlS8wO1F4pqFJOD7f/KNxCZ
         2hMyDefw/zOcjbGniKK2x+GF9DuXMyWgwhz+joWiOuDH+8dArmnUNmeE3ZKYaCR52Rk5
         nJIjgAGqxi4DvRgpwcUEiT/LD9BcneaVQ0ysmQcPYz7flUSA6c+aVKvxwVYJpJ1LNfOO
         xBuEAeuSqzRYlnV7k2h4ZRbeKswC1viMvTMHb0PSNQxH3meDZv99JBbtWZlEaKCGSPTz
         zxguX3N17oi6Fqemy6+phDDUpXBDXSaAyo0Pami4YQ84AJuFtYZXVe6BPqRzcBwO5Ul8
         JMJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=g0xRp3ILeOxeOjpu2zVdwE+YAA0zoG6o4Ccb2GVxlZo=;
        b=D8xmgAjhV8gtRUUc0ziWa8pNmUm8A0HxfqrrRIF1yIVIsyga9I+AUlRbjyIuT+18z4
         Jk9bPOK9U+bunrhOzrcP98eQe2WWFS8CpBKZJDIP7glzrWREoNj7a0DqnwGoxM/DRXwM
         rT5oHql9+EsSc6EIKxdhmkbC2tUFwlvgO0OZQGu7ihbIGOT5spbuV/o+l3JKUwcLL68j
         /I3jPxe2xAN6gqD313khYRgm6zgW1So8roBFfhTNzmjSgZcxSC23kuvdlacWgQM/kWMz
         FlM4aFgdFhvWNU2wArhORv1viqTOC9bklw1K3usQJjqoqxjRYJkLWxukxNRREMtyuZyR
         6pXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eM24BRUA;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id j67si1652850ybj.430.2019.02.22.15.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 15:01:19 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eM24BRUA;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c707f460000>; Fri, 22 Feb 2019 15:01:26 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 15:01:18 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 22 Feb 2019 15:01:18 -0800
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 23:01:17 +0000
Subject: Re: [PATCH v5 9/9] mm/mmu_notifier: set MMU_NOTIFIER_USE_CHANGE_PTE
 flag where appropriate v2
To: <jglisse@redhat.com>, <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-kernel@vger.kernel.org>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, Andrea
 Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler
	<zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini
	<pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, John Hubbard <jhubbard@nvidia.com>,
	<kvm@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-rdma@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <20190219200430.11130-10-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <af766eb9-c8a4-a8f7-6aad-f56845d514ce@nvidia.com>
Date: Fri, 22 Feb 2019 15:01:16 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190219200430.11130-10-jglisse@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550876486; bh=g0xRp3ILeOxeOjpu2zVdwE+YAA0zoG6o4Ccb2GVxlZo=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=eM24BRUA73+1ip4wo3rpUTGtO64UyMx9hYRGsuD4A68r1lc4FCpJBKcViWtsD25hT
	 Wl5BtpO+6r4C2z3u0ZhDUAsrqJuG6RKgFrv2G521N5bO0IpQueYY/I1KhpzitaRR2N
	 /kkxKEM8QASsNGtbUyLYj6CN5M9+nlpTQB3SX2EyYFNrymIozGmWqqDoFyLcjUPX/E
	 pv3+vzjJu0LznDx5ybpIsXRXIXYLfMVtnVENpef/9v5GiazKruN7ckwB0jzhk0akhR
	 16JHkIvnx2qBFirICIVU25yEPIHKlE3Th7fZN3clXtJy8ixlxByy3TzpzhOnZbP1fs
	 5KEzTjN2hOyLQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/19/19 12:04 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> When notifying change for a range use MMU_NOTIFIER_USE_CHANGE_PTE flag
> for page table update that use set_pte_at_notify() and where the we are
> going either from read and write to read only with same pfn or read only
> to read and write with new pfn.
>=20
> Note that set_pte_at_notify() itself should only be use in rare cases
> ie we do not want to use it when we are updating a significant range of
> virtual addresses and thus a significant number of pte. Instead for
> those cases the event provided to mmu notifer invalidate_range_start()
> callback should be use for optimization.
>=20
> Changes since v1:
>      - Use the new unsigned flags field in struct mmu_notifier_range
>      - Use the new flags parameter to mmu_notifier_range_init()
>      - Explicitly list all the patterns where we can use change_pte()
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Xu <peterx@redhat.com>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>   include/linux/mmu_notifier.h | 34 ++++++++++++++++++++++++++++++++--
>   mm/ksm.c                     | 11 ++++++-----
>   mm/memory.c                  |  5 +++--
>   3 files changed, 41 insertions(+), 9 deletions(-)
>=20
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index b6c004bd9f6a..0230a4b06b46 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -40,6 +40,26 @@ enum mmu_notifier_event {
>   	MMU_NOTIFY_SOFT_DIRTY,
>   };
>  =20
> +/*
> + * @MMU_NOTIFIER_RANGE_BLOCKABLE: can the mmu notifier range_start/range=
_end
> + * callback block or not ? If set then the callback can block.
> + *
> + * @MMU_NOTIFIER_USE_CHANGE_PTE: only set when the page table it updated=
 with
> + * the set_pte_at_notify() the valid patterns for this are:
> + *      - pte read and write to read only same pfn
> + *      - pte read only to read and write (pfn can change or stay the sa=
me)
> + *      - pte read only to read only with different pfn
> + * It is illegal to set in any other circumstances.
> + *
> + * Note that set_pte_at_notify() should not be use outside of the above =
cases.
> + * When updating a range in batch (like write protecting a range) it is =
better
> + * to rely on invalidate_range_start() and struct mmu_notifier_range to =
infer
> + * the kind of update that is happening (as an example you can look at t=
he
> + * mmu_notifier_range_update_to_read_only() function).
> + */
> +#define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
> +#define MMU_NOTIFIER_USE_CHANGE_PTE (1 << 1)
> +
>   #ifdef CONFIG_MMU_NOTIFIER
>  =20
>   /*
> @@ -55,8 +75,6 @@ struct mmu_notifier_mm {
>   	spinlock_t lock;
>   };
>  =20
> -#define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
> -
>   struct mmu_notifier_range {
>   	struct vm_area_struct *vma;
>   	struct mm_struct *mm;
> @@ -268,6 +286,12 @@ mmu_notifier_range_blockable(const struct mmu_notifi=
er_range *range)
>   	return (range->flags & MMU_NOTIFIER_RANGE_BLOCKABLE);
>   }
>  =20
> +static inline bool
> +mmu_notifier_range_use_change_pte(const struct mmu_notifier_range *range=
)
> +{
> +	return (range->flags & MMU_NOTIFIER_USE_CHANGE_PTE);
> +}
> +
>   static inline void mmu_notifier_release(struct mm_struct *mm)
>   {
>   	if (mm_has_notifiers(mm))
> @@ -509,6 +533,12 @@ mmu_notifier_range_blockable(const struct mmu_notifi=
er_range *range)
>   	return true;
>   }
>  =20
> +static inline bool
> +mmu_notifier_range_use_change_pte(const struct mmu_notifier_range *range=
)
> +{
> +	return false;
> +}
> +
>   static inline int mm_has_notifiers(struct mm_struct *mm)
>   {
>   	return 0;
> diff --git a/mm/ksm.c b/mm/ksm.c
> index b782fadade8f..41e51882f999 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1066,9 +1066,9 @@ static int write_protect_page(struct vm_area_struct=
 *vma, struct page *page,
>  =20
>   	BUG_ON(PageTransCompound(page));
>  =20
> -	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm,
> -				pvmw.address,
> -				pvmw.address + PAGE_SIZE);
> +	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR,
> +				MMU_NOTIFIER_USE_CHANGE_PTE, vma, mm,
> +				pvmw.address, pvmw.address + PAGE_SIZE);
>   	mmu_notifier_invalidate_range_start(&range);
>  =20
>   	if (!page_vma_mapped_walk(&pvmw))
> @@ -1155,8 +1155,9 @@ static int replace_page(struct vm_area_struct *vma,=
 struct page *page,
>   	if (!pmd)
>   		goto out;
>  =20
> -	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
> -				addr + PAGE_SIZE);
> +	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR,
> +				MMU_NOTIFIER_USE_CHANGE_PTE,
> +				vma, mm, addr, addr + PAGE_SIZE);
>   	mmu_notifier_invalidate_range_start(&range);
>  =20
>   	ptep =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
> diff --git a/mm/memory.c b/mm/memory.c
> index 45dbc174a88c..cb71d3ff1b97 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2282,8 +2282,9 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf=
)
>  =20
>   	__SetPageUptodate(new_page);
>  =20
> -	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm,
> -				vmf->address & PAGE_MASK,
> +	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR,
> +				MMU_NOTIFIER_USE_CHANGE_PTE,
> +				vma, mm, vmf->address & PAGE_MASK,
>   				(vmf->address & PAGE_MASK) + PAGE_SIZE);
>   	mmu_notifier_invalidate_range_start(&range);
>  =20
>=20

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

