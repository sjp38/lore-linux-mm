Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CDD0C3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 23:05:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C526121848
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 23:05:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="sECy1IDo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C526121848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E2A06B0287; Mon, 26 Aug 2019 19:05:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 593C76B0288; Mon, 26 Aug 2019 19:05:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A81D6B0289; Mon, 26 Aug 2019 19:05:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0051.hostedemail.com [216.40.44.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC196B0287
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:05:18 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B22DC181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 23:05:17 +0000 (UTC)
X-FDA: 75866111874.21.scarf64_68630721f1261
X-HE-Tag: scarf64_68630721f1261
X-Filterd-Recvd-Size: 2577
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 23:05:17 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E2C02206BA;
	Mon, 26 Aug 2019 23:05:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566860716;
	bh=cl70OECwhOCqI7sxkc/Ft+EL3YyE5brFJ+VFfmAluBE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=sECy1IDonKrYQ2nLaj1eiMbxLkbkQ25Ax1DH8KDGu91ViEAU5zM+pMa7lSZY2HIAS
	 oyHC5+L9IuinAqpcegYdcRykO4IfktmcVG510+/9LUwyoYqk791/6hOCdM6ZEHdnE8
	 E2xpgPr+F7ymNwxz5XjrQqRNz8FzLgvzPhVZcTYM=
Date: Mon, 26 Aug 2019 16:05:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Henry Burns <henryburns@google.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/z3fold.c: fix lock/unlock imbalance in
 z3fold_page_isolate
Message-Id: <20190826160515.446dabc587706fc80e5c6e6b@linux-foundation.org>
In-Reply-To: <20190826030634.GA4379@embeddedor>
References: <20190826030634.GA4379@embeddedor>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 25 Aug 2019 22:06:34 -0500 "Gustavo A. R. Silva" <gustavo@embeddedor.com> wrote:

> Fix lock/unlock imbalance by unlocking *zhdr* before return.
> 
> Addresses-Coverity-ID: 1452811 ("Missing unlock")
> Fixes: d776aaa9895e ("mm/z3fold.c: fix race between migration and destruction")
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
>  mm/z3fold.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index e31cd9bd4ed5..75b7962439ff 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -1406,6 +1406,7 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
>  				 * should freak out.
>  				 */
>  				WARN(1, "Z3fold is experiencing kref problems\n");
> +				z3fold_page_unlock(zhdr);
>  				return false;
>  			}
>  			z3fold_page_unlock(zhdr);

Looks good, thanks.


This is a bit silly:

			if (..) {
				...
				z3fold_page_unlock(zhdr);
				return false;
			}
			z3fold_page_unlock(zhdr);
			return false;

but presumably the compiler will clean up after us.

