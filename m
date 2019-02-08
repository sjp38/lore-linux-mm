Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0845C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:53:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91E2921916
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:53:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91E2921916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AD288E007D; Fri,  8 Feb 2019 00:53:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25C4B8E0079; Fri,  8 Feb 2019 00:53:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14B958E007D; Fri,  8 Feb 2019 00:53:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D92768E0079
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 00:53:03 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q3so2443638qtq.15
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 21:53:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=EdWg7t5clHHyjIuZwgAgH0hXxK3yfesua4rUUk5hG74=;
        b=mf0y32pHI+Th11C0qjojrZq9qdbh/mae4bAqIhvI1ao0RejjUeg9Sl2lDsr48cxR5J
         3mXnWtqnnFEB1ER4fWqP1BIRyGao3idKfX6AOxLQt9LVWSIQ/3Un7qlW0uDC8m5W6dn+
         TiTVCnu4KEpQGuTVuDYw2MXeR1y1GNfTTguwrBA3M54UMbsLSTIkHeV2Ax0VvUwBXqvY
         pVXM8KcmKvroqqqA/zgFJTXmLt3TtSuA9SGUc4bZwm9aEO+f+K6UeJqTdEfx9GgNgiro
         /UdpAE8RWL2HyR5vIuG4hUbwDXBaUWLwb0CAeUBfS/dGnFBzxdjKoUwITMOjIssnm0+0
         T9PA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYo1fSvB/9eZwUgpvt1TTb+bDgAJE/IXMytD611YZZAkY42eUaC
	6l0tYziLyTGKROlTIDnN+nu+8iSrInKNVWjL9PLewqbtP+9ZWTLpKnTyF6qLeW9pAhYdm9oyG6F
	t9uADvOnVnWPV2FigyVVLuhVXcx54j/kUxl1qk7DleyKcpttTjiE+XJP1mZtY2n9cbIMEUoyf1L
	p8IDrYIsOFXJgUAU5P9XArXpflhtokRY2Ww+2bk9ahyfemazgpaE2H72NJBC+kU3XrAbdqAUKUT
	EmqSnUIyemcyHe031PXyqjlaKGbGhoW3YFhr/XchRPf6Y1fVQbSJBOonUjOx3p79nomACqsq09i
	W7skUNGFPjYLSUz/e1sRQEL+NimcwEcB29Grwenaz9VuizTZv7pAROYDrL+fwEUYdwnUG54ZEPT
	K
X-Received: by 2002:aed:3f7b:: with SMTP id q56mr10408037qtf.258.1549605183670;
        Thu, 07 Feb 2019 21:53:03 -0800 (PST)
X-Received: by 2002:aed:3f7b:: with SMTP id q56mr10408026qtf.258.1549605183300;
        Thu, 07 Feb 2019 21:53:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549605183; cv=none;
        d=google.com; s=arc-20160816;
        b=hUk4t+geUV+BJ44JCo1qzUB5hisOgakAQI2Q3qdIAFMV/C5gwuG/P599sJXf58cBL7
         ly/ZQ9crNRdhV2gG07g90/5fen8FQwINk7GWxbCKXQTP5KR2fHN6qJkDxxLNPyFTl2Y7
         dyVWvaue2ORxWj8lusYeyKbGMbK3Id5JKOY2Th8OEFoYwiKbrLr5wyxejfUzjkZe1dQ/
         L3oEpk21TC2DOLn1nd1zw+94hS/Kyll+0fOfY2PVeo4Q6nLSMXBwbWIqz7A7xGtyyCVz
         znz1E11rF+fvy0WicBpu0JS0Lr6adIWRLy093shVD9mjaBc473o44/n+0fru7UTQ3bk1
         M89g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=EdWg7t5clHHyjIuZwgAgH0hXxK3yfesua4rUUk5hG74=;
        b=mdqih7Rr+BnH9BG8WZ51PM9OJbcHFKTznlt/Cg+lT0sI8GiTZ02/aGQpTyT9BG4E1t
         G0Ep4sZevVkzPEP7mnnF7ihVZ4Jnij3dYOpObGBXU0Wd6wj5KGltjR1taZGbDuErgFA4
         8e+t8tFGSMbLwTl8yqAbOsIETF0Rp4LAlWB5iZtvPSn9LTGKTXCTciWSBdNksFBi7hZv
         OjR81dfHy14x8ajojNmRxjm//9XouuH7yniP0QZYXMIHFkLxLZuCcKBxEtPwWP36mj31
         /iV3FlhBm59vxFucZy7X4E0xMwPgSSdpttKnhbYNuJnprk9/HRLKh3c3BQ8sPW7jWZ79
         pzuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor1210655qtj.60.2019.02.07.21.53.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 21:53:03 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: AHgI3IahxvXlLwD30LNYnLLsJZTMzXcLcC4ZzfWlXsqAs+Vev+Ouo3OcuJfBjOvIELXmXQHzoy0fzQ==
X-Received: by 2002:ac8:300a:: with SMTP id f10mr4736014qte.236.1549605183121;
        Thu, 07 Feb 2019 21:53:03 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id p63sm882677qkd.52.2019.02.07.21.53.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 21:53:02 -0800 (PST)
Date: Fri, 8 Feb 2019 00:53:00 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org, linux-mm@kvack.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm/page_poison: update comment after code moved
Message-ID: <20190208005242-mutt-send-email-mst@kernel.org>
References: <20190207191113.14039-1-mst@redhat.com>
 <20190207210141.f0c0b08841f53ba4ee668440@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207210141.f0c0b08841f53ba4ee668440@linux-foundation.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 09:01:41PM -0800, Andrew Morton wrote:
> On Thu, 7 Feb 2019 14:11:16 -0500 "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > mm/debug-pagealloc.c is no more, so of course header now needs to be
> > updated. This seems like something checkpatch should be
> > able to catch - worth looking into?
> > 
> > Cc: trivial@kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > Cc: akpm@linux-foundation.org
> > Fixes: 8823b1dbc05f ("mm/page_poison.c: enable PAGE_POISONING as a separate option")
> 
> Please send along a signed-off-by: for this.

Oh sorry.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Good enough or should I repost?

