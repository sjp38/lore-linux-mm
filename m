Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2603AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:19:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4D432173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:19:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C3qFbm/L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4D432173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B3978E0003; Tue, 26 Feb 2019 01:19:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53BF18E0002; Tue, 26 Feb 2019 01:19:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 405188E0003; Tue, 26 Feb 2019 01:19:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F02558E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:19:38 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id k10so9736646pfi.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:19:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=Cjawy4N96Is7QYxOfWtULwPM5Mp5Omal0QxDOVwHSyw=;
        b=fXOzYOs4Cy/shmwbQrP0jZJ29QV6lKYjLjX6RDi8tuvXbPV1uz836CFZvxzrJdgFPS
         +U5NOtjRW2CbrOc1pwigKHsNN74pdAYZIK37kQjieLmS27QB1BkCRU0q4CoLngsog1gB
         yudQHzjUD/EBOXOPfhrLxr1nkGB24+3WcRKG1j9ymSWXivSlC7L63khj3QfGlN8JMJnY
         EbSPxsne/sDgtn5BiKZRyIc9zRiexv/M2VCiGaoi3tYg3GM/U+OeNZAJisPDygqXruiD
         663om0mK29eIAB9I1O1pab+2/caWzlw5c7SwyBZrKKiWU8zVF4NoVv433qlKe4OAmPIv
         fn2g==
X-Gm-Message-State: AHQUAuZLqSSHn8jR+AaVgHYJ9VVNJRSj/fLGAadmpd1Dxl9pZwfR0A6M
	YsymrjGsv1U4vgpZMKKgE8nZoAXW1TaRaYoL85wh0WHAPZ30MiGlOOVideuN1BUsj9lGaBOwJi+
	KOBbNgjAYD8y/xEP6E2NzEIy6sRSxVyBAfmqsRAeKodIzjr2Clwsmd8w9IZHYh5IUuv2BhwWqbI
	tA48eIzHyYEXEKNFz0qFUK9m7DwS5dn4KjnZ6cb5+LpcngNtMdbQPcTUhZl9SKjq2oUhsigfAI/
	2OYDkJRlJIly163j1NyC1ktoIX16acg4gnIF41txJkGxh0US5OYqih68SydhNAideOBqSYAyBaR
	xsEX1G86+gkNblaOSPgqGN/t/QKFhLwg7LgrIwRJT1KmKtgbBAUiwADhZgtgciQn1MKX/8aKpS6
	/
X-Received: by 2002:a63:1155:: with SMTP id 21mr17307307pgr.96.1551161978501;
        Mon, 25 Feb 2019 22:19:38 -0800 (PST)
X-Received: by 2002:a63:1155:: with SMTP id 21mr17307266pgr.96.1551161977624;
        Mon, 25 Feb 2019 22:19:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551161977; cv=none;
        d=google.com; s=arc-20160816;
        b=t/Cu7vqzEx7b1luFZ1FudeOSpivhYnNJ0nzAqIV2oTJjkYmz27NOJfefHCUknxvbXk
         sgJDjAraUnNBZPt3Upr1h3rOnT2FoCnk2KqzBcoh1Z0E/NhHx/E6qz4xOk76o2XggyH7
         3XqaQ+NUCLy4qhwPHvSPW6hOYPVIkhMlsYNSmuQgKvrG3K97lKZXxZl9/3ndVypdyF7p
         HE75jzuiXFn0z7xka9+b1JTFNBlJXY5DAB61xXCCxojAuT8dOn+JRpXr2X0NBTcOM5SJ
         N6vtc1F3bkNvy9yNAagTIIbmPst11yd4QpVv0tLYVv+iiRwex3HVHfcsV4yr8dqlo0SZ
         e4Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=Cjawy4N96Is7QYxOfWtULwPM5Mp5Omal0QxDOVwHSyw=;
        b=TvT3WYV0V9D3YeQc3xynz9aU95yqXxx7HXdpKhaPaPSIAlfcJ6vCuS4peUFawRgY+r
         VQVYjVI4umgP82ARhHZxTmLmLxfLHOYecqT2CPSKSgjOw4oaJuEMsSYQIh4QvwIbDhYr
         5aS55bUZcllSoI5qyLi9l+u/y+j912LhLIazalyGYy50Yjo5zp1IyrOnNnFU6ND4yZDI
         X/akgy4NEw5LbvaBUZw/95ofJUUzADzcXX9pdjgx/yO508nXpcj5i78Wr/gj77Z/qwis
         qR822qDWQ1qwzAtQY5rj4Wc4NjxasX47Jjq9hSmYts4CULZ53BdoeA8GnYSFLcL/XRhI
         fwLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="C3qFbm/L";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h1sor17129630pgd.35.2019.02.25.22.19.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 22:19:37 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="C3qFbm/L";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=Cjawy4N96Is7QYxOfWtULwPM5Mp5Omal0QxDOVwHSyw=;
        b=C3qFbm/L1t0CD+5KrYBq7SknyNCO7kIpoZxHeeG/2qj6Q9tmAxx8Syr3tKRsuzSntl
         V/f8qXRqM1HIQGMozSGesTfJwiz5i4FLOFtrThGskKYumy1WuayA3GkZzIiUOEvYz/4L
         4WFeVg5EKdCaXis9HURYjbAovPy2BHstjdX7/uZgx45NSAKgh7qWY2jGS3tyNKg/eqSu
         eAENIuhOc5qFKFpFvXFwx4MwyWRc4+6j7BXL42aVv7gz6WUaWIowuWCHJMFWMZkqI8cw
         j3rwqBpLmErPvImd+c1F6Ieg1Ij+VvJ/2iP3Aq9h3BEra3Q0ugDYPxbYdV2bTrXamK+L
         utcA==
X-Google-Smtp-Source: AHgI3IZQhhyeA2A429uyIr3Dd4xAwkKg0hAf7XQJSSM4JfbLTeOcDZX9l/X1Ky9ySHWIqx1etViV2Q==
X-Received: by 2002:a63:1947:: with SMTP id 7mr3010247pgz.279.1551161977266;
        Mon, 25 Feb 2019 22:19:37 -0800 (PST)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id b68sm21509433pfc.128.2019.02.25.22.19.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:19:36 -0800 (PST)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: compaction: remove unnecessary CONFIG_COMPACTION
Date: Tue, 26 Feb 2019 14:19:14 +0800
Message-Id: <1551161954-11025-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The file trace/events/compaction.h is included only when
CONFIG_COMPACTION is defined, so it is unnecessary to use
CONFIG_COMPACTION again in this file.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/compaction.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 6074eff..06fb680 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -132,7 +132,6 @@
 		__entry->sync ? "sync" : "async")
 );
 
-#ifdef CONFIG_COMPACTION
 TRACE_EVENT(mm_compaction_end,
 	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
 		unsigned long free_pfn, unsigned long zone_end, bool sync,
@@ -166,7 +165,6 @@
 		__entry->sync ? "sync" : "async",
 		__print_symbolic(__entry->status, COMPACTION_STATUS))
 );
-#endif
 
 TRACE_EVENT(mm_compaction_try_to_compact_pages,
 
@@ -195,7 +193,6 @@
 		__entry->prio)
 );
 
-#ifdef CONFIG_COMPACTION
 DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 
 	TP_PROTO(struct zone *zone,
@@ -296,7 +293,6 @@
 
 	TP_ARGS(zone, order)
 );
-#endif
 
 TRACE_EVENT(mm_compaction_kcompactd_sleep,
 
-- 
1.8.3.1

