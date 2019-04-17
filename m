Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48C91C10F14
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 03:37:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0204321773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 03:37:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0204321773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99AFA6B027D; Tue, 16 Apr 2019 23:37:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94C056B027E; Tue, 16 Apr 2019 23:37:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83A396B027F; Tue, 16 Apr 2019 23:37:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFAA6B027D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 23:37:35 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d15so13842992pgt.14
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 20:37:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sVlJkPMFHyWruH/ymzdjKSLzNjAtQFQtSk1NIUkWvAE=;
        b=IBgaf44fi2DdYhCfNO6+yUKph9UEvyGqtTBlHXZ67Vh2nDlkhln1pSUOSDQCJAwCtM
         Y7qQl1Ij7FLd50xIA4g06PHcn5/dqyeMS3kyT3oPQ+JIoJJe9qFjDcQah9VlQz+Yf6MQ
         7YJCTowXPdQHwVY8GVz+EKoeVaJwOCXSAcJTZgHRFIaMg5YHBqUD1qGdJXVtit+87hX4
         zXAHxJq3dCD0THCxOa9Qv87XQ0CoIF1+Ypalfyi24Hvv70fTqti6fz7QHfF1m9G1U8KS
         U1+ho71iktnQmoiKlQw5rK1mj9v+Vym8C57W2KEspeKPli7kxLOmB3ttUyeOw8hjpr3I
         M/BQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVXYG9U8QI8zSyQzttaJshF6kQT0yoR/kMCw45G1LJv7GxJIU58
	C/96AeTwyueuDrdGxsXiylkKedCs8J0gGNncj7d3fDetgVya+eK02So9CZUOLjYFuHRGQnf7ZXs
	9d/VVs1NV+EVZAOljzaHTZdQMRrlUPlCCeadoie6P6Lcq7FTjuzeGlA2fs43P/hv6KA==
X-Received: by 2002:a63:e653:: with SMTP id p19mr79219928pgj.284.1555472255043;
        Tue, 16 Apr 2019 20:37:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6wPnUmaox9RxpomRVLsjvUbc4MC9Czgfl4jwkIHU86WYtkkHc+Nqd8c1G9Such3HZ0cKf
X-Received: by 2002:a63:e653:: with SMTP id p19mr79219889pgj.284.1555472254465;
        Tue, 16 Apr 2019 20:37:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555472254; cv=none;
        d=google.com; s=arc-20160816;
        b=MZedJ9LcsZD1JdDZ1nM8+FybKd5ztSdJgoa7ecYSA0a8OPquP1KE/EEUiK7Sb6GQEi
         5ulJudOJ6rXKOiBgftJhQIBmpmYTrLdjaiRNUOf7dhG+Eji52f9FYhdloS3I6rPEZJ61
         +s4+qLd1uBx6ducN+eSU9L7XizBiHHhRqvg6e7KMXvPIUveJVM6g5u3k6o57y++0v7w5
         tIajwtvL3NtvRU8L9nfPBEUiFoO/TILvKwkQIIzMme1QT7kra7P7ayHhlzyYwGUp6n1K
         f4feFe0DILcpgC6zsPeBZSd/QqPcIDvrrjlpF+ulFmXk0u875bpr1JpwbWtRRtWR4h2r
         v27Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=sVlJkPMFHyWruH/ymzdjKSLzNjAtQFQtSk1NIUkWvAE=;
        b=T2kwdYSVfvraaPWjoT4+q41DT4DL7Tv2e+naKLHHp2XovdQI2X0xbX+mivvYhsIL0z
         5VU6t9Otbde3SMvUOW5UJ53CP7XLpF4uyt0YKFuw5RxJ1piAa/hOlJrFpt/yupqddzY9
         uEzwS8ficSq7zKlbxsZ8qai3PLWZyzjtV+mWn/G9zxr3lL0mnjtAmYNriVe9mlXrN63W
         XUYzrJ57I9Dmcatv3JJh4DkjIXylAipLGY2uKCBxsjvS2NmQ6M7DXSWcjN7NYUHyg0yY
         5BTFPLiAB8SRASXS02w3JCNehDFITTXyLNQ9YTMFC37MmNl2+MXH92cXY3jX30zjH3ol
         7bXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 62si48721586pft.98.2019.04.16.20.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 20:37:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id CDE9FB7A;
	Wed, 17 Apr 2019 03:37:33 +0000 (UTC)
Date: Tue, 16 Apr 2019 20:37:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador
 <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Wei Yang <richard.weiyang@gmail.com>, Qian Cai
 <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre
 <malat@debian.org>
Subject: Re: [PATCH v1 1/4] mm/memory_hotplug: Release memory resource after
 arch_remove_memory()
Message-Id: <20190416203732.eec38cecd35d4242a59ca19a@linux-foundation.org>
In-Reply-To: <7cbea607-284c-4e20-fee8-128dae33b143@redhat.com>
References: <20190409100148.24703-1-david@redhat.com>
	<20190409100148.24703-2-david@redhat.com>
	<20190409154115.0e94499072e93947a9c1e54e@linux-foundation.org>
	<7cbea607-284c-4e20-fee8-128dae33b143@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Apr 2019 10:07:24 +0200 David Hildenbrand <david@redhat.com> wrote:

> Care to fixup both u64 to resource_size_t? Or should I send a patch?
> Whatever you prefer.

Please send along a fixup.

This patch series has no evidence of having been reviewed :(.  Can you
suggest who could help us out here?

