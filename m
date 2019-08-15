Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6642C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 21:02:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C6AD2063F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 21:02:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C6AD2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D2EE6B0003; Thu, 15 Aug 2019 17:02:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3835B6B0006; Thu, 15 Aug 2019 17:02:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24B106B0007; Thu, 15 Aug 2019 17:02:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id F2ABF6B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:02:57 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9DA768248AB5
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:02:57 +0000 (UTC)
X-FDA: 75825886794.20.jam95_8e387c67d6449
X-HE-Tag: jam95_8e387c67d6449
X-Filterd-Recvd-Size: 2881
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:02:57 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 69495C057E9A;
	Thu, 15 Aug 2019 21:02:56 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 68B3B17966;
	Thu, 15 Aug 2019 21:02:55 +0000 (UTC)
Date: Thu, 15 Aug 2019 17:02:53 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: "Yang, Philip" <Philip.Yang@amd.com>
Cc: "alex.deucher@amd.com" <alex.deucher@amd.com>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"jgg@mellanox.com" <jgg@mellanox.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>
Subject: Re: [PATCH] mm/hmm: hmm_range_fault handle pages swapped out
Message-ID: <20190815210253.GD25517@redhat.com>
References: <20190815205227.7949-1-Philip.Yang@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815205227.7949-1-Philip.Yang@amd.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 15 Aug 2019 21:02:56 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 08:52:56PM +0000, Yang, Philip wrote:
> hmm_range_fault may return NULL pages because some of pfns are equal to
> HMM_PFN_NONE. This happens randomly under memory pressure. The reason i=
s
> for swapped out page pte path, hmm_vma_handle_pte doesn't update fault
> variable from cpu_flags, so it failed to call hmm_vam_do_fault to swap
> the page in.
>=20
> The fix is to call hmm_pte_need_fault to update fault variable.
>=20
> Change-Id: I2e8611485563d11d938881c18b7935fa1e7c91ee
> Signed-off-by: Philip Yang <Philip.Yang@amd.com>

Reviewed-by: J=E9r=F4me Glisse <jglisse@redhat.com>

> ---
>  mm/hmm.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 9f22562e2c43..7ca4fb39d3d8 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -544,6 +544,9 @@ static int hmm_vma_handle_pte(struct mm_walk *walk,=
 unsigned long addr,
>  		swp_entry_t entry =3D pte_to_swp_entry(pte);
> =20
>  		if (!non_swap_entry(entry)) {
> +			cpu_flags =3D pte_to_hmm_pfn_flags(range, pte);
> +			hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
> +					   &fault, &write_fault);
>  			if (fault || write_fault)
>  				goto fault;
>  			return 0;
> --=20
> 2.17.1
>=20

