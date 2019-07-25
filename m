Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8007CC76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AB712190F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="itn+ATRx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AB712190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEEEE6B0003; Thu, 25 Jul 2019 14:44:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9FDD6B0269; Thu, 25 Jul 2019 14:44:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8E5C8E0002; Thu, 25 Jul 2019 14:44:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 957656B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:44:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k9so26795013pls.13
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NhwngYDbvri5ejmcM0XgYmhjUBSSl/buGnAbDPDI9EI=;
        b=akiJhJxa1hdgqYljxJXVhLqM8mU3co9e9buEyxAhvLOyBpKFakBKXqoqIyAKQ08xJH
         SgKpvHs2IGHwK0c7ZYEIWS3DWbN9PzGR8owWtpAfYxLEqNrsvm4jZGsHcuC3Eyk1nW95
         1Ur3tslnTyLScp3+3b7nGrd1RcmflVjc/Qtg7qRBvm8sRHXJ+J08Mr8Z5mf0IN4m1cIz
         eDiwRWSxiA3w1xxfgFR6VwOXkCccHKQ9x7pXjACx3zTxF8qxpmG1I06Gwo82j1RbKrpR
         EVc+jijxmlmRWcuFxA95ZmTsHZa+uN9NghciyeHhlhL2AzxqBnKaKhN2s3JUYd0BJP4I
         0Ucg==
X-Gm-Message-State: APjAAAWEYdeCbElWvezdjvs8ChqhtXvg66FzEIfw49tZihz9Hjwf4CoU
	jiWaOK3W8vobFbK5DCdwHQCLWjujFaDIEhXbwvJZ1ptGW2g2uXbUjUu/lskjhdAQHj+MRVt/q0e
	amNYZLZQe17jjZcDq1eYN2Y8kTfbVxrAkxEXjVZynIFJJMMljMhdmFhOaQD/v/1g34w==
X-Received: by 2002:a17:902:82c4:: with SMTP id u4mr92268038plz.196.1564080287294;
        Thu, 25 Jul 2019 11:44:47 -0700 (PDT)
X-Received: by 2002:a17:902:82c4:: with SMTP id u4mr92267985plz.196.1564080286303;
        Thu, 25 Jul 2019 11:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080286; cv=none;
        d=google.com; s=arc-20160816;
        b=dy3/gPn0HOkFladEn3rPPAhbDszdqysXW3ByOUp9I/brCA0iN//UDMeLiv7qf8LzyH
         acZ77cxM7mrOd22ktUKQ1JlPWDDypMg+DvmAyRJcvY8n6Jfpv6eFVO5jvwjxzhvmZyDG
         YXElpJeKOTvBvydsOY+Bi/xO7NMTecYISlKI5WcvR0SimfoVd4GR9zB7z5F52jiP19bv
         jn/yx7rx78qZnVJ0yYymenqdzrAPwGjSnokGJsgKj6AEcPuhKranBRSTf6ro2RU8KEol
         qwbU+CZSek1OJ2tPBUwwLjIPNqBW9euOrsZ9XGKhbLah6ZqGWeTlmDkTxuKE1NFd4qMi
         pJGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NhwngYDbvri5ejmcM0XgYmhjUBSSl/buGnAbDPDI9EI=;
        b=mrlzq/3wt3Zw0YJ5R2wz+VtDCrTfLk5hUQcvsA4c51+E97U62y3EgImJ9i9J1St7je
         6rX+aCk6cKoPEu8kjFcUBfKffyN4wSwjF1sqKWl5QV/PVpbV84BoHkIh/Bc39gU9bIsJ
         4qAeHtVUaOICCZMakN9BDE6nQQqlbPZi9fGmh9yktC/buGWp7bjU78gJwm/mhmXrzG9U
         axSIHeuCU+FBRD0ndnjkk+o/OnGBC53sFqpJRGCZd0T/rsQreHWIAp8rPkeaj125a29s
         ranRvycxkHl0jIw1ayVmzi3F/Z3GskR2o9AxlVDWYXbyaCYrxqw0+mixpa1MmcvoAWuI
         JqQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=itn+ATRx;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n6sor61305904plp.9.2019.07.25.11.44.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:44:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=itn+ATRx;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NhwngYDbvri5ejmcM0XgYmhjUBSSl/buGnAbDPDI9EI=;
        b=itn+ATRxnc66FvQMYJryteL+cOXPgFskNlezDWkecZsggx+jExRT3w/o6Zozs9r4lG
         7p+nYoCch1hfycj2Nee5j56Dal/g7Fchu2Bo2iHKtJuZT1VJX80T3oUPlIJFK8zFzP3l
         fLnG1YQh79ExZFmGg3Vdh4sIhJXUvwotn0Rdca8RSEGgBD61h9ckWIZGcKP63fnc4DeU
         NtdzrRSRiFo6iIaf5S09Z1w1VIWf47s6ZRjqMN/SQet0AgUstkkV0e/If8ZBqHwuVvZw
         n7UJO9EjWtc94vpUjFu23209ncO9R4sRtMWsUI649YSjzndG72fY/mV2qUIliSKCqnrP
         qPng==
X-Google-Smtp-Source: APXvYqxd1avMi033AmybLadPo/1ryj1iZmvCPadNNWuTSgJQuR4oMLhBqyYbEtyoNYRC9tLu3admKA==
X-Received: by 2002:a17:902:28e9:: with SMTP id f96mr88604969plb.114.1564080285671;
        Thu, 25 Jul 2019 11:44:45 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.44.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:44:45 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	mhocko@suse.com,
	vbabka@suse.cz,
	cai@lca.pw,
	aryabinin@virtuozzo.com,
	osalvador@suse.de,
	rostedt@goodmis.org,
	mingo@redhat.com,
	pavel.tatashin@microsoft.com,
	rppt@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 09/10] mm/compaction: use unsigned int for "kcompactd_max_order" in struct pglist_data
Date: Fri, 26 Jul 2019 02:42:52 +0800
Message-Id: <20190725184253.21160-10-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190725184253.21160-1-lpf.vector@gmail.com>
References: <20190725184253.21160-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Because "kcompactd_max_order" will never be negative, so just
make it unsigned int.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/linux/compaction.h | 6 ++++--
 include/linux/mmzone.h     | 2 +-
 mm/compaction.c            | 2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a8049d582265..1b296de6efef 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -175,7 +175,8 @@ bool compaction_zonelist_suitable(struct alloc_context *ac,
 
 extern int kcompactd_run(int nid);
 extern void kcompactd_stop(int nid);
-extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
+extern void wakeup_kcompactd(pg_data_t *pgdat, unsigned int order,
+				int classzone_idx);
 
 #else
 static inline void reset_isolation_suitable(pg_data_t *pgdat)
@@ -220,7 +221,8 @@ static inline void kcompactd_stop(int nid)
 {
 }
 
-static inline void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
+static inline void wakeup_kcompactd(pg_data_t *pgdat, unsigned int order,
+					int classzone_idx)
 {
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0947e7cb4214..60bebdf47661 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -723,7 +723,7 @@ typedef struct pglist_data {
 	int kswapd_failures;		/* Number of 'reclaimed == 0' runs */
 
 #ifdef CONFIG_COMPACTION
-	int kcompactd_max_order;
+	unsigned int kcompactd_max_order;
 	enum zone_type kcompactd_classzone_idx;
 	wait_queue_head_t kcompactd_wait;
 	struct task_struct *kcompactd;
diff --git a/mm/compaction.c b/mm/compaction.c
index aad638ad2cc6..909ead244cff 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2607,7 +2607,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		pgdat->kcompactd_classzone_idx = pgdat->nr_zones - 1;
 }
 
-void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
+void wakeup_kcompactd(pg_data_t *pgdat, unsigned int order, int classzone_idx)
 {
 	if (!order)
 		return;
-- 
2.21.0

