Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C577FC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 09:04:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8493321773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 09:04:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8493321773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 055AC6B0005; Wed, 24 Apr 2019 05:04:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0026E6B0006; Wed, 24 Apr 2019 05:04:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E353C6B0007; Wed, 24 Apr 2019 05:04:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB41A6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 05:04:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m47so9516228edd.15
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 02:04:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4B4mZi39i0XWuKLroY575XCcdNvvxzPvfQrYSmIyGH4=;
        b=VAD8AIV1+JqI4/6Ta5QFF53j0P/DBjOVKsNFypVcqzetHc6/3n1OUNdDax3HaSXqZp
         rW71wWkoEfciaVnM/kpuqwFESGce7WQy8Mn6SMJPRJAgwFrwMtXC2EjMmF0HxVkuZNrH
         0S9uouEFlM7PFzLeXPiiF4s6gnCqO6sLKiN+K471XsPEuaXstY8vCw7jNhfjD1toouOn
         vJn0qKafCpIwxQOzZwpAAKE7XAX02l4ibDNzL5jWB/58ZBnsFof9UOEEgnezd8aTyHUq
         L80hSH4pPq4JseNo6w9ZbGWYU7GX0c0fsAjgUktX8xyl8lbGPLLoSY2odJrrplGsiyPa
         xI/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVECt2tdL+Mxx7gVTiuPmENsuPmaZv1loLp1iAl9siH6iaLV8mE
	KjsCaomgXtZwdxnRRUVYmes4IgHi8LbVT4CyLlJwn1ICwwC7Rp75sM26hXswRU78mRoN2X88NNG
	m7iRMlz9Q1oUA0rDn7JmaWNtJVGG9vbCZBuys9wTHKL6dlI4fxDLSY/wOpnS70sCvOQ==
X-Received: by 2002:aa7:de09:: with SMTP id h9mr18997262edv.271.1556096646191;
        Wed, 24 Apr 2019 02:04:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzW19ARryiShofrMM4oCJuKcZRMI3LmC1AWTgRLsnYMQRD21bpN/LMTXlkcuKB7QzesiX2A
X-Received: by 2002:aa7:de09:: with SMTP id h9mr18997220edv.271.1556096645392;
        Wed, 24 Apr 2019 02:04:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556096645; cv=none;
        d=google.com; s=arc-20160816;
        b=kzL5q3fx6TB1BZ4xWMawMF/0hFHbceAkbN+u8bEC4VaFWRGwfgfdq+NfUvdMy5wps9
         RsqLfRY6jEJ7Odsn53gMfCgt0RVHYqEj6Hvl0cJolxFGgqJmqRLAg/bRn5fbSIN8SF6U
         4fGAzYBLZP9Rr+kh1R19Xwl6tXNi9++TZB6LAFwXVkZnfZDi9gsyjbVkdMQA29u4jV4z
         F6Z91GNzTWwIKrVifOXes6NVwE3Jis1hcgWz1Xfh8Ja3mSKZz2YhBVtn2ALqWgUcBQpj
         PtapkeKxq61sOIXBjHDkc7DyxGMflhQiJtawJ+W1B9wUXd3bm/wTjKbQdQw63Q1DGdPg
         RHtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4B4mZi39i0XWuKLroY575XCcdNvvxzPvfQrYSmIyGH4=;
        b=mxDU4tBldNT9HC6dwy0Jze2yqn3SK3hhaIz4CA6eba6M9mfHbZaNCRCZfHNNY1zAc6
         r2bayku81AA9a0jrphke/ijnCSOSVv214JRtT2tKv3eGm0Epw21qLVyFJlvaG8fygzSv
         tuElDbiGTRzXKV7RyEy4C7FCNsalvrriMnM02ZEfTuuMkGfNdXOJzvFyv7G+ez/ZGOxd
         0QjLdZYewbZEBkudEGVs3Me3SmrC0Dc9b9YOOlElqXZeYPu4NBOrtaCOGA/GHjeUsdaD
         Uc9wUv+VgzPph3jSqry5mvIngFB/MJIZOXMkApsm31+HRTFc0r+/qSxG5iPIaDYhnJjy
         yKRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp18.blacknight.com (outbound-smtp18.blacknight.com. [46.22.139.245])
        by mx.google.com with ESMTPS id p63si1236160edd.9.2019.04.24.02.04.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 02:04:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) client-ip=46.22.139.245;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp18.blacknight.com (Postfix) with ESMTPS id 8AF261C1D1C
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:04:04 +0100 (IST)
Received: (qmail 31721 invoked from network); 24 Apr 2019 09:04:04 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 24 Apr 2019 09:04:04 -0000
Date: Wed, 24 Apr 2019 10:04:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm/page_alloc: fix never set ALLOC_NOFRAGMENT flag
Message-ID: <20190424090403.GS18914@techsingularity.net>
References: <20190423120806.3503-1-aryabinin@virtuozzo.com>
 <20190423120806.3503-2-aryabinin@virtuozzo.com>
 <20190423120143.f555f77df02a266ba2a7f1fc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190423120143.f555f77df02a266ba2a7f1fc@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 12:01:43PM -0700, Andrew Morton wrote:
> On Tue, 23 Apr 2019 15:08:06 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> 
> > Commit 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
> > removed setting of the ALLOC_NOFRAGMENT flag. Bring it back.
> 
> What are the runtime effects of this fix?

The runtime effect is that ALLOC_NOFRAGMENT behaviour is restored so
that allocations are spread across local zones to avoid fragmentation
due to mixing pageblocks as long as possible.

-- 
Mel Gorman
SUSE Labs

