Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C752C06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:02:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19BC6206A3
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:02:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19BC6206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98DC06B0008; Tue,  2 Jul 2019 10:02:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9175D8E0003; Tue,  2 Jul 2019 10:02:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 805868E0001; Tue,  2 Jul 2019 10:02:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 335B36B0008
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:02:37 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id n8so6961960wrx.14
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:02:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UELiINs9G9o3FrNkSSey1z3BVGQyTOgV4egTzbnmvB4=;
        b=LeCHEXSUys8F6xoJgzymVoIszkoiNyiuRGKxsETpQrlOfqcLvA9ZlLUviJQeXEEWAB
         NYgbXBGOU6znJBKWWlA/2RmHbcFkCXAwMhHBpk47eCGKUUSfkODqdPPxDvvIDaROw3a5
         fQqjE2rZjhhheX4lT9/Go4gwQgJ9EWMt5tZB5Nmg8Onw/gH/ix6BCDvr5TTV4WAxsMPz
         48cHLaz+HsIMOnxirzzWC3ZI8b+wL9z2kb2qAitnq76LFsTPIOapFrFDl85FFH5J3L2r
         C1a2rS/2hqy6Xu88W+ls652MehMQ8p5ciyxw2L3bSEh2iexAhI8ogu/A+3yI9dpQNyjE
         mrGg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUywvIgvD4mSxZ1CJ/evkkkJvIzNSX00k8s1cipKqa/ZPaC6959
	Whev5N5TqSdr8lhFv/0XM93t9v72L1yyxqbN5d/XZiZ5MOVl/bqrt4MYVRvYaCm39N4UtoA964Q
	u/MiG1Wm5F9Dj5iI5CejIb85M07+O/Swn0O1g+yw+74/22iNSVKD2aQi7tyCKFxc=
X-Received: by 2002:adf:f902:: with SMTP id b2mr14777538wrr.199.1562076156746;
        Tue, 02 Jul 2019 07:02:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/8uaxLx5kYkD+3H/mPpAfgd9oYsF5TmQw7V2aA28qc47tN4ka2y4CE+LAaEbJk6YPMYEA
X-Received: by 2002:adf:f902:: with SMTP id b2mr14777463wrr.199.1562076155817;
        Tue, 02 Jul 2019 07:02:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562076155; cv=none;
        d=google.com; s=arc-20160816;
        b=Lie/3CsUC0rSsdX9ZF1aSB1u2s1Sfip32pK8OaCSEsy5Uw3g8iuJV/l+Wh9YJp2AHE
         01mLgBqPINrwmdcbNZCtbjjQBU9+3Cn61WHg6AJIodP+xo7hMQXNb5f1ifleVmshByMl
         +xamx14oXur4L4Xk/0M64y6ZvFpdBvJMCA0irgQmiEBlRK0whWF9st94F4/m9PArOF9P
         baNtZps+4/CZRZl0NFa/9ZGZyeQQVdRznY1A8QtJmTb8rlCNoVmB8nzGqqeTMahKJuJX
         QTLtn6OCPOMmdU+7QL7315xIK8dNrzz8Z6TMlJ+aXXklRnb8ouV4UyrKXRf31s4VX1bu
         bu1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UELiINs9G9o3FrNkSSey1z3BVGQyTOgV4egTzbnmvB4=;
        b=KnwRa6JNDJD4nMOsUjtkhrf7g1AFvbuRc4XWkxZm+2IGvrmdvVOlCw3MONqQgagKBS
         t88O4BiX66GY6v6G9Y450i4TCwruQTt9XRavB+Ny3LFh172mMO0g9x8a1YrWNlMpdPcv
         2eZzmoBuoe0+rv63Fxj5iE4nuw0nB+tWxP0pc921A6WA1u7Z/OTlJ19TZZPkkhztTdNp
         k+6rZtvptSi9pTr9WkXj1nD46xwkCSGNmpPZkb8bFallDblCLqQdF/W35AmYYRTJany6
         LwmwKUz8Y92kq9d5p0o85oaxYRR3Ji0XGs5J8X/NGv17SCR414yGI8nMYGofzoQidkHW
         4HFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m32si12106401edm.415.2019.07.02.07.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 07:02:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D1C2CB6FE;
	Tue,  2 Jul 2019 14:02:34 +0000 (UTC)
Date: Tue, 2 Jul 2019 16:02:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>, Qian Cai <cai@lca.pw>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/page_isolate: change the prototype of
 undo_isolate_page_range()
Message-ID: <20190702140232.GH978@dhcp22.suse.cz>
References: <1562075604-8979-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562075604-8979-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-07-19 21:53:24, Pingfan Liu wrote:
> undo_isolate_page_range() never fails, so no need to return value.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: linux-kernel@vger.kernel.org

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/page-isolation.h | 2 +-
>  mm/page_isolation.c            | 3 +--
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 280ae96..1099c2f 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -50,7 +50,7 @@ start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>   * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
>   * target range is [start_pfn, end_pfn)
>   */
> -int
> +void
>  undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  			unsigned migratetype);
>  
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index e3638a5..89c19c0 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -230,7 +230,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  /*
>   * Make isolated pages available again.
>   */
> -int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
> +void undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  			    unsigned migratetype)
>  {
>  	unsigned long pfn;
> @@ -247,7 +247,6 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  			continue;
>  		unset_migratetype_isolate(page, migratetype);
>  	}
> -	return 0;
>  }
>  /*
>   * Test all pages in the range is free(means isolated) or not.
> -- 
> 2.7.5

-- 
Michal Hocko
SUSE Labs

