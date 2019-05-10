Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5F3DC04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 02:12:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EBC52084A
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 02:12:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EBC52084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08CAA6B0007; Thu,  9 May 2019 22:12:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03D906B0008; Thu,  9 May 2019 22:12:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6F096B000A; Thu,  9 May 2019 22:12:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B07456B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 22:12:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 14so2981071pgo.14
        for <linux-mm@kvack.org>; Thu, 09 May 2019 19:12:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=feXkgBdiuN5qHZPZA9EQ7hgk1zD8KbeJwRgKIBVEnUk=;
        b=p/UKQvUezHqMaU9MmNFWnDxZKDUW3iXjJHccUTf35z2lJYP4HUgigCpIhbzRpUtlUj
         f5VZ1psYb8wXufKft+8MUIWVIn1bMYeNKClLzo7EtgawauUXIWZB3ishixcMVqg7d7Qy
         il9gZvO1+utoGCkKYbQfamT6YaLuV2CiAu0jEDrq6s9xBbMsvw1ucLhhztFZsGTlOogq
         JOApHMrmOJZPyeaucbERTApBMMAdsAUR1hQc4YMYbIVdAvLaHz/xJp7UMK+FuaY2mb9c
         2jLS5VUdNkHAPsF8RCbHvAOk+YTairCWt2ZW6lrLQj/1HZ8+Ky4sbspgUqaZrfu4CTen
         lM5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVgRJ8Sgu2VtCve/bAuU9EFTH0zYxxYn5O6LelR287C4sIwjRLN
	ZgqRxnZyc93l4uRl9c8I3CTy1vJYnyKCwQ85F5or2i5bVEIHcOxDkikxNnuKEBY2KTmHWoZbQeg
	5N2GL7rXnZocTrIxsrDJb5YgEny03tWbH+5qzRRiimpGW8ha2aTaQrLFFglN+st3t8g==
X-Received: by 2002:a65:6541:: with SMTP id a1mr9806710pgw.233.1557454363986;
        Thu, 09 May 2019 19:12:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsLy8g8LB/oDvkcHZf5QtzU4YacbpWlMtHthpJDbMNBk+B0WBdaFhLTa90iCjPmhXFOurE
X-Received: by 2002:a65:6541:: with SMTP id a1mr9806612pgw.233.1557454363193;
        Thu, 09 May 2019 19:12:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557454363; cv=none;
        d=google.com; s=arc-20160816;
        b=HLHSHvTGnGslW2/EZ7pK+fCCWBMXW2Ie4SIKFkVwy+pCXpMab/WM7+hW0unirrd9Nq
         NendysbA4GZ6Oc+YuqXy14e5uCW0LOT1vw/dOY23m8xEts/i4N9CaTTEjDs6JNsmE74v
         RTqS6sMCNsK4jcxfrtt7yhiTvKtwV1dN4hMkI++7+UDXajz/Pnz972Yn1x9/jqqEaRcO
         3oXYI2Q0fMr7whjI03bQ7X9fCaFxlD15zeXY/xhXUkMyZ5Ljx7JV8m94hx3YXfogRUJ6
         9H+HgeakM+t0N+y7KMc43b45FTFLpaunQ9ebjP+4F9G3z0aTVky4Fd5XW4gh0IvDtnA0
         KmzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=feXkgBdiuN5qHZPZA9EQ7hgk1zD8KbeJwRgKIBVEnUk=;
        b=cmQ7Gi2VVeNEnTlKBuuomsnRuHnOaLr9BuVa/InYE475wFGOSxsFdntEfneqnTJzN5
         dCaT2cwHNi/QqPE1VorwhfJmkNB8WSM9nnLFm+Tz1+/HknijTHyhrDqg0nX2cumhGgvl
         NFmZS+q1YFVQKrktx1cRMB6rBvvOITuJMQyFJMvbvNv9QMxUHTImaVuoRHr1aXVlvif/
         LOd/96YMBDrpA/4JwhU2XDd7ZqluURdSVDApTGOae5UEIGjnBPIrD8WGhcrTc33ooAWK
         d5lgvdCS1G4tdwOCHQ771vYZmLDuUMDLdoBkni3FMrpV91xiEuThOoYjy9Q7TRYoMO3w
         cymw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c38si5770608pgl.185.2019.05.09.19.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 19:12:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 May 2019 19:12:42 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga007.fm.intel.com with ESMTP; 09 May 2019 19:12:40 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <hannes@cmpxchg.org>,  <mhocko@suse.com>,  <mgorman@techsingularity.net>,  <kirill.shutemov@linux.intel.com>,  <hughd@google.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
Date: Fri, 10 May 2019 10:12:40 +0800
In-Reply-To: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Fri, 10 May 2019 08:16:32 +0800")
Message-ID: <87y33fjbvr.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yang Shi <yang.shi@linux.alibaba.com> writes:

> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
> still gets inc'ed by one even though a whole THP (512 pages) gets
> swapped out.
>
> This doesn't make too much sense to memory reclaim.  For example, direct
> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
> could fulfill it.  But, if nr_reclaimed is not increased correctly,
> direct reclaim may just waste time to reclaim more pages,
> SWAP_CLUSTER_MAX * 512 pages in worst case.
>
> This change may result in more reclaimed pages than scanned pages showed
> by /proc/vmstat since scanning one head page would reclaim 512 base pages.
>
> Cc: "Huang, Ying" <ying.huang@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> I'm not quite sure if it was the intended behavior or just omission. I tried
> to dig into the review history, but didn't find any clue. I may miss some
> discussion.
>
>  mm/vmscan.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fd9de50..7e026ec 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1446,7 +1446,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		unlock_page(page);
>  free_it:
> -		nr_reclaimed++;
> +		/* 
> +		 * THP may get swapped out in a whole, need account
> +		 * all base pages.
> +		 */
> +		nr_reclaimed += (1 << compound_order(page));
>  
>  		/*
>  		 * Is there need to periodically free_page_list? It would

Good catch!  Thanks!

How about to change this to


        nr_reclaimed += hpage_nr_pages(page);

Best Regards,
Huang, Ying

