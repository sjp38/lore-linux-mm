Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EFF5C49ED9
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 08:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B8B12084F
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 08:26:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B8B12084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D5856B0005; Thu, 12 Sep 2019 04:26:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 985046B0006; Thu, 12 Sep 2019 04:26:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89A446B0007; Thu, 12 Sep 2019 04:26:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id 653DB6B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 04:26:52 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 04EC034A4
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 08:26:52 +0000 (UTC)
X-FDA: 75925587864.08.hands66_7619e5324742e
X-HE-Tag: hands66_7619e5324742e
X-Filterd-Recvd-Size: 2305
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 08:26:51 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 6EA70227A81; Thu, 12 Sep 2019 10:26:48 +0200 (CEST)
Date: Thu, 12 Sep 2019 10:26:48 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/4] mm/hmm: allow snapshot of the special zero page
Message-ID: <20190912082648.GB14368@lst.de>
References: <20190911222829.28874-1-rcampbell@nvidia.com> <20190911222829.28874-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190911222829.28874-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 03:28:27PM -0700, Ralph Campbell wrote:
> Allow hmm_range_fault() to return success (0) when the CPU pagetable
> entry points to the special shared zero page.
> The caller can then handle the zero page by possibly clearing device
> private memory instead of DMAing a zero page.
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Christoph Hellwig <hch@lst.de>
> ---
>  mm/hmm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 06041d4399ff..7217912bef13 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -532,7 +532,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk,=
 unsigned long addr,
>  			return -EBUSY;
>  	} else if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) && pte_special(pte=
)) {
>  		*pfn =3D range->values[HMM_PFN_SPECIAL];
> -		return -EFAULT;
> +		return is_zero_pfn(pte_pfn(pte)) ? 0 : -EFAULT;

Any chance to just use a normal if here:

		if (!is_zero_pfn(pte_pfn(pte)))
			return -EFAULT;
		return 0;

