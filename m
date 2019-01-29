Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45826C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02E3420989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02E3420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EC118E0004; Tue, 29 Jan 2019 11:54:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 699808E0001; Tue, 29 Jan 2019 11:54:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53A7D8E0004; Tue, 29 Jan 2019 11:54:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2306B8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:42 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so22078321qkb.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QcLzV1gGPkQedQiJBQ1N5gPCY/e3jxaa42upoNgKKqI=;
        b=WN+B6sSX3vaoBcPh9333onfZ4vkprO2pvwK6Eto7LTg9vnhsuu+U/ZeQMpwC99l4LS
         UTrWRi1EPxe06PzJx/56MtKvYc4YehIgcaneXG+Tzh8Micy0BPSn3ZULntd+C0OI/N6K
         ZhHMyEcThijmJ2tNv8aHNjRvJKD2e5Pvarr39ha2T+lf+2SU5rHJLVB5CEMJuhBr2XAr
         6r7quetH/sb+dEUn7YyhEKjWfd9DO1baeVRhFdqRqq8lWkZVnnQEOMuXqkxxHcvFUqYj
         149JQ0ECSH5WgW59/eBtHSKkRlpnYiP/ckyogk8/cVg8F+W3OBG+3EJFAFB285rCoxsS
         d7VA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukco2ZAcIC6t7Cn8ThUKI9bxBPUlQhoqQusSLlWYEpsnEGILWWFs
	jdh6fNGUWTJQKvFFAiChc3tUYTv1NpFZFgRf05SPufWf272NTqD+YwXVa/x3oXE7hVNYi5s00Er
	rhEoORf3Huf0OBQ2SEE56eZ8csrk4AjV4PUgq46ghtH+G7jis0GUj96ivz72IaitsUg==
X-Received: by 2002:a37:9845:: with SMTP id a66mr23463915qke.271.1548780881949;
        Tue, 29 Jan 2019 08:54:41 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5+PNGHaW2uaV7/IBg2Gh77U9o6G0OJkNIjyHQb/8U6C/YXw0LNpdsLZ0wda10rwDaniaXf
X-Received: by 2002:a37:9845:: with SMTP id a66mr23463892qke.271.1548780881546;
        Tue, 29 Jan 2019 08:54:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780881; cv=none;
        d=google.com; s=arc-20160816;
        b=zQiUJ8DoufIXrlotrfjxzf7oEjWkIvGmdTq6EnjyEfDVlWUzNXFV12XreAOLgaIxg2
         b7+JudZDQIjta+iyYSu/6bwyWunRqQMMc6CjeCHVSYUzBwEhBtztnl3kbY60b8ol/kFb
         BDqPQ2hdWpUbpbGI4REyrAQe/KuSX4qPm1Hg00BanZqadKTQylF7/3SfZBichmMJUmZU
         kq01SaHyUwCKS+gsDpCRj7ci1kB0+ftY99SzDQtl49Egr1pz28PAILfZNdFuCeNvaf2j
         zllHYvFAhMpMeo/dfZ2zoVyOTYdbIN4zym3zUKCUuetawKEX/36e6nwbN3B7pywAn7IG
         MyAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QcLzV1gGPkQedQiJBQ1N5gPCY/e3jxaa42upoNgKKqI=;
        b=OEprGEexS5lAnY0aVLt28MsWhFrLgy2UgQiXvy5LbIyBZ5+FcsnVoa0KeBZEdPBT7G
         2vQ7wIKAI4Axfw54DLQvydu/lA3LiXGf5iuosovv2UEP6MojyQzWiNMPMTizZmPMOQJ/
         3ZdoH1G5G5zbOlWuu0kYJs9xGQM1haeT+VQtP5uOMCUgg6/gBzW9ixqh99Vd7gxglijk
         eBtJY9U4b63BNx5px7Cs6KhEcAPHKELJsMATaZ5sVfDLYMOqgQpzPIXKedQhbnI+ZTwB
         qqmWfc/BubwaHHqB2sAxstw+y6HPx5Vg1uxgdw3R7pssLxmiVETTVkVTJzaGKr2CXCDg
         Dq+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o13si1528246qkk.92.2019.01.29.08.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B1D3237E8E;
	Tue, 29 Jan 2019 16:54:40 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AC35D102BCEB;
	Tue, 29 Jan 2019 16:54:39 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 02/10] mm/hmm: do not erase snapshot when a range is invalidated
Date: Tue, 29 Jan 2019 11:54:20 -0500
Message-Id: <20190129165428.3931-3-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 29 Jan 2019 16:54:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Users of HMM might be using the snapshot information to do
preparatory step like dma mapping pages to a device before
checking for invalidation through hmm_vma_range_done() so
do not erase that information and assume users will do the
right thing.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index b9f384ea15e9..74d69812d6be 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -170,16 +170,10 @@ static int hmm_invalidate_range(struct hmm *hmm, bool device,
 
 	spin_lock(&hmm->lock);
 	list_for_each_entry(range, &hmm->ranges, list) {
-		unsigned long addr, idx, npages;
-
 		if (update->end < range->start || update->start >= range->end)
 			continue;
 
 		range->valid = false;
-		addr = max(update->start, range->start);
-		idx = (addr - range->start) >> PAGE_SHIFT;
-		npages = (min(range->end, update->end) - addr) >> PAGE_SHIFT;
-		memset(&range->pfns[idx], 0, sizeof(*range->pfns) * npages);
 	}
 	spin_unlock(&hmm->lock);
 
-- 
2.17.2

