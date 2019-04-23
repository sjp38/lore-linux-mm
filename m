Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39A2CC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 14:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD10921738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 14:35:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD10921738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 344AA6B0003; Tue, 23 Apr 2019 10:35:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F4146B0006; Tue, 23 Apr 2019 10:35:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BFBE6B0007; Tue, 23 Apr 2019 10:35:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D722A6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:35:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k56so8082970edb.2
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 07:35:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gsDrQzndwT6J1SDmOesp5ETe0qGalQbPzULyQ2iff3M=;
        b=ibZMJD/vGgGBHSoDDgbC7kLi/60tYm0058oqD4wCLwwkle7jv7QrHMCec4Ng/EEAcr
         20CNe6InP1vp4edUrUv7OZdIZgUOg5lwJ5vzuq0/+hZ3AIDRE6e/w+mqITwo4e7FWVzH
         tgAoQl7nYs94VHhAwXbPf9YFQ+N8WnZhNcvOVRmdrqJ0UvyrfFL0dwp6K+MvQj00F05U
         bQjEkzd+sCyNpDXTMJGZpkh2dCthshiyUdm+fXZ5BmmFqy3pjhk73SHmxeYW44VxBW9t
         Gsdgu3Vhutm+TSKiTms1HYJO8uXm+n5Ow0hIWWxJn+7jqyORITWSQ2YBPWSYRv82WCBw
         Z6CA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAU49vBbbe4lX3Y+3VALkBbbiTauxxGxTH8n7yInc2UtDw5bKu+/
	4Ui7Tnw+/O4HHcerRWWUavxZiA9Y9FrO1gnEJKsoxYbU4cpHsildBA8VyIlaDWtHZGS+1vREIRM
	WmwuRQDXEGy9sw4ER+OPnPZ5iub23clwCc94FaII4bEtPqBzeUk4Mu1nfIT8uiTPS/A==
X-Received: by 2002:a17:906:2acb:: with SMTP id m11mr7594160eje.216.1556030118340;
        Tue, 23 Apr 2019 07:35:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwA4+XxmTgf0U8+8wOblPuTmHG514SVL0MvzCzJuyhlFqnYeJlxQQCehAuIDqEcdojPH00T
X-Received: by 2002:a17:906:2acb:: with SMTP id m11mr7594113eje.216.1556030117267;
        Tue, 23 Apr 2019 07:35:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556030117; cv=none;
        d=google.com; s=arc-20160816;
        b=1GLIpIB6PEgLAJ86Ec6WSOwCbMuEoZk8BobBNirHnc/lqfqaQAkG34hubhLc/WSgYw
         5wI8KU1lVHrlOo/yU2Mbfaw9sbZ41FD+BdPpdfz1DG0WsW+OUBmP5ycDILiMrWuNNPP2
         smBqySFs9mSYi7jXH0gFQ579pSG+hqPvAmz1RBK4vdsswbo0eLu/f2UMFRKRagpkPlyZ
         7ZyZLSW7s8L06XE7dR/NFHW+PEWv+NsbnoSNsgSfmQLO5OEKYah5A/8DaoXc4Wb+HoTG
         BQCS5XlykTucEa7Y7vEK3YgNhvUPdUzYYAso3dOJW06vLGcf1Ww87KfCYaWUrIdWamaW
         TUQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gsDrQzndwT6J1SDmOesp5ETe0qGalQbPzULyQ2iff3M=;
        b=JTpsZYoD+aXKcekB3akFqDIBBBfJ37Ry9S5T0VhgMWasLPwy76mOoRAPuluOMl/Z5M
         FZWtNTqeBjmQD2dhBp5czcNaMQG0pnHK7ft5NWPoy85BGU49pAps7iuQaB9sN6DPQRu1
         G7y418yOs23kdZSO2BiEcNGgwKoRco/c3QLI3YiH1AXPNyPdxpuyk+rFhfzqTOJ8hTXf
         N0URLX8Zv5Y64kj/dVgcK5/A01Yy6kxiIZbzrPCHb7JIwR4RlO7Pm/O9+EjYjdjmZaiE
         T7iXiNmarSuITn6czEMm7zgQ6oWIXPAgYBcEYPEL+A2atLEydWVTqn5J9Y2n+2EMO98e
         aTUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id gu5si399238ejb.282.2019.04.23.07.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 07:35:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id BC2B21C25CF
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:35:16 +0100 (IST)
Received: (qmail 21554 invoked from network); 23 Apr 2019 14:35:16 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 23 Apr 2019 14:35:16 -0000
Date: Tue, 23 Apr 2019 15:35:15 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm/page_alloc: fix never set ALLOC_NOFRAGMENT flag
Message-ID: <20190423143515.GP18914@techsingularity.net>
References: <20190423120806.3503-1-aryabinin@virtuozzo.com>
 <20190423120806.3503-2-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190423120806.3503-2-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 03:08:06PM +0300, Andrey Ryabinin wrote:
> Commit 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
> removed setting of the ALLOC_NOFRAGMENT flag. Bring it back.
> 
> Fixes: 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

