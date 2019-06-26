Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C733C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:49:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6ED91205C9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:49:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ED91205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD34F8E000C; Wed, 26 Jun 2019 10:49:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D831A8E0002; Wed, 26 Jun 2019 10:49:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4C068E000C; Wed, 26 Jun 2019 10:49:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7409D8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:49:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so3551698edm.21
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:49:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F1ICB47OhDLdmbIw8ue1wS4VYkILz+T5uVLMeHYjO0Y=;
        b=OIiBH+hXxbgCn/wH7EMD4aeBHGSm0PP0Lw310jBXsZtLiqqRBL/3MXIAfoxtW8473l
         QBjyvQTT7C/rXAdkRvVnBHVWg4f7BhWzph4NqCuCYDzjU6m8EHOHLeSqhLYfxmdhGTkR
         /L8WRN0PqKcF3HMAh1T4qla9cGVGvzx1gNOB80X4AbBVmDy6PoCUiFYiU37/SoYOrUIc
         CDoBcsJ4NxvqoJGbwZ4MQ3WM/LiuPWcL2QY+wckJBEV0JSFaKZsyJIxZhMqj8kEbRxl3
         79CgucotS1uuOXyQW+Tr7ulya4jCVAIhsH52FWitVRiqVDy8R34CTTe6u6TNCqtX2PEx
         +k0Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUrMCjLL5pgixxMGkWt2X6vfbipLydn8UG2kYVfjmwS/uhTLzvo
	ZWYkh5wDtx4LC2E6Wo4FA+QhiALjlcvl9+LmewQRCitjGnqjXNEiZig/5odyeEYFmoTtPDc8COb
	Dz3Suqa2WYif0MREz8EU9iQZAQYRzdSh8wMkzOIsC0j24fiM+TiXBQQrGU4M94CA=
X-Received: by 2002:a50:9762:: with SMTP id d31mr5784732edb.114.1561560587068;
        Wed, 26 Jun 2019 07:49:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+gqReOQKIlhioPDnOdmsAQLBqfmkdFoL9nWlvsp8YnSdTZ51iwbB2yssWW+4MxUNSs4A7
X-Received: by 2002:a50:9762:: with SMTP id d31mr5784648edb.114.1561560586215;
        Wed, 26 Jun 2019 07:49:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561560586; cv=none;
        d=google.com; s=arc-20160816;
        b=sKonQ4ArIm4EP2QrHlAjxCELm/aFXbxFGVVqm1ct9Vu8fN72rZ/QBvozTi3XObCN+f
         lVCmoS3G4zC9RUU08gObbfyliB1zj5PgccWruaBXb0sm4B23iUkdJrfngTVRTycUILRb
         yQTu+yomsLXa7ldGO2qKOY2wY+N/rhrhbHqOa8YlRqJ6khASVTCwPBCYXwXgENQ0pnwy
         FGwZTQKWOdhQ91zt197+h/peXJXfdrn29l+DWlLHhIwl0xagIoIz+FcvOrcq8sO5GqYX
         J2RSVMMPG5uFfjBGLS5RP4iiZWCeVseyRkX92QLRtAJgT+KVUA+wHoe+l1sJrCxG58hB
         F7qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F1ICB47OhDLdmbIw8ue1wS4VYkILz+T5uVLMeHYjO0Y=;
        b=r+k32wLoq1WFIWzueeTeeHd5w38FAmnNJRtgbfZ57fPau0K/Z+VlV/BUpDtmJ7/5rg
         WsrmfxKHzeWS+6y8KO0vv7sSLb8u4i8OYvGyyChHnyNlbcdYpWERzgRuk0N68cuNcZb6
         OLF9JrhsUsgTkkJIt2plT1WOFPUtWpe4vj0J/UNh2MehXN9ehp0eFYkhIxxXZd8qh/Mp
         QDb8PyUnDBt3J1OWl931EPsw3jZXwhCmsZSyftFp+fCvMJwsG4wyIL2ZpeDDAWuzz/yP
         hId0swuAU9KCag9aU9PnfU1vmk0dpbgXYL4bRnLPrC/W8Mdji7AvEL8znH+EXjXQHolw
         b6pA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ka18si2718614ejb.151.2019.06.26.07.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 07:49:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4CFCFAC2E;
	Wed, 26 Jun 2019 14:49:45 +0000 (UTC)
Date: Wed, 26 Jun 2019 16:49:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	Qian Cai <cai@lca.pw>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190626144943.GY17798@dhcp22.suse.cz>
References: <20190626121943.131390-1-glider@google.com>
 <20190626121943.131390-2-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626121943.131390-2-glider@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 14:19:42, Alexander Potapenko wrote:
[...]
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index 8c94c89a6f7e..fe5d33060415 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
[...]
> @@ -428,6 +428,8 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
>  	}
>  
>  	offset = vaddr - page->vaddr;
> +	if (want_init_on_free())
> +		memset(vaddr, 0, pool->size);

any reason why this is not in DMAPOOL_DEBUG else branch? Why would you
want to both zero on free and poison on free?

>  #ifdef	DMAPOOL_DEBUG
>  	if ((dma - page->dma) != offset) {
>  		spin_unlock_irqrestore(&pool->lock, flags);

[...]

> @@ -1142,6 +1200,8 @@ static __always_inline bool free_pages_prepare(struct page *page,
>  	}
>  	arch_free_page(page, order);
>  	kernel_poison_pages(page, 1 << order, 0);
> +	if (want_init_on_free())
> +		kernel_init_free_pages(page, 1 << order);

same here. If you don't want to make this exclusive then you have to
zero before poisoning otherwise you are going to blow up on the poison
check, right?

>  	if (debug_pagealloc_enabled())
>  		kernel_map_pages(page, 1 << order, 0);
>  
-- 
Michal Hocko
SUSE Labs

