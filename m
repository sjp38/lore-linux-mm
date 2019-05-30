Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E7C0C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B4B5261EF
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XJvjTBc1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B4B5261EF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A85746B026F; Thu, 30 May 2019 17:54:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A35C46B0270; Thu, 30 May 2019 17:54:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94C896B0271; Thu, 30 May 2019 17:54:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A42C6B026F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:54:00 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v13so2755393oie.12
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:54:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Wtqhuc8tld+njwpNjaUC3LbpBQWLP9ZV0hs8fIq5ASw=;
        b=Rd0L7nFpwelfCnapnBea/xND+oTFmL4khjQhwid/F4pw8F3O/ha1e9HiFUOO4ewEcW
         Z4Hal1JQkZjIaD2tmcFX6yyzIgzUCZ2jHVMHGP163xFHma2sgX95NFpgqqURUST9mcM+
         pfKxvXV9JYX3ZG1rQ+qkVU2jH/fN0ayS/68X8uy7+6SatZXfMZDgyM4t84aIsfVvsasx
         LKCW6AIbu30pypr6sk/emze5UpT2HiHBCneFtm0lptkRftmXauTLspcgmQL2NqPlVZn5
         RGalKuG9GXO1fNscseTmLi9eoS8RTqLGazWOcK8VxeB5UInAsDjMUa0ZPjVJpyTmM6I3
         ctIA==
X-Gm-Message-State: APjAAAUDl2opuN56NCxuGi2WT3WKIcJpOKkRBhSNkpQqLP/Dg0QLMY8A
	JdMVKOhOUH1+u20IEPXVhsH2OAqGfcGt3fPGZb15dhZVtwIaiRXwf4LyJ7r0Bguj+FDyPhnn3wW
	HFh3lQyRFjdSFI7Z607Lrrfdh2/kDwYMtG8B9SgkW3pNxmn2SjexyaG3tbIMBjm9gLw==
X-Received: by 2002:aca:300d:: with SMTP id w13mr4006782oiw.26.1559253240117;
        Thu, 30 May 2019 14:54:00 -0700 (PDT)
X-Received: by 2002:aca:300d:: with SMTP id w13mr4006765oiw.26.1559253239414;
        Thu, 30 May 2019 14:53:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253239; cv=none;
        d=google.com; s=arc-20160816;
        b=M90+IlqJnKszUyjJQcPJtkXwIc2SCjUOCLMoiMGMuc5oURcKyi9pkHkgdzNstWjEdD
         rOUZmSqKc4kbX19rmZuHtELDEDk8HS7XnI/M3rGqmddXgTnoZwUfP8Sd7Ie+q3vBxSXr
         94GOA26qEYhEnqHVqyglQk7UmpWDTxNmGfCqxsrEgulU/ZJmUz1cOBZF9uxtA6LPL8Mm
         ZdTYmig0X7chUOQW8Xf/sXlTNM5w7PabVOvuUq1RV0OQLk2XKd4Kc5M1m/zYK1DSEnPi
         Mwkt2Ekp60UE4V0ZIQqpFssHKV5OAxFluPqAmWrqZUjg9YlLn78fdpGapktxnBKFHjDf
         BWVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=Wtqhuc8tld+njwpNjaUC3LbpBQWLP9ZV0hs8fIq5ASw=;
        b=GpkDJCeWsCJlWCLza1XtqIEEgEczXp1AS68MZX6Cr8EIKT22YkH5YM/l6YewBgtuca
         Kul5dhe1WPb9PoxjILkJGjsq2SuHbR7J/X2QhUO9vxyNdAGvKU0+6uFA1rBbTwvl+IhU
         GArMOjVRhuVOPnz8n5Kxy1ei1m7ccbCp7oXXUt/ArtN2xO47OADsK6gSMSq6taHqWYmu
         iwM1+0yIhNJOwRzK9S10/XQCSlFs2hgQsybuugQandf2eZ+umtshwOHDp8bMDve497DY
         b13AUUN9F/zkc4kCd5oBWttTXeGXMBJxSHecf7jy0tdSUt8kqVXn+ue+yHXWg/UdWLI9
         M8JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XJvjTBc1;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c26sor1978166otr.58.2019.05.30.14.53.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:53:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XJvjTBc1;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Wtqhuc8tld+njwpNjaUC3LbpBQWLP9ZV0hs8fIq5ASw=;
        b=XJvjTBc1+3PwDTickpM7WozJzbnV4CpwNeBr8/C7ZbJbctSTJZ+22GmcTknusuOoDr
         2D/QL0yQASYrqIjKmMGZ3xqFG90FA2JAtq+lrDy0HQr9MXSz2qBD2cBdM4ZhHAuwE/Zd
         Q9dwWl8Ada9Zdo9/JEx9uFscSKEAWOpBTfgK529lzzWDXo6fUzrmPi2d62PgdJ29IGOa
         gK7cUg9CxpeecwgzN6TbiRfynxidJ0jNKZW5/jR6vInd5DleH5Nq3BWGpnZFvrhdNCBK
         zATeaXk0EmpgYeqnWbNJyZPrTHkkI1urnEhXtBXMhTPcPWMDJBMr1rxPelkrhnsQoH8+
         rpuQ==
X-Google-Smtp-Source: APXvYqzVcIJEh7xNp7JK47qwuZzzsGLJK5TMq9FSbM20Pm3+szfoUg8qiY/3svza+IjLBI7oHuRCkg==
X-Received: by 2002:a9d:7347:: with SMTP id l7mr4421138otk.183.1559253239042;
        Thu, 30 May 2019 14:53:59 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id o124sm1462102oig.23.2019.05.30.14.53.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:53:58 -0700 (PDT)
Subject: [RFC PATCH 03/11] mm: Add support for Treated Buddy pages
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:53:56 -0700
Message-ID: <20190530215356.13974.95767.stgit@localhost.localdomain>
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

This patch is adding support for flagging pages as "Treated" within the
buddy allocator.

If memory aeration is not enabled then the value will always be treated as
false and the set/clear operations will have no effect.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h     |    1 +
 include/linux/page-flags.h |   32 ++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |    5 +++++
 3 files changed, 38 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 297edb45071a..0263d5bf0b84 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -127,6 +127,7 @@ static inline void del_page_from_free_area(struct page *page,
 {
 	list_del(&page->lru);
 	__ClearPageBuddy(page);
+	__ResetPageTreated(page);
 	set_page_private(page, 0);
 	area->nr_free--;
 }
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9f8712a4b1a5..1f8ccb98dd69 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -722,12 +722,32 @@ static inline int page_has_type(struct page *page)
 	VM_BUG_ON_PAGE(!PageType(page, 0), page);			\
 	page->page_type &= ~PG_##lname;					\
 }									\
+static __always_inline void __ResetPage##uname(struct page *page)	\
+{									\
+	VM_BUG_ON_PAGE(!PageType(page, 0), page);			\
+	page->page_type |= PG_##lname;					\
+}									\
 static __always_inline void __ClearPage##uname(struct page *page)	\
 {									\
 	VM_BUG_ON_PAGE(!Page##uname(page), page);			\
 	page->page_type |= PG_##lname;					\
 }
 
+#define PAGE_TYPE_OPS_DISABLED(uname)					\
+static __always_inline int Page##uname(struct page *page)		\
+{									\
+	return false;							\
+}									\
+static __always_inline void __SetPage##uname(struct page *page)		\
+{									\
+}									\
+static __always_inline void __ResetPage##uname(struct page *page)	\
+{									\
+}									\
+static __always_inline void __ClearPage##uname(struct page *page)	\
+{									\
+}
+
 /*
  * PageBuddy() indicates that the page is free and in the buddy system
  * (see mm/page_alloc.c).
@@ -744,6 +764,18 @@ static inline int page_has_type(struct page *page)
 PAGE_TYPE_OPS(Offline, offline)
 
 /*
+ * PageTreated() is an alias for Offline, however it is not meant to be an
+ * exclusive value. It should be combined with PageBuddy() when seen as it
+ * is meant to indicate that the page has been scrubbed while waiting in
+ * the buddy system.
+ */
+#ifdef CONFIG_AERATION
+PAGE_TYPE_OPS(Treated, offline)
+#else
+PAGE_TYPE_OPS_DISABLED(Treated)
+#endif
+
+/*
  * If kmemcg is enabled, the buddy allocator will set PageKmemcg() on
  * pages allocated with __GFP_ACCOUNT. It gets cleared on page free.
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2fa5bbb372bb..2894990862bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -942,6 +942,11 @@ static inline void __free_one_page(struct page *page,
 			goto done_merging;
 		if (!page_is_buddy(page, buddy, order))
 			goto done_merging;
+
+		/* If buddy is not treated, then do not mark page treated */
+		if (!PageTreated(buddy))
+			__ResetPageTreated(page);
+
 		/*
 		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
 		 * merge with it and move up one order.

