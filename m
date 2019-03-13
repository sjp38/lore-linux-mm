Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CAAAC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:06:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA79421019
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:06:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="kVz4Ty34"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA79421019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A9968E0004; Wed, 13 Mar 2019 14:06:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 857D38E0001; Wed, 13 Mar 2019 14:06:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7470A8E0004; Wed, 13 Mar 2019 14:06:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6238E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:06:46 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k5so2735212qte.0
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:06:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=WKEbSNObSyJ0eVcku+AA9Y4x0Cyfh20haiejK86KEDE=;
        b=bUZX32U39o5MbaYfTeqd2Iahbzzm79VXtpdWrfFosh+LZo/u17W1KVqt+hQ8x99d8N
         aaOEUE34bbqvtOwCR8xLfJhFNi4lBqJuUTDwCF/+RuC2XYa2deOX9mTpkAtQxeU5ViMi
         8HPdm/gOeuhRqFU1P+/dee+IGgwp8ABuBNo1RX0PdVI3SjMCeu5geqDKMpFeCvQ33fJQ
         Dncp5IuG91TTSIL285PLBCz3bYcIY60MVYfJ8G79PtM/2sIBoy4Tg59ohH/1vPmfdJY6
         jXaov9nf2TQ5ag43buToE105v/Kv0RDxYlK88bH8TY4u+RdII6EegrGStU/ByMu5ml3g
         WaRg==
X-Gm-Message-State: APjAAAUfMdagWzCW8OUrwIjwtsfKYnZCUWUvlgzUcKfFY7XD8wYj1c6c
	YOOCHqlQyzjvBjbHeg8BOLRxUWE1HNtCyrCtm/jFFUh7MohhOvzOohgmUAymSxq/pNq2KTQjk3/
	FVdX+k0ulu+5IN2JOoseFbfxz5aRhImLZ0AQ22Utn20p6NbeDdjhHyGgYkLjZfgfutY5QhvICSU
	9ln6wyxWtwA7JbkdfVRrj/wLtQJm0T2d8kckgWOfQ7Wo0DaEuf8RKusUNq0BwVbjZQJBSDtecu/
	TfZ8qQ6n9v6ic/gLjC+nY+xUyqGRiIQJ/L7FriCzi3PviITP2AJVGoLBmj1395XRTRUmaSEW83l
	GN44Y2YhHAZWjE2MyTtqBbH6gIPTFWFRZUs2d0tsLk1ZqJFno6hPIjc/kpPtiRjpIDnKnf9NAkX
	p
X-Received: by 2002:a0c:b785:: with SMTP id l5mr35544637qve.225.1552500405998;
        Wed, 13 Mar 2019 11:06:45 -0700 (PDT)
X-Received: by 2002:a0c:b785:: with SMTP id l5mr35544561qve.225.1552500405045;
        Wed, 13 Mar 2019 11:06:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552500405; cv=none;
        d=google.com; s=arc-20160816;
        b=lzDkEptwnRmsV3zysnLBCnFbI3pi49kYZ4Ls/GfOuzdCoNha2wfDUmxxwOHmtE4ZRq
         KUGdsWhjlL7ACJlevCNcnE4YVVAoX6+pGzbwZ0qHcw+OfaGvDFrO2JLKvDQfECtFcnKq
         Pu+zo6UV4KNFt0Y69Pwa/pi4qL0+u6IXM5hS3bb7Oh5hIWE558/Vj9bAQnKCO8EFKTpF
         aHdZZePXCTnp1GWN9+WlveAvvhrkw7tvyHA2A3TF6PANoe9nugOmaDLe1rgzn22MaYZI
         s/SUNCG7s2iTWDvaF7sjR1zZ3IQ6oxxjdoYnnYl8vIfiyi32qKIjU53FY6dkPaYaOynU
         YqUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=WKEbSNObSyJ0eVcku+AA9Y4x0Cyfh20haiejK86KEDE=;
        b=axl1VcgXyrY13aV+izY9hMPe8c2WUpUvwoiTX1jNl/wqioVYbcTOtKyd0QPwAaVu2A
         onnl4dl/FLIGJa4b/rWihwwYu6HizQoCnDbRRBLr7C/nzLA+6p6TKltRBptON2H0xi6D
         1fovACKGQGnY/jS2x+7cWjhXXiCxJcPR/scQ0HjixoIvQGUXKftrWJPj/JLCT+6fAyd8
         DRDR6cAmvY7iHGIu+I7X4kKMWmd0IbNS6ZvT5Z7CYPsCdhkuesSStUNfK2fx6YX+3OPE
         NTzbavLljpX4jXypdAP9EQP/Z8EgO+W4Tfg5QnupvQY6OL39QaLIWxuy0i6J7++zcib2
         sKcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=kVz4Ty34;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y19sor6758890qki.92.2019.03.13.11.06.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 11:06:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=kVz4Ty34;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=WKEbSNObSyJ0eVcku+AA9Y4x0Cyfh20haiejK86KEDE=;
        b=kVz4Ty34FFrT8TEAFM7VD0XKFSo0HuQnisSzWEtLt6G1bfUA28YUHcbOmpskNEvQ1x
         wblA5PRMy0lj1OslEop4e64zR9EUCQ1O8LJRVXrIQu0B5PqHp9+9JLtKYsr4I39DLlrv
         Ol3p3u/tuoTOWptnXiZ76MOGouXR8RCiG5WX29vmZriPndVfFxt5Scledi/EnMVhpkxS
         awpxGE97HXR+B7Bb5vEyMWiqhY1f6xaFvoaPh29mT8qyy5sKwRpCbtFJ6F8ta7DW2W7q
         t1LrDdyLL/uFDC198a/R1X2F7sGGbjc4pWbH3R13vE31IElIeONwtwISI2lQE0nQtHNy
         A9MA==
X-Google-Smtp-Source: APXvYqxsM9B99gVY4PtfaQMbrsc3613hCE9cUFX3iItJClNNTE+Fr5Uh52mLFQgE3jR0K6wmJkjztQ==
X-Received: by 2002:a05:620a:16c5:: with SMTP id a5mr9943313qkn.200.1552500404794;
        Wed, 13 Mar 2019 11:06:44 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id y2sm10665535qty.63.2019.03.13.11.06.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 11:06:44 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [RESEND PATCH] mm/compaction: fix an undefined behaviour
Date: Wed, 13 Mar 2019 14:06:16 -0400
Message-Id: <20190313180616.47908-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In a low-memory situation, cc->fast_search_fail can keep increasing as
it is unable to find an available page to isolate in
fast_isolate_freepages(). As the result, it could trigger an error
below, so just compare with the maximum bits can be shifted first.

UBSAN: Undefined behaviour in mm/compaction.c:1160:30
shift exponent 64 is too large for 64-bit type 'unsigned long'
CPU: 131 PID: 1308 Comm: kcompactd1 Kdump: loaded Tainted: G
W    L    5.0.0+ #17
Call trace:
 dump_backtrace+0x0/0x450
 show_stack+0x20/0x2c
 dump_stack+0xc8/0x14c
 __ubsan_handle_shift_out_of_bounds+0x7e8/0x8c4
 compaction_alloc+0x2344/0x2484
 unmap_and_move+0xdc/0x1dbc
 migrate_pages+0x274/0x1310
 compact_zone+0x26ec/0x43bc
 kcompactd+0x15b8/0x1a24
 kthread+0x374/0x390
 ret_from_fork+0x10/0x18

Fixes: 70b44595eafe ("mm, compaction: use free lists to quickly locate a migration source")
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Qian Cai <cai@lca.pw>
---

Resend because Andrew's email was bounced back at some point.

 mm/compaction.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index f171a83707ce..6aebf1eb8d98 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1157,7 +1157,9 @@ static bool suitable_migration_target(struct compact_control *cc,
 static inline unsigned int
 freelist_scan_limit(struct compact_control *cc)
 {
-	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
+	return (COMPACT_CLUSTER_MAX >>
+		min((unsigned short)(BITS_PER_LONG - 1), cc->fast_search_fail))
+		+ 1;
 }
 
 /*
-- 
2.17.2 (Apple Git-113)

