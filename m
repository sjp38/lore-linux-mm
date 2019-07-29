Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1524C41514
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:28:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85DE02073F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:28:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85DE02073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BEE88E0003; Mon, 29 Jul 2019 05:28:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1490F8E0002; Mon, 29 Jul 2019 05:28:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 036DC8E0003; Mon, 29 Jul 2019 05:28:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A942F8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:28:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so37933419eda.2
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 02:28:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=e6GYdyPBr/ibqC5njQa9O/P2Sv1wu89zoiFFgZZ5WDs=;
        b=fMT6Sx2hVGJO8OVxk7ORpVMlRf99Lrn+5Gk69YGWjnLUdCIT/OY8VnC3niF/ZERtSl
         7Pu7kWgdzhjjJuyQiX4MYiuZFriiXCS6MjkuWUjQbWmZ8M4siGJ1w7xbZdZXaUGVTgW4
         c9CjTFwln5Z4MDYm7scLRpy36fv54kkLj0uUgYnENTa63bBgbXrF96sAa9tb9bfeaMr2
         0uE5QroG0T8c5/d1iGadNGa8Q5CFvpmZYRkDgK8uEcXV0rI8UHVRd1/VqLsotFptWTUa
         KqO3fi4/8RkT0FKFCuQVZju69Q/CQU1s+7ptlDEa1qdVHZ4IqqoKVMuJSecreyf57x92
         UX0w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUDxHXmxVw2WuuJuzB9uSp4F2Tc5/ctiOXhv3mrCDXklh2O3yA5
	rJuFzVdg/fg1gXWEjNIaCVOOvQ2DzF0+FpE+kdM6f0YIuSoiCbrCuZ25itDyNYYBPJnevOOZNdn
	piLfYAcn5Jwqc5EQQK8NQLPsUxLvUfdh010U1DeZ6opQ7iAkB8qOUpoqPEj5Fihw=
X-Received: by 2002:a50:9177:: with SMTP id f52mr95243977eda.294.1564392512226;
        Mon, 29 Jul 2019 02:28:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxECGV+peNm+Nrh0LvD8QVNbg4hTy1V5S3MrDKtS0DnJtEzkDybo7biJ/1TRCgxJm54QQl
X-Received: by 2002:a50:9177:: with SMTP id f52mr95243918eda.294.1564392511224;
        Mon, 29 Jul 2019 02:28:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564392511; cv=none;
        d=google.com; s=arc-20160816;
        b=aTNirjmGZdlA4i4D2sk4gXzCx+YvrOtWKnQ3HTASVqJtDgIXZPG36AXBtfZaadUGRS
         aYWT9A/dW9l6xwRGNvicxuJDtIC+TLdvPeB/v5p6luURzA0d3bosAmYp5ORrgpUqCJsm
         urccep4Ni2suSuyJfAlJeUctS4MrJQDgXCCUtS+ZqAxZWdfpRkyrRXiDKVH/t2ibdjRS
         oKQZXTfjefckjoMQdj+rvjVqpsFkNCjFTkuMnvW2A0YEo0bikxEqpZAZn2Axe07Gw0d3
         +qhVF4kkMx3M3s7ZvRlBdLxUb4G3V14M5TPtDsUmHBoobOOeJmUUMSpjEWcpbiWOZX+i
         zBRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=e6GYdyPBr/ibqC5njQa9O/P2Sv1wu89zoiFFgZZ5WDs=;
        b=m8H4eSJUvPoWM7BCgwM6YiCRE8ya6Vy+8t35ieyxGhYMOa1jIWFeaevh6orac70wfU
         BtoXszbXKFtMLIv94WepCFUAaaJBRyCYXRsa54H3uFAHXMvMImms2aTWaoA3mPeHvWDi
         jnuT2a2MnKbvNn2Fw//j0K8ebW8u/uNYXDsXasQfYw6sg53BvIBngPIA9QBEWXEFr+eG
         HY9VK4NirZgRQbGvnob9v/UST7GBQWad7gkpu281Msc8IFGDHTryRNQZfZFZpRLIZydl
         r5xEAmnBVmDnzgGyHMJ4suDKrLB/mmZfUbMDZvaX0R8BSUXJHqX1PQIdFlHAFUFifdA0
         X8Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2si17470516edh.405.2019.07.29.02.28.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 02:28:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A3037AF21;
	Mon, 29 Jul 2019 09:28:30 +0000 (UTC)
Date: Mon, 29 Jul 2019 11:28:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Henriques <lhenriques@suse.com>,
	Christoph Hellwig <hch@lst.de>,
	Carlos Maiolino <cmaiolino@redhat.com>
Subject: Re: [PATCH] mm: Make kvfree safe to call
Message-ID: <20190729092830.GB10926@dhcp22.suse.cz>
References: <20190726210137.23395-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726210137.23395-1-willy@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-07-19 14:01:37, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> Since vfree() can sleep, calling kvfree() from contexts where sleeping
> is not permitted (eg holding a spinlock) is a bit of a lottery whether
> it'll work.  Introduce kvfree_safe() for situations where we know we can
> sleep, but make kvfree() safe by default.

So now you have converted all kvfree callers to an atomic version. Is
that really desirable? Aren't we adding way too much work to be done in
a deferred context? If not then why a regular vfree cannot do this
already and then we do not need vfree_atomic and kvfree_safe.

In other words, why do we want to complicate the API further?

> Reported-by: Jeff Layton <jlayton@kernel.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Luis Henriques <lhenriques@suse.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Carlos Maiolino <cmaiolino@redhat.com>
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> ---
>  mm/util.c | 26 ++++++++++++++++++++++++--
>  1 file changed, 24 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index bab284d69c8c..992f0332dced 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -470,6 +470,28 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  }
>  EXPORT_SYMBOL(kvmalloc_node);
>  
> +/**
> + * kvfree_fast() - Free memory.
> + * @addr: Pointer to allocated memory.
> + *
> + * kvfree_fast frees memory allocated by any of vmalloc(), kmalloc() or
> + * kvmalloc().  It is slightly more efficient to use kfree() or vfree() if
> + * you are certain that you know which one to use.
> + *
> + * Context: Either preemptible task context or not-NMI interrupt.  Must not
> + * hold a spinlock as it can sleep.
> + */
> +void kvfree_fast(const void *addr)
> +{
> +	might_sleep();
> +
> +	if (is_vmalloc_addr(addr))
> +		vfree(addr);
> +	else
> +		kfree(addr);
> +}
> +EXPORT_SYMBOL(kvfree_fast);
> +
>  /**
>   * kvfree() - Free memory.
>   * @addr: Pointer to allocated memory.
> @@ -478,12 +500,12 @@ EXPORT_SYMBOL(kvmalloc_node);
>   * It is slightly more efficient to use kfree() or vfree() if you are certain
>   * that you know which one to use.
>   *
> - * Context: Either preemptible task context or not-NMI interrupt.
> + * Context: Any context except NMI.
>   */
>  void kvfree(const void *addr)
>  {
>  	if (is_vmalloc_addr(addr))
> -		vfree(addr);
> +		vfree_atomic(addr);
>  	else
>  		kfree(addr);
>  }
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

