Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37E06C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:01:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C837521E6A
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:01:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C837521E6A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28E8A6B0003; Wed,  7 Aug 2019 07:01:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 219696B0006; Wed,  7 Aug 2019 07:01:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E1006B0007; Wed,  7 Aug 2019 07:01:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2B9F6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 07:01:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so55917666edt.4
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 04:01:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=+eLVrO3ftv6KhrHCmUP/sYnuS3BLP7735j97X+SR3hM=;
        b=l8rIWjiLsnCbKktl99f9eDjInlTgYVUO98qTRZbt0LlOCcmoSf+GVJh9uwbhBZ07AX
         AP49JreOXX5awqAuQ/6Tcy8kH9LXknBFnhY8VJye4oQRqGWfWHEZ8qRuCAmxVjnZoh/J
         3ZcLSv18Jh+brbBhtsaYRA6gVOkTqAWdmqYE2xPRYRXwynL4SpUSXI8Yov1GYUuDpO6U
         m+sARiTTyfdiNMjQzdbXXX8et5NHXxwHA2MCx3R4l5jSEZnepDHrUd1TgBVnvr2bfF7a
         qMBH/3Go1vEdt6J7DiLqSeo40v2DaQgUwLveHuCG0GEC0yw6OmRxyS6IAjUdq+A2oSrU
         nsYg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUD/WITuBRxSKV4aUlth6boOYdDoP2UygZU6rDck5pwOAPoi8ez
	/WtvEw/AIKfO88hN75zRz/2tnwItwipuFYVPhKq469QJNcGxcIsZGA+J4qdPxyUeea+jI0gtYTp
	bwpnKN/PrPG8/8Uyv11t8PDwgphCiorVp4ZvfAcoIF6lf1f6c4CHXaHBiWsg6h5Q=
X-Received: by 2002:aa7:c559:: with SMTP id s25mr8780083edr.117.1565175710309;
        Wed, 07 Aug 2019 04:01:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOKbuTj3LO7qNX/1mYG5pae0gXVr8W3p7cMTTIiqgHWDYYu1DC12xmn34fev3OiB31h89h
X-Received: by 2002:aa7:c559:: with SMTP id s25mr8779978edr.117.1565175709274;
        Wed, 07 Aug 2019 04:01:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565175709; cv=none;
        d=google.com; s=arc-20160816;
        b=L2kkhvRia9NAQfLJFGP3YDHW5ZU25CF5SUSxfT3a1KMBHRdMAHhDymoBdqsxnCw7y+
         Vu3y9BR7fTWoFRjI6lhnVCzqRAnLeOyGZEqZfVJOnEkWYBqjbW1lNFQI0gymqoKjGdc2
         SferKtG6qPpuaQBbdQiQ/gDNa4TFoO+hNukD2ce7rmkBBpYO10RdX/Uh8K9sOsAIBwyq
         ISH7I84VSmD6QUuXhZ50E7lORKC61jQPTMyeHitKOQ01hCA/z9d8XG//k/UaboWXs2mG
         2hds5NHlW3xm39LxLBAOgQqgSvk4PJ2WjoYcIVqHBOi7Ks/jj7bBc2FOPV/mcj4Ibw/e
         wUOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=+eLVrO3ftv6KhrHCmUP/sYnuS3BLP7735j97X+SR3hM=;
        b=ZdBKfirkSue9OO4r/m1HXUVRAVn17b/rvu3Adu3In89z5wiJUBQbLQKa8R+yS0OJw1
         t8BuLQuGN532okQLddaXpSl1J6LiTqDA/ymio/Us8tzlYX5FYIyiS4j9wALEkDnoC+Io
         YtT8QYtC4p1N6NpprJMeAJvnsewW0s4OBfvtLg/vg7D0pZO7Pb/ig8frKbMTdhCmIU32
         nJ9Z2B5uUEfY24LLDjG4r3FsREVWy/tyAvvjuoOElOcBCwmV6ClCOo7sLnjYxiiKy2A4
         FXfDgEXRWhuyULea5TKMe+KeWT4IqUKYOceLCZix2uKJzu6krjCckcryoucKRs5vSSAn
         M3bA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si34136864edb.404.2019.08.07.04.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 04:01:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3BFCAE48;
	Wed,  7 Aug 2019 11:01:47 +0000 (UTC)
Date: Wed, 7 Aug 2019 13:01:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Message-ID: <20190807110147.GT11812@dhcp22.suse.cz>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190805222019.28592-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 15:20:17, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().

Hmm, this is an interesting code path. There seems to be a mix of pages
in the game. We get one page via follow_page_mask but then other pages
in the range are filled by __munlock_pagevec_fill and that does a direct
pte walk. Is using put_user_page correct in this case? Could you explain
why in the changelog?

> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Daniel Black <daniel@linux.ibm.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/mlock.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index a90099da4fb4..b980e6270e8a 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -345,7 +345,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>  				get_page(page); /* for putback_lru_page() */
>  				__munlock_isolated_page(page);
>  				unlock_page(page);
> -				put_page(page); /* from follow_page_mask() */
> +				put_user_page(page); /* from follow_page_mask() */
>  			}
>  		}
>  	}
> @@ -467,7 +467,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>  		if (page && !IS_ERR(page)) {
>  			if (PageTransTail(page)) {
>  				VM_BUG_ON_PAGE(PageMlocked(page), page);
> -				put_page(page); /* follow_page_mask() */
> +				put_user_page(page); /* follow_page_mask() */
>  			} else if (PageTransHuge(page)) {
>  				lock_page(page);
>  				/*
> @@ -478,7 +478,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>  				 */
>  				page_mask = munlock_vma_page(page);
>  				unlock_page(page);
> -				put_page(page); /* follow_page_mask() */
> +				put_user_page(page); /* follow_page_mask() */
>  			} else {
>  				/*
>  				 * Non-huge pages are handled in batches via
> -- 
> 2.22.0

-- 
Michal Hocko
SUSE Labs

