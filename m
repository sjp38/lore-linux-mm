Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B54FC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:13:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 312E7214AE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:13:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 312E7214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B86FD6B0005; Thu, 25 Apr 2019 04:13:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B32BD6B0006; Thu, 25 Apr 2019 04:13:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FB746B0007; Thu, 25 Apr 2019 04:13:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 618B46B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:13:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id u16so11235112edq.18
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:13:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/R8jGX5rxgMQn5PSRES5v7IjN7JRn2UJ07FSIbIddek=;
        b=jLRqP9nEPNMUJV6bT4qOo3UIdLFBOz5ngjA1gty0fEs41zOUU7Q0l00onwR7alNSGx
         +az6K4FWwDUTomIuzK0ePyDfi9sJPkDItQMuXBfJT72fok+LyXz4UCHKgVAyhPWVW+EL
         kbuSss7X+QGG1khQ48u1oBPtKiigJUU2cRyWCgJgTIe0q85NewObr2GWxzKCNT2uhc31
         +ztMYeuT3udpKYEJklBVxZaSJYG1tlptRvf9TR/S+fV5IdaX2zUopw1k9jS5QkNX/atD
         S3aUiTeUkm67/0njc3GjFtbmuSO/q/KQxz6yDojA5/NILBxk9TKZaOdQwZkkxHlBtUql
         AUzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAXyxOj1fPsGRxa3rFvANy5xgtyOh3VcqZDJnp2cVdGRAGdkMIcD
	P1lraFgAlHOMEgqHx5Df8qao7h73M98AUVB3Q/BhZInPfi5jCYv4vnJFgr7iGYlohNSFdBE0FNf
	Ty7e/NzedUtgIsp+rlEoM6lxE8xS9AFh4BfRb1YkTCuEBk8RHx/4TakZu+RwbIPFgzQ==
X-Received: by 2002:a50:901b:: with SMTP id b27mr23395469eda.250.1556173851398;
        Wed, 24 Apr 2019 23:30:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPJR0gpnGSKplVZ9eap4lAhp6ODVG8f6JP468+RZ38jIOEyzcvw7veGDOAj/ZpCFVGXNOJ
X-Received: by 2002:a50:901b:: with SMTP id b27mr23395418eda.250.1556173850518;
        Wed, 24 Apr 2019 23:30:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556173850; cv=none;
        d=google.com; s=arc-20160816;
        b=eTJme7zAIWABEO6sVtQ6nCeFblfvRdt59MvE6SH5WdYWvT760y3hF8gP121xG4t2+p
         rOGmc2bPJsnoY/pjzt2ZQuCqlyF2kXWHJW58+LCIqsb8+vY1cQ5hGbyfl9rCHHCvAZ0t
         wSjsHBIXl1dRz+LwPRHaiFrewElTDYwwWGjmBn8B/37Z84SVqj2XUi78hzhSZA2gy2ND
         VwfAcM3gsEabileFGobebv04bfJIkqeQuzh40MNDvKk4txJFTveoJjO4WvKqYFJhTJPX
         iwZOKRqbkVBgG+qXQnWn5CMgkz2XO0MVOCJxjsvUGpCkvdL3v6CbSv700YAL+ggDMtFD
         mylg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/R8jGX5rxgMQn5PSRES5v7IjN7JRn2UJ07FSIbIddek=;
        b=fl5DUDB85EhHuaY0swuAbukazFyS4/6gRmxQyAnlkOImC/LZdHgwbht/PmQ1SCD36X
         bCABNhhM6G1v/GebIIAakTgkQeocScCm8rIHMcmXJMY/2Et+OQnRC1xkuThPrtAIKbsI
         /UAYquzqxGzEM7VfY8ZXOJEIX591QsUL0Wi3+oiPOY/GFSt5QPAk133fqREjIHPGSNef
         Hk5D2TFVOr4xhgSgElaeqnZG/dvfR60BhTaHEyDyPfi3gKVH0wOt02kEeFjsnWd6FPoM
         mA4u6i4HLy4tL9a4DXY5iF91BkstQFOii5/rz8PfhZ1s1XwfDoo2HonLCixdeJC2fqgf
         lSVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si2915095edb.172.2019.04.24.23.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 23:30:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DEC69AEB2;
	Thu, 25 Apr 2019 06:30:49 +0000 (UTC)
Date: Thu, 25 Apr 2019 08:30:48 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/vmscan: don't disable irq again when count pgrefill
 for memcg
Message-ID: <20190425063048.GI12751@dhcp22.suse.cz>
References: <1556093494-30798-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556093494-30798-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-04-19 16:11:34, Yafang Shao wrote:
> We can use __count_memcg_events directly because this callsite is alreay
> protected by spin_lock_irq.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 347c9b3..18d48e6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2035,7 +2035,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	__count_vm_events(PGREFILL, nr_scanned);
> -	count_memcg_events(lruvec_memcg(lruvec), PGREFILL, nr_scanned);
> +	__count_memcg_events(lruvec_memcg(lruvec), PGREFILL, nr_scanned);
>  
>  	spin_unlock_irq(&pgdat->lru_lock);
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

