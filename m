Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94BFCC04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 05:37:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E4E427B92
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 05:37:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sPcwms7L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E4E427B92
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0E7A6B026C; Mon,  3 Jun 2019 01:37:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBFE56B026D; Mon,  3 Jun 2019 01:37:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAEBB6B026E; Mon,  3 Jun 2019 01:37:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96ABC6B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 01:37:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r4so12796603pfh.16
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 22:37:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AspJoK2TnbwgjAatSkGxez0VLRm0DAxlcRNfqD2t6lc=;
        b=TNVf36kU4Z+FyaPEl6uyRS+Kn+ig+VWQOB05/dT7/l7d3e2m4hNMUTTf0ad57zHDPO
         sUdDttauQpCMO0YeFKJu6CBrPrPGj5rWnCw0hjHjkluxmlydl0CNAPPkr2vaNHcTPqGM
         0AXFUf4IsvcFY2dDrhfkmbv0yvCusox4JUUXj1UzZryBjkmPRlHFMc1CVmagZNsqDIT/
         4+44+4WeMoQZ/V03QdU7kQ/l39g68tTLwi478uNzIEJ4n+VZ6r0ZpRKjyyNHrvpQ/hQv
         /yg3gE1ZsVW0SHSuwFaCt+dKetDodnrtYvcYCjI3iRePfPvM9JKIif6ylL36FIsrL9SI
         pfew==
X-Gm-Message-State: APjAAAXQf6NGRQVn0kVS3Xx1AfebaMyIbcHneTl5X/w5jWx3vUzLrzzv
	QVGE5sBECfa3KvuIlI/9Oce0GZKDMulYZppbIHUKjMcrI0FDBNJVOYO7G3KEokNMjq1oav+sLJd
	e+CmzH81Q5AShC6anY2SIca6QtKTtyXHzWQYkX2rRvZBXqfBQqKj7ulmWnfGmokA=
X-Received: by 2002:aa7:83d4:: with SMTP id j20mr29711611pfn.90.1559540241073;
        Sun, 02 Jun 2019 22:37:21 -0700 (PDT)
X-Received: by 2002:aa7:83d4:: with SMTP id j20mr29711556pfn.90.1559540240147;
        Sun, 02 Jun 2019 22:37:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559540240; cv=none;
        d=google.com; s=arc-20160816;
        b=g9rmpHd3wmmIRVkMl1bxCg53js1pzDVAgJDohGiHfpLwPekbXJClYSXmXjj36UL9mn
         nTKG4Absj5E9HhaNXII8dBzgNVeHr8/fAdEN4J/sPcGXsNdmAJ2p3z9497mDAlXnGVXX
         4e3i8C3tGEKdADNbjOF6er1FS+I7Ao7mNtzPsbiu0/+POhTfUzfuOQkmzBwgisR+/k91
         b6mJ2ExRqgBnf3T1NwO1N7zTp9kyAdnuVdQYljSOCL/2b0OJiiBcffcKr9npSQvp10Sq
         dDZJnCtSo22HZ8tjiH8nPM3RGKk3a9HhKVZnhHcJije+IvyCXZGCyIhVWbHe0bZxAGWl
         TNtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=AspJoK2TnbwgjAatSkGxez0VLRm0DAxlcRNfqD2t6lc=;
        b=uE8jpWXIf7MMzdrdIspjg+OOFF8netNN5Cgiq0QicwRhNW32cfpI2nLjzGqZPVHSii
         1dnvrtkPgdXRrKsUaRnHrzQnB+v1u9C05TAw0Mq2M9v4saczk4TStgHbQ8vDFuodW+yi
         yob2KRKvYZ8TtDaqT5bxVKhCD8SErIncAxOzOuONaUspQx9FFPhVsZJvyMAcQAhDYD3T
         lHSdKRtqTWPlg/87EkgdgDXZoYgSg+IsRvs4VN4dzF2mjIbvWHDeE/mk8Umi/9TxCmwB
         DNPIjmAym0vkCU05ikSe+mWQ0i7UoyuRUt+EiY9UvTjr9bMeSTNMkd84NWJJ7z8pJIQF
         3t5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sPcwms7L;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 194sor14004351pgc.19.2019.06.02.22.37.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 22:37:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sPcwms7L;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AspJoK2TnbwgjAatSkGxez0VLRm0DAxlcRNfqD2t6lc=;
        b=sPcwms7LYj4OL0DvDW4nBr5ZoY9hI81X1IP/z3cTp0vq+ISknRS5WqE6Zw8bwdF1Sg
         yvbs53EAb/7oq1V6nr51+aJkcyrxHNvFmHHLSNvUb6ZOgkOKpazX8IPcwl1VbQuR1hd8
         Qpn/AscGh273pm+aEcqMzd3eQ64p3IcnT2e5OFQsccb3pMmblaCx37gA1Uk2W6gmH174
         J36Nb/oBVslBf/K7IHRDzps+IdfImuzteUG++SbBm9HjFenHj/eh3aqLpTn6pVfugtYk
         HoPaCxRCQ8aicl8uWFhoOKf49ggJZvYN/PKYwPokllmdUqk2vB0MaRcq8x+dRrxtN00s
         hG/w==
X-Google-Smtp-Source: APXvYqz0WzWbOPH7SHnTOp8MB+cFakTtiCbidmfpKSiMxWd9qnxaF17/qkGfGsSNuehNI7zsyP+OdA==
X-Received: by 2002:a63:788a:: with SMTP id t132mr26741639pgc.52.1559540239802;
        Sun, 02 Jun 2019 22:37:19 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a18sm5986222pjq.0.2019.06.02.22.37.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 22:37:18 -0700 (PDT)
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
	Brian Geffon <bgeffon@google.com>,
	jannh@google.com,
	oleg@redhat.com,
	christian@brauner.io,
	oleksandr@redhat.com,
	hdanton@sina.com,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 2/4] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Mon,  3 Jun 2019 14:36:53 +0900
Message-Id: <20190603053655.127730-3-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
In-Reply-To: <20190603053655.127730-1-minchan@kernel.org>
References: <20190603053655.127730-1-minchan@kernel.org>
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84dcb651d05c..0973a46a0472 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1102,7 +1102,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      struct reclaim_stat *stat,
-				      bool force_reclaim)
+				      bool ignore_references)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -1116,7 +1116,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 		bool dirty, writeback;
 		unsigned int nr_pages;
 
@@ -1247,7 +1247,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
+		if (!ignore_references)
 			references = page_check_references(page, sc);
 
 		switch (references) {
-- 
2.22.0.rc1.311.g5d7573a151-goog

