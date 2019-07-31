Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC963C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:10:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1521208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:10:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1521208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 592128E0006; Wed, 31 Jul 2019 05:10:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51C5A8E0001; Wed, 31 Jul 2019 05:10:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E6E98E0006; Wed, 31 Jul 2019 05:10:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E30368E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:10:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so41963721edr.13
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:10:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Wzn0shD/jWfiWGoCb6QDl7S1UN2cuodt769AG6bBrkc=;
        b=EJn0CXlEIDDuKZFMtzo/IfDnl1oyzl8sdA8b4jDhKKEbP18CHicGLDO00729zPApnZ
         OS4Zk1o6Y2o0trSozjixUvt/lBpQ1btbDTDwGzs4ko8OCJGNOYb4lGTC0UykJ/wDz3Hp
         KPnPiSbCJChBTlRi0bJ4Nu0DBSC9i+COb/8RPrgmFT/gZliWe/xVSc66IvpQv5TTW4XX
         jMsJCteqa8QsxI7/Cm12kqgGZVx8bokFDnYanic5DJoIuhHbN/Vy9bxS19QuDZIqFaGU
         W0LM5LmDoX+c2L7lNF9A0LOwOuIXpw+hnTl/KLJEaFOBeIeHi79m7j2J91C88uyhg25B
         gEGw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV5rym1bdyPfs93iHyfy4g5OIOZ1GHlP6Ai8rD0OIVG+Td+zNIN
	7QlYHllelPBvJaKilfyA+T3Iwd2T5VKJ0FiE/NkP/GZpbn66fTG2vzMDM5peUADAmFWsIPk9UR6
	nUYZt7YdODuipnq/9erWH93WKr2DW/VwlMfvbN7otoeOjiMa3g1M0aKRIHkm9gn4=
X-Received: by 2002:a50:b122:: with SMTP id k31mr107025252edd.204.1564564214517;
        Wed, 31 Jul 2019 02:10:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEh5AsldPm1UkxDkChaqE36VjHy+zrEZo4Hr2iCiDUAwPj+0D/FkZv1Km3q3GQf6Q1UeHi
X-Received: by 2002:a50:b122:: with SMTP id k31mr107025186edd.204.1564564213575;
        Wed, 31 Jul 2019 02:10:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564564213; cv=none;
        d=google.com; s=arc-20160816;
        b=cS/AItcuC02bUvl2cI80xOLZRJa507QwNwQIzkvFTvNWkgRqJZ6SM0VSWBqQSP1qWM
         WDuL1p7xguX9w31OWIKI/90WyX3a5v4AwR6A4eM1ZZJ5XeQVlJLRLYRrDwJgCZGsMx+E
         PTHjbCNl6OUx8Lbj46Xa69aGmseIkBg671jYCIqa8pwkzHJ1FKIlKAM3eWYSNL1dZZb2
         q7cmIo/rP2RLSLuG4QbBrMXr1BmtRhGZ+JVp4klQvpdmls7YAZLfjaNut+AAUbeHm6f6
         Rw7zAtSNCezvgTwooTdent/MUV9fe/907LJDAQU/fUrAI4xk5cqIpycGmE0GjPwqIteF
         jSPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Wzn0shD/jWfiWGoCb6QDl7S1UN2cuodt769AG6bBrkc=;
        b=ixV0J4vQ5NkQfZNIQoJABz3G/uItuQBUYCDDQyQy9cwY+Ty5LPmgoUzFP6bWiFPg7u
         Zy3JSgbiqmzzai9gpcn7CKfwd6hgme1QbbHOiMqN8zShGDv2vTwurBCOaGxMkET72mvl
         19sWVJUXpxYahEiYkjbP500PN+rgmpnki9Ykdgm0m4zv5Dpz70LEhxTsuiaKTT5oHSlM
         S2xviq/iFGOB02T1fyJOZrJF0f1ATlv6GnwEVweYxhy245zNRf4dFTGPIQqFUoi8eQqj
         M7RMbBl/nSU4seEEs72s4wbdRYP4ADE1hCgVLBuloF1e7d9SzwlNV5F4EwPH+d5Hf9dq
         KEXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f58si20178332edf.135.2019.07.31.02.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 02:10:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0FB9BABE9;
	Wed, 31 Jul 2019 09:10:13 +0000 (UTC)
Date: Wed, 31 Jul 2019 11:10:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-ID: <20190731091012.GE9330@dhcp22.suse.cz>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190727132334.9184-1-catalin.marinas@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 27-07-19 14:23:33, Catalin Marinas wrote:
> Add mempool allocations for struct kmemleak_object and
> kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> under memory pressure. Additionally, mask out all the gfp flags passed
> to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> 
> A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> different minimum pool size (defaulting to NR_CPUS * 4).
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Qian Cai <cai@lca.pw>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

I am not familiar with the kmemleak code so I cannot really give my ack
but I can give my thumbs up at least. This is definitely an improvement
and step into the right direction. The gfp flags games were just broken.

My only recommendation would be to drop the kernel parameter as
mentioned in other email. We have just too many of them and if the
current auto-tuning is not sufficient we want to hear about that and
find a better one or add a parameter only if we fail.

Thanks!
-- 
Michal Hocko
SUSE Labs

