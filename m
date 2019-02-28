Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0868BC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:22:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC6D32084D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:22:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC6D32084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 538778E0003; Thu, 28 Feb 2019 13:22:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6B08E0001; Thu, 28 Feb 2019 13:22:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 389168E0003; Thu, 28 Feb 2019 13:22:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2A748E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:22:37 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id z1so16675959pfz.8
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 10:22:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZnplVlbm1Fztuiu2an74qTJaN8yoAPf/g6n2PmpRNZs=;
        b=I2YlZ+JXW19qUCTCZqSybNP/4rC8M9wZ/LGbHpFNxhnlxOoi94eC4vwJDnyP1VXIIG
         vr4Z4ikHi7H+Ff8TJ4fuvg+DzkEUk1DJbfPbctaIj3935agy9Xp7mv61p4pia9ObT0cp
         xVcxajsKQ1RHDKUYWdHm731im/ThqZy0ucKlK6ZsPlef04TFgBfoJgY6T2ajpb70n6jJ
         ye46Riq6/5uxjTCUkBuG1jPOvnns6y1A1/+KACQKjdRE4CB0nlViLVxlxELdRSVWQk1Y
         KSBEWxbd3GKw3WLTQLVDLePuZ//vrMslVmj3Ai0bVs2yncda2R2/aTJ8e5In8kwTn4Ji
         5m/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVdeV/rMxtY+z1sl7FMg9lFjyzuXkSAKa7dTFchxTlAJ2EYBVX5
	6Hdw51/ZeDaELzd3PebezmrVhEdRvtnu0qmmhAlUGpU6QgybX3jkXZJXsheKBnU1qWabhyF5kSH
	GdHeB+0J64neuMx9z+1HIhdzIxK8JPyKKmw0zw1Iy3rHTCTfPzx9HGlSUCDDkg/PUWQ==
X-Received: by 2002:a17:902:48c8:: with SMTP id u8mr738269plh.87.1551378157251;
        Thu, 28 Feb 2019 10:22:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqxvz6GyP7XGvB4v1VAQltKzrm5dvhTWiora/vqxMfFXgjKOtOjNFU2RnOA947r/21LQaPyr
X-Received: by 2002:a17:902:48c8:: with SMTP id u8mr737881plh.87.1551378151215;
        Thu, 28 Feb 2019 10:22:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551378151; cv=none;
        d=google.com; s=arc-20160816;
        b=sbYv/fbLwvcBncU8gMzX04p/IF59r9XjAWi7xqBeZS98lI0eu6awNv69AAKmXgPlx+
         UDpyzqauhlpGudZ483Qp88sg9Y1w/qSr7exVvufqontHigiLZAmoYmEtxmzD7TMaIHef
         9Gp6iI73tixOPYx415Y0KVx4f8Ykn0X6oYcoxJ8B5kkepIiVGxFG5fsoZPo9aq6DxVEc
         IZT291bVBDj8d9UWyHriGf0eF1cAt0OWnHcsE12+7VHYXqQzF1nhb4QizdiPhktthLqy
         FfZP18qPh2M+XgeBXCDYqXJPMpsnYN7e6hZOlucfrCCy/ftbvVDj1UJupRe8+m882O+H
         Zysw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=ZnplVlbm1Fztuiu2an74qTJaN8yoAPf/g6n2PmpRNZs=;
        b=RmdkJIVCcbJFzVXmAOU0mLCk66l4sBL0nz9FA8MCK7gTWYYr6gGLzbfmOF8/dwEDPM
         480MeyaCoW3rpHyaFTu09VyUNoqnnlH18w7KbUpVGgcKbIY2Qn8vK56tjfWrWdhQTgjG
         MvrfMQZLcrWfafmftqY1ltZDC6YE3RxFv6BX7eQCL03GhsVKvjJseCyecLIoOajDIxq1
         5B/dayWZyjJ2HI+Axc6EsKnUvccSantBuhvjdwiNOADvNkMg5kHjvDMp4XExY6dqrU0O
         6rvUwJbT8hsyjqbSLozxRPWtPp6E/8gxFQMVh11H7OJ/61ATkdXbOkj2LiJH9AyMii4e
         E2lA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e4si16917327pgs.492.2019.02.28.10.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 10:22:31 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id A4D50ADFA;
	Thu, 28 Feb 2019 18:22:30 +0000 (UTC)
Date: Thu, 28 Feb 2019 10:22:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Johannes Weiner
 <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel
 <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
Message-Id: <20190228102229.dec5e125fc65a3ff7c6f865f@linux-foundation.org>
In-Reply-To: <7AF5AEF9-FF0A-41C1-834A-4C33EBD0CA09@oracle.com>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
	<20190228083329.31892-2-aryabinin@virtuozzo.com>
	<7AF5AEF9-FF0A-41C1-834A-4C33EBD0CA09@oracle.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2019 05:53:37 -0700 William Kucharski <william.kucharski@oracle.com> wrote:

> > On Feb 28, 2019, at 1:33 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a9852ed7b97f..2d081a32c6a8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1614,8 +1614,8 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
> > 
> > }
> > 
> > -/*
> > - * zone_lru_lock is heavily contended.  Some of the functions that
> > +/**
> 
> Nit: Remove the extra asterisk here; the line should then revert to being unchanged from
> the original.

I don't think so.  This kernedoc comment was missing its leading /**. 
The patch fixes that.

