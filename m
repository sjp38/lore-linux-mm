Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD9C8C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:57:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A43782081B
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:57:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OoJLwlcF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A43782081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B3D36B026F; Fri,  6 Sep 2019 10:57:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 462DD6B0270; Fri,  6 Sep 2019 10:57:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 379036B0271; Fri,  6 Sep 2019 10:57:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0186.hostedemail.com [216.40.44.186])
	by kanga.kvack.org (Postfix) with ESMTP id 15B906B026F
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:57:53 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B4514180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:57:52 +0000 (UTC)
X-FDA: 75904800384.01.money41_7ef123e22d80a
X-HE-Tag: money41_7ef123e22d80a
X-Filterd-Recvd-Size: 3401
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:57:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8uK72fUcoR/dOk67AIhDl3phYWTEBOSNQgXr2opx6YQ=; b=OoJLwlcFoMcbFlWhKHZL0Iv2t
	xGSzljJBjV7GRPPUygW13XZxQrWrvjLCjMUwNZW1LKX0QBQ/7xZEL5PN+q9J0HdZjEWQZnB1tw+QA
	/yGOWMjkyadvtPvYE/i3REW8kTAdxbBkXW++18U4vW2fZEKZkfY0jAQMz79K+9ZagWBVKrEeNFTjZ
	8pPK5z1TpoluFgMEjSdLdJJlJerF+SffUw/gVMsURZvjv/PbcVSU1u8Q53JMAu4ldpzE7c/cnfxN4
	pD/nYxN6XMpI9wEUPWYoyhHn8LvediGThCGX7hpHY8aVNvnFA/fQK0YLj65WvTI/X8geljykGhl7S
	PzGWja24w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i6FgE-0001Sx-K1; Fri, 06 Sep 2019 14:57:42 +0000
Date: Fri, 6 Sep 2019 07:57:42 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jia He <justin.he@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Peter Zijlstra <peterz@infradead.org>,
	Dave Airlie <airlied@redhat.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Catalin Marinas <Catalin.Marinas@arm.com>
Subject: Re: [PATCH v2] mm: fix double page fault on arm64 if PTE_AF is
 cleared
Message-ID: <20190906145742.GX29434@bombadil.infradead.org>
References: <20190906135747.211836-1-justin.he@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906135747.211836-1-justin.he@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 09:57:47PM +0800, Jia He wrote:
>  		 * This really shouldn't fail, because the page is there
>  		 * in the page tables. But it might just be unreadable,
>  		 * in which case we just give up and fill the result with
> -		 * zeroes.
> +		 * zeroes. If PTE_AF is cleared on arm64, it might
> +		 * cause double page fault. So makes pte young here

How about:
		 * zeroes. On architectures with software "accessed" bits,
		 * we would take a double page fault here, so mark it
		 * accessed here.

>  		 */
> +		if (!pte_young(vmf->orig_pte)) {

Let's guard this with:

		if (arch_sw_access_bit && !pte_young(vmf->orig_pte)) {

#define arch_sw_access_bit	0
by default and have arm64 override it (either to a variable or a constant
... your choice).  Also, please somebody decide on a better name than
arch_sw_access_bit.

> +			entry = pte_mkyoung(vmf->orig_pte);
> +			if (ptep_set_access_flags(vmf->vma, vmf->address,
> +				vmf->pte, entry, 0))

This indentation is wrong; it makes vmf->pte look like part of the subsequent
statement instead of part of the condition.

> +				update_mmu_cache(vmf->vma, vmf->address,
> +						vmf->pte);
> +		}
> +

