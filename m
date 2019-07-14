Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0F8EC74A44
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:34:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6552F216F4
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:34:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WfvIdRNO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6552F216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F16B66B0008; Sun, 14 Jul 2019 19:34:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EED746B000A; Sun, 14 Jul 2019 19:34:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDCFF6B000C; Sun, 14 Jul 2019 19:34:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A922A6B0008
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:34:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id c31so8683468pgb.20
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 16:34:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dXmXb4hHePla+El29aWi3bvhcbCN7txGRytZMqhI7AI=;
        b=fyfU8AtkCvo1BUpGqFJH03FgMpHkNv3USh91EZGkVnkKrSwEuC38Unarbl2ykWhmNm
         4U3W9nlN4vh9c4RgGXi3CGm+VMoF4cEudyINkT8lQVikeU6M9ymR/pz4F2gaNF3Hs1gH
         fK9aRHwQIYZFDnB3yOOQBqZTIxXOZ/zqAzaZgvCiQpfwJTQ1ETiLFQ15N8k17rPaerFS
         M2DgNCQC517kRdmFhUWGJY/2+gqqVnA1VrwLOgNBxjM8p0G6v453NTETjzo/mAajk4rw
         hVJlYjAuSo3w06JFQHCpplr41EL590aQk2JD0sN1EGN4xZ/5Aj2m4igLvQWU4CnSs9f0
         v2rg==
X-Gm-Message-State: APjAAAWiiXADAKDGA4lepWb5lbqZN6Ow1RctQjLoxmTbAR323fTY/yR0
	MGbPDtBGRkVsGHrmE0HbWJAE3Vc+YK6wISRSLjWugCyGY5RP4NtgWAd1WSgbipShkRt4/0BezCC
	qH1MeMEpWQK5wBp5QWnht6BwHK2w2NRG2dG4knBH5UuUgSBTTemLcJr8TlZ4eaes=
X-Received: by 2002:a17:902:e65:: with SMTP id 92mr24001234plw.13.1563147262326;
        Sun, 14 Jul 2019 16:34:22 -0700 (PDT)
X-Received: by 2002:a17:902:e65:: with SMTP id 92mr24001190plw.13.1563147261623;
        Sun, 14 Jul 2019 16:34:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563147261; cv=none;
        d=google.com; s=arc-20160816;
        b=LMd5nXLGRxr9+qPUfSmNsVC4CSA3CQ0GAuMH26sTqdcriQRd9tWwP+hwH7TWtKt23n
         imq+oqfYeRQPcr+dZrLJPt90RehNQS9c6qKXxJKAE6plg0q19nOHXS2woPr7gXFq5HDp
         faNGzI+cF6ZxJ/QUCBv5WfcJEHxXZuBVNTIxmYJVQH3AMEtmlZ7Hxo4YcpVWi5gxscAO
         5S8tAB7BypZSXQw6E7ih8sVGaEoga5MwkQwgSs/d5ISjcR2ePOlJ/XIn0yxgpliVexFV
         aVNhAMZHj25KT5Mkqvnj+PZXKiZHOWPzMq2UMou2wtNKT5sB9vntNezOFp3qIYKdObMN
         H0Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=dXmXb4hHePla+El29aWi3bvhcbCN7txGRytZMqhI7AI=;
        b=T2v3OgnpkDSKIxwRwi8Xs4AuR1XgzklPuC9KeGqnuI8jOGfDKLLAJJJKPjc15+prjj
         fwSyZ6V/9qB3LzkxllPvHdEHMaSCrDe3SsmTsStJRYlOoo4ZhurYidqW6l850pnnCDX1
         HqM17ggerjrD95ooP2hvPJBCYWDMdqnmeGwZALu1Zj/w0W0FJBFPkgoFOhqQVTnDzjM1
         3OnMasp70JunkDzos4kcGZWVC+koGNjI3shCVTWT7acYvDievkGeazhqlnkcC0DZBo7O
         vsR8FFvNeYbkLHyOUbp0FlGvLxWg3jDcImzUzJdkNn9Q6YWxDDFuj0ofby8zQb02cn/i
         fy9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WfvIdRNO;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor18842611plf.60.2019.07.14.16.34.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jul 2019 16:34:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WfvIdRNO;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dXmXb4hHePla+El29aWi3bvhcbCN7txGRytZMqhI7AI=;
        b=WfvIdRNOEo5M3yqFQ95X+vfDsPgzs25Ux+W4a/3b0F9+lSPVhBU179TivXn7eJEcmJ
         V22evIfrP5qzt8j3EEbNGr9Cvxr5RHydDispLsawnpwS+nHo6VkqM/P9PGR0X+UElKV4
         mDKb2zjj60mKgRGXZyWtcGNLiUVwP5GSH0k1GPzGyIpiAhSSsdEVzGdg0PrI9ahJXM1e
         o5dJpgB4/blnAaNTpN3xA/Sq69f7umq2GgXLfqmnvzrQNcc3ouReHxWXqU2OrRkNua08
         4m8cNSl/Tn3dM+2HjgPGqx9RgjsKf+mLls7u+Guu/TTd5spfTGYh/uTQBOUOwl9q6GAm
         TVsw==
X-Google-Smtp-Source: APXvYqyoIoiBc9BVkZkT+Mht+XPRNWcu2bkpsPgUKHDpHhdXHUndHSbJNQ8VyCvOS+D5QoVIUDIXhg==
X-Received: by 2002:a17:902:e011:: with SMTP id ca17mr25554044plb.328.1563147261258;
        Sun, 14 Jul 2019 16:34:21 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id n26sm16256923pfa.83.2019.07.14.16.34.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 14 Jul 2019 16:34:20 -0700 (PDT)
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
Subject: [PATCH v5 2/5] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Mon, 15 Jul 2019 08:33:57 +0900
Message-Id: <20190714233401.36909-3-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.510.g264f2c817a-goog
In-Reply-To: <20190714233401.36909-1-minchan@kernel.org>
References: <20190714233401.36909-1-minchan@kernel.org>
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
index a0301edd8d03..b4fa04d10ba6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1119,7 +1119,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      struct reclaim_stat *stat,
-				      bool force_reclaim)
+				      bool ignore_references)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -1133,7 +1133,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 		bool dirty, writeback;
 		unsigned int nr_pages;
 
@@ -1264,7 +1264,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
+		if (!ignore_references)
 			references = page_check_references(page, sc);
 
 		switch (references) {
-- 
2.22.0.510.g264f2c817a-goog

