Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63EDCC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 18:47:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F27221874
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 18:47:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F27221874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E4996B0008; Fri, 19 Jul 2019 14:46:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75AA56B000A; Fri, 19 Jul 2019 14:46:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4499A6B000C; Fri, 19 Jul 2019 14:46:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D68B78E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so22568755edx.12
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 11:46:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=uCDkeNVbjDAM8yrLHlMPqnxhh17i0B5p0qCieHpy4M0=;
        b=DMN7M/kd12VAP828pqTkIf8Ktm4h/0HtlhLLh0IfO2JicYzc5gX1vsr0qoSVGt8G4K
         9JEg//M/qfY8OydLnBnlLbByeZo70u8Ii2b46YslOXliGUjlc0YTXQcZk7JA2k1FMlBW
         xtl7C4CTid8k24EmNpwsFrLgUg2LyNssBE/E7bouQYcTnz0Mn8s+HuIdqdjXW3k+wlmY
         h1WVK9WVf9g3Sd0kBrqQqNMoQhq4Sb+0N7CgT0bRnl3Cf5ap8EvhyK4xMBWwDBNA7Zr6
         k1pzIx0sZNEzaei+MjV/eT3WCMgm+NN7helfTr0D7XRbi5ZNWgtQDspff3TzVWl/A7qD
         xTNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAVVuX0Dvc+0EDryy4pyup/Zu09h9TRvxu9+cyemDLNyFBGtveDB
	LIR100pTkTJ+RZZkERVydrks0EySy1A5qY//nKxAJ0G/Dtne4DVhU15p1bg4bNVppMVDcOJ/Lpo
	yHT7o/Alf4cwfyvdaL/JyibXxJ75w7Kpy273skpC26cIiN+PMANU0HpewvWuvxWq3Pw==
X-Received: by 2002:a17:906:8409:: with SMTP id n9mr41583945ejx.128.1563562017422;
        Fri, 19 Jul 2019 11:46:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+e7qfGhKBOC0/JKMaK3d1FvEwdwzl/LIyj1I6xgXTT8b24/YVjJf4Nu3pcFBfYIH+ADCO
X-Received: by 2002:a17:906:8409:: with SMTP id n9mr41583902ejx.128.1563562016542;
        Fri, 19 Jul 2019 11:46:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563562016; cv=none;
        d=google.com; s=arc-20160816;
        b=MXhFjleQS8LcYPzDf1DMoSOqDcLtwxrRwwuq3hrosw3HKYQzYAk8tXn6JEnRYBlxc3
         4OGDIDeJJgdGmAsZpDCS3oj6A1GS1iEYPny60/Y+JDeobnj5oxQdpI7aJzRrhdzg8Szt
         2Ec85Jc8SPYCx80xgdhUfzyyjL9UyVE0Z7qE+ptizVWzl0wDtOkC/d4SSa7p2m4+t1db
         Xj1Jgr7qZoxZ4F2nHJNay+0PF90UCej3p41INbclhuyLvixOlxNtqDhzPl+5AOA/B6qb
         QArIs06JvVu5Ed+pGLMs8x4IReDTR8rYraG7jx28MZ60b3+lEuz9q1eAI+/tpi5QW4e1
         lu6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=uCDkeNVbjDAM8yrLHlMPqnxhh17i0B5p0qCieHpy4M0=;
        b=RgA9BSSV8i12J7k6wFGVPZUr9YOGbX7i03/A6NZkh734jm5wtG8NLfCDeBevpyuLf+
         FKR2qug3qIEFLYnHKahiEIa3//wedsNa32b1g3R0CSray6yIQ/e39Ccpc+81p7mLC+Ra
         jPwG8n8iJoJ3Sde0kCvMHuz9ltMnKb4V7PGtMTWEeH1UkqdhD8FBvvgYArAnPRxBRJvm
         Io4GlGbluzMB7VnYssvTDbrrx0xkQ+5Jymg+fdmmfjlBPFVTaaFrPFGF+ba0l094pwc1
         VQl/uq9b5TIgSxzFz1yej9Zkk86NvhfjHi78asJcS7ELC9yMXDiLDF9QbDeXkaWVSZbM
         LoLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id b8si124695ejp.210.2019.07.19.11.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 19 Jul 2019 11:46:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) client-ip=2a01:238:4383:600:38bc:a715:4b6d:a889;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id D322026B; Fri, 19 Jul 2019 20:46:54 +0200 (CEST)
From: Joerg Roedel <joro@8bytes.org>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Joerg Roedel <jroedel@suse.de>
Subject: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
Date: Fri, 19 Jul 2019 20:46:52 +0200
Message-Id: <20190719184652.11391-4-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190719184652.11391-1-joro@8bytes.org>
References: <20190719184652.11391-1-joro@8bytes.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joerg Roedel <jroedel@suse.de>

On x86-32 with PTI enabled, parts of the kernel page-tables
are not shared between processes. This can cause mappings in
the vmalloc/ioremap area to persist in some page-tables
after the region is unmapped and released.

When the region is re-used the processes with the old
mappings do not fault in the new mappings but still access
the old ones.

This causes undefined behavior, in reality often data
corruption, kernel oopses and panics and even spontaneous
reboots.

Fix this problem by activly syncing unmaps in the
vmalloc/ioremap area to all page-tables in the system before
the regions can be re-used.

References: https://bugzilla.suse.com/show_bug.cgi?id=1118689
Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 mm/vmalloc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4fa8d84599b0..e0fc963acc41 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1258,6 +1258,12 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	if (unlikely(valist == NULL))
 		return false;
 
+	/*
+	 * First make sure the mappings are removed from all page-tables
+	 * before they are freed.
+	 */
+	vmalloc_sync_all();
+
 	/*
 	 * TODO: to calculate a flush range without looping.
 	 * The list can be up to lazy_max_pages() elements.
@@ -3038,6 +3044,9 @@ EXPORT_SYMBOL(remap_vmalloc_range);
 /*
  * Implement a stub for vmalloc_sync_all() if the architecture chose not to
  * have one.
+ *
+ * The purpose of this function is to make sure the vmalloc area
+ * mappings are identical in all page-tables in the system.
  */
 void __weak vmalloc_sync_all(void)
 {
-- 
2.17.1

