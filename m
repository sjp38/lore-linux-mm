Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29A3AC3A59B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:22:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB4A82083B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:22:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB4A82083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BDCF6B02E6; Thu, 15 Aug 2019 13:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86DFB6B02E8; Thu, 15 Aug 2019 13:22:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75DC66B02E9; Thu, 15 Aug 2019 13:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0008.hostedemail.com [216.40.44.8])
	by kanga.kvack.org (Postfix) with ESMTP id 55D426B02E6
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:22:27 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0B98E6D92
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:22:27 +0000 (UTC)
X-FDA: 75825331134.10.touch60_6c9fac7276000
X-HE-Tag: touch60_6c9fac7276000
X-Filterd-Recvd-Size: 4128
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:22:26 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6EBA730832E1;
	Thu, 15 Aug 2019 17:22:25 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 643C55C219;
	Thu, 15 Aug 2019 17:22:24 +0000 (UTC)
Date: Thu, 15 Aug 2019 13:22:22 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/migrate: see hole as invalid source page
Message-ID: <20190815172222.GD30916@redhat.com>
References: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
 <1565078411-27082-2-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1565078411-27082-2-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 15 Aug 2019 17:22:25 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 04:00:10PM +0800, Pingfan Liu wrote:
> MIGRATE_PFN_MIGRATE marks a valid pfn, further more, suitable to migrat=
e.
> As for hole, there is no valid pfn, not to mention migration.
>=20
> Before this patch, hole has already relied on the following code to be
> filtered out. Hence it is more reasonable to see hole as invalid source
> page.
> migrate_vma_prepare()
> {
> 		struct page *page =3D migrate_pfn_to_page(migrate->src[i]);
>=20
> 		if (!page || (migrate->src[i] & MIGRATE_PFN_MIGRATE))
> 		     \_ this condition
> }

NAK you break the API, MIGRATE_PFN_MIGRATE is use for 2 things,
first it allow the collection code to mark entry that can be
migrated, then it use by driver to allow driver to skip migration
for some entry (for whatever reason the driver might have), we
still need to keep the entry and not clear it so that we can
cleanup thing (ie remove migration pte entry).

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
>  mm/migrate.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index c2ec614..832483f 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2136,10 +2136,9 @@ static int migrate_vma_collect_hole(unsigned lon=
g start,
>  	unsigned long addr;
> =20
>  	for (addr =3D start & PAGE_MASK; addr < end; addr +=3D PAGE_SIZE) {
> -		migrate->src[migrate->npages] =3D MIGRATE_PFN_MIGRATE;
> +		migrate->src[migrate->npages] =3D 0;
>  		migrate->dst[migrate->npages] =3D 0;
>  		migrate->npages++;
> -		migrate->cpages++;
>  	}
> =20
>  	return 0;
> @@ -2228,8 +2227,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  		pfn =3D pte_pfn(pte);
> =20
>  		if (pte_none(pte)) {
> -			mpfn =3D MIGRATE_PFN_MIGRATE;
> -			migrate->cpages++;
> +			mpfn =3D 0;
>  			goto next;
>  		}
> =20
> --=20
> 2.7.5
>=20

