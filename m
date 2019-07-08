Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D732C606C4
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:06:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6115121707
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:06:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nE4pF6WC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6115121707
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E606F8E0020; Mon,  8 Jul 2019 13:06:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E10678E0002; Mon,  8 Jul 2019 13:06:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD8268E0020; Mon,  8 Jul 2019 13:06:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9753E8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:06:58 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q14so10704911pff.8
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:06:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=5b7anIeqnAhA6BO/lx8yoH/EvcoMVwex3ww0hx0nIBk=;
        b=a8vk8PAUQmjFpyJEkFdrvP/wCXYpQQ0bj7ew7woF89Q3b91jqbNvZKAoQKVYbbCbTF
         sT+JAjVvx8XS6aobts1ht652zMwFFXKO+aLPy3TpdUMUAgYI5uZZ9p5VjFCNOOT9MOKA
         +SsSGKJdZ2LBvgWz3b1G8au4q/ex2aqsKLJXoQAPiUcUjZ+mlUIGK9uj3Ujyhl4FslHP
         o+IvUVWjggQ7eahJo8i3ZgvSD3yoX5P+bpvhVD/V4THQLI04rOOxUE61YObZ2QNbpmh7
         EJHNCGmq+wBhFzK5Mtc/OBOcys73kd+Er+2zVM47sjm5z6hfXLdbX0ctv7uLZ+7SGjyE
         AMjQ==
X-Gm-Message-State: APjAAAVJqNlK6gog/xJSOShDc13Vrvyqx2rhwOd2pcRj4+IN46lSQaj/
	PCcNfitJwAF2GVJhEu0OGjI0BirYjslQOciHeNd+V+htysPvBRQtDYj35WbiqEDi3IfxpxLPSNy
	m/Fd+oj21fm3xtklDjxxLjrMhZHAIxyWzqpi/7QZKPHofqgnIkZmgfVtxbpaLebrlCA==
X-Received: by 2002:a17:902:ba8e:: with SMTP id k14mr26295598pls.256.1562605618233;
        Mon, 08 Jul 2019 10:06:58 -0700 (PDT)
X-Received: by 2002:a17:902:ba8e:: with SMTP id k14mr26295503pls.256.1562605617159;
        Mon, 08 Jul 2019 10:06:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562605617; cv=none;
        d=google.com; s=arc-20160816;
        b=oIbJL3IMt+H8gmuXI9c+AKB4oaI8VS6Bl1PJzf4LdmDDYGPKEKOLAyc3G3QAiY+2C7
         NL/GsAquwQ5NcHnFTVgJY564Ups9mCnd2Q95iLyiEHRgtYcJid5/7eU3oPNRAzaEkEWD
         0LHSsab3efMSiEs9fnJ7b7mYbFkb1ga26/DfOO6aKMi7Vk7oVxAlXxnTzOBObqiwSrpd
         SQdp2Dgm4nyqaWB1vK5uj3W8Du25hSssWdxKkE7ocgydCpLVnyFlaiEDJy3JNUcamA5W
         pQOqfIV8oj4l5U2w17Osm3ZEtwCaUfPGxeD5QCUNvsYf4AmZNATccOhpnZQPiaGwJKot
         0blw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=5b7anIeqnAhA6BO/lx8yoH/EvcoMVwex3ww0hx0nIBk=;
        b=plpetr1YjjImhzuhDL1oZ9e+N4hXJn9VjLViwayV+wC2iqbWfDKQwRyWBbY9BzHPcx
         zkHTSbDb0zMw3kYLlfJj13y4RnKel+pscXMsUP4G88/GmBcS3H6o2xxPThO0Iw3SKhjj
         1evtaPjWC8slE6f08W5Qo/2kWbz6uM7nywo6GkFedMGmeK9zEq7Xr5PMVzIbj514Pzer
         JQhBOz7pRcGAzH9+jhHjZsp3R2ZELJJMg7qNLTfqmPkmOUPnZ2E3nD1muvs5OYMRjD/o
         ko/QY04m1d8O6vUF5sVs7oZwRXwQxgV6pqg9b8AIIqRuMHGRF2kmlg67ZOEktXyL+SB6
         kafg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nE4pF6WC;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor21963720plg.28.2019.07.08.10.06.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:06:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nE4pF6WC;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=5b7anIeqnAhA6BO/lx8yoH/EvcoMVwex3ww0hx0nIBk=;
        b=nE4pF6WCSfy5375pasiGnK6x/BoAlKvJiEjKHA1Z6LC61rUtkohvgs+pMqeqoxrHeJ
         QaoQIYQBVzZdYmyimFzvOOvkufThmb+yZ/4JPuZk6Vll7Vgc2aPjWaiSruazPDixu8y+
         MC4cvlyfnXnFY2cPZh2uu8o6bDhtz0x/6j8cB//biI5O9TvD9bC+T/gL5B5tf7CHvRYr
         RxFPEo/q+Y4ypdM2KWGRBpOJoOMygvy5tt61wahtCaSnBQ7/twQqoocOOgu+BscuktVJ
         YlpYTN9kzOINtxTO6MsLndbEJJry/TBKMD8GLviUttA82JUu2V4o6hu6UgvfMjPuHWlN
         OseQ==
X-Google-Smtp-Source: APXvYqzt+il4zwPT6FRB06smT4nafOFmaW59SnLzajCBM2ImXEDODHJR8LpJ1IuBFwxXC7wAgigEgg==
X-Received: by 2002:a17:902:6a85:: with SMTP id n5mr24841812plk.73.1562605616776;
        Mon, 08 Jul 2019 10:06:56 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:b30:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id 30sm149551pjk.17.2019.07.08.10.06.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 08 Jul 2019 10:06:56 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: urezki@gmail.com,
	rpenyaev@suse.de,
	peterz@infradead.org,
	guro@fb.com,
	rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com,
	aryabinin@virtuozzo.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH] mm/vmalloc.c: Remove always-true conditional in vmap_init_free_space
Date: Tue,  9 Jul 2019 01:06:31 +0800
Message-Id: <20190708170631.2130-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When unsigned long variables are subtracted from one another,
the result is always non-negative.

The vmap_area_list is sorted by address.

So the following two conditions are always true.

1) if (busy->va_start - vmap_start > 0)
2) if (vmap_end - vmap_start > 0)

Just remove them.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/vmalloc.c | 32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0f76cca32a1c..c7bdbdc18472 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1810,31 +1810,25 @@ static void vmap_init_free_space(void)
 	 *  |<--------------------------------->|
 	 */
 	list_for_each_entry(busy, &vmap_area_list, list) {
-		if (busy->va_start - vmap_start > 0) {
-			free = kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);
-			if (!WARN_ON_ONCE(!free)) {
-				free->va_start = vmap_start;
-				free->va_end = busy->va_start;
-
-				insert_vmap_area_augment(free, NULL,
-					&free_vmap_area_root,
-						&free_vmap_area_list);
-			}
-		}
-
-		vmap_start = busy->va_end;
-	}
-
-	if (vmap_end - vmap_start > 0) {
 		free = kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);
 		if (!WARN_ON_ONCE(!free)) {
 			free->va_start = vmap_start;
-			free->va_end = vmap_end;
+			free->va_end = busy->va_start;
 
 			insert_vmap_area_augment(free, NULL,
-				&free_vmap_area_root,
-					&free_vmap_area_list);
+				&free_vmap_area_root, &free_vmap_area_list);
 		}
+
+		vmap_start = busy->va_end;
+	}
+
+	free = kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);
+	if (!WARN_ON_ONCE(!free)) {
+		free->va_start = vmap_start;
+		free->va_end = vmap_end;
+
+		insert_vmap_area_augment(free, NULL,
+			&free_vmap_area_root, &free_vmap_area_list);
 	}
 }
 
-- 
2.21.0

