Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 902CCC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 07:46:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 537962147A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 07:46:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 537962147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7BC96B0003; Wed,  3 Apr 2019 03:46:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2A316B000A; Wed,  3 Apr 2019 03:46:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A19B16B000C; Wed,  3 Apr 2019 03:46:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56CFC6B0003
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 03:46:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c40so7033245eda.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 00:46:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=EdZf1v01vwXSVXwjOGLls8NMppVTiD0btXucI4P+Tww=;
        b=jIVoQzLUduNXALeh0QDXy8XSf3wP5ZiS44LLfa4DRuMRpNMx9lZQ2wM9VI6PJ60J39
         7QCjP28EcXNEF687yOo6GWhxHCyXezPzgO+Yd4BHmCiX0QMmiuVPW8hEMA7K6aXsCxH8
         1fbBRpUFxWlhGEWvdm9cz8z6tNUfr0pa/nkQ3H8gWrXcR+7uulKH7M5Gipa+vPzQ4MMH
         UFVCmJBql9cM71E5+KpGNgaCb6DYS+GhRmnLvfzCExa6hqphGOjqGcU8A+hxW71cyeUx
         CjE6ER5fjnZ9TcK1wozBXr2Ok+Q68Djc0utRAtPImEFrohpSjFX/vPxywbWHUIpixxzS
         m3oQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWViaqwXAz5icnWRJYKRq2RZKhh6HkQ0pkLWbXw+dMh1cju7Otf
	SACI7pm5svGhOXbKz0vsh3HZaU1GE056WbaJIh4u5Dc8vv2dsLFoCXiWzTSfut/TWFwx0CElhDw
	jp0EPU3cPx5MIa+3XV5pI4VJQ7mL9ef1/vnm/z3yjH4+yosFkxPPRlUCX+KMqUy76QA==
X-Received: by 2002:a17:906:7645:: with SMTP id d5mr42580011ejn.22.1554277562866;
        Wed, 03 Apr 2019 00:46:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBcAIKozcUOZnvhc8exWOGhYgDZEUCtweSN3X+69i5xZ6AGsbv00TM6iwEUQ0Uju1Quo2L
X-Received: by 2002:a17:906:7645:: with SMTP id d5mr42579974ejn.22.1554277561948;
        Wed, 03 Apr 2019 00:46:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554277561; cv=none;
        d=google.com; s=arc-20160816;
        b=yH/7QeGA6mMx52kpFhOWLBd6xIyRvTK5+KOrofKF7tQ0efPI3f4CoUfq5hK5F4g0J2
         6AbTdGOsbmKeLLuHAJRwR9q8GK/sXUCIGO8vIJAcbWFpb75+xu6qBm2i5sPmG1TPl55T
         OU291/0Lfm94HBSO+pVx4+cyyoRvV4Z2+UJnMH8JB0jGf3brTU+EC+eCeQYmmJq/w/mE
         0YJLTBvyUnSvHVkpMF9QuPK6+nHH8l/Y2Kzs9lecN3zeBblhQR3jpVdJz0E5HbRSoOGt
         iuOBOnSSnHf2gh+TioQ16SbAhgZFTUgetrMlNPDO1070VlP6dsVO6Jblj1xsFu1++3rI
         H6HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EdZf1v01vwXSVXwjOGLls8NMppVTiD0btXucI4P+Tww=;
        b=nfeJAfl1oNtkElW7pWH6OiAHlCompYSeKcJeosx1HQTqg2RQJ0jN9imB8cygXbnAL/
         skr+05aV2HkpvWAcQESEoYyn5BlG1rUyG+x5KO+NH4uZaGcqC64pKV41SBB33/MEBwOo
         WOdxWHXqM+J7oerALgbgXJLdaoIQ+gICmES6I7PXSxcjvHcTaSVkUK25ahpRRe+ouPlW
         rXGdGZrQ/qclf5V/U/j/b8AN7/l8vSRylB3NwcZPXmrAsSb1wD6aaeAx+GnnES6tz3E7
         3sfnKdQ8akZOjnxj4WuTibuMX4uzL7SN6OiV8RMKElu3nCZBpV8UaMqKon36o3KwxRKQ
         42uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5si167998ejk.168.2019.04.03.00.46.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 00:46:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B4B96AE21;
	Wed,  3 Apr 2019 07:46:00 +0000 (UTC)
Subject: Re: [PATCH] mm: __pagevec_lru_add_fn: typo fix
To: Peng Fan <peng.fan@nxp.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "mhocko@suse.com" <mhocko@suse.com>,
 "willy@infradead.org" <willy@infradead.org>,
 "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
 "arunks@codeaurora.org" <arunks@codeaurora.org>,
 "nborisov@suse.com" <nborisov@suse.com>,
 "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
 "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>,
 "ldr709@gmail.com" <ldr709@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "van.freenix@gmail.com" <van.freenix@gmail.com>
References: <20190402095609.27181-1-peng.fan@nxp.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <38b6976a-9529-5ce5-f0f8-03dbf7548437@suse.cz>
Date: Wed, 3 Apr 2019 09:45:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190402095609.27181-1-peng.fan@nxp.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/2/19 11:43 AM, Peng Fan wrote:
> There is no function named munlock_vma_pages, correct it to
> munlock_vma_page.
> 
> Signed-off-by: Peng Fan <peng.fan@nxp.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/swap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 301ed4e04320..3a75722e68a9 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -867,7 +867,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
>  	SetPageLRU(page);
>  	/*
>  	 * Page becomes evictable in two ways:
> -	 * 1) Within LRU lock [munlock_vma_pages() and __munlock_pagevec()].
> +	 * 1) Within LRU lock [munlock_vma_page() and __munlock_pagevec()].
>  	 * 2) Before acquiring LRU lock to put the page to correct LRU and then
>  	 *   a) do PageLRU check with lock [check_move_unevictable_pages]
>  	 *   b) do PageLRU check before lock [clear_page_mlock]
> 

