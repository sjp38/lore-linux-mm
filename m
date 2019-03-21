Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AE7BC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA8212175B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA8212175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1969D6B0008; Thu, 21 Mar 2019 16:03:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7A766B0007; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA12C6B000C; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 080136B0007
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v3so6452858pgk.9
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:03:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=+jDHrInzqAkEuroi35KDeQz8ygOnozOul64UgglecQs=;
        b=p2q4hVJCPG27gIBmTUQGvU0hdXzDKDewmAPvcrav+JXWMk1gCx6L9AyU5QbgBDSaCm
         CPJZuEE3xUsswDpCZfb0fjMuP6l/ShHZ6rcF6keUYO1TKpHqwJFKxKecj+37XPZyazrV
         s9DpVJIS65zKPQI8JyycSQLF5eSn/EFt1TPWD0oDKvCbVvS0/YtKq/D+60dxGeIFHrci
         mPb2kZ2Ipq9cm2fBkrPFNSOXHJTpgwqEygbcuUxjEZcFz6ueqUMQMh+Y9v0k2pLUblZM
         PBgeavVv5CshhiBv2/PPdXMnpRKjHy5W97AA7x0DtjiTZy2kcNFdbehwfhgpw9XseK/x
         Gahw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXg2lh2aqYp/V2Q2XwZDL+3JF00ptdg8naOU5/+3M/Htvu8fwkx
	qWjTArJY0rzy1AYX3koHiQTqDS8HB1YIARsU+cjZ9zNcmm1FIwyJs6vHEZNEMktdPW2Djw642GY
	Jy4Ug1WxcKyqsTLSpI9dv/4bZuaWrq2QQaUgpvmxqSo9Gh7+MTNzTU5g82IwkjelIwg==
X-Received: by 2002:a62:1249:: with SMTP id a70mr5181240pfj.160.1553198580640;
        Thu, 21 Mar 2019 13:03:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbduOdmCnUo3PAoxsUYOXWXOclHVugZFMyTW+e2YndqO4EtuI0N642gfwyQlUIdPcVKRB5
X-Received: by 2002:a62:1249:: with SMTP id a70mr5181182pfj.160.1553198579844;
        Thu, 21 Mar 2019 13:02:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553198579; cv=none;
        d=google.com; s=arc-20160816;
        b=lROQEgeN/C/Td0VpFG7iHWDDOyL29F8BHshBy51ULpEX8uOZbPXIKjJe5Zghjoqiwj
         Q4Qzdn0Adf6VxdCrfMhehBNAQcFxFZV9WI9Ui3TF4bBIHz0I0H5stQk2V3r2x6NI60Wl
         I85YM8d+hotshRiDLKed1vdqI8JqWikE0a4G2wz2HRT+Nrl4PAhDWCNRooMhSsatlSvG
         5p3hXjZs1E9rKKgMZj/tfsXFRecVA2dr98xavGlUtjPcs9Dvj2fvgij6WItHO/GGkYEZ
         oWN66AG6/JmtZKQj26rJRf/ZlURp9xLKYMS/+Wa5SFu6L24xFk3SdWJHXTBd8q4w6aPe
         pfmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=+jDHrInzqAkEuroi35KDeQz8ygOnozOul64UgglecQs=;
        b=pi7RT5Itc5tVRikvs0zw0l4MpG9GjgQAlBIreAoky62Ugx+RKbF/f8PygOLZTYD9oS
         2rFv/KhfDWJx9fNBC0HixvczVHZmvLtKR2sc9wnm/5+4T5va8YQExjt+YlnqY3177buW
         zQhLh8422wF6jX1rrHZX1wi9J4e3AnxEGQRBL9W2V6bghrRmAvl65XFWhgIXdErIiQlj
         GM66386duAKUwR0xECOkEjW7Pc1jOvsuwiHzTETHGCWJjtr2ZTxJeF6AhHC6l1elVHSs
         0M35AoiOM+TS2ncfHKA80uMidXyqcV0RBvOpXo12dij3QCKUFfzM8Jpwbg2cGYQRm+yL
         IkXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r25si4703408pfd.91.2019.03.21.13.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:02:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Mar 2019 13:02:59 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,254,1549958400"; 
   d="scan'208";a="309246248"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga005.jf.intel.com with ESMTP; 21 Mar 2019 13:02:58 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCH 5/5] mm/migrate: Add page movement trace event
Date: Thu, 21 Mar 2019 14:01:57 -0600
Message-Id: <20190321200157.29678-6-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190321200157.29678-1-keith.busch@intel.com>
References: <20190321200157.29678-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Trace the source and destination node of a page migration to help debug
memory usage.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 include/trace/events/migrate.h | 26 ++++++++++++++++++++++++++
 mm/migrate.c                   |  1 +
 2 files changed, 27 insertions(+)

diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index d25de0cc8714..3d4b7131e547 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -6,6 +6,7 @@
 #define _TRACE_MIGRATE_H
 
 #include <linux/tracepoint.h>
+#include <trace/events/mmflags.h>
 
 #define MIGRATE_MODE						\
 	EM( MIGRATE_ASYNC,	"MIGRATE_ASYNC")		\
@@ -71,6 +72,31 @@ TRACE_EVENT(mm_migrate_pages,
 		__print_symbolic(__entry->mode, MIGRATE_MODE),
 		__print_symbolic(__entry->reason, MIGRATE_REASON))
 );
+
+TRACE_EVENT(mm_migrate_move_page,
+
+	TP_PROTO(struct page *from, struct page *to, int status),
+
+	TP_ARGS(from, to, status),
+
+	TP_STRUCT__entry(
+		__field(struct page *, from)
+		__field(struct page *, to)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->from = from;
+		__entry->to = to;
+		__entry->status = status;
+	),
+
+	TP_printk("node from=%d to=%d status=%d flags=%s refs=%d",
+		page_to_nid(__entry->from), page_to_nid(__entry->to),
+		__entry->status,
+		show_page_flags(__entry->from->flags & ((1UL << NR_PAGEFLAGS) - 1)),
+		page_ref_count(__entry->from))
+);
 #endif /* _TRACE_MIGRATE_H */
 
 /* This part must be outside protection */
diff --git a/mm/migrate.c b/mm/migrate.c
index 83fad87361bf..d97433da12c0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -997,6 +997,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 			page->mapping = NULL;
 	}
 out:
+	trace_mm_migrate_move_page(page, newpage, rc);
 	return rc;
 }
 
-- 
2.14.4

