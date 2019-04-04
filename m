Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBBDFC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:39:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A37B206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:39:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="N9O/P989"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A37B206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 233D56B0269; Thu,  4 Apr 2019 12:39:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B9796B026A; Thu,  4 Apr 2019 12:39:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0822A6B026B; Thu,  4 Apr 2019 12:39:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5BC76B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:39:19 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id q195so2266188ybg.3
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:39:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sVZzefylPUert59vxaZI/oiiATEF9PQOgxdOg2fXoEs=;
        b=JhU9Npb5eW13zvasExSzypS9R2wqf0W8aZRKj5JjyNyhZZU/n9Vv8TCjXAkhI1YpK0
         5kgdTAow9t9uzQbv2t3XuGhrumGNktufgVlATYMUEfiO/k9NYG+zHl22likT+MHlJYzu
         IWZQ7OCHad+Sol1ilXHuXg9CJuzQ8HbY4SX/WpdjWOcwelmEo+UYwYleaNp4+dIZKPHi
         zJdhloSz40qwnu4EI3+MeBjbX6hAgco0sqFhs+j8TTJ+t/DYZkD+XhVaZZ+4obnc+bFz
         BlIFYw+Y7p8QOVl9HS27PTsaGBknwDRTl2Sr6bsbZiL5Ruzs5AyCDRKHj8NYHSoAMcCE
         PXRQ==
X-Gm-Message-State: APjAAAUb15obaZgjsiOSJKMrspN7+sU4oEbypx6SGv59ykZA8YWY6rJu
	vu9leCdkZOtlkxvXNsozY5EdymByyKrrPBGI6Sh9XKM2O8mL+j4+jLglJn/P/2p4lCMfCYNDzN/
	kdr8bw0rlawMFKi1PfFQ1dOX9kUtCiXdVkDp6BwHCmW3FGTkx3H6dL7xQjGK+1BWH9g==
X-Received: by 2002:a0d:ee41:: with SMTP id x62mr5870235ywe.58.1554395959644;
        Thu, 04 Apr 2019 09:39:19 -0700 (PDT)
X-Received: by 2002:a0d:ee41:: with SMTP id x62mr5870168ywe.58.1554395958886;
        Thu, 04 Apr 2019 09:39:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554395958; cv=none;
        d=google.com; s=arc-20160816;
        b=f9uB3fxNb+W9Qdjl+53nbfkQxvHatIvg06NSuxirCkFYOg8Gjb2FtTCFyVvVl1lcw4
         +D61RayuK7ispLYeRzfH9/wpZGLVgahclfQv9AuVGGf3ub+rFpSg4lzgVD1sMLGl/d1N
         tXZIxTs5KfKKECinT8bAwwoemkPK0pmUjqZJq+Gs11P7oHyGMQSHL0iLdc0y3b6eYWVt
         E8edojYlJunbpnYLBojKgp63JVTOqpVjjpbOgPoGhz79HI5V23azzT71LfzKBbRCY1Zh
         SlnT1RunjkL3YpJMZ/2pUr++MhgBXkKNKLA6yFO58qqTXcqUvxBhDDfK2Hw2ewOFZTd2
         kkFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sVZzefylPUert59vxaZI/oiiATEF9PQOgxdOg2fXoEs=;
        b=tfHA5LM6g00Z5AkiZqObUdbBzzhtzfxwa2KypXeBKLf3oEc5pTsfoUcrdrNAP7re+i
         l7TA0pOwruP+r0tE8Sy3T+5hrr6NQo7NuxPdbL52tdfuEfnN8q+XZx9YlIdQrskc6Bu3
         FinL08H8Ew8kvPapRR469X46T/rQ/C5pZtNHN1onihpctmauorsM/afKEJvyMbIKN7e5
         bD1jYK7Mou+It3NpQG86f7Q8h0A1pYv2qkyq+pArBdTXsZNrGdBJCtHrw9AziK3E67AV
         I5H3odJjr5jYIXS+uOpT5DQ+ow5NRa2MKlpJ30lShK6M3OPqrPY7OHLbFk0FyJATKOGM
         3VqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="N9O/P989";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h136sor6622861ywa.41.2019.04.04.09.39.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 09:39:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="N9O/P989";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=sVZzefylPUert59vxaZI/oiiATEF9PQOgxdOg2fXoEs=;
        b=N9O/P989CYq5nDJ+5cfuaXQTyO9yPFp/1/eKojWhp/i7Y2K8efOxl8h5pcHtpCFXpV
         2/Fgk3oF02TPKWP0j2FhXquqaxWo7pcBk+LSDFbvbP6L7+AKKu3P8X1Bc/ih1Un5oAHW
         lidSBfVBXnjoYtvNI8yPV/jeLc7aSm1KqADr4p45hgk+VpTgdmNZgYK7a9ZtS8/nOvWv
         Ze6qWGbBNiCJZnPke88ZMLvYVM1HMR/817cLJax12DTXw/4xn7MrjL1SOwjZX3E93CRT
         n9tNcxv2bv+8v9aEkys2lEACvHlf/xG0dxvVaY7Mo0mI/Orl1g12urtpIGjl1Q1vKsWG
         eLEQ==
X-Google-Smtp-Source: APXvYqzilLKYDRMZlOnegsGNrRHGCTLtWjZZcd0Pk6bBZMtt4KU1a29LEu2clZfsFtRi2mMQ7fOucw==
X-Received: by 2002:a81:4d8b:: with SMTP id a133mr5725050ywb.122.1554395956113;
        Thu, 04 Apr 2019 09:39:16 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::1:af4])
        by smtp.gmail.com with ESMTPSA id j187sm6563806ywj.32.2019.04.04.09.39.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 09:39:15 -0700 (PDT)
Date: Thu, 4 Apr 2019 12:39:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm:workingset use real time to judge activity of the
 file page
Message-ID: <20190404163914.GA4229@cmpxchg.org>
References: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 11:30:17AM +0800, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> In previous implementation, the number of refault pages is used
> for judging the refault period of each page, which is not precised as
> eviction of other files will be affect a lot on current cache.
> We introduce the timestamp into the workingset's entry and refault ratio
> to measure the file page's activity. It helps to decrease the affection
> of other files(average refault ratio can reflect the view of whole system
> 's memory).

I don't understand what exactly you're saying here, can you please
elaborate?

The reason it's using distances instead of absolute time is because
the ordering of the LRU is relative and not based on absolute time.

E.g. if a page is accessed every 500ms, it depends on all other pages
to determine whether this page is at the head or the tail of the LRU.

So when you refault, in order to determine the relative position of
the refaulted page in the LRU, you have to compare it to how fast that
LRU is moving. The absolute refault time, or the average time between
refaults, is not comparable to what's already in memory.

