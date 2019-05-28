Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 391AFC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 21:56:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F41D020B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 21:56:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="qG03h26g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F41D020B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E1E46B028F; Tue, 28 May 2019 17:56:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 892B76B0290; Tue, 28 May 2019 17:56:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 781426B0291; Tue, 28 May 2019 17:56:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0D86B028F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 17:56:42 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d2so48989pla.18
        for <linux-mm@kvack.org>; Tue, 28 May 2019 14:56:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bTzfa4MPBlCsa2uhQknRd/UBV4ojcryy1ZVgr46O0Y0=;
        b=cV7OGR22AudJdl58YiAMAX9pq9dQ9k6aFNRymLvYYgYv2m9y+CKVu8/IQyxV2on6PP
         LR28J/rKAYx6ioxNtRHKEy9x8Nse9aKCB6ClrLCtYjOKfEAwXZmnGWmKFlz6m0yxR18C
         Z7KruPHPxzTHaNsdSn27OciMt0LGc5iz6lGhFjmIASTiCw6STFe9nMMDoYOByjjMxuff
         LcYG2J3t5aigfYHVyIi0Dn4WKQHudGU01yh8nnihqOk0Zr9vOhtN72eNnQ0siycrzG4c
         3F8UxeTJPybS4MTv+Kz4RUkImUh4J4C2XAkYxX72Kh0GFHpClGJ9HORl2I096oFhJHvX
         yBEg==
X-Gm-Message-State: APjAAAUXaMFlRNSOKl7yr3HyWhL2YYN1Ir98fYjSV7E8/W5F0Dgjg2Kf
	iLdJ2fqa0rAbWfXwuPIcV8eoS2QN77KbN0lj+0W8e6AfL6Lx14tf18MpTSD4fuGgcflEjuwJeFm
	l18iz8SUGo03mkFDjaNq2B3TnUaZJ5C1pj+GWSztKKlormzYqmrfZRkkpSeONjZbuXQ==
X-Received: by 2002:a62:5103:: with SMTP id f3mr147837164pfb.146.1559080601906;
        Tue, 28 May 2019 14:56:41 -0700 (PDT)
X-Received: by 2002:a62:5103:: with SMTP id f3mr147837131pfb.146.1559080601185;
        Tue, 28 May 2019 14:56:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559080601; cv=none;
        d=google.com; s=arc-20160816;
        b=UKYoWvlIbxoWOdOcoaIrmxzTOo2Mjnv8Z6HiWC0R9YETqgHAO4XuZFOU/H63m9Q2En
         KEEKzuigklgCP9VUU87gJeIyySF8NomW01+AMKQc2wu8AHFAA9I2Vww5Epj8cz3/37yi
         hk70Efspvduse7/glpiSwRDZLBokg+Xytv1zrb+gdxL8rKKm+LHZDFtcTuExAXCZsZyo
         xRah9XP4Kmww/9OsnRz7oOcT0qjMnfTX3/tz9oVwteQ6NYKYnJysw8Hxhpm0NfG/45YE
         Yn5LeeM3BLCuWBX3N8Zk8tRTZky/2/tKYF72NsXpgWEyMzJli3M2+hu6MC4FT97dmiA8
         DXJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bTzfa4MPBlCsa2uhQknRd/UBV4ojcryy1ZVgr46O0Y0=;
        b=m5WY6U4LwvJKuZQe8jRjtJOqczJeACuT5Wk9mEL7xcoVarcmGl/4Mv7XrRl0GsjHc1
         gnUBBiDiBbQZ67rOeILKrgFvLUZIDaOIXLisn+Z1A3eNdXAUz+nGhaEkEWtypT2K2C6U
         995dpqq9rN1GHJSkM369Ns7qR2Ndke1sL7g8d1CXgrMkYYuS5+qTU3rjnfvQkxzKhyPt
         GdYy3uqr/yKe64YaR/2ZZxJtMlV+dpSauM9ujk9tQNyqlZfkBjRXvZMW6jGUEC1dSER8
         QbW92KIVItPZuhlYHxCA/dj64WTGpC4mY++zQnyhTFeoGnt9eMSK4XuWSBRgcMuKg5/V
         WiaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qG03h26g;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e5sor18018899pfn.49.2019.05.28.14.56.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 14:56:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qG03h26g;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bTzfa4MPBlCsa2uhQknRd/UBV4ojcryy1ZVgr46O0Y0=;
        b=qG03h26gMGgX2CIkJTJdgFwW1fdUGvwM+12oszmGpSYZILYYex8mUqUYB6umJaX2Ge
         BPs7imkNRty6RvcxCTTiaTmPe5Xa7U8IH4yrqIXzMGTxxoN84iWr7xdRxHP+vD9H1P5p
         dq8iGcLIIIWikZqSc6UFy/+0zDb72gN/C0xjf1mr/a9yQaKT749fFHtZt2jdLd6q74oz
         9cto1oQA1PS9VLo2TFd0bDJmnEuDFf3JyqvvRgun2EM123fVGo3KtW0SHC90c8aDUUbG
         aNfTXaIBezA+iAftELYk80T9oTBtjgPINgmGAHwOZWxXxPIIrCx20PddZ/3IOb8uvPvy
         ZI7Q==
X-Google-Smtp-Source: APXvYqznXt8OYMnBy3Azq3tIojg91yQzx9R1e6BJtkRAhSjpY+ySRhViNsQx7rAzPfZ+zrQXA+VJhg==
X-Received: by 2002:a63:d347:: with SMTP id u7mr135250092pgi.254.1559080600401;
        Tue, 28 May 2019 14:56:40 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:77ab])
        by smtp.gmail.com with ESMTPSA id x23sm14860815pfn.160.2019.05.28.14.56.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 14:56:39 -0700 (PDT)
Date: Tue, 28 May 2019 17:56:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 1/7] mm: postpone kmem_cache memcg pointer
 initialization to memcg_link_cache()
Message-ID: <20190528215637.GA26614@cmpxchg.org>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521200735.2603003-2-guro@fb.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:07:29PM -0700, Roman Gushchin wrote:
> Initialize kmem_cache->memcg_params.memcg pointer in
> memcg_link_cache() rather than in init_memcg_params().
> 
> Once kmem_cache will hold a reference to the memory cgroup,
> it will simplify the refcounting.
> 
> For non-root kmem_caches memcg_link_cache() is always called
> before the kmem_cache becomes visible to a user, so it's safe.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

