Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9110C04E84
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 08:30:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0FC720665
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 08:30:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0FC720665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 053376B0005; Wed, 29 May 2019 04:30:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1E1D6B000C; Wed, 29 May 2019 04:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0E106B0010; Wed, 29 May 2019 04:30:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76CCC6B0005
	for <linux-mm@kvack.org>; Wed, 29 May 2019 04:30:15 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id q25so498483lfo.14
        for <linux-mm@kvack.org>; Wed, 29 May 2019 01:30:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=66z9CXn36BXlIrCgiNA17P4fMDdbt/qtJa35gb5lgsc=;
        b=ZFxXrZ/GBYxnv4IKy+fk5beUq+dBzOWgE44K3ZC3O4dSTMXDY61hP4gUaoNizJDAeS
         ReSqYhAuCaHAohCIqJjYFFEOcMbr1V4G+q035wzSdKRXT1K+Gx0yqjdQQOQn9zQEcJ8p
         dWmHmnae8L/iKlx2JHevbe88RXv9RGGAINCSiHTHsppFCyuQOoWtbfFVNESXB1ccdV50
         mYB5qNMzNRRDlDQ8ClhVOMNxJySne/8vr7Ifwy5Ekk2AJxcc1DIQcUACpvcIQD9T7RxC
         44nQq2NSSFNYPh9E5Q88dlFcrRaDLgGIXy5nnZ/cOSIwxobcE+w5cZj7psI3LqRG0fYy
         z3vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUpi+ymVN8O6p2K+jmE85/9Z0CyqxpxeVtFemaRYQyfyc2WwKSN
	FNTPyaX3vvupykCNrw85c3nR4uOlOpuwsiFa5yXD6rMv4srWCevEkgQcUqhDsqzd4KYyfVij61R
	gGUbdN1bCLYQQpll3gF3jtHL0mS2lLepIvTZQfTxS9LdUhh5eig/Pk9YAHdrwW/z/Sg==
X-Received: by 2002:a2e:884e:: with SMTP id z14mr21907384ljj.19.1559118614964;
        Wed, 29 May 2019 01:30:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwAdQGtxJxOUYMQCFXdQy+BjCdktqcC7z0czoOIcu9EhtXLQucY8O1AuljScFhkYV+Kl4Q
X-Received: by 2002:a2e:884e:: with SMTP id z14mr21907293ljj.19.1559118613466;
        Wed, 29 May 2019 01:30:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559118613; cv=none;
        d=google.com; s=arc-20160816;
        b=zb5TZ7VtQiPn/4Q+6nhLcpNi7fVyh09n4z8EJGYeshHpBYDwoV490xAPfsc4fDx50V
         2q15o/UkBxFJc/tF5K679mEXPLPyLLBAdsUWxX/iMuToVL/XaVxUR6670PtbdB24DgsV
         C/szIhDmaHbEfjKFUBWng0Fz7WkNNZG6wkRu5N6UWKWCCB4OvKauANfdxqTcRmziOGvu
         qnf4yREnByajpRcKw/m8Xo9QKyuzf5/AFJIQ2uyaA7ATT/dQZW1jKzzjsS+6rZp3jg46
         6CDwhmyt90o53tWQhVKliuGgz87ev3eF5DkW/dfvXo4aUqp7gw+0UvmpfC96FG0YOkQ9
         YUew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=66z9CXn36BXlIrCgiNA17P4fMDdbt/qtJa35gb5lgsc=;
        b=pvE5y6TLaHklDLLE7TdIULfe/wuMKDnd6g3aKDB8H9OdxpQHNlMKxNsOfFvG6kwPar
         xseF8pp9/8yLS/tGfcmDtiUD4E731UTxZvYyU6uV79rVIfm/BpQ+NNF4xYZ0Q8GnLR0E
         n71rrU789gcXzLllxLpscuO/iVo8cERRAQFZBkfeWFVDecwM6Zj6qvwx9WfrXUA7a571
         4y9Dr5oDDW2VGlnkyZrvKQxl/8zo7n6bw4mJdKWBtxp2Wmz3v2eU2DrwLYKk3E09cvor
         5Ka8wvr40u4mVaRYTkOS2dFPRoXwt2zud4hDV6TUyWW3MgkiFL24VZrHiAEuZl/q+TOs
         90QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id w1si1719074ljj.33.2019.05.29.01.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 01:30:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hVtyM-0001yM-CE; Wed, 29 May 2019 11:30:10 +0300
Subject: Re: [PATCH] mm: Fix recent_rotated history
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <155905972210.26456.11178359431724024112.stgit@localhost.localdomain>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <0354e97d-ecc5-f150-7b36-410984c666db@virtuozzo.com>
Date: Wed, 29 May 2019 11:30:09 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <155905972210.26456.11178359431724024112.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Missed Johannes :(

CC

On 28.05.2019 19:09, Kirill Tkhai wrote:
> Johannes pointed that after commit 886cf1901db9
> we lost all zone_reclaim_stat::recent_rotated
> history. This commit fixes that.
> 
> Fixes: 886cf1901db9 "mm: move recent_rotated pages calculation to shrink_inactive_list()"
> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  mm/vmscan.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d9c3e873eca6..1d49329a4d7d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1953,8 +1953,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	if (global_reclaim(sc))
>  		__count_vm_events(item, nr_reclaimed);
>  	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
> -	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
> -	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
> +	reclaim_stat->recent_rotated[0] += stat.nr_activate[0];
> +	reclaim_stat->recent_rotated[1] += stat.nr_activate[1];
>  
>  	move_pages_to_lru(lruvec, &page_list);
>  
> 

