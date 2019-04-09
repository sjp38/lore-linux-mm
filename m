Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBDCFC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:01:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 597652084F
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:01:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="c3RBLKxg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 597652084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA52C6B0008; Tue,  9 Apr 2019 09:01:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B53F36B000D; Tue,  9 Apr 2019 09:01:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A467A6B000E; Tue,  9 Apr 2019 09:01:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 394C26B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:01:28 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id c21so4684714lji.18
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:01:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=QNJxg5ExNJ6bFzaVN3amxQmlqui1fp3QtzeKauuH4OE=;
        b=N09u7l/5lIJTjXmEuRPjN8zQd64UZk3CnJOOReVDmUk2REWEEkwy6YBLdg1b4O7pkM
         v9tk+UFsbSzLvApKH3GjF+2H087PGDgV0K7wKF8F0j1zM9p2PuTAtZ2QskcnTeXZUkrF
         PCpASASXBDHlcNEmp5a1xLjl2g5K3CqSLtae367gHlVVq85bhopr69dQT6dMwR4/XD7t
         OrayNwDhF4omlk5q7Yz8eAJRNiGogdsPz8MiBKjziL8ixRSK79PDrUCzFryblCu6+BQ0
         fo4h7lKYBKVEfJS6OYNPoeJorfXNMLWfTyTIWkTmt8v7vmtdUiKaoWgRai4Yl/4ZsIrF
         LzJw==
X-Gm-Message-State: APjAAAXTblonG67lv0CHbgXU8FvC4PSpEOGCiWwTvg315XLem6+ha5m2
	YATN9K30asOYRYt3rfiNVJ3TKYLucCN5C027H7FHacOsFNJoC7Ylkl4WRDI55nit02k7M5KfpsB
	XOy+b+DMSJtdNxOgj4NBxwD6WFjhoqQsdWLiUlKg17NHKQwJ8MrMFpS+V+/MBAkOMYA==
X-Received: by 2002:a2e:22c4:: with SMTP id i187mr19119450lji.94.1554814887412;
        Tue, 09 Apr 2019 06:01:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuQfhQ7H0VG5voA/67P71aCSTCaSJriai6Vw/C/FXy403zHkngWpPIrcnLibOe0XY6HdI/
X-Received: by 2002:a2e:22c4:: with SMTP id i187mr19119382lji.94.1554814886247;
        Tue, 09 Apr 2019 06:01:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554814886; cv=none;
        d=google.com; s=arc-20160816;
        b=W4XBSpVD6xyjrPKimxBF4xQdrQQMJPt/z2FYnnv9cGXI4au9CcKEhFwQsP4QR4AwW0
         M3E07hELGBg0+OXbdMxi7ogkX2q3BtyhkWSdyqgT/N5kxsahfUmfaS2k/zQXo7/qRA1q
         9H6teGr2ia6FWlIM63bbO1nt6FFo0Aaa34NIHjqW7L37GkCAYNAKm5RGzLzNjKJwhEEk
         F4XG2EFb2rc0PGym8gnWQnJHo5cmm5vjPTbFAVVOPNqgW9eMjIN5GooNhqFwRgFkQs6z
         jSnDqNuvh0R7ssxZk9QCqqcAsfOJp8QI65LcXBAg7+O7Ye5aFGOve1Fx1ROHIxskAGlN
         yaTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=QNJxg5ExNJ6bFzaVN3amxQmlqui1fp3QtzeKauuH4OE=;
        b=eBfrcx5yC+huDn2iahE2TE27vpqOM4FD8vT0AnU2suMazDKcMDaZ5xX/o8o7sykiDd
         8udsLKjxrm/EebNrIKCgEzCufqo3/+SyHGaunBBImekL6WCO8Z9W2gBVSA2eqoGUGnne
         pcZr7Yv75n76ARHGF7GAqSSnDm7r/5K/9r0N3ZgvkLWMhht1gNdy5yL9tO1Ti0CUDRdg
         o20K+FJhwbtEVuEZhq6Aw7lME2FsxsKZg7qHBF5Y0EwZ5HSKBvdEAGc5+hcSuitKaKTn
         2ky1Q+MtpiBn3+d15GQyu0yvHlorSTbu3206VIBaDbcbpqQqnZteNThCBQP3KAUB9Bu7
         x/lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=c3RBLKxg;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTP id b9si26528264lji.213.2019.04.09.06.01.26
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 06:01:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=c3RBLKxg;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id C891E2E14F9;
	Tue,  9 Apr 2019 16:01:25 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id 7a8Rsk49OT-1PeORcnc;
	Tue, 09 Apr 2019 16:01:25 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554814885; bh=QNJxg5ExNJ6bFzaVN3amxQmlqui1fp3QtzeKauuH4OE=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=c3RBLKxgg6odcBewDveWr9wGVAyT5Go0jzwAmnYQ/OYLui+I7j3QN4kxE4m3hwfk2
	 mjmXxCWFbnoRe6MOBCRZvwwhs3xf5G7FZpNvW7jCxr5GFH1zS7RwhPURJvzRUnrSCN
	 0sIOkHKsr9odKr5P1o7FYMdp9tYMJbG31hQLqgMw=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-vpn.dhcp.yndx.net (dynamic-vpn.dhcp.yndx.net [2a02:6b8:0:3711::1:6d])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id Z1ZqwzxHC4-1P0mS5oG;
	Tue, 09 Apr 2019 16:01:25 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH] mm/vmstat: fix /proc/vmstat format for
 CONFIG_DEBUG_TLBFLUSH=y CONFIG_SMP=n
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>,
 Jann Horn <jannh@google.com>
Date: Tue, 09 Apr 2019 16:01:24 +0300
Message-ID: <155481488468.467.4295519102880913454.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
depends on skipping vmstat entries with empty name introduced in commit
7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
but reverted in commit b29940c1abd7 ("mm: rename and change semantics of
nr_indirectly_reclaimable_bytes").

So, skipping no longer works and /proc/vmstat has misformatted lines " 0".
This patch simply shows debug counters "nr_tlb_remote_*" for UP.

Fixes: 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/vmstat.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 36b56f858f0f..a7d493366a65 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1274,13 +1274,8 @@ const char * const vmstat_text[] = {
 #endif
 #endif /* CONFIG_MEMORY_BALLOON */
 #ifdef CONFIG_DEBUG_TLBFLUSH
-#ifdef CONFIG_SMP
 	"nr_tlb_remote_flush",
 	"nr_tlb_remote_flush_received",
-#else
-	"", /* nr_tlb_remote_flush */
-	"", /* nr_tlb_remote_flush_received */
-#endif /* CONFIG_SMP */
 	"nr_tlb_local_flush_all",
 	"nr_tlb_local_flush_one",
 #endif /* CONFIG_DEBUG_TLBFLUSH */

