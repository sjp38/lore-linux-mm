Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 173B9C282DC
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:28:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A77B6218AC
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:28:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A77B6218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0F0E8E0002; Fri,  1 Feb 2019 09:28:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBFEE8E0001; Fri,  1 Feb 2019 09:28:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C87DA8E0002; Fri,  1 Feb 2019 09:28:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B94C8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 09:28:04 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so7997338qtr.7
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 06:28:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=7Nt1E7CNW+Jp3l4ItHB2lwY/ss8CDbizwT0xLCBIusg=;
        b=me0EPfJiEniqOB6dgqvdiuuR81LCMcizodl+qI9WmdFs2NGYBBmznjNS8ucFfbjojY
         df9uyHBrgb5iOOj/hV0RdB1+3R5fS+8byz/WEr2WdXPSNjOE9Wif3r3/UxncqVasSblx
         Q2I4HVVd3hIrWM/iLAba9T4UjgY54+fZb8Fq6iNiS6p/hkyMvQdVO3B6D+0MMt+GlZbD
         ZIIlP8MI+bmVX0X4j2U9XFqc24ZdxI6NOazya5XC3pbz3tatZy6R+67Rp7usstUhmd/m
         5Ft24jkrV1GG9W8tZ4q4ArDFNzgs/e9J6XLPMLr2l4LnShhpOqsbi9Mwd9XagXtBNlMj
         ccrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukerhrIhX+VZKrgQ8VXiA9z0npg6UpuRRIJnuRAsLpE6G89kAdJV
	Xj1KwodFUnlpnBapmcggxFGx27fkrPr6mSAG+vHB3zzYxv4fGU4qSwao0waIfPco4T8366BxRIR
	eB0cqoXKsbn3x08Cr4vD+KIRXs5V2Vce0V7RBt5hySJMs8d72ZH3a5UQe+47O5gKP3w==
X-Received: by 2002:ac8:2a81:: with SMTP id b1mr39261258qta.110.1549031284275;
        Fri, 01 Feb 2019 06:28:04 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5gNU3bSp36x/zN+Y2PvJtSnLln4NzoBgX37q2xDgK9F5Z4vBgMShe4ybRztVv3kVUttJd3
X-Received: by 2002:ac8:2a81:: with SMTP id b1mr39261226qta.110.1549031283714;
        Fri, 01 Feb 2019 06:28:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549031283; cv=none;
        d=google.com; s=arc-20160816;
        b=c7TzWbukty688wN0sRmoITJqyCiWdbtYxqEClbLnI3UPOpzU8I5cTIudva3+MGQrl8
         EXwSIV4CGA2dN5WfTmcuMS3pXGTQ2yCW7/hpWre9CCsq5BXMYIcOfa6+RG18gr8jAkxj
         m0j5qujsJf5kWOq3XoOIcoNEz75nk99U/9x7Xtppn+0X9krKByoymbBESckORNyukwQi
         B2xuFVthrHTkH/Wsp7xGZwbBdGs2/mChpk+FXiWL6C0ULjRWrcg5wWtiSdtGkkDBn8al
         Jf1qiNIJ7yukpzYPAsNGiALHWwNWx4KqWam9Hs724uCTPTY6JqI2rsttV/7Qax7IgWGm
         xM3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=7Nt1E7CNW+Jp3l4ItHB2lwY/ss8CDbizwT0xLCBIusg=;
        b=v2MfnL5GWQPI3SVtivio3nOigw14GsXG3Vo9LMH3czeHf1wHPfL/eT+ppBLDIRjQ9D
         QsLCgTCDOdSovtRmftrtEXURkblBWfFrMMVDjLN80b4TkwQwc9eUoMIvL1Kebv3wqXa1
         qPfOB/fCtz7cU18850O6L9zz/3jPS+EjGGcpGzE3uRR3RKeX52TMEjkmWGu9CLsBA+FO
         LnQjynFvYP4ydXBZzSR0zF/CNfIf0LD64ZmlYJON9jx5BWiKba9upZ8QJP3dDp4857lo
         8K5aRQvsij/tnZnCs4HjfKt7sxxMi9Neu7xHHNq8Mjei6BCisMur9wZtW0CQMFmzDCuw
         lU7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a76si120686qkg.65.2019.02.01.06.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 06:28:03 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5FC427AE9A;
	Fri,  1 Feb 2019 14:28:02 +0000 (UTC)
Received: from [10.36.118.43] (unknown [10.36.118.43])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC2D7101963F;
	Fri,  1 Feb 2019 14:27:56 +0000 (UTC)
Subject: Re: [PATCH v2 for-4.4-stable] mm: migrate: don't rely on
 __PageMovable() of newpage after unlocking it
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>,
 Dominik Brodowski <linux@dominikbrodowski.net>,
 Matthew Wilcox <willy@infradead.org>, Vratislav Bendel <vbendel@redhat.com>,
 Rafael Aquini <aquini@redhat.com>,
 Konstantin Khlebnikov <k.khlebnikov@samsung.com>,
 Minchan Kim <minchan@kernel.org>, Sasha Levin <sashal@kernel.org>,
 stable@vger.kernel.org
References: <20190131020448.072FE218AF@mail.kernel.org>
 <20190201134347.11166-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <59672e74-37f7-ea45-19b0-4de2fee7c58d@redhat.com>
Date: Fri, 1 Feb 2019 15:27:55 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190201134347.11166-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 01 Feb 2019 14:28:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.02.19 14:43, David Hildenbrand wrote:
> This is the backport for 4.4-stable.
> 
> We had a race in the old balloon compaction code before commit b1123ea6d3b3
> ("mm: balloon: use general non-lru movable page feature") refactored it
> that became visible after backporting commit 195a8c43e93d
> ("virtio-balloon: deflate via a page list") without the refactoring.
> 
> The bug existed from commit d6d86c0a7f8d ("mm/balloon_compaction: redesign
> ballooned pages management") till commit b1123ea6d3b3 ("mm: balloon: use
> general non-lru movable page feature"). commit d6d86c0a7f8d
> ("mm/balloon_compaction: redesign ballooned pages management") was
> backported to 3.12, so the broken kernels are stable kernels [3.12 - 4.7].
> 
> There was a subtle race between dropping the page lock of the newpage
> in __unmap_and_move() and checking for
> __is_movable_balloon_page(newpage).
> 
> Just after dropping this page lock, virtio-balloon could go ahead and
> deflate the newpage, effectively dequeueing it and clearing PageBalloon,
> in turn making __is_movable_balloon_page(newpage) fail.
> 
> This resulted in dropping the reference of the newpage via
> putback_lru_page(newpage) instead of put_page(newpage), leading to
> page->lru getting modified and a !LRU page ending up in the LRU lists.
> With commit 195a8c43e93d ("virtio-balloon: deflate via a page list")
> backported, one would suddenly get corrupted lists in
> release_pages_balloon():
> - WARNING: CPU: 13 PID: 6586 at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0
> - list_del corruption. prev->next should be ffffe253961090a0, but was dead000000000100
> 
> Nowadays this race is no longer possible, but it is hidden behind very
> ugly handling of __ClearPageMovable() and __PageMovable().
> 
> __ClearPageMovable() will not make __PageMovable() fail, only
> PageMovable(). So the new check (__PageMovable(newpage)) will still hold
> even after newpage was dequeued by virtio-balloon.
> 
> If anybody would ever change that special handling, the BUG would be
> introduced again. So instead, make it explicit and use the information
> of the original isolated page before migration.
> 
> This patch can be backported fairly easy to stable kernels (in contrast
> to the refactoring).
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Vratislav Bendel <vbendel@redhat.com>
> Cc: Rafael Aquini <aquini@redhat.com>
> Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sasha Levin <sashal@kernel.org>
> Cc: stable@vger.kernel.org # 3.12 - 4.7
> Fixes: d6d86c0a7f8d ("mm/balloon_compaction: redesign ballooned pages management")
> Reported-by: Vratislav Bendel <vbendel@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/migrate.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index afedcfab60e2..3304c98f9a78 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -936,6 +936,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  	int rc = MIGRATEPAGE_SUCCESS;
>  	int *result = NULL;
>  	struct page *newpage;
> +	bool is_lru = !isolated_balloon_page(page);
>  
>  	newpage = get_new_page(page, private, &result);
>  	if (!newpage)
> @@ -984,10 +985,14 @@ out:
>  	 * If migration was not successful and there's a freeing callback, use
>  	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
>  	 * during isolation.
> +	 *
> +	 * Use the old state of the isolated source page to determine if we
> +	 * migrated a LRU page. newpage was already unlocked and possibly
> +	 * modified by its owner - don't rely on the page state.
>  	 */
>  	if (put_new_page)
>  		put_new_page(newpage, private);
> -	else if (unlikely(__is_movable_balloon_page(newpage))) {

And to be save, we should turn this into

 else if (rc == MIGRATEPAGE_SUCCESS && unlikely(!is_lru)) {

But will resend this either way as already mentioned to Greg.

> +	else if (unlikely(!is_lru)) {
>  		/* drop our reference, page already in the balloon */
>  		put_page(newpage);
>  	} else
> 


-- 

Thanks,

David / dhildenb

