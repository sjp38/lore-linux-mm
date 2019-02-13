Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14485C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:23:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFE40222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:23:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFE40222BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 679818E0002; Wed, 13 Feb 2019 09:23:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 629028E0001; Wed, 13 Feb 2019 09:23:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 518D58E0002; Wed, 13 Feb 2019 09:23:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC2378E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:23:10 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u7so1081680edj.10
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:23:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=02/KIR4uFq6Kp5YWpHnlgUfm0mgT3Xh137Apdjb/mRw=;
        b=QVFzr1W36L3fFUNfHBkSM+37NTBw6U41+CO8MaA7uhaI4/edrsOcyHDm+nssOEJznD
         Yz2Z/1qn7QvTo4ynrimjvgx3j/095cMZf5PbH+xKaPfyNswYJoBeRzZiCPrboS/i2AeA
         6G1m1giIJv3iG7Ik5PluStYqheGh68bHVaZIKa896uJq3Hsyo0Qc3HzhAch2eD44fxWB
         ARt12KEKxsrZmbnFJmXErjsOjjnTgRMMfH1C1vyNInr8MXlSV/TgPQbzweFenGtBmGsj
         BBl6Jz/OzAEGeqBwJ98CsqguYWECME/j6MEVjrnDzhTCfzi4c/uSDwn+xRiw2CLrOiIw
         eKeQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAua2Mmqh2ZlvOkJrm2ouwCcFSz4v6XxWNMzGl05FG81MVL++RQ0P
	EZ1extoKnX7QKViMvMDcR/FUBNuL4/WBtpxl7nfyl9+UtzV/C7kStfF14XybhS0WvgraipgvcH1
	JIa9lI3Zsg3T1/zMDWRfx08zxpaLGamC3OpB4YpaBskZd7Xvu0kQHzE27NSYTrQw=
X-Received: by 2002:a50:bb2c:: with SMTP id y41mr576871ede.147.1550067790474;
        Wed, 13 Feb 2019 06:23:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLTDMs1TWqZ9HEEZjsKETRmrWV2xUxMWLKlREFIhX3wGlHEe8KjSkZ4QpbixTe/ji3jxqx
X-Received: by 2002:a50:bb2c:: with SMTP id y41mr576822ede.147.1550067789638;
        Wed, 13 Feb 2019 06:23:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550067789; cv=none;
        d=google.com; s=arc-20160816;
        b=I7JHtmzYb0iWkLB7wVEW6V/NM+/nl4LwYYR7HpPEUAz6q7Ay0vj+sMvlQXcoAJ7aO+
         GZCDzZyhxog5dOUuSTNiudUF/6ljBSEujJ1BGsW91TFC9ZFtrKBLNkMKPvYCs50quf9U
         +TV3oBCE0CHIwYjXO27doe5i5s8zX0aV/G2Kam/qGlVCUJIWAaADMtf+tTD08dTiK+y4
         wc5htvcIeVkUBdfsnFbV7cxN/wjCxjlvfvnr0VV0TUSb/hT0j8TttwDsUANkKLrsql7o
         MoeyN6N+frppfvYgfQVThj2uZdMNmAUdqIBVRM+na6tSDStbYxwCksZBw3t7OLPt5GmA
         qxbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=02/KIR4uFq6Kp5YWpHnlgUfm0mgT3Xh137Apdjb/mRw=;
        b=K3NybTjovL9qtERe+1ijVQXGtxXNJUS+xhieGrmpt3mx8Z+8IcxQbChViLX8kf1cmg
         ldz8Iu27CWWuXC36Znpsw2fS3oGSey+ASMTderts05w6KxwH8vWSD/syNrldAHalteaf
         lWzigeBQvNhnru3tQDzN1CF5qKWuXZNCZu0Iq0dDRhPUZVTfWNcVU/a6rdb5wzHDo0V1
         2O35zY1hOp0jZSGS0ZxRvUVZrLKKnNQWFpJKcPVDMnkfcxhXQLFtnIHQ0EanPPyaUgXJ
         56MFTpjyJ+Loh190kioT3zP+LrEZUdqhDak4JQqPXICba4TDIOZwY79T40uo8bv+iLkB
         zF1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k59si4737684edc.187.2019.02.13.06.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 06:23:09 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CE619B120;
	Wed, 13 Feb 2019 14:23:08 +0000 (UTC)
Date: Wed, 13 Feb 2019 15:23:08 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Fix __dump_page() for poisoned pages
Message-ID: <20190213142308.GQ4525@dhcp22.suse.cz>
References: <dbbcd36ca1f045ec81f49c7657928a1cdf24872b.1550065120.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dbbcd36ca1f045ec81f49c7657928a1cdf24872b.1550065120.git.robin.murphy@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 13:40:49, Robin Murphy wrote:
> Evaluating page_mapping() on a poisoned page ends up dereferencing junk
> and making PF_POISONED_CHECK() considerably crashier than intended. Fix
> that by not inspecting the mapping until we've determined that it's
> likely to be valid.

Has this ever triggered? I am mainly asking because there is no usage of
mapping so I would expect that the compiler wouldn't really call
page_mapping until it is really used.

> Fixes: 1c6fb1d89e73 ("mm: print more information about mapping in __dump_page")
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> ---
>  mm/debug.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index 0abb987dad9b..1611cf00a137 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -44,7 +44,7 @@ const struct trace_print_flags vmaflag_names[] = {
>  
>  void __dump_page(struct page *page, const char *reason)
>  {
> -	struct address_space *mapping = page_mapping(page);
> +	struct address_space *mapping;
>  	bool page_poisoned = PagePoisoned(page);
>  	int mapcount;
>  
> @@ -58,6 +58,8 @@ void __dump_page(struct page *page, const char *reason)
>  		goto hex_only;
>  	}
>  
> +	mapping = page_mapping(page);
> +
>  	/*
>  	 * Avoid VM_BUG_ON() in page_mapcount().
>  	 * page->_mapcount space in struct page is used by sl[aou]b pages to
> -- 
> 2.20.1.dirty
> 

-- 
Michal Hocko
SUSE Labs

