Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A8CEC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 13:19:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F840206E0
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 13:19:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hVGnkDM1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F840206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3A006B0580; Mon, 26 Aug 2019 09:19:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEAC06B0581; Mon, 26 Aug 2019 09:19:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD8C56B0582; Mon, 26 Aug 2019 09:19:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0140.hostedemail.com [216.40.44.140])
	by kanga.kvack.org (Postfix) with ESMTP id B6B956B0580
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 09:19:09 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 67BE6181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:19:09 +0000 (UTC)
X-FDA: 75864634818.29.party64_4fe5bcdfab452
X-HE-Tag: party64_4fe5bcdfab452
X-Filterd-Recvd-Size: 3310
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:19:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+bgymjxTeTPqaFGWJ2AMHVWjnnle7Q/z0U8HHD/hi4E=; b=hVGnkDM1pOtFegv+JLKwElFh1
	rG8IIiPdmVMJaBghnBwOEWK7b1abdsG3+9h0E281WSNP594lWFYR5Zy9gPyUIV665jQJ93Brtg6q1
	b4ve8yBr3pLIySNScM1DAYcjEXx6ztoNASFIq+PG8nraiQdZovJ5nCIiO6/7NPPsVJRV3LoJzBPb9
	WQeyyjDWRDI5qaYboiMVNiZuP1oIpEQh+flExFYEITNZsDeb0BV13X4wFnerlgF54QkNyzfMNCyaJ
	hy51a9OWTDo5NLVu2SDcvGoVRaTOgpYUqoa/vU0mnN6LIu3utfE5O6XBz0x6a57W53p8hDNbghybs
	UrAn07Bjw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i2Ete-0004nK-Vo; Mon, 26 Aug 2019 13:18:58 +0000
Date: Mon, 26 Aug 2019 06:18:58 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Will Deacon <will@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Dave Airlie <airlied@redhat.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH] mm: replace is_zero_pfn with is_huge_zero_pmd for thp
Message-ID: <20190826131858.GB15933@bombadil.infradead.org>
References: <20190825200621.211494-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190825200621.211494-1-yuzhao@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Why did you not cc Gerald who wrote the patch?  You can't just
run get_maintainers.pl and call it good.

On Sun, Aug 25, 2019 at 02:06:21PM -0600, Yu Zhao wrote:
> For hugely mapped thp, we use is_huge_zero_pmd() to check if it's
> zero page or not.
> 
> We do fill ptes with my_zero_pfn() when we split zero thp pmd, but
>  this is not what we have in vm_normal_page_pmd().
> pmd_trans_huge_lock() makes sure of it.
> 
> This is a trivial fix for /proc/pid/numa_maps, and AFAIK nobody
> complains about it.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e2bb51b6242e..ea3c74855b23 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -654,7 +654,7 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
>  
>  	if (pmd_devmap(pmd))
>  		return NULL;
> -	if (is_zero_pfn(pfn))
> +	if (is_huge_zero_pmd(pmd))
>  		return NULL;
>  	if (unlikely(pfn > highest_memmap_pfn))
>  		return NULL;
> -- 
> 2.23.0.187.g17f5b7556c-goog
> 

