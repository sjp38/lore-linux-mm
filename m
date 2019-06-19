Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E077C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:09:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AA41215EA
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:09:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AA41215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA7CC6B0005; Wed, 19 Jun 2019 09:09:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E578E8E0002; Wed, 19 Jun 2019 09:09:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D207D8E0001; Wed, 19 Jun 2019 09:09:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85E106B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:09:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l14so1220861edw.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:09:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7SQPNktCLhCqG/wC14MDxLI9EWyQNI+OuEYWpOWC0+8=;
        b=fuMFq9acSozjCwbDt70ickwMmrm56TPM3rtn/jeMhNfY9EP8FTFwfaCbNvvqiRLA59
         WFOrJAkc86+ts7gg/NQRoRZ/aU2mZpFOpWXXXxvwHmGhfccyxJgGIt/U+W6lEDAghoAF
         m0HlJfjF6iOH0F/WXnE8qcB2b/a1KLysfSTmcskFfiSAjKhK66RKRXZQTPLchJIU/jE8
         8sSJgAnC+xVogV8n9FXVQfVZGfwBuW73W/RYNujGWbIvIOr7tejBWo6UwrzdcSG7V9Jx
         bJ6yGq8UROWLTPbosA0vUCX6rv7J1ZrtnT1iKJsahjM1fL9aVox7KPCC0a4VDMVvAsl3
         XPng==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVRFyvxLyp02bXsbWu3cquF9s2M8IDyTb97nj/sdUt+2cqy2kqR
	6o96XwWMc5nooRFvXvJhKQPNQMmroQZhEmUnspQNZEzq19lRbg6mVH2Zzb7Dzc8I5b4ETEhaiOc
	n3kSNTqJNA5oXWqVQPZPSBy0JKajJaRI/uAH0aaalL17gH8JUtQKyQ3COiNFrk7c=
X-Received: by 2002:a17:906:eb93:: with SMTP id mh19mr33405234ejb.42.1560949787926;
        Wed, 19 Jun 2019 06:09:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtzBzkiFA/XKS0/y+ILhe7rmcXXiGVtwi5QsEXRiOjs85v4UU0UEZUu9fEqcVpllwhiSIl
X-Received: by 2002:a17:906:eb93:: with SMTP id mh19mr33405168ejb.42.1560949787052;
        Wed, 19 Jun 2019 06:09:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560949787; cv=none;
        d=google.com; s=arc-20160816;
        b=YH3uuTMjejqerejj+UNS9nqOCglL/ix5ZiomZXxa5+a7I5SLejOU7QsSACB4oqlB2q
         WckTrC3qLHrgk6ukEN0yc1iCgaXpryFmXhGpyi5vx68NF1qAdoQJdfFzOIU8SyHi4PSG
         i3oolVrW6heZF09NLunl0Cuz0tUSxL4To3UMQsLJhidtZsc5WlFKWEzZef6EtKv0z8Fg
         z31Xb/TtvScKd6iZ+onQyEJlcjyUfP35SRvVWNPwTrsw5xnrfsBCNd4GMVRYuHRCXlyN
         mN5fZe6HVi1WRIxKep0veyL2lpIdB8Ql0qj/ONzRe6qfT2UUOEDe4tSnjcuMWPjzGRpP
         lG4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7SQPNktCLhCqG/wC14MDxLI9EWyQNI+OuEYWpOWC0+8=;
        b=Tw/U6qbNPiv3pmoWXZ98m9dCxGb10I9Ksf7I+f6jh1nne8eMMOGrV78ZugUFHJAi1t
         Nfh4Y+Pj9/q42FaEfFUTceJ734wdcmljeOj8dQsrmaxWvWM/Xr7mjqeqlKvwdTp/6Vjo
         srOxUFWYI4gNnO99vEPEAYJOQE4EclKgphHKe5HAracUx5wZjgxwQ4wlHRn8y4fFHET7
         Mt1xeMkPFWrkXiJsdMr/WtZsZWO/MzJ06IBnNR3sw0r9eLyc5QaKssgSOdJxpO+5SYlR
         2iwyKxNgbLc8RhB2T4Xus5KQGi2UVj+i3LyIRMb2vd69L8X1K5FrprOwIHbV95ha/K0J
         IfGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si13648673eda.200.2019.06.19.06.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 06:09:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 53761B002;
	Wed, 19 Jun 2019 13:09:46 +0000 (UTC)
Date: Wed, 19 Jun 2019 15:09:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 2/5] mm: change PAGEREF_RECLAIM_CLEAN with
 PAGE_REFRECLAIM
Message-ID: <20190619130943.GP2968@dhcp22.suse.cz>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-3-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610111252.239156-3-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 10-06-19 20:12:49, Minchan Kim wrote:
> The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
> as default. It is for preventing to reclaim dirty pages when CMA try to
> migrate pages. Strictly speaking, we don't need it because CMA didn't allow
> to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.
> 
> Moreover, it has a problem to prevent anonymous pages's swap out even
> though force_reclaim = true in shrink_page_list on upcoming patch.
> So this patch makes references's default value to PAGEREF_RECLAIM and
> rename force_reclaim with ignore_references to make it more clear.
> 
> This is a preparatory work for next patch.
> 
> * RFCv1
>  * use ignore_referecnes as parameter name - hannes
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

The code path is quite tricky to follow but the patch looks OK to me.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 84dcb651d05c..0973a46a0472 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1102,7 +1102,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				      struct scan_control *sc,
>  				      enum ttu_flags ttu_flags,
>  				      struct reclaim_stat *stat,
> -				      bool force_reclaim)
> +				      bool ignore_references)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> @@ -1116,7 +1116,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		struct address_space *mapping;
>  		struct page *page;
>  		int may_enter_fs;
> -		enum page_references references = PAGEREF_RECLAIM_CLEAN;
> +		enum page_references references = PAGEREF_RECLAIM;
>  		bool dirty, writeback;
>  		unsigned int nr_pages;
>  
> @@ -1247,7 +1247,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -		if (!force_reclaim)
> +		if (!ignore_references)
>  			references = page_check_references(page, sc);
>  
>  		switch (references) {
> -- 
> 2.22.0.rc2.383.gf4fbbf30c2-goog

-- 
Michal Hocko
SUSE Labs

