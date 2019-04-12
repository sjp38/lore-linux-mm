Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB5D2C282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 12:10:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AA5620652
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 12:10:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AA5620652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF24D6B0010; Fri, 12 Apr 2019 08:10:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9F7D6B026A; Fri, 12 Apr 2019 08:10:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C67086B026B; Fri, 12 Apr 2019 08:10:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6476B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:10:09 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id c9so995620lfi.6
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 05:10:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=j512GlKb0lb61lrFHi7j3PnBGZa0KgAbVBlq8ZlD74g=;
        b=S+ayvl6AUk9ZC01zUyYi6o5Hc43k2uA+vPt78oxu2QHJFaWJXyaPzJyDzNvb8ZVnT5
         th0s5Hlm/t2lT9SwcG9m+1kHOJLRgc9ZTCZJERi5Wz7mlJdZHIFZeVPah8QGnqC/PB9/
         +ZjAm0aR5/53I2L7VDDEuOHqy16x6fAwwvKngQtMV9FKnIdwifJmC0E5qD2n8XZYuRx1
         V6kdPAy918OAcQsgb7pQb/zBkb+OqRYVWWAITQ+5F7+dZSXCo0n2S5YwmNLjW+6ImI0l
         wqpmadTnbA0SET9cJh96OY7IacAOta2xhfEBtkR1Cwu5K+9ybPhPttkrzIZf9URJbLi4
         xwRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWSAywbnXYlpwqLZnSesPAIZqM2x2Zj/vOKIgA3Y6XqQ9yyRd65
	oYXAscDWRrV4OuN9KHsmCcD8BtjSkY+mPDwOKkyP91PiqHjdIJA8Q0eJO/yNMUJ6EVKlDbVG6mZ
	qkyKvGBDSE0OaY8EXNyKLuYNRwK3D7gRfD15CUnuNIQ6hMe7dpmr79YiAU9q3MexiBg==
X-Received: by 2002:ac2:42c8:: with SMTP id n8mr31213992lfl.28.1555071008602;
        Fri, 12 Apr 2019 05:10:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzm33qShA5wZ+JfS+1VS2mjwEMpEW8nbLqkjusl1VuXS7Z1Q6UTnH/ODA9oc7HnYh7Vd/Sy
X-Received: by 2002:ac2:42c8:: with SMTP id n8mr31213944lfl.28.1555071007709;
        Fri, 12 Apr 2019 05:10:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555071007; cv=none;
        d=google.com; s=arc-20160816;
        b=aNr0jviUuJ1wcEIfWPgWnj0wzYhooluKXQvHIK0NlaVAwI1HXR8NDpjo6aileM+Evx
         H1JeLt2CakbGpL684oSinBLoXzUCyt6fzcm9Ie5QDtNAVBDHJD5pPNEi8Fp8qJpTRSkg
         6U+NW91BH7oM2s7fe/VwfBPJdnSwv2DT6ropwiY2e7aL30BdY3Ad2WoufZyRyFKbscO7
         a6k4jyYlVGuDIMl8E2u+DAr/3QiOon/IGsheKHgpoyeUif6C6OAJWgIKMP42DYsOx9LA
         nfH1moRFVGRHLENlqLcXpLAvWVZ42XeueQmUHAstG6VlE4ApMp9ApTjMTDBLdZK3C0eM
         8b9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=j512GlKb0lb61lrFHi7j3PnBGZa0KgAbVBlq8ZlD74g=;
        b=rJJjiF2VYq9gtJrQH/2v7BZh8dmDOi6Wkrm0VdViC4Md7qRI4EfWrsbvUBPFiQhiz7
         7D+JmxaFpnAIiC5rUrrtCHFdxUrvi/KMIRj1CgJdafkNhC2t+hoVPE6NpKfaZiYgSGQ6
         CvJQBWKTMzMVG3l7tl+3eijvOMCu72WhI4T4p314bJkpIriD0nc7EiBxndbFtJZSSjNA
         W8VHRw0ZpFOiXWt2cjRAzxMPPbjNjE9FZly3UJWzv0HzAZNBUzwAwf7oVI0eppT09JFN
         RSMkCnU1q8cRP46tggDFXEmYjXhSnmtX96t5AGrpIghYXVpqBl8o4UfjRsg4efwXyExP
         BoQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id u10si31491054ljh.46.2019.04.12.05.10.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 05:10:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hEv0N-0007jb-JA; Fri, 12 Apr 2019 15:10:03 +0300
Subject: [PATCH v3] mm: Simplify shrink_inactive_list()
To: Michal Hocko <mhocko@suse.com>
Cc: Baoquan He <bhe@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>,
 akpm@linux-foundation.org, hannes@cmpxchg.org, dave@stgolabs.net,
 linux-mm@kvack.org
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
 <20190412000547.GB3856@localhost.localdomain>
 <26e570cd-dbee-575c-3a23-ff8798de77dc@virtuozzo.com>
 <20190412113131.GB5223@dhcp22.suse.cz>
 <4ac7242c-54d3-cd44-2cd9-5d5c746e2690@virtuozzo.com>
 <20190412120504.GD5223@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <2ece1df4-2989-bc9b-6172-61e9fdde5bfd@virtuozzo.com>
Date: Fri, 12 Apr 2019 15:10:01 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190412120504.GD5223@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This merges together duplicating patterns of code.
Also, replace count_memcg_events() with its
irq-careless namesake, because they are already
called in interrupts disabled context.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>

v3: Advance changelog.
v2: Introduce local variable.
---
 mm/vmscan.c |   31 +++++++++----------------------
 1 file changed, 9 insertions(+), 22 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 836b28913bd7..d96efff59a11 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1907,6 +1907,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_taken;
 	struct reclaim_stat stat;
 	int file = is_file_lru(lru);
+	enum vm_event_item item;
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	bool stalled = false;
@@ -1934,17 +1935,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
-	if (current_is_kswapd()) {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
-		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
-				   nr_scanned);
-	} else {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
-		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
-				   nr_scanned);
-	}
+	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
+	if (global_reclaim(sc))
+		__count_vm_events(item, nr_scanned);
+	__count_memcg_events(lruvec_memcg(lruvec), item, nr_scanned);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	if (nr_taken == 0)
@@ -1955,17 +1949,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	spin_lock_irq(&pgdat->lru_lock);
 
-	if (current_is_kswapd()) {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
-		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
-				   nr_reclaimed);
-	} else {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
-		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
-				   nr_reclaimed);
-	}
+	item = current_is_kswapd() ? PGSTEAL_KSWAPD : PGSTEAL_DIRECT;
+	if (global_reclaim(sc))
+		__count_vm_events(item, nr_reclaimed);
+	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
 	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
 	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
 

