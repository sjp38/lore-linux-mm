Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFA1AC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:11:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F92F2080C
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:11:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F92F2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AEDF6B059E; Mon, 26 Aug 2019 11:11:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 437D96B059F; Mon, 26 Aug 2019 11:11:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34DC96B05A0; Mon, 26 Aug 2019 11:11:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0035.hostedemail.com [216.40.44.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2036B059E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:11:05 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AF6D7180AD801
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:11:04 +0000 (UTC)
X-FDA: 75864916848.04.stove74_2670772533d39
X-HE-Tag: stove74_2670772533d39
X-Filterd-Recvd-Size: 2945
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:11:04 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B4C73AEF6;
	Mon, 26 Aug 2019 15:11:01 +0000 (UTC)
Subject: Re: [PATCH] mm/migrate: initialize pud_entry in migrate_vma()
To: Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190719233225.12243-1-rcampbell@nvidia.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0d639edf-9f96-c170-4920-d64c2891d35d@suse.cz>
Date: Mon, 26 Aug 2019 17:11:01 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190719233225.12243-1-rcampbell@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/20/19 1:32 AM, Ralph Campbell wrote:
> When CONFIG_MIGRATE_VMA_HELPER is enabled, migrate_vma() calls
> migrate_vma_collect() which initializes a struct mm_walk but
> didn't initialize mm_walk.pud_entry. (Found by code inspection)
> Use a C structure initialization to make sure it is set to NULL.
>=20
> Fixes: 8763cb45ab967 ("mm/migrate: new memory migration helper for use =
with
> device memory")
> Cc: stable@vger.kernel.org
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

So this bug can manifest by some garbage address on stack being called, r=
ight? I
wonder, how comes it didn't actually happen yet?

> ---
>  mm/migrate.c | 17 +++++++----------
>  1 file changed, 7 insertions(+), 10 deletions(-)
>=20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 515718392b24..a42858d8e00b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2340,16 +2340,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  static void migrate_vma_collect(struct migrate_vma *migrate)
>  {
>  	struct mmu_notifier_range range;
> -	struct mm_walk mm_walk;
> -
> -	mm_walk.pmd_entry =3D migrate_vma_collect_pmd;
> -	mm_walk.pte_entry =3D NULL;
> -	mm_walk.pte_hole =3D migrate_vma_collect_hole;
> -	mm_walk.hugetlb_entry =3D NULL;
> -	mm_walk.test_walk =3D NULL;
> -	mm_walk.vma =3D migrate->vma;
> -	mm_walk.mm =3D migrate->vma->vm_mm;
> -	mm_walk.private =3D migrate;
> +	struct mm_walk mm_walk =3D {
> +		.pmd_entry =3D migrate_vma_collect_pmd,
> +		.pte_hole =3D migrate_vma_collect_hole,
> +		.vma =3D migrate->vma,
> +		.mm =3D migrate->vma->vm_mm,
> +		.private =3D migrate,
> +	};
> =20
>  	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm_walk.mm=
,
>  				migrate->start,
>=20


