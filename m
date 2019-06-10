Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C881C282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 07:27:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEFB1207E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 07:26:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEFB1207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AFEA6B026E; Mon, 10 Jun 2019 03:26:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 062BE6B026F; Mon, 10 Jun 2019 03:26:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E92166B0270; Mon, 10 Jun 2019 03:26:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97BC66B026E
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 03:26:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so4422078edp.11
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:26:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/ktFxWC8f5VaA3fAqx8/BgVwk4wAVIvuEdrQ3jObty8=;
        b=J9+QITC/rcjS1lgeeEuI0TFoQTnM+qIr9ZX4zaYPfmbbt1Bl29oOX6pdinSlNkGEcx
         WXKNkQSbiw52VvYHdWvSMdw2NjinDxz1yFnLgyA5QH8xEP1AyTWIZp7c2+lgRMqOP/y8
         nNf/V9LwZU/gXh/iesTQTA6B4BqiDR0Z8sThoNmJ8vJl+F1EjftUFGvW+gauncxd41WK
         rxCjTb21pd4FEYfRIYL3S4ZErrnknmYGC+q+dTagzp/KIcS5IZh9MABXLKEr8a2iN603
         5hA2ib3YCFRB3bC/Ts/yp6EonMrMbG0iMv/3An5DBYnbJRrbPP8+7cKAf1Q8lirHgs7i
         TCIw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU/0f8jxGvKNV/69Dlhi8gr2LGFSUdDLySHeWAE6cJyy86WzbW3
	TUSSh2i32bkZTTdFQMDV6q/9e5wq0/3JItET17LIMkNLKXviUMghQPDhEaqDL2DlOa12HfUCoCw
	LuCHG3itYjtd83LDyychvoXnbweI6helj/PdYHIhwmykvbuViuB0CW6oZb0AHD6Q=
X-Received: by 2002:a17:906:53c4:: with SMTP id p4mr58272053ejo.160.1560151618096;
        Mon, 10 Jun 2019 00:26:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/ONDKLFJxLkrX8uafvKOCAo86Ko0fdz9HPPS0NufQuyhUWy9erN7w1d+QWYvwfwST4Vob
X-Received: by 2002:a17:906:53c4:: with SMTP id p4mr58272013ejo.160.1560151617261;
        Mon, 10 Jun 2019 00:26:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560151617; cv=none;
        d=google.com; s=arc-20160816;
        b=C9U6RcoFJTDwhS7rCUl6yogYXROA8j7G0jzNm7H5sdB7Cz0QIi/lQHjdB3owXraxFZ
         MKNjfcsE8BhbGzJSDWcyrJ7GTfJgvIXlTms7/U4+yAD78gQ/GlWj3KwVO0AOw91QooUV
         Da0x4/pflfCfhP2cHXq1KK513lzBCaiDoMCc4XTMMkz9XfCJBFJtDu25WEEPF63d0/4Z
         N9HQdgdZ8ew26d3BFyCiKrslt9V/QGOOAZYk5OHUgBClo0AgzhgvaoAnfJmaviRGN7bs
         NfEOZ1k0lpjL7ruGKxPKu60yTZvpjdN+L2u3o7q2e8UFpHiywz7ys+Km65Fi41NmNpuq
         8DIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/ktFxWC8f5VaA3fAqx8/BgVwk4wAVIvuEdrQ3jObty8=;
        b=pTDpdFmqhGZloLfdUIgIGQxrs6x3vj0RJG67lYAfhXV4rRi/Pfk3p/RYClJRmvk0HR
         ZLQH/Dfa7h5D/sTc/eeg/WGqOCyRHKb2EB2ADaDEcHqiK5BHOXAiHDAqpkXtuz3sKl05
         AbNaO7PO/cm9ZW1I/roqT7U154nQhzimnvlImgdnE+w9u7RM3xKzbDZY4HZLG1lx+C6z
         zWfYTFCC5rq1uc6d+4MY5+WyPn4lNN2fpwcOU5ckOzFK9qtL+azSnIVV3rCgPn4X+QjY
         DglCD0EjdXGQYeKwDRIZKdayB8+OWJpvwxUHGqmUP6Xeic2PLEvN0vzeTaNFGLjHh15q
         ZefA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z51si8063819edz.300.2019.06.10.00.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 00:26:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6B06FAE5A;
	Mon, 10 Jun 2019 07:26:56 +0000 (UTC)
Date: Mon, 10 Jun 2019 09:26:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: ChenGang <cg.chen@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de,
	pavel.tatashin@microsoft.com, mgorman@techsingularity.net,
	rppt@linux.ibm.com, richard.weiyang@gmail.com,
	alexander.h.duyck@linux.intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: align up min_free_kbytes to multipy of 4
Message-ID: <20190610072655.GB30967@dhcp22.suse.cz>
References: <1560071428-24267-1-git-send-email-cg.chen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560071428-24267-1-git-send-email-cg.chen@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 09-06-19 17:10:28, ChenGang wrote:
> Usually the value of min_free_kbytes is multiply of 4,
> and in this case ,the right shift is ok.
> But if it's not, the right-shifting operation will lose the low 2 bits,
> and this cause kernel don't reserve enough memory.
> So it's necessary to align the value of min_free_kbytes to multiply of 4.
> For example, if min_free_kbytes is 64, then should keep 16 pages,
> but if min_free_kbytes is 65 or 66, then should keep 17 pages.

Could you describe the actual problem? Do we ever generate
min_free_kbytes that would lead to unexpected reserves or is this trying
to compensate for those values being configured from the userspace? If
later why do we care at all?

Have you seen this to be an actual problem or is this mostly motivated
by the code reading?

> Signed-off-by: ChenGang <cg.chen@huawei.com>
> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8a..1baeeba 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7611,7 +7611,8 @@ static void setup_per_zone_lowmem_reserve(void)
>  
>  static void __setup_per_zone_wmarks(void)
>  {
> -	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
> +	unsigned long pages_min =
> +		(PAGE_ALIGN(min_free_kbytes * 1024) / 1024) >> (PAGE_SHIFT - 10);
>  	unsigned long lowmem_pages = 0;
>  	struct zone *zone;
>  	unsigned long flags;
> -- 
> 1.8.5.6
> 

-- 
Michal Hocko
SUSE Labs

