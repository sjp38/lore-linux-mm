Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEF42C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 771782087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 771782087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A2EE6B000A; Mon, 25 Mar 2019 10:40:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36D496B0010; Mon, 25 Mar 2019 10:40:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07C306B000D; Mon, 25 Mar 2019 10:40:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9BD76B000C
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:18 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d8so8764125qkk.17
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jtubiF8dOMY7rDYGXJ5NcNneghyDcZXbXzBZlbzJKik=;
        b=Vj0RAhixeB2gnsmtWSgYAMM08dgf2BBpOUfMoaf2Vr9H5bW7/zOHo/ubLWxbf4M+Ik
         tLQIoUUju5gYoKz0mwssTcqjw66v8ufFq6hHBeAclujYuMhGbjULmXrs6IlEdvHuv3Yo
         DbOhX5Fa9Rd2ORv9IgOYX5IY3pj72zMeUu22esb7tSUK4K5Ud73W621j+QCsnn7NzI6u
         qdL6yV2TzKD5HHck1zIfBWTC56rAUMJqb+Rm+5+abK048SMW2bwBEiaTeCsVUmbfYWEB
         iBnqnAcFRQlpaYO1akgGgZyId1BFwcH/Izesv9aR1K+szvbMzrbuut3yhdOjBNz+eCSc
         RTvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/oVujc1W/Vk/q4S73jGAok+5vs6H7usSol2WxKfLZuQ+ZCIgS
	aTdFzdkuOO0Qrd0/mAhNMkH9Hc1gVjaUcR+zPUGAG7olZQ88bQORzVpMg/9745cwDQKf2abo8Vh
	4QckUhxmmGLCdvY9Q/w0y0q8W9fGjykZCtNpm2J1jgcZ8u2pbPjvKf8UzuubuMJA+hw==
X-Received: by 2002:a0c:fa4b:: with SMTP id k11mr20397930qvo.140.1553524818594;
        Mon, 25 Mar 2019 07:40:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5x+lmJIdkCaCHo9jzHWra6dmlY7ddRxW0E50Oqmmo6e4AbGkysrB5GkqjnCyp/b5ykaCO
X-Received: by 2002:a0c:fa4b:: with SMTP id k11mr20397863qvo.140.1553524817627;
        Mon, 25 Mar 2019 07:40:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524817; cv=none;
        d=google.com; s=arc-20160816;
        b=hm0ooLb/m82ne0HexyIj/Lf2ouwxo9h2stfJXqTefuG7mSpY5zunUypvfhfaRXZFHU
         NvsLbooeR9jmqEZdQM7rQDR4mhkb2o74wl1ZSUDfjFsOAs+oa+XcH45Hdxl9R03grSYa
         n/TbJ4XWTQZfmc+j6VMpjSb3KgZnCl1KwlHAA/x5clx81/VWbh8wcpYlMrukDyfJfXyI
         2V5IvWVTwmYTBjZH8FbqggIrsKEa3A0UKAhxZQD3V3RpVdBkKXV60+eohp6FLBo44qYI
         fVA7yfGp53mXqNWggYxOxtxNnL7Jv0urS11C//Brmy0vZVcH9OHkoYAe65W5j8oVGw3G
         P0NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jtubiF8dOMY7rDYGXJ5NcNneghyDcZXbXzBZlbzJKik=;
        b=CjaTIHtqoP095Qn34hA4PmAb6GAjUuwFjzqEhKXwQHxwk2Lt8sWbAiKrDbSsIx9GpP
         NVOG+k2dVkZN1oz3U3BRba0YYAd2j56sEoCHy/MqofSCwDjUcyeFGQxlO07FJsqrMG2Y
         zPuqj6DPwGeKHVD1UZOKQcJdXgw3Bab/nVvdM1xqJKtihve5XUnGpbkDTir3cLqdEe7K
         +RXmTtKPSztOD9UU64+bIBa5TNqg7PbocgEdlwdOCCm3aSeBbE34FGcdpm1CihCDzNUU
         RMxGK0P+SNMMZmJXtu/lxkP81QcVvfBbGUgQfTT1B+zkaRf1obroPU1YcvvCWkANWvyP
         E+jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x134si3057846qka.64.2019.03.25.07.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E301E3092657;
	Mon, 25 Mar 2019 14:40:16 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 53D421001DE4;
	Mon, 25 Mar 2019 14:40:16 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 03/11] mm/hmm: do not erase snapshot when a range is invalidated
Date: Mon, 25 Mar 2019 10:40:03 -0400
Message-Id: <20190325144011.10560-4-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 25 Mar 2019 14:40:16 +0000 (UTC)
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
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/hmm.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 306e57f7cded..213b0beee8d3 100644
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

