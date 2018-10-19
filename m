Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6F4F6B000A
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 22:02:10 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id w137-v6so2263762itc.8
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 19:02:10 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 12-v6si1452611itz.142.2018.10.18.19.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 19:02:09 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH V2 2/5] mm/hugetlb: Distinguish between migratability
 and movability
Date: Fri, 19 Oct 2018 01:59:31 +0000
Message-ID: <20181019015931.GA18973@hori1.linux.bs1.fc.nec.co.jp>
References: <1539316799-6064-1-git-send-email-anshuman.khandual@arm.com>
 <1539316799-6064-3-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1539316799-6064-3-git-send-email-anshuman.khandual@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0D6086D1CF56CC48B332AC9789ACCB2B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "suzuki.poulose@arm.com" <suzuki.poulose@arm.com>, "punit.agrawal@arm.com" <punit.agrawal@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Steven.Price@arm.com" <Steven.Price@arm.com>, "steve.capper@arm.com" <steve.capper@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>

On Fri, Oct 12, 2018 at 09:29:56AM +0530, Anshuman Khandual wrote:
> During huge page allocation it's migratability is checked to determine if
> it should be placed under movable zones with GFP_HIGHUSER_MOVABLE. But th=
e
> movability aspect of the huge page could depend on other factors than jus=
t
> migratability. Movability in itself is a distinct property which should n=
ot
> be tied with migratability alone.
>=20
> This differentiates these two and implements an enhanced movability check
> which also considers huge page size to determine if it is feasible to be
> placed under a movable zone. At present it just checks for gigantic pages
> but going forward it can incorporate other enhanced checks.

(nitpicking...)
The following code just checks hugepage_migration_supported(), so maybe
s/Movability/Migratability/ is expected in the comment?

  static int unmap_and_move_huge_page(...)
  {
          ...
          /*
           * Movability of hugepages depends on architectures and hugepage =
size.
           * This check is necessary because some callers of hugepage migra=
tion
           * like soft offline and memory hotremove don't walk through page
           * tables or check whether the hugepage is pmd-based or not befor=
e
           * kicking migration.
           */
          if (!hugepage_migration_supported(page_hstate(hpage))) {

Thanks,
Naoya Horiguchi

>=20
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  include/linux/hugetlb.h | 30 ++++++++++++++++++++++++++++++
>  mm/hugetlb.c            |  2 +-
>  2 files changed, 31 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 9c1b77f..456cb60 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -493,6 +493,31 @@ static inline bool hugepage_migration_supported(stru=
ct hstate *h)
>  #endif
>  }
> =20
> +/*
> + * Movability check is different as compared to migration check.
> + * It determines whether or not a huge page should be placed on
> + * movable zone or not. Movability of any huge page should be
> + * required only if huge page size is supported for migration.
> + * There wont be any reason for the huge page to be movable if
> + * it is not migratable to start with. Also the size of the huge
> + * page should be large enough to be placed under a movable zone
> + * and still feasible enough to be migratable. Just the presence
> + * in movable zone does not make the migration feasible.
> + *
> + * So even though large huge page sizes like the gigantic ones
> + * are migratable they should not be movable because its not
> + * feasible to migrate them from movable zone.
> + */
> +static inline bool hugepage_movable_supported(struct hstate *h)
> +{
> +	if (!hugepage_migration_supported(h))
> +		return false;
> +
> +	if (hstate_is_gigantic(h))
> +		return false;
> +	return true;
> +}
> +
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
>  					   struct mm_struct *mm, pte_t *pte)
>  {
> @@ -589,6 +614,11 @@ static inline bool hugepage_migration_supported(stru=
ct hstate *h)
>  	return false;
>  }
> =20
> +static inline bool hugepage_movable_supported(struct hstate *h)
> +{
> +	return false;
> +}
> +
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
>  					   struct mm_struct *mm, pte_t *pte)
>  {
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3c21775..a5a111d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -919,7 +919,7 @@ static struct page *dequeue_huge_page_nodemask(struct=
 hstate *h, gfp_t gfp_mask,
>  /* Movability of hugepages depends on migration support. */
>  static inline gfp_t htlb_alloc_mask(struct hstate *h)
>  {
> -	if (hugepage_migration_supported(h))
> +	if (hugepage_movable_supported(h))
>  		return GFP_HIGHUSER_MOVABLE;
>  	else
>  		return GFP_HIGHUSER;
> --=20
> 2.7.4
>=20
> =
