Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 496B2C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:26:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 038332238C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:26:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uuhLoA0B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 038332238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74B956B000A; Tue, 23 Jul 2019 02:26:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FF448E0003; Tue, 23 Jul 2019 02:26:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 529788E0001; Tue, 23 Jul 2019 02:26:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 141B36B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:26:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x10so25511827pfa.23
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:26:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bnIASPZxrrGOWF/G5OfEZ1yV57NTr/ruSeiXKsRM3nk=;
        b=VTRvdm0gy/I8WmRLo9wO4E57HzGM+/1cF1XEcEs89Tu/5MdbIKtvnzF+XO2E+66L5K
         MfZ6TSCnZUhroKUiNaXTzCRd2na8E2617giurOawnfSfTqIwpFXU7nUaJ566D/Q/VWcA
         KlGOf7vpsHyDLsXTeobvZ7QTI5Qvnn7GYKpcF4JBQU8PA+CwUghvYhiP3m0ZKoXHhr0E
         M7NIVEGBEsf3ynTREtj6m79YmKz9fxJh8mcgCQ+8M4AXPVY/utl8LIQYevwFIPqZ2nOj
         2LaUgJ6RddbePJm5qCnNHRo7lhR10aWC7pmZEnm5nA1tc0DX3EDVPAMORCWH3J0ODUqb
         cjCA==
X-Gm-Message-State: APjAAAW99+83OM3YgdvjMT7lOmz6jye2AcG1mD0qTKVQfhqW6tOoKUgv
	C1gA69i9Y+dGHskDgpstfuRQeTBNJwOWE3BkNjXoXUogISD/1m84JH5/DscRJNsmLlbrhE/RoUH
	b1ryDJRzvH+Qm/T+BwVst18ZwwBRDULE6VNqVABDHHpR7UlFMn76HKcpI70DeA7w=
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr81742463pje.130.1563863160751;
        Mon, 22 Jul 2019 23:26:00 -0700 (PDT)
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr81742423pje.130.1563863159985;
        Mon, 22 Jul 2019 23:25:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563863159; cv=none;
        d=google.com; s=arc-20160816;
        b=Uic0uNxrEhx2+trq4RGv4yJPHlDcjsazUUDfhzZI/n8Gjv72s5CfeCfVpiXqbZFn4c
         Fq4uSfphLaPJFJTzawKkMDTO7aXGcWp3zI15G3EaD1XEXWpsMkMDgai9pcspJ8pFJau4
         ZdT9v5E1YszN4eYtgy2xdePhqv0Chp660qJbQiF4Js4gHMMJm/QxjtP3PO2aSFqrhNMR
         QL2IBtDY1WQT8rm8IXnCTOLaIn0juTd7DAFmp6mQJNx+vkyLMnAQUAj3CfY47wc72MaX
         QN8VGanbsGsCi89sE/1+cOZF+KBIp2NjQLlmQw5wbr/TPeJjySHtenM9T0vjtqOCGZaQ
         cGmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=bnIASPZxrrGOWF/G5OfEZ1yV57NTr/ruSeiXKsRM3nk=;
        b=mC800lAmd4nFY5iJueuxDZxuX/oJjWzAwFnZTmLx1KuvUWExfZcmY5ldzV09VxNC+P
         WB65+7sxrmwY3FK/+nPbQ5iST0z45xl4b1hmJ8WqSU9XmmDrqqdmxT8xIZfxeaEWoAPE
         J1uYF0OqwrUYHuukfRUZP+JBeTXaenDqtvhha89XecBUJlbPNHehfJynU6A1asao/Uoq
         byg3lihcpoMfubqf74pbSJhqj7oSHBBtjf3VDzEYGuVEqaUh9/DLI8TZPJ/78rLaOByw
         elsw6S2SUh2n2mTEGc7VXdEOP24stLSsmbO6HzXuO5dp2+btXMpqq5wBK3IMd+P/sg5N
         yYcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uuhLoA0B;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m39sor50663953plg.49.2019.07.22.23.25.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 23:25:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uuhLoA0B;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bnIASPZxrrGOWF/G5OfEZ1yV57NTr/ruSeiXKsRM3nk=;
        b=uuhLoA0BBoERKypNBgrn/ZlmpMF92srWO/6MUGEN3xX1GzOTomN23OaW/P/sopLIED
         2Xzsuj6Co6dKvk0D5MbrA8TfP4zStCUOHX6h5EBFSgLyStisdYhYvIEJEqB78ObpfvQx
         CIGiXaI8bQsfzUcHQORkIa8aacyWCE9dLGwtRaXBrzmU5hzTk6jGGgYCl9PXzw3/0bkL
         xe3svs11oSO6Hq0wAytjsddI9jOX0atWt4ZiE7429kLMyXjLHClGvJP6kuBdw9t/NZ/n
         Pj8j5fZXo7JbPhPs7ets5aP15dM9d29pdU+nhxzKURWL9WBl7Y2iQjcanm0fOfDBvhjW
         LBnw==
X-Google-Smtp-Source: APXvYqyOx95R0nQcXqx5AoqfhCHYUJ6uEq79frQnW+ZOvXT1NvMLzarqUl004ZEy3UbXm7PLzVCYcQ==
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr77632984plb.26.1563863159650;
        Mon, 22 Jul 2019 23:25:59 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s66sm44630376pfs.8.2019.07.22.23.25.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 23:25:58 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 2/5] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Tue, 23 Jul 2019 15:25:36 +0900
Message-Id: <20190723062539.198697-3-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.657.g960e92d24f-goog
In-Reply-To: <20190723062539.198697-1-minchan@kernel.org>
References: <20190723062539.198697-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
as default. It is for preventing to reclaim dirty pages when CMA try to
migrate pages. Strictly speaking, we don't need it because CMA didn't allow
to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.

Moreover, it has a problem to prevent anonymous pages's swap out even
though force_reclaim = true in shrink_page_list on upcoming patch.
So this patch makes references's default value to PAGEREF_RECLAIM and
rename force_reclaim with ignore_references to make it more clear.

This is a preparatory work for next patch.

* RFCv1
 * use ignore_referecnes as parameter name - hannes

Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f4fd02ae233ef..f68449ce0c44c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1124,7 +1124,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      struct reclaim_stat *stat,
-				      bool force_reclaim)
+				      bool ignore_references)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -1138,7 +1138,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 		bool dirty, writeback;
 		unsigned int nr_pages;
 
@@ -1269,7 +1269,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
+		if (!ignore_references)
 			references = page_check_references(page, sc);
 
 		switch (references) {
-- 
2.22.0.657.g960e92d24f-goog

