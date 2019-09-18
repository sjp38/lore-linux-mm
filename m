Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C67DDC4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:39:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A46E20665
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:39:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X4AGJTsD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A46E20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 280096B02C8; Wed, 18 Sep 2019 10:39:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 230DD6B02CA; Wed, 18 Sep 2019 10:39:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16DE66B02CB; Wed, 18 Sep 2019 10:39:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0202.hostedemail.com [216.40.44.202])
	by kanga.kvack.org (Postfix) with ESMTP id EDE766B02C8
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:39:17 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 98C72824376C
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:39:17 +0000 (UTC)
X-FDA: 75948299154.05.news60_5117c7c3ba924
X-HE-Tag: news60_5117c7c3ba924
X-Filterd-Recvd-Size: 4266
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:39:17 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id b10so51629plr.4
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:39:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=quDi5FFcEHmlmH1e9u/MVGG/WChEumxXk9EifB9fhCs=;
        b=X4AGJTsD51BzXMVwK60Kca2mkVAorXHjtmOlaZmPsf02Km0NHNPnq13zWfat/YHbtE
         MV426iBdoaftcc9CNARoo9dNrKrwcZL4wBWxBcv93uDY1tG18vQdFyTr5wQz5d6/1lq5
         3lQz/3U76yl0m6th7oYYIAGey6OJIu9/koqpHyYGIMnlIFoRXuty8rR1WIYFh0yF+GVB
         AhYxq+YLPDtaaYDt0eYStxC/EKX79V2fKip58qT/VjKFMF7VmJYvOuJXaJWGMI1C854P
         PfMMGrru9f7WlqiI2p3n2RWtbExtuQYTlaSnLnzYyKxhGMvtyzsu/7caN3OpTAvEUyUF
         oYeA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=quDi5FFcEHmlmH1e9u/MVGG/WChEumxXk9EifB9fhCs=;
        b=B9yzyaMzj5byg4dZdYTVU4OY4O8jG6eS8hmukICF1UD36da0eET0kbpJyfZ+JcY1Nt
         YPiG1yC/bYAvd9u6YSFKtufSfmlMHm58F1cN8wfzM9Fj5q7filE2IiyMjPS2l0cxRrbP
         EkwVsKWuz8x+QgEA7Z3QdETPOsxMID+PzgZF1/+XeS3RwN25zexnlUBymDyG6a33sMVr
         eWQwHwZhpPxkjZsUf4qMizobFckbTAs/S+y5h6IyX7UOYR/Qg8mMR09CfQR8kKzj+oHR
         q2lZlRN87KkQdkphzNXXpoKK+u0HCCZfeH9LWbYuIiVc0/OsDCG527I/iRaXg12BBzCG
         Dhxw==
X-Gm-Message-State: APjAAAW26oRjHJ2sL/O76kUyBVUJOJgHz05Fefr8kN1Q2CsG6K3kHxM2
	WVLbEz8afmZ7CaxKG5jsWTM=
X-Google-Smtp-Source: APXvYqzMwzc7yuyYjnb76QPE6ltH+wKNbQpk+wmIggNsOZEqgDsGe2eSrc7MLGYNJSazFP7gPANnIg==
X-Received: by 2002:a17:902:7c13:: with SMTP id x19mr4662626pll.322.1568817556152;
        Wed, 18 Sep 2019 07:39:16 -0700 (PDT)
Received: from dev.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id l11sm5272197pgq.58.2019.09.18.07.39.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 07:39:15 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: peterz@infradead.org,
	mingo@redhat.com,
	acme@kernel.org,
	jolsa@redhat.com,
	namhyung@kernel.org,
	akpm@linux-foundation.org
Cc: tonyj@suse.com,
	florian.schmidt@nutanix.com,
	daniel.m.jordan@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH 2/2] tracing, vmscan: add comments for perf script page-reclaim
Date: Wed, 18 Sep 2019 10:38:42 -0400
Message-Id: <1568817522-8754-3-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1568817522-8754-1-git-send-email-laoar.shao@gmail.com>
References: <1568817522-8754-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently there's no easy way to make perf scripts in sync with
tracepoints. One possible way is to run perf's tests regularly, another way
is once we changes the definitions of tracepoints we must keep in mind that
the perf scripts which are using these tracepoints must be changed as well.
So I add this comment for the new introduced page-reclaim script as a
reminder.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/vmscan.h | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a5ab297..f0447ad 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -1,4 +1,17 @@
-/* SPDX-License-Identifier: GPL-2.0 */
+/* SPDX-License-Identifier: GPL-2.0
+ *
+ * Bellow tracepoints are used by perf script page-reclaim:
+ *	mm_vmscan_direct_reclaim_begin
+ *	mm_vmscan_direct_reclaim_end
+ *	mm_vmscan_kswapd_wake
+ *	mm_vmscan_kswapd_sleep
+ *	mm_vmscan_wakeup_kswapd
+ *	mm_vmscan_lru_shrink_inactive
+ *	mm_vmscan_writepage
+ * We must keep the definitions of these tracepoints in sync with the perf
+ * script page-reclaim.
+ */
+
 #undef TRACE_SYSTEM
 #define TRACE_SYSTEM vmscan
 
-- 
1.8.3.1


