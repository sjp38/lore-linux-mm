Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC25EC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:05:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A2DC218B0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:05:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="iyQnjGnG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A2DC218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9C3E6B0003; Fri, 22 Mar 2019 11:05:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E23756B0006; Fri, 22 Mar 2019 11:05:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC59A6B0007; Fri, 22 Mar 2019 11:05:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9566B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:05:17 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id n125so817036wmn.1
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:05:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=la79GVMa47gWOb0qD5kRoQk6VC6UfGHw4stP89HbwZw=;
        b=UlNuf75nxn+lDVwLQzWbS4IMcGM6lM31fzZs+Nr8Li5UBmcKxddTWdgCAWPijWN8Ln
         UUKgGuh+gSBJfIAfuGIebgehr71iHg9+F1Czw0nKRy+zAY8ADWL7il4LcbBfjqBc7RlU
         SCytlV0NKy+ZuxBHoZJryn3hZKTI9/7cC9kxb3gEgEuTOV/3bi07KpdylGz/yVEfDNMt
         CqeDGOpeqXaT7/aeRTYQhzpSMBF1qB1ZAeiWIjybuRtp77xhQdS1P0nImUsy3AMx12Qn
         MN/bQtDsAXEhS4Z8o0KRgtQDQk4mNwKC5aBgYHlLWI+0OX182mklCnmBiddU0hHfchgh
         9AHQ==
X-Gm-Message-State: APjAAAWJ3Ws0bpLew0Gkr9Tf0WRFpnpN5+h3L13WZn9ih2ndiwFkmvYL
	A4pomfXBch8TgDjYGhZihhTfNuVEgzJVtTJ5EfFh0BRRJg6dIU/81J4OZlFVoJyn9HRytm7whBO
	AJTZUg8fRj+TXwDCKik7yzRnn8um5PzZCi1L6N9hy1KfgFoMwbDokJkBRSHf31C9S3w==
X-Received: by 2002:a1c:480b:: with SMTP id v11mr2621946wma.25.1553267116815;
        Fri, 22 Mar 2019 08:05:16 -0700 (PDT)
X-Received: by 2002:a1c:480b:: with SMTP id v11mr2621892wma.25.1553267115919;
        Fri, 22 Mar 2019 08:05:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553267115; cv=none;
        d=google.com; s=arc-20160816;
        b=WF46pvcevrQ02D25y9LcNA0va+0oae/TuFRCb1pXBVocN/nPF+1QJOfuBytWBMcH9m
         RX3F/Ihv0GlTV/dZ2ZZCrEI0jXNOCPtHqvc80ygTn9RBWeQLvH9ubGCkhcQtrE73rgyf
         fbIkWNi43IC/D6RSgp4gq+knujB9ZOU7CitxtQ/dseDO1s4LWVUC87wXWBXUtXOGOIHC
         AxLu/aufHneuZDY9J652Xeu3qW8tjuSqnwgBFgKtWIMdN+Y7q3dZBQfVMpBMPPpN0nBq
         Z/NPnNrcuAIFzLydA5ctsAt9wCTGJM0IM842tTX6eOlf3D3V3IieucygZUdvbvpcZw98
         9cqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:message-id:subject:cc:to:from:date
         :dkim-signature;
        bh=la79GVMa47gWOb0qD5kRoQk6VC6UfGHw4stP89HbwZw=;
        b=xoWM9IdKLbA6LVN1sxLyyK8VZIxE6Ji0bZFebCHpE1EO1+9eB6zCk1dhDYM1VbWmUu
         BCYW9HWSvHkYilIBbRVNxjeYa83undUP+UUn7YZng6zcWMA7d9kLeMZUiHd03buGhGW4
         wB/+7r/Wl5wdaqLD9xrSZNzebUDRtvj+EUTLAWgELYFMVt8PNrf8cmbHJei8eHOdt0di
         ZiwmEB+/x14hN3q1bBMKLYvgyinq2o4nQhmvbkromIb1YoPvq5+ui1GZpDzogXFX0VoZ
         fgmUmbYwHcv471X78n9fdUnzVKdtJ2VmnodieIrPeaKN7QvfMA+NwLzTMOEfDJGBwp9r
         zYRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=iyQnjGnG;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y3sor5658942wmj.10.2019.03.22.08.05.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 08:05:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=iyQnjGnG;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=la79GVMa47gWOb0qD5kRoQk6VC6UfGHw4stP89HbwZw=;
        b=iyQnjGnG51BIfxJIICh18JKJdtzPSrWThifwALw2gWvK1/gNZEsTAKEvxsc3wzKXqK
         tQ08PhWRYD6ROgWHR8CED2SyxdwNUvt1+EpYx+TraC3D3f4BUhopjef2d0iHHuR+fvRW
         OK+Dxeh5EfJv5kyTXhWF0/qOB6NJxdNwXhYr8=
X-Google-Smtp-Source: APXvYqxcd9chc48Z5gs026zGSni+ohQ1klMDVbYgMSEarwtJFSVYwpEsS7QdBncOnajxC7rDh/Irvg==
X-Received: by 2002:a1c:4641:: with SMTP id t62mr3569438wma.53.1553267115327;
        Fri, 22 Mar 2019 08:05:15 -0700 (PDT)
Received: from localhost ([2620:10d:c092:200::1:a21b])
        by smtp.gmail.com with ESMTPSA id y125sm4365149wmc.39.2019.03.22.08.05.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 22 Mar 2019 08:05:14 -0700 (PDT)
Date: Fri, 22 Mar 2019 15:05:13 +0000
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH] fixup: vmscan: Fix build on !CONFIG_MEMCG from nr_deactivate
 changes
Message-ID: <20190322150513.GA22021@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <155290128498.31489.18250485448913338607.stgit@localhost.localdomain>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"mm: move nr_deactivate accounting to shrink_active_list()" uses the
non-irqsaved version of count_memcg_events (__count_memcg_events), but
we've only exported the irqsaving version of it to userspace, so the
build breaks:

    mm/vmscan.c: In function ‘shrink_active_list’:
    mm/vmscan.c:2101:2: error: implicit declaration of function ‘__count_memcg_events’; did you mean ‘count_memcg_events’? [-Werror=implicit-function-declaration]

This fixup makes it build with !CONFIG_MEMCG.

Signed-off-by: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 include/linux/memcontrol.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 534267947664..b226c4bafc93 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1147,6 +1147,12 @@ static inline void count_memcg_events(struct mem_cgroup *memcg,
 {
 }
 
+static inline void __count_memcg_events(struct mem_cgroup *memcg,
+					enum vm_event_item idx,
+					unsigned long count)
+{
+}
+
 static inline void count_memcg_page_event(struct page *page,
 					  int idx)
 {
-- 
2.21.0

