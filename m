Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E143EC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 09:15:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7CF720989
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 09:15:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7CF720989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5472C6B0273; Mon, 13 May 2019 05:15:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F6C66B0274; Mon, 13 May 2019 05:15:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E5FA6B0275; Mon, 13 May 2019 05:15:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E2AE56B0273
	for <linux-mm@kvack.org>; Mon, 13 May 2019 05:15:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r20so17002175edp.17
        for <linux-mm@kvack.org>; Mon, 13 May 2019 02:15:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aiSC7P6i3DPe9sDdJVZLY3gYyXY/1sYaFRvlo04lPcM=;
        b=rxm31MFZfx+p5N5qOuxXd/dY24JWEv+bszGtDJUttIA0DXVoSVwplplUc5pjhF5IjC
         3qjUVNnX5HdW5ghL9sfrXyO/i4yVPKcjVJ0xzSWTs3ymuBbnOcZGrVMmZMFOUgNAGREM
         HMftYNoBk4VOFd1qvSVwJ7lBWPg7Qyi0gGCRH97LmP6Nns8rR5M4VpSXKTXQ8Y7aBVXi
         /QXjUuwQ79Ai3bZKBMsa1x6nwIrIbVXfjaA8wKNpOwpiYIagbESH/X2q8249y8DETZNO
         Hk3FIf3YzU4y6Xep0UScxhQm02MOOPULiTIO0gfN/tyZAtToIiuHwOJmcjBxs434s24W
         g4oQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUcCgrWKBFHy4RYyLr6nvpWNt53HqXYggPtISSrpSK7bqaNrS66
	S3NCuA/0UEOQ63Fxes54e9Ol/2dPSlqIbkONWOSN+wbgZ9yFmp8v97zWXUsqj5VqB7UUeurqH+5
	nb2sxXDfHVJp+8Vb1z5ZccxHBtKyU4K8aU5mYRM7uSaCCHdh3uY2SrDFG5KclL54=
X-Received: by 2002:a50:f5ad:: with SMTP id u42mr27964416edm.17.1557738924515;
        Mon, 13 May 2019 02:15:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEUtmM7DomGh0aXTl014998zt8495/Wmzrg2g/9MpW+INQlX6LnuuztPxcZviKqnK6liZu
X-Received: by 2002:a50:f5ad:: with SMTP id u42mr27964369edm.17.1557738923852;
        Mon, 13 May 2019 02:15:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557738923; cv=none;
        d=google.com; s=arc-20160816;
        b=XSqfVLRJ/1qAB20I/Ubh7yoVZ/CRIjA5lbr5R+r4atLwpRPyAzbFSM5qA8+WXH302E
         ohST5zEuO7jHeF3XYbuSXSIzpq+DEcBZxIRH9SunxQ2VwwNNHgctNcZxTPSgBiXtlRZv
         uV91PUZFgdqOeUC1qdrLTivNfiZwOTTJXAt5ZrsAJsubcTDdo7IBU9sO2JgudPubRzQl
         2toSoVx2hxQ2qMykhsCbIlnE5X80a39QSPZ+zfFj9H+L/+tViIZeMexb19tCacxewPJJ
         Y1MI2HvNrJLrTZfs7r0psXKo1eQioEQDCbn4HjnkXEZA5N8E4kBSE62wzqgpBpDXcngl
         KaoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aiSC7P6i3DPe9sDdJVZLY3gYyXY/1sYaFRvlo04lPcM=;
        b=N3cXljZQUo4Mp2egBgWCotMBEaoVVwMbkNac72t3Is/HlDm7l+xpQwvN8BmAx7E0og
         4WwOEoawcy/wiMjrGcExRF04XncC+EUCVf6UDfdJRtYuAh3Y7cYrYW86BePKYqAt90cr
         5xfkVMAQHTFfpkWPgXk3FqE5N31NTHFBVWsd/Z/zYzO1zVNcpB7aXUztfMeSsymm6obh
         oUd6u0kneiqEAdZHl+4wkY6C510Q4OP/6L+7NSLLquKiQ3eYpZaf/Kyaqar2HtVhrd80
         VVx9i43Kx/bnkQstgkfNeJ2WzDZfNZhSD6d6kf11EbK2+mbs4E+6RsT7t9FWeE9eYG81
         HowA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bs3si2143844ejb.315.2019.05.13.02.15.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 02:15:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 38569ACCE;
	Mon, 13 May 2019 09:15:23 +0000 (UTC)
Date: Mon, 13 May 2019 11:15:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Weikang shi <swkhack@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Change count_mm_mlocked_page_nr return type
Message-ID: <20190513091522.GA30100@dhcp22.suse.cz>
References: <20190513023701.83056-1-swkhack@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190513023701.83056-1-swkhack@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 13-05-19 10:37:01, Weikang shi wrote:
> From: swkhack <swkhack@gmail.com>
> 
> In 64-bit machine,the value of "vma->vm_end - vma->vm_start"
> maybe negative in 32bit int and the "count >> PAGE_SHIFT"'s result
> will be wrong.So change the local variable and return
> value to unsigned long will fix the problem.
> 
> Signed-off-by: swkhack <swkhack@gmail.com>

Fixes: 0cf2f6f6dc60 ("mm: mlock: check against vma for actual mlock() size")

Acked-by: Michal Hocko <mhocko@suse.com>

Most users probably never noticed because large mlocked areas are not
allowed by default. So I am not really sure this is worth backporting to
stable trees.

> ---
>  mm/mlock.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 080f3b364..d614163f5 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -636,11 +636,11 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
>   * is also counted.
>   * Return value: previously mlocked page counts
>   */
> -static int count_mm_mlocked_page_nr(struct mm_struct *mm,
> +static unsigned long count_mm_mlocked_page_nr(struct mm_struct *mm,
>  		unsigned long start, size_t len)
>  {
>  	struct vm_area_struct *vma;
> -	int count = 0;
> +	unsigned long count = 0;
>  
>  	if (mm == NULL)
>  		mm = current->mm;
> -- 
> 2.17.1

-- 
Michal Hocko
SUSE Labs

