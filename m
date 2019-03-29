Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FD7CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:12:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FEC2217F5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:12:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FEC2217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4CFD6B026A; Fri, 29 Mar 2019 10:12:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD5DA6B026B; Fri, 29 Mar 2019 10:12:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC4FE6B026C; Fri, 29 Mar 2019 10:12:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98DFF6B026A
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:12:54 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c67so1880288qkg.5
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 07:12:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=9cWb1NVLa8ybFjtRFsTC7/aZsERN67DYELWNz6G7OZU=;
        b=q//KMuGvKQS7w8TaaUI+J7vF/5MVMUpOvKDtDikQ1M4vflFDlJTcSjBtbqIWf2yGmi
         doXLaMYiz8vLVF6W8tSMBX0YwHbplHS83+TBcVMLDzHyurBs1SVbeH4hQ6Odc9aNMOPF
         dOTlx4tkSIReqs90qp6DeSvFpy0/TqfkbLh+PP1XjVTqTdo+kdGR21AEbIjKqbhUStyM
         /nqHGeB1zs33POumkj5BQuLyqlnffZiTqVSf9XNUAVOZY5U5rXZ5tU7xIHQUSm+UNirw
         LUD3bzFMpR7UBx1fViDQw9BwZHKu/Wk5zVwSkACgn8mkVW5WluMNCGoyywOGQ+QwhUZj
         twLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWfewZhWMxdOidkvC/Oz4SaRNbf7nJUgH0bBdtA/WJzwLeU+6Gp
	67jqTo6Djit3jS+u/6w4mX246EGwKg7wSB9yWs/Hvjs4NDyyaFV04rD53io9nK9NWje3QoHBvT8
	EU6SXW2cXJfazuBB7TBmgWWeRnzrZ4/g0DzntduG96Sft6ajG//ZfllHGRG9GHPDiew==
X-Received: by 2002:a37:a1d5:: with SMTP id k204mr9074477qke.167.1553868774344;
        Fri, 29 Mar 2019 07:12:54 -0700 (PDT)
X-Received: by 2002:a37:a1d5:: with SMTP id k204mr9074425qke.167.1553868773634;
        Fri, 29 Mar 2019 07:12:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553868773; cv=none;
        d=google.com; s=arc-20160816;
        b=Pzv5Fll6KMjITjod2QLA1wYucAFF3gYtCgHTpvYnujpzpkZnCMSA7C3/Y0WOJDm2hX
         wk/woObUJ8/sfYnnr0OGz2I/iUeT+eInd8uduWNOtcFJWDrFeWK7tWdinx0Atvba2d8Z
         eWISHJ0B9ZObvmiYTlJsBvX1hkhOJG+2jg4NVljhqebCCTsNjA7R++HVowtlCli3Y2gT
         q88Hs0Ga54p+6q3RVIMYRpWEYwvjYaKAQvFJz84nSGya8iYSWV/rkLp40BlnIZziiqbv
         s2OeucVN6LTAN/SWksPaOfKmcoSuFz9SoZNIYCwK3LLoVMNIEKSfPYyw0j/npfaWpI8x
         vRgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=9cWb1NVLa8ybFjtRFsTC7/aZsERN67DYELWNz6G7OZU=;
        b=LlsZhnpesI54uUriYc6eCCNjFfCTM/KElrcEwEY1+FDdfDc//0VUNp5V8lAkbNYul+
         8erwM19qcJGGWU/QU7CunEs0F7g8nmpzMf3rUZ2pPfpg/B/JNi2ZVE0s0UdRfl8XLOc/
         pt7Jw/C5pxpElNMjOG6KN4v8BkIIyPQ10obPe1d2kyPZ0p2vhF3RZEHjZ0F+kaXGpR80
         RDI1oVjsLqC8roV+dx2eIPtXAIJCYZ9BuqxfUiuq3StChg8ZTezCt1yuSNM/QIBab3pR
         /Tpel5BgJP1jxJO826tTASQhjCmTNFWZKCXM9SwhvC4JKBQkSljF16GsaNptbJ54ePda
         M5xA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l89sor2666092qte.60.2019.03.29.07.12.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 07:12:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyCdRzYVvALtlsV1CwYoLmEEcEnlERcrSZlMQttVZxB6icqGdntGEAhgpSpiUYwrRq+sz8fOw==
X-Received: by 2002:ac8:6646:: with SMTP id j6mr40853858qtp.197.1553868773464;
        Fri, 29 Mar 2019 07:12:53 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id k33sm1129643qte.8.2019.03.29.07.12.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 07:12:52 -0700 (PDT)
Date: Fri, 29 Mar 2019 10:12:50 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>,
	Pankaj Gupta <pagupta@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH v1] mm: balloon: drop unused function stubs
Message-ID: <20190329101235-mutt-send-email-mst@kernel.org>
References: <20190329122649.28404-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329122649.28404-1-david@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 01:26:49PM +0100, David Hildenbrand wrote:
> These are leftovers from the pre-"general non-lru movable page" era.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  include/linux/balloon_compaction.h | 15 ---------------
>  1 file changed, 15 deletions(-)
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index f111c780ef1d..f31521dcb09a 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -151,21 +151,6 @@ static inline void balloon_page_delete(struct page *page)
>  	list_del(&page->lru);
>  }
>  
> -static inline bool __is_movable_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool balloon_page_movable(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool isolated_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
>  static inline bool balloon_page_isolate(struct page *page)
>  {
>  	return false;
> -- 
> 2.17.2

