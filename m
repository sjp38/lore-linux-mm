Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35137C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:19:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01DF2205F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:19:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01DF2205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95D186B02E2; Thu, 15 Aug 2019 13:19:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90CCB6B02E4; Thu, 15 Aug 2019 13:19:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8226B6B02E5; Thu, 15 Aug 2019 13:19:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 613EB6B02E2
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:19:23 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 1FE4F8248AB8
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:19:23 +0000 (UTC)
X-FDA: 75825323406.08.plant16_51d7a2a40a832
X-HE-Tag: plant16_51d7a2a40a832
X-Filterd-Recvd-Size: 3842
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:19:22 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 41DFE8535C;
	Thu, 15 Aug 2019 17:19:21 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 24D02601A4;
	Thu, 15 Aug 2019 17:19:20 +0000 (UTC)
Date: Thu, 15 Aug 2019 13:19:18 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv2] mm/migrate: clean up useless code in
 migrate_vma_collect_pmd()
Message-ID: <20190815171918.GC30916@redhat.com>
References: <20190807052858.GA9749@mypc>
 <1565167272-21453-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1565167272-21453-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 15 Aug 2019 17:19:21 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 04:41:12PM +0800, Pingfan Liu wrote:
> Clean up useless 'pfn' variable.

NAK there is a bug see below:

>=20
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Jan Kara <jack@suse.cz>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> To: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/migrate.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
>=20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 8992741..d483a55 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2225,17 +2225,15 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  		pte_t pte;
> =20
>  		pte =3D *ptep;
> -		pfn =3D pte_pfn(pte);
> =20
>  		if (pte_none(pte)) {
>  			mpfn =3D MIGRATE_PFN_MIGRATE;
>  			migrate->cpages++;
> -			pfn =3D 0;
>  			goto next;
>  		}
> =20
>  		if (!pte_present(pte)) {
> -			mpfn =3D pfn =3D 0;
> +			mpfn =3D 0;
> =20
>  			/*
>  			 * Only care about unaddressable device page special
> @@ -2252,10 +2250,10 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  			if (is_write_device_private_entry(entry))
>  				mpfn |=3D MIGRATE_PFN_WRITE;
>  		} else {
> +			pfn =3D pte_pfn(pte);
>  			if (is_zero_pfn(pfn)) {
>  				mpfn =3D MIGRATE_PFN_MIGRATE;
>  				migrate->cpages++;
> -				pfn =3D 0;
>  				goto next;
>  			}
>  			page =3D vm_normal_page(migrate->vma, addr, pte);
> @@ -2265,10 +2263,9 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
> =20
>  		/* FIXME support THP */
>  		if (!page || !page->mapping || PageTransCompound(page)) {
> -			mpfn =3D pfn =3D 0;
> +			mpfn =3D 0;
>  			goto next;
>  		}
> -		pfn =3D page_to_pfn(page);

You can not remove that one ! Otherwise it will break the device
private case.

