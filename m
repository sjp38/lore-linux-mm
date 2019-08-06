Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AC11C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:03:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29833217F4
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:03:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29833217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7C646B0003; Tue,  6 Aug 2019 04:03:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2C756B0006; Tue,  6 Aug 2019 04:03:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF5056B0008; Tue,  6 Aug 2019 04:03:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 766776B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:03:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so53286882eds.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:03:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+B78Vu0+V9FK7UAs8BPG//X0Qw0Vd42Ya7WH0kg98lk=;
        b=WvAK+VZ1WexdM1zsPJonKtcCD61mpwF69TQ/M6Nk+kh0ehL3v8RavJYbpKZNRezcxO
         RJ7j8TT+Ie9vjGxXRiMh9p5jbkNOnBH4/87SbhK8/MDJL2HlCUZyVn07vQH67BVawIOm
         XYNydzOuZacFNyZnIIuLA80PQBJYfnuUKVTkfn4ck5saby8YN9rEy46BYlfZXZ4V1/np
         K3R0nHvt4rlo6cOWYT8becBhX8+BCgz4nT2u8NgMH78+VoNqLXp5IOGG/g1igtGBUGaI
         VEz6xaHLVp26Y/GV5z+GGj5f/yFVCxgdHefEyDP7ApaEptmmMxJyDfxZPGi2FieM7aI1
         K0jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUc0CnTi5mLl34h+ztWcibM9DZ+xjwB3SPYVXBTldktiCjouwha
	K2ZGsuQZTvxg8iHAUh7xaUgezbIS8FXA8Mewok+Vob3j2EutmIB6OPzXJgH2jnriH/2/ms7wpTF
	MtZ565xSBw831WhQXJ4MRiW0BAx8yf5u7upQRSbUUDviMvABb1dwtqKqwFWQ3OvyMQA==
X-Received: by 2002:a17:906:5384:: with SMTP id g4mr1847156ejo.241.1565078625061;
        Tue, 06 Aug 2019 01:03:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz12gow2D3HpKSCeBSZBFE9u75GdCCdGSk7eUzxJuIyAmv9LmvRvoCuUP/mTvLNNJokOfqn
X-Received: by 2002:a17:906:5384:: with SMTP id g4mr1847121ejo.241.1565078624455;
        Tue, 06 Aug 2019 01:03:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565078624; cv=none;
        d=google.com; s=arc-20160816;
        b=UaLWdEPIPBUJHybKTu6/tK/7jC9ck9NxqeyUGWRygzHpkRjpn3JDtBa4va/xxjO9SG
         p3J3t9aQpClqIG8nC1ZKigYvf5h3YKCBDRQzb8PrHMnfM18lm3+3SdrNlj89sEAXJ4ET
         CqSp1NaVb4TSwqA4QXNWZsZss9ejJxJJ+PmfNUqzu/MGsQaDeVzUz2/Gk/vh5dtoyLL5
         kRb+9tfFsC8Qvl+jphPXHjnk1FIjdYAxP8HOdnbuKNvPmQ15GQxYI/ve8WKgiOVLs3+G
         ZNZfMltdf9TVfvyWvPmuJRL0zOIzFfih3+zg0daiZbgVSTLJ/28/y2Qi9ejCB8LlbAxc
         wvDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+B78Vu0+V9FK7UAs8BPG//X0Qw0Vd42Ya7WH0kg98lk=;
        b=tkKkOO1dV5WZqNP32E5fg4yKIOJTrqi9g8cm2hQhhmocuBKe38nhjD9W/DklOuAx2K
         nPdR/LYa6CcsiLNgx6FQeoQJoMGXsnyUAbFRamK+2gJHy7+9I6pNR3XIalpDwzMKRln7
         DUuT5qqwQY+QAum/Tw/UW4t//nRSOnhF1G4zS5F/4mB3Xwd6b+i0u8eC30BGnvacVDOQ
         HTaOodB33XeQyPh2M6b43XQYqSzfUDSfsgxpr7oPngMJI3xm/yoZhr0KIb5CvXouhmxf
         7xz/fgF3PPqQrHyS3ZbOLzUYrydPdAyKKxgccaAKpHfcEvEJYop+Pkv7yQPIkNKYmVtt
         2KXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a24si31834731edd.382.2019.08.06.01.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:03:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8C56BAF5D;
	Tue,  6 Aug 2019 08:03:43 +0000 (UTC)
Subject: Re: [PATCH v2 4/4] hugetlbfs: don't retry when pool page allocations
 start to fail
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrea Arcangeli <aarcange@redhat.com>, David Rientjes
 <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190806014744.15446-1-mike.kravetz@oracle.com>
 <20190806014744.15446-5-mike.kravetz@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c13c0c78-55d1-b2e2-c24b-897ce2469410@suse.cz>
Date: Tue, 6 Aug 2019 10:03:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806014744.15446-5-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 3:47 AM, Mike Kravetz wrote:
> When allocating hugetlbfs pool pages via /proc/sys/vm/nr_hugepages,
> the pages will be interleaved between all nodes of the system.  If
> nodes are not equal, it is quite possible for one node to fill up
> before the others.  When this happens, the code still attempts to
> allocate pages from the full node.  This results in calls to direct
> reclaim and compaction which slow things down considerably.
> 
> When allocating pool pages, note the state of the previous allocation
> for each node.  If previous allocation failed, do not use the
> aggressive retry algorithm on successive attempts.  The allocation
> will still succeed if there is memory available, but it will not try
> as hard to free up memory.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

