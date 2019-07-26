Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43A7DC76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 02:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC0CE22C7D
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 02:34:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oKcEphqr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC0CE22C7D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 738D26B0007; Thu, 25 Jul 2019 22:34:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C07C8E0003; Thu, 25 Jul 2019 22:34:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B04E8E0002; Thu, 25 Jul 2019 22:34:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25C226B0007
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:34:58 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 8so26649553pgl.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 19:34:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kQxMbqrsX/nZiD0N6XPZDIM95WzOo92zapucPy1vlUg=;
        b=q4ojxIxO6OIutrVgOQVXraEzRKiDZFOVrL+ENbJ+vCvg1MByvupX6HP55F7n2+1/gS
         iXuPnELY2Ie5h4gVl5STclzjNmw89XycfKk5rI4ZpJv4cSm6hHremuHgYCwpjnj4dzU1
         RsuJmJxvROeGETyv+HYj4crecASheK9tAUWiycCUF7ezwJzzkgxG88Pw6ojoRtKoDzXI
         yhbgYgyDwpVHL+lWKRb7N3HBldNzrjbiXmYnCSpOs/kkI9+RPnckraloq86UCTAS2Jlx
         zUdzd1P0D68HZTnRn5GjRQdIIAvibJX1N7dHQnEs4NcsLrzA9saPxPLBV8/HfOk6c4es
         rHpA==
X-Gm-Message-State: APjAAAXKjLL99V7mvj4Q4BHEZ/EOnfgYfbhQpWQSvOfTE/TuZSQW0/Yt
	CppnJwAtY4kBEXqfnLR6Ut/I9K6vkWFqG9zSFSGu1G8SF+Nj22QwvzOR6vAayPAy4RU93fiksHy
	JcjGpzLtuusEMvNQfTG6ekUnGStV/T/UZ4ju9VKCZvOTi7m9VVwTbKlnq1meh5RE=
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr55799942pjw.85.1564108497818;
        Thu, 25 Jul 2019 19:34:57 -0700 (PDT)
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr55799912pjw.85.1564108497112;
        Thu, 25 Jul 2019 19:34:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564108497; cv=none;
        d=google.com; s=arc-20160816;
        b=QTjHcWF55NqwkMEK4S/r1Mrz08OH9DFvwO2gk6r047jLG5u8rGCXH4QfGKDl83GOTl
         ejUwes3VN2Pht9x8x56cNH3cvlwvvBDZ3etcaxJZyY4LLqY4rPBLNcJXDJCkcVCbhqpd
         gYWS4sULENK2rtS26G3q/GGPPIIrzityhTpkTrlZPy+8YwFQpVWSUgoWJUg0Az/T3sFI
         bXuO34b5J4uX6lmkwbLUwDKe3rSYn2Y86F4ZnSOnu8ZIjKk5oei/3v3v1LQ0AUiphhCv
         SNPOsLMGEZ6byK97WR+fgqj5JHLQdBtaArRAonxiI34FC98b7pFp5s05mx4VI4h4Y1wb
         8uoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=kQxMbqrsX/nZiD0N6XPZDIM95WzOo92zapucPy1vlUg=;
        b=ecM6QyWZYm/Wn1O4nQkXfJPhvfjhEnOmFwFYpSRPnulXS43Ito8ijq/7TPyArrQMDJ
         oNc1HS/UoplL8TTazMBkEnS1CmcC1/ifI36bFFsmisrpZwleZD3XlZDQUCvh3pmkhoP2
         dAvBT8pTok9TBQO022A0c52w0CN2FYOwA/bilQwpziIQ9YDijGpqDE9gCAyp/J/KbvXG
         CCBHiSMSB1+gYbrBbQre8/cAbI6FNOOPe/3gNEUV16s2I/ihXgZPaF7tDfR4vZhUHsaC
         npwnAufnIurnacolOBjLVazIBojtEh4l3oBbvfV2/48XmSEBcVMQS8+LAiX/zUVFborq
         ESgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oKcEphqr;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 142sor30519756pge.7.2019.07.25.19.34.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 19:34:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oKcEphqr;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kQxMbqrsX/nZiD0N6XPZDIM95WzOo92zapucPy1vlUg=;
        b=oKcEphqrcIJTXgzvD1uIGdr1uqZO2gHbJqUCYNEjScVnAblxZ7V2fe3YaOhp91mxei
         HMBTDS5xNe4zP8el69NOJvVwqVrbeZ4vhgV39daqg1CBlxo1/Y0l1fJlXb2u0POuHO+G
         +fR8O/S29Hirw56Er6PMRq7F+Vh3GI18riHLeQYpDi6lRimdRcOAePdbgZFqMWzIeJRZ
         wfLljhwWF8vsCNEVuFI9iu9LiKanPYdZ0cOZ7vhxfgQ7CnngyxpbiaKc8mM2UEo7piE/
         CEtQMq6PjMVOCWeKRpdJPWERXx4gZj0BLLz1IUhQV2CVQ7ZIL+/i8gkgUlPDYMRdHKHm
         a5+g==
X-Google-Smtp-Source: APXvYqwCBy1Zc5tBK+qCsIuV/IuM/t64Rz0ADnQpNhj+o/kGXbRTjM5yaRilbKPxid2BEuggsNOknw==
X-Received: by 2002:a63:3805:: with SMTP id f5mr55887841pga.272.1564108496625;
        Thu, 25 Jul 2019 19:34:56 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id l31sm88958450pgm.63.2019.07.25.19.34.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 19:34:55 -0700 (PDT)
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
Subject: [PATCH v7 2/5] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Fri, 26 Jul 2019 11:34:32 +0900
Message-Id: <20190726023435.214162-3-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
In-Reply-To: <20190726023435.214162-1-minchan@kernel.org>
References: <20190726023435.214162-1-minchan@kernel.org>
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
index 82e1e229eef21..436577236dd3e 100644
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
2.22.0.709.g102302147b-goog

