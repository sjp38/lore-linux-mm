Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 267FBC3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 01:37:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9B3D2173E
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 01:37:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gH7sjdEq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9B3D2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7463B6B0008; Thu, 29 Aug 2019 21:37:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F66C6B000C; Thu, 29 Aug 2019 21:37:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BE436B000D; Thu, 29 Aug 2019 21:37:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFB96B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 21:37:10 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E5C83180AD7C1
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 01:37:09 +0000 (UTC)
X-FDA: 75877380978.22.cart34_44d1500ca719
X-HE-Tag: cart34_44d1500ca719
X-Filterd-Recvd-Size: 2939
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 01:37:09 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2665821726;
	Fri, 30 Aug 2019 01:37:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567129028;
	bh=wblmtwAPChh3pCJc193Sn72+9+tyKF8aXZAv7ytdG80=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=gH7sjdEq3ppqk1qjdFYzMatBtsJBLj0iAfB8MpFHaWARSglXLrGojpXQ/2dLwo4/b
	 fHq54qBu5XfxNbY+3zndxiNkLPXH+umnmVwEJoB6ogmOSt9YQk6cB5Km9NrKnNBXBF
	 mvduXpDEjDhSGvVQ4HyyJD/xPohoqaXalCeDGJOA=
Date: Thu, 29 Aug 2019 18:37:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/z3fold.c: remove useless code in z3fold_page_isolate
Message-Id: <20190829183707.71f13473d1b034dd424f85d7@linux-foundation.org>
In-Reply-To: <20190829191312.GA20298@embeddedor>
References: <20190829191312.GA20298@embeddedor>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Aug 2019 14:13:12 -0500 "Gustavo A. R. Silva" <gustavo@embeddedor.com> wrote:

> Remove duplicate and useless code.
> 
> ...
>
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -1400,15 +1400,13 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
>  			 * can call the release logic.
>  			 */
>  			if (unlikely(kref_put(&zhdr->refcount,
> -					      release_z3fold_page_locked))) {
> +					      release_z3fold_page_locked)))
>  				/*
>  				 * If we get here we have kref problems, so we
>  				 * should freak out.
>  				 */
>  				WARN(1, "Z3fold is experiencing kref problems\n");
> -				z3fold_page_unlock(zhdr);
> -				return false;
> -			}
> +
>  			z3fold_page_unlock(zhdr);
>  			return false;
>  		}

Thanks.

We prefer to retain the braces around a code block which is more than a
single line - it's easier on the eyes.

--- a/mm/z3fold.c~mm-z3foldc-remove-useless-code-in-z3fold_page_isolate-fix
+++ a/mm/z3fold.c
@@ -1400,13 +1400,13 @@ static bool z3fold_page_isolate(struct p
 			 * can call the release logic.
 			 */
 			if (unlikely(kref_put(&zhdr->refcount,
-					      release_z3fold_page_locked)))
+					      release_z3fold_page_locked))) {
 				/*
 				 * If we get here we have kref problems, so we
 				 * should freak out.
 				 */
 				WARN(1, "Z3fold is experiencing kref problems\n");
-
+			}
 			z3fold_page_unlock(zhdr);
 			return false;
 		}
_


