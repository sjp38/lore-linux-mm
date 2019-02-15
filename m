Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59C5FC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2E0B222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="i7j2CAoB";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Z5sYyg6S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2E0B222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E11688E0005; Fri, 15 Feb 2019 17:09:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC2FA8E0004; Fri, 15 Feb 2019 17:09:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC8008E0005; Fri, 15 Feb 2019 17:09:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4F28E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:07 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m37so10331052qte.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=RN4jTJoPdWMgq6GZ1y2ohLIXcnShrFSTPPlAuRog5E4=;
        b=r9hyjQ+n10IHuo1iZ/TmE5NcDB7YGzTsA0wiLRk5xvLLpV51SocgmDeU74RxAzWHoP
         LdqgC5sSyTChaPkzYyweIl9J0EDUhfuJBgDsKsdHaHQZ8addYKTtQQuBOhQPUinPk/JC
         NhNO0+D5uyQHSELU6eNiEP3NuILwrgnYfNWXqND499hMVNF6xdZazaudAeiHxqK0Vmj2
         tUsJqa8YgGXJF75+W+Jw5gSRYzBqvgo6J9BRGNciVv1ey3nM89L9AsZw0Jubk9s3GwKM
         eqrnPpBR4w1oaZLzh9uEJfCR620+etu+dIwlQigGcQwtFeZ1vbkT5xKFwRdxHMJRU8tl
         TIhQ==
X-Gm-Message-State: AHQUAuY3skzEbMWnSi28KnMFXdUHUyPIqgB4U1AnPCmDHkWlWc5kBTwP
	hh4NQsPNwTRxcWw6Rorny6eKFfxJARkG5ud8+hwEfeAgYusVwkXFyC+OwVOZIvGdHob7WbbGj3z
	tvbA7BIAXPV+uutBsbywK4tKpABB+RiPEnE3V5eEFTMyEOncWL7XLNZ0pGGp2rYsXBg==
X-Received: by 2002:a0c:985d:: with SMTP id e29mr9044960qvd.16.1550268547266;
        Fri, 15 Feb 2019 14:09:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVDrPYNz82Ldk5oaWBAEuPDZBhHupKJRBWiVIK+Ha182KGIm6Vpzn7DIWhq1Ncif8fIN4y
X-Received: by 2002:a0c:985d:: with SMTP id e29mr9044873qvd.16.1550268545503;
        Fri, 15 Feb 2019 14:09:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268545; cv=none;
        d=google.com; s=arc-20160816;
        b=av4cKh2gEA3b0VJl20s7yM0DmLm5A8sSXNKgTR5dgKkG5wr9UiOtl9xXzlKa7Cas9U
         rmrTrfKgMTSNQ6iBJT1g+j+nTLu+IXs+9tqcwgTvuboLGT4cr8J3e4VS7AhDxha5M2uy
         +be1/V5TmjPzu1A8IkLkvU71iDH2InerlTAX+QWzhID8eP0BT6H2wjB2lGjVR+wVSGtB
         vZCPh5AJLIpXZTUbsO9yek4joDwqfAG/fTGKaQohPQrqEWrlurdAAXj/0s3pOuAKVE7Q
         3aYuHU7F6SEafVnZoPBwNbeTO4VSFvZ9dwhtUJ69NtAaAE20+steuKauQlv1ydyJB/Nt
         sXAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=RN4jTJoPdWMgq6GZ1y2ohLIXcnShrFSTPPlAuRog5E4=;
        b=FQCltLn4b/MgXhsmOEBVy3mOW/zarsebcWELimoelQKt/vMOQAGlK03dPip+FTxH94
         dXb0nNojT/o0MS+FA2b9gPnVzVW9rvsU6H3T7zFnBYaYC0DqsF8c3ZAbQX+JUJI8foQI
         OSybjUyA8d/8+MGFdFLXmCrVBQ+FZJ67urt3u1Glbwl1OtLlj/S+2NL2816V3hOG79bG
         OOq15OBum0A3znCAK3hS+GcTiwMe5OMcNq9olK9U7j30bM03/5KNjlNuZmghHwvRT4nQ
         8XqSiLSx07R7S3BnnlQ6u2YNY2BDKjWb8lk25j5PzQ3NzYyE3YJ2NM8DD9PPmJZ3UEHr
         tufg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=i7j2CAoB;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Z5sYyg6S;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id n17si601965qvh.69.2019.02.15.14.09.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:05 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=i7j2CAoB;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Z5sYyg6S;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id ABCED31CA;
	Fri, 15 Feb 2019 17:09:03 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:04 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=RN4jTJoPdWMgq
	6GZ1y2ohLIXcnShrFSTPPlAuRog5E4=; b=i7j2CAoBCFlpOq2n3HkJbbBwl+yJJ
	VIyt6w06xzOF9KNk6hHifjoxjTmYvtktTMvc8hSkkXt/M0gYCatxr+g+qksyn0AR
	wCSVYqnXN6Be1XubK2GiKV6aZ5C2VYYg/8J0zG/NOpkpAqxLuz+yhTAZaGAKx0Gb
	N81KHxxDRNw9hJwMl/sZnCFTlrzVuiuZ1BigVyCm8oc+TEQJMPvICYKdm7+ztSP2
	7Cd5o2wXjDtxNQYddDZOon1wLG8nr5Pqh8T2FAOSk9pV5Bs9k4Wz0WovFjRpDk4n
	NpDU9CsHN5G3sWAjr0nrg5T89x4AcuBz9lj7YtS/OZ718HaDfvWxcfn8Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=RN4jTJoPdWMgq6GZ1y2ohLIXcnShrFSTPPlAuRog5E4=; b=Z5sYyg6S
	Z/adO9X+JvksOM354CK/MOU1k2BCim0rr83fFmesipk8FGvpZUBPGW7/nDokBrXE
	fX7TtFSXhRdhH5XEHUgGW9K5Lh7GcNQxz3/6I16+m9UlZtCOzCPAdpX262T8+TT3
	XBgrtr9pE8UMRq3PvB/6KigEUfZTck3LnoDBjyKnc+9HZzR4suZaW+n66r585Wic
	hEsONqbDIH+M8e8DdTZdJjYioTPkQH5V6ZJYsxppLsL5FU6ldJJrxMAOAcw1i7BF
	MC4xHQasSo7PsSihxXWd0rdfwnQOGzbMQAY+DYEi5nzZlg3x3xeB6t0TS3NOg1k6
	GsEgwE9Hksb0XQ==
X-ME-Sender: <xms:fjhnXFMGEO1LyJUKXdCUCoNEJAWigxX5QFb4-wMJbC2E7DqtYbWcnQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedt
X-ME-Proxy: <xmx:fzhnXAY7zsJq9b4bTCxwtgsx6G65N_T9gbWUnjoVNZlBI7BcyxtPjg>
    <xmx:fzhnXJ6v82WUE6HW9c6zC-Uc_0GmPUsGIKtnfw-xqXjbzu3AiijRvQ>
    <xmx:fzhnXFzhoUUGGdcEdoZPfS3-2Wc6bmTtpQDBeuIP_Blf-oKaTPLfpg>
    <xmx:fzhnXIjgofhaJhU43vCxNuh7cKu2An_5dwKL_ka-7JOYNJrOTloRoQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 70871E4511;
	Fri, 15 Feb 2019 17:09:01 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two lists of pages.
Date: Fri, 15 Feb 2019 14:08:26 -0800
Message-Id: <20190215220856.29749-2-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

In stead of using two migrate_pages(), a single exchange_pages() would
be sufficient and without allocating new pages.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/ksm.h |   5 +
 mm/Makefile         |   1 +
 mm/exchange.c       | 846 ++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h       |   6 +
 mm/ksm.c            |  35 ++
 mm/migrate.c        |   4 +-
 6 files changed, 895 insertions(+), 2 deletions(-)
 create mode 100644 mm/exchange.c

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 161e8164abcf..87c5b943a73c 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -53,6 +53,7 @@ struct page *ksm_might_need_to_copy(struct page *page,
 
 void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
+void ksm_exchange_page(struct page *to_page, struct page *from_page);
 
 #else  /* !CONFIG_KSM */
 
@@ -86,6 +87,10 @@ static inline void rmap_walk_ksm(struct page *page,
 static inline void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 {
 }
+static inline void ksm_exchange_page(struct page *to_page,
+				struct page *from_page)
+{
+}
 #endif /* CONFIG_MMU */
 #endif /* !CONFIG_KSM */
 
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..1574ea5743e4 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -43,6 +43,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 
 obj-y += init-mm.o
 obj-y += memblock.o
+obj-y += exchange.o
 
 ifdef CONFIG_MMU
 	obj-$(CONFIG_ADVISE_SYSCALLS)	+= madvise.o
diff --git a/mm/exchange.c b/mm/exchange.c
new file mode 100644
index 000000000000..a607348cc6f4
--- /dev/null
+++ b/mm/exchange.c
@@ -0,0 +1,846 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (C) 2016 NVIDIA, Zi Yan <ziy@nvidia.com>
+ *
+ * Exchange two in-use pages. Page flags and page->mapping are exchanged
+ * as well. Only anonymous pages are supported.
+ */
+
+#include <linux/syscalls.h>
+#include <linux/migrate.h>
+#include <linux/security.h>
+#include <linux/cpuset.h>
+#include <linux/hugetlb.h>
+#include <linux/mm_inline.h>
+#include <linux/page_idle.h>
+#include <linux/page-flags.h>
+#include <linux/ksm.h>
+#include <linux/memcontrol.h>
+#include <linux/balloon_compaction.h>
+#include <linux/buffer_head.h>
+#include <linux/fs.h> /* buffer_migrate_page  */
+#include <linux/backing-dev.h>
+
+
+#include "internal.h"
+
+struct exchange_page_info {
+	struct page *from_page;
+	struct page *to_page;
+
+	struct anon_vma *from_anon_vma;
+	struct anon_vma *to_anon_vma;
+
+	struct list_head list;
+};
+
+struct page_flags {
+	unsigned int page_error :1;
+	unsigned int page_referenced:1;
+	unsigned int page_uptodate:1;
+	unsigned int page_active:1;
+	unsigned int page_unevictable:1;
+	unsigned int page_checked:1;
+	unsigned int page_mappedtodisk:1;
+	unsigned int page_dirty:1;
+	unsigned int page_is_young:1;
+	unsigned int page_is_idle:1;
+	unsigned int page_swapcache:1;
+	unsigned int page_writeback:1;
+	unsigned int page_private:1;
+	unsigned int __pad:3;
+};
+
+
+static void exchange_page(char *to, char *from)
+{
+	u64 tmp;
+	int i;
+
+	for (i = 0; i < PAGE_SIZE; i += sizeof(tmp)) {
+		tmp = *((u64 *)(from + i));
+		*((u64 *)(from + i)) = *((u64 *)(to + i));
+		*((u64 *)(to + i)) = tmp;
+	}
+}
+
+static inline void exchange_highpage(struct page *to, struct page *from)
+{
+	char *vfrom, *vto;
+
+	vfrom = kmap_atomic(from);
+	vto = kmap_atomic(to);
+	exchange_page(vto, vfrom);
+	kunmap_atomic(vto);
+	kunmap_atomic(vfrom);
+}
+
+static void __exchange_gigantic_page(struct page *dst, struct page *src,
+				int nr_pages)
+{
+	int i;
+	struct page *dst_base = dst;
+	struct page *src_base = src;
+
+	for (i = 0; i < nr_pages; ) {
+		cond_resched();
+		exchange_highpage(dst, src);
+
+		i++;
+		dst = mem_map_next(dst, dst_base, i);
+		src = mem_map_next(src, src_base, i);
+	}
+}
+
+static void exchange_huge_page(struct page *dst, struct page *src)
+{
+	int i;
+	int nr_pages;
+
+	if (PageHuge(src)) {
+		/* hugetlbfs page */
+		struct hstate *h = page_hstate(src);
+
+		nr_pages = pages_per_huge_page(h);
+
+		if (unlikely(nr_pages > MAX_ORDER_NR_PAGES)) {
+			__exchange_gigantic_page(dst, src, nr_pages);
+			return;
+		}
+	} else {
+		/* thp page */
+		VM_BUG_ON(!PageTransHuge(src));
+		nr_pages = hpage_nr_pages(src);
+	}
+
+	for (i = 0; i < nr_pages; i++) {
+		cond_resched();
+		exchange_highpage(dst + i, src + i);
+	}
+}
+
+/*
+ * Copy the page to its new location without polluting cache
+ */
+static void exchange_page_flags(struct page *to_page, struct page *from_page)
+{
+	int from_cpupid, to_cpupid;
+	struct page_flags from_page_flags, to_page_flags;
+	struct mem_cgroup *to_memcg = page_memcg(to_page),
+					  *from_memcg = page_memcg(from_page);
+
+	from_cpupid = page_cpupid_xchg_last(from_page, -1);
+
+	from_page_flags.page_error = TestClearPageError(from_page);
+	from_page_flags.page_referenced = TestClearPageReferenced(from_page);
+	from_page_flags.page_uptodate = PageUptodate(from_page);
+	ClearPageUptodate(from_page);
+	from_page_flags.page_active = TestClearPageActive(from_page);
+	from_page_flags.page_unevictable = TestClearPageUnevictable(from_page);
+	from_page_flags.page_checked = PageChecked(from_page);
+	ClearPageChecked(from_page);
+	from_page_flags.page_mappedtodisk = PageMappedToDisk(from_page);
+	ClearPageMappedToDisk(from_page);
+	from_page_flags.page_dirty = PageDirty(from_page);
+	ClearPageDirty(from_page);
+	from_page_flags.page_is_young = test_and_clear_page_young(from_page);
+	from_page_flags.page_is_idle = page_is_idle(from_page);
+	clear_page_idle(from_page);
+	from_page_flags.page_swapcache = PageSwapCache(from_page);
+	from_page_flags.page_writeback = test_clear_page_writeback(from_page);
+
+
+	to_cpupid = page_cpupid_xchg_last(to_page, -1);
+
+	to_page_flags.page_error = TestClearPageError(to_page);
+	to_page_flags.page_referenced = TestClearPageReferenced(to_page);
+	to_page_flags.page_uptodate = PageUptodate(to_page);
+	ClearPageUptodate(to_page);
+	to_page_flags.page_active = TestClearPageActive(to_page);
+	to_page_flags.page_unevictable = TestClearPageUnevictable(to_page);
+	to_page_flags.page_checked = PageChecked(to_page);
+	ClearPageChecked(to_page);
+	to_page_flags.page_mappedtodisk = PageMappedToDisk(to_page);
+	ClearPageMappedToDisk(to_page);
+	to_page_flags.page_dirty = PageDirty(to_page);
+	ClearPageDirty(to_page);
+	to_page_flags.page_is_young = test_and_clear_page_young(to_page);
+	to_page_flags.page_is_idle = page_is_idle(to_page);
+	clear_page_idle(to_page);
+	to_page_flags.page_swapcache = PageSwapCache(to_page);
+	to_page_flags.page_writeback = test_clear_page_writeback(to_page);
+
+	/* set to_page */
+	if (from_page_flags.page_error)
+		SetPageError(to_page);
+	if (from_page_flags.page_referenced)
+		SetPageReferenced(to_page);
+	if (from_page_flags.page_uptodate)
+		SetPageUptodate(to_page);
+	if (from_page_flags.page_active) {
+		VM_BUG_ON_PAGE(from_page_flags.page_unevictable, from_page);
+		SetPageActive(to_page);
+	} else if (from_page_flags.page_unevictable)
+		SetPageUnevictable(to_page);
+	if (from_page_flags.page_checked)
+		SetPageChecked(to_page);
+	if (from_page_flags.page_mappedtodisk)
+		SetPageMappedToDisk(to_page);
+
+	/* Move dirty on pages not done by migrate_page_move_mapping() */
+	if (from_page_flags.page_dirty)
+		SetPageDirty(to_page);
+
+	if (from_page_flags.page_is_young)
+		set_page_young(to_page);
+	if (from_page_flags.page_is_idle)
+		set_page_idle(to_page);
+
+	/* set from_page */
+	if (to_page_flags.page_error)
+		SetPageError(from_page);
+	if (to_page_flags.page_referenced)
+		SetPageReferenced(from_page);
+	if (to_page_flags.page_uptodate)
+		SetPageUptodate(from_page);
+	if (to_page_flags.page_active) {
+		VM_BUG_ON_PAGE(to_page_flags.page_unevictable, from_page);
+		SetPageActive(from_page);
+	} else if (to_page_flags.page_unevictable)
+		SetPageUnevictable(from_page);
+	if (to_page_flags.page_checked)
+		SetPageChecked(from_page);
+	if (to_page_flags.page_mappedtodisk)
+		SetPageMappedToDisk(from_page);
+
+	/* Move dirty on pages not done by migrate_page_move_mapping() */
+	if (to_page_flags.page_dirty)
+		SetPageDirty(from_page);
+
+	if (to_page_flags.page_is_young)
+		set_page_young(from_page);
+	if (to_page_flags.page_is_idle)
+		set_page_idle(from_page);
+
+	/*
+	 * Copy NUMA information to the new page, to prevent over-eager
+	 * future migrations of this same page.
+	 */
+	page_cpupid_xchg_last(to_page, from_cpupid);
+	page_cpupid_xchg_last(from_page, to_cpupid);
+
+	ksm_exchange_page(to_page, from_page);
+	/*
+	 * Please do not reorder this without considering how mm/ksm.c's
+	 * get_ksm_page() depends upon ksm_migrate_page() and PageSwapCache().
+	 */
+	ClearPageSwapCache(to_page);
+	ClearPageSwapCache(from_page);
+	if (from_page_flags.page_swapcache)
+		SetPageSwapCache(to_page);
+	if (to_page_flags.page_swapcache)
+		SetPageSwapCache(from_page);
+
+
+#ifdef CONFIG_PAGE_OWNER
+	/* exchange page owner  */
+	BUILD_BUG();
+#endif
+	/* exchange mem cgroup  */
+	to_page->mem_cgroup = from_memcg;
+	from_page->mem_cgroup = to_memcg;
+
+}
+
+/*
+ * Replace the page in the mapping.
+ *
+ * The number of remaining references must be:
+ * 1 for anonymous pages without a mapping
+ * 2 for pages with a mapping
+ * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
+ */
+
+static int exchange_page_move_mapping(struct address_space *to_mapping,
+			struct address_space *from_mapping,
+			struct page *to_page, struct page *from_page,
+			struct buffer_head *to_head,
+			struct buffer_head *from_head,
+			enum migrate_mode mode,
+			int to_extra_count, int from_extra_count)
+{
+	int to_expected_count = 1 + to_extra_count,
+		from_expected_count = 1 + from_extra_count;
+	unsigned long from_page_index = from_page->index;
+	unsigned long to_page_index = to_page->index;
+	int to_swapbacked = PageSwapBacked(to_page),
+		from_swapbacked = PageSwapBacked(from_page);
+	struct address_space *to_mapping_value = to_page->mapping;
+	struct address_space *from_mapping_value = from_page->mapping;
+
+	VM_BUG_ON_PAGE(to_mapping != page_mapping(to_page), to_page);
+	VM_BUG_ON_PAGE(from_mapping != page_mapping(from_page), from_page);
+
+	if (!to_mapping) {
+		/* Anonymous page without mapping */
+		if (page_count(to_page) != to_expected_count)
+			return -EAGAIN;
+	}
+
+	if (!from_mapping) {
+		/* Anonymous page without mapping */
+		if (page_count(from_page) != from_expected_count)
+			return -EAGAIN;
+	}
+
+	/* both are anonymous pages  */
+	if (!from_mapping && !to_mapping) {
+		/* from_page  */
+		from_page->index = to_page_index;
+		from_page->mapping = to_mapping_value;
+
+		ClearPageSwapBacked(from_page);
+		if (to_swapbacked)
+			SetPageSwapBacked(from_page);
+
+
+		/* to_page  */
+		to_page->index = from_page_index;
+		to_page->mapping = from_mapping_value;
+
+		ClearPageSwapBacked(to_page);
+		if (from_swapbacked)
+			SetPageSwapBacked(to_page);
+	} else if (!from_mapping && to_mapping) {
+		/* from is anonymous, to is file-backed  */
+		struct zone *from_zone, *to_zone;
+		void **to_pslot;
+		int dirty;
+
+		from_zone = page_zone(from_page);
+		to_zone = page_zone(to_page);
+
+		xa_lock_irq(&to_mapping->i_pages);
+
+		to_pslot = radix_tree_lookup_slot(&to_mapping->i_pages,
+			page_index(to_page));
+
+		to_expected_count += 1 + page_has_private(to_page);
+		if (page_count(to_page) != to_expected_count ||
+			radix_tree_deref_slot_protected(to_pslot,
+				&to_mapping->i_pages.xa_lock) != to_page) {
+			xa_unlock_irq(&to_mapping->i_pages);
+			return -EAGAIN;
+		}
+
+		if (!page_ref_freeze(to_page, to_expected_count)) {
+			xa_unlock_irq(&to_mapping->i_pages);
+			pr_debug("cannot freeze page count\n");
+			return -EAGAIN;
+		}
+
+		if (mode == MIGRATE_ASYNC && to_head &&
+				!buffer_migrate_lock_buffers(to_head, mode)) {
+			page_ref_unfreeze(to_page, to_expected_count);
+			xa_unlock_irq(&to_mapping->i_pages);
+
+			pr_debug("cannot lock buffer head\n");
+			return -EAGAIN;
+		}
+
+		if (!page_ref_freeze(from_page, from_expected_count)) {
+			page_ref_unfreeze(to_page, to_expected_count);
+			xa_unlock_irq(&to_mapping->i_pages);
+
+			return -EAGAIN;
+		}
+		/*
+		 * Now we know that no one else is looking at the page:
+		 * no turning back from here.
+		 */
+		ClearPageSwapBacked(from_page);
+		ClearPageSwapBacked(to_page);
+
+		/* from_page  */
+		from_page->index = to_page_index;
+		from_page->mapping = to_mapping_value;
+		/* to_page  */
+		to_page->index = from_page_index;
+		to_page->mapping = from_mapping_value;
+
+		if (to_swapbacked)
+			__SetPageSwapBacked(from_page);
+		else
+			VM_BUG_ON_PAGE(PageSwapCache(to_page), to_page);
+
+		if (from_swapbacked)
+			__SetPageSwapBacked(to_page);
+		else
+			VM_BUG_ON_PAGE(PageSwapCache(from_page), from_page);
+
+		dirty = PageDirty(to_page);
+
+		radix_tree_replace_slot(&to_mapping->i_pages,
+				to_pslot, from_page);
+
+		/* move cache reference */
+		page_ref_unfreeze(to_page, to_expected_count - 1);
+		page_ref_unfreeze(from_page, from_expected_count + 1);
+
+		xa_unlock(&to_mapping->i_pages);
+
+		/*
+		 * If moved to a different zone then also account
+		 * the page for that zone. Other VM counters will be
+		 * taken care of when we establish references to the
+		 * new page and drop references to the old page.
+		 *
+		 * Note that anonymous pages are accounted for
+		 * via NR_FILE_PAGES and NR_ANON_MAPPED if they
+		 * are mapped to swap space.
+		 */
+		if (to_zone != from_zone) {
+			__dec_node_state(to_zone->zone_pgdat, NR_FILE_PAGES);
+			__inc_node_state(from_zone->zone_pgdat, NR_FILE_PAGES);
+			if (PageSwapBacked(to_page) && !PageSwapCache(to_page)) {
+				__dec_node_state(to_zone->zone_pgdat, NR_SHMEM);
+				__inc_node_state(from_zone->zone_pgdat, NR_SHMEM);
+			}
+			if (dirty && mapping_cap_account_dirty(to_mapping)) {
+				__dec_node_state(to_zone->zone_pgdat, NR_FILE_DIRTY);
+				__dec_zone_state(to_zone, NR_ZONE_WRITE_PENDING);
+				__inc_node_state(from_zone->zone_pgdat, NR_FILE_DIRTY);
+				__inc_zone_state(from_zone, NR_ZONE_WRITE_PENDING);
+			}
+		}
+		local_irq_enable();
+
+	} else {
+		/* from is file-backed to is anonymous: fold this to the case above */
+		/* both are file-backed  */
+		VM_BUG_ON(1);
+	}
+
+	return MIGRATEPAGE_SUCCESS;
+}
+
+static int exchange_from_to_pages(struct page *to_page, struct page *from_page,
+				enum migrate_mode mode)
+{
+	int rc = -EBUSY;
+	struct address_space *to_page_mapping, *from_page_mapping;
+	struct buffer_head *to_head = NULL, *to_bh = NULL;
+
+	VM_BUG_ON_PAGE(!PageLocked(from_page), from_page);
+	VM_BUG_ON_PAGE(!PageLocked(to_page), to_page);
+
+	/* copy page->mapping not use page_mapping()  */
+	to_page_mapping = page_mapping(to_page);
+	from_page_mapping = page_mapping(from_page);
+
+	/* from_page has to be anonymous page  */
+	VM_BUG_ON(from_page_mapping);
+	VM_BUG_ON(PageWriteback(from_page));
+	/* writeback has to finish */
+	BUG_ON(PageWriteback(to_page));
+
+
+	/* to_page is anonymous  */
+	if (!to_page_mapping) {
+exchange_mappings:
+		/* actual page mapping exchange */
+		rc = exchange_page_move_mapping(to_page_mapping, from_page_mapping,
+					to_page, from_page, NULL, NULL, mode, 0, 0);
+	} else {
+		if (to_page_mapping->a_ops->migratepage == buffer_migrate_page) {
+
+			if (!page_has_buffers(to_page))
+				goto exchange_mappings;
+
+			to_head = page_buffers(to_page);
+
+			rc = exchange_page_move_mapping(to_page_mapping,
+					from_page_mapping, to_page, from_page,
+					to_head, NULL, mode, 0, 0);
+
+			if (rc != MIGRATEPAGE_SUCCESS)
+				return rc;
+
+			/*
+			 * In the async case, migrate_page_move_mapping locked the buffers
+			 * with an IRQ-safe spinlock held. In the sync case, the buffers
+			 * need to be locked now
+			 */
+			if (mode != MIGRATE_ASYNC)
+				VM_BUG_ON(!buffer_migrate_lock_buffers(to_head, mode));
+
+			ClearPagePrivate(to_page);
+			set_page_private(from_page, page_private(to_page));
+			set_page_private(to_page, 0);
+			/* transfer private page count  */
+			put_page(to_page);
+			get_page(from_page);
+
+			to_bh = to_head;
+			do {
+				set_bh_page(to_bh, from_page, bh_offset(to_bh));
+				to_bh = to_bh->b_this_page;
+
+			} while (to_bh != to_head);
+
+			SetPagePrivate(from_page);
+
+			to_bh = to_head;
+		} else if (!to_page_mapping->a_ops->migratepage) {
+			/* fallback_migrate_page  */
+			if (PageDirty(to_page)) {
+				if (mode != MIGRATE_SYNC)
+					return -EBUSY;
+				return writeout(to_page_mapping, to_page);
+			}
+			if (page_has_private(to_page) &&
+				!try_to_release_page(to_page, GFP_KERNEL))
+				return -EAGAIN;
+
+			goto exchange_mappings;
+		}
+	}
+	/* actual page data exchange  */
+	if (rc != MIGRATEPAGE_SUCCESS)
+		return rc;
+
+
+	if (PageHuge(from_page) || PageTransHuge(from_page))
+		exchange_huge_page(to_page, from_page);
+	else
+		exchange_highpage(to_page, from_page);
+	rc = 0;
+
+	/*
+	 * 1. buffer_migrate_page:
+	 *   private flag should be transferred from to_page to from_page
+	 *
+	 * 2. anon<->anon, fallback_migrate_page:
+	 *   both have none private flags or to_page's is cleared.
+	 */
+	VM_BUG_ON(!((page_has_private(from_page) && !page_has_private(to_page)) ||
+				(!page_has_private(from_page) && !page_has_private(to_page))));
+
+	exchange_page_flags(to_page, from_page);
+
+	if (to_bh) {
+		VM_BUG_ON(to_bh != to_head);
+		do {
+			unlock_buffer(to_bh);
+			put_bh(to_bh);
+			to_bh = to_bh->b_this_page;
+
+		} while (to_bh != to_head);
+	}
+
+	return rc;
+}
+
+static int unmap_and_exchange(struct page *from_page,
+		struct page *to_page, enum migrate_mode mode)
+{
+	int rc = -EAGAIN;
+	struct anon_vma *from_anon_vma = NULL;
+	struct anon_vma *to_anon_vma = NULL;
+	int from_page_was_mapped = 0;
+	int to_page_was_mapped = 0;
+	int from_page_count = 0, to_page_count = 0;
+	int from_map_count = 0, to_map_count = 0;
+	unsigned long from_flags, to_flags;
+	pgoff_t from_index, to_index;
+	struct address_space *from_mapping, *to_mapping;
+
+	if (!trylock_page(from_page)) {
+		if (mode == MIGRATE_ASYNC)
+			goto out;
+		lock_page(from_page);
+	}
+
+	if (!trylock_page(to_page)) {
+		if (mode == MIGRATE_ASYNC)
+			goto out_unlock;
+		lock_page(to_page);
+	}
+
+	/* from_page is supposed to be an anonymous page */
+	VM_BUG_ON_PAGE(PageWriteback(from_page), from_page);
+
+	if (PageWriteback(to_page)) {
+		/*
+		 * Only in the case of a full synchronous migration is it
+		 * necessary to wait for PageWriteback. In the async case,
+		 * the retry loop is too short and in the sync-light case,
+		 * the overhead of stalling is too much
+		 */
+		if (mode != MIGRATE_SYNC) {
+			rc = -EBUSY;
+			goto out_unlock_both;
+		}
+		wait_on_page_writeback(to_page);
+	}
+
+	if (PageAnon(from_page) && !PageKsm(from_page))
+		from_anon_vma = page_get_anon_vma(from_page);
+
+	if (PageAnon(to_page) && !PageKsm(to_page))
+		to_anon_vma = page_get_anon_vma(to_page);
+
+	from_page_count = page_count(from_page);
+	from_map_count = page_mapcount(from_page);
+	to_page_count = page_count(to_page);
+	to_map_count = page_mapcount(to_page);
+	from_flags = from_page->flags;
+	to_flags = to_page->flags;
+	from_mapping = from_page->mapping;
+	to_mapping = to_page->mapping;
+	from_index = from_page->index;
+	to_index = to_page->index;
+
+	/*
+	 * Corner case handling:
+	 * 1. When a new swap-cache page is read into, it is added to the LRU
+	 * and treated as swapcache but it has no rmap yet.
+	 * Calling try_to_unmap() against a page->mapping==NULL page will
+	 * trigger a BUG.  So handle it here.
+	 * 2. An orphaned page (see truncate_complete_page) might have
+	 * fs-private metadata. The page can be picked up due to memory
+	 * offlining.  Everywhere else except page reclaim, the page is
+	 * invisible to the vm, so the page can not be migrated.  So try to
+	 * free the metadata, so the page can be freed.
+	 */
+	if (!from_page->mapping) {
+		VM_BUG_ON_PAGE(PageAnon(from_page), from_page);
+		if (page_has_private(from_page)) {
+			try_to_free_buffers(from_page);
+			goto out_unlock_both;
+		}
+	} else if (page_mapped(from_page)) {
+		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(from_page) && !PageKsm(from_page) &&
+					   !from_anon_vma, from_page);
+		try_to_unmap(from_page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		from_page_was_mapped = 1;
+	}
+
+	if (!to_page->mapping) {
+		VM_BUG_ON_PAGE(PageAnon(to_page), to_page);
+		if (page_has_private(to_page)) {
+			try_to_free_buffers(to_page);
+			goto out_unlock_both_remove_from_migration_pte;
+		}
+	} else if (page_mapped(to_page)) {
+		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(to_page) && !PageKsm(to_page) &&
+						!to_anon_vma, to_page);
+		try_to_unmap(to_page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		to_page_was_mapped = 1;
+	}
+
+	if (!page_mapped(from_page) && !page_mapped(to_page))
+		rc = exchange_from_to_pages(to_page, from_page, mode);
+
+
+	if (to_page_was_mapped) {
+		/* swap back to_page->index to be compatible with
+		 * remove_migration_ptes(), which assumes both from_page and to_page
+		 * below have the same index.
+		 */
+		if (rc == MIGRATEPAGE_SUCCESS)
+			swap(to_page->index, to_index);
+
+		remove_migration_ptes(to_page,
+			rc == MIGRATEPAGE_SUCCESS ? from_page : to_page, false);
+
+		if (rc == MIGRATEPAGE_SUCCESS)
+			swap(to_page->index, to_index);
+	}
+
+out_unlock_both_remove_from_migration_pte:
+	if (from_page_was_mapped) {
+		/* swap back from_page->index to be compatible with
+		 * remove_migration_ptes(), which assumes both from_page and to_page
+		 * below have the same index.
+		 */
+		if (rc == MIGRATEPAGE_SUCCESS)
+			swap(from_page->index, from_index);
+
+		remove_migration_ptes(from_page,
+			rc == MIGRATEPAGE_SUCCESS ? to_page : from_page, false);
+
+		if (rc == MIGRATEPAGE_SUCCESS)
+			swap(from_page->index, from_index);
+	}
+
+out_unlock_both:
+	if (to_anon_vma)
+		put_anon_vma(to_anon_vma);
+	unlock_page(to_page);
+out_unlock:
+	/* Drop an anon_vma reference if we took one */
+	if (from_anon_vma)
+		put_anon_vma(from_anon_vma);
+	unlock_page(from_page);
+out:
+	return rc;
+}
+
+/*
+ * Exchange pages in the exchange_list
+ *
+ * Caller should release the exchange_list resource.
+ *
+ */
+static int exchange_pages(struct list_head *exchange_list,
+			enum migrate_mode mode,
+			int reason)
+{
+	struct exchange_page_info *one_pair, *one_pair2;
+	int failed = 0;
+
+	list_for_each_entry_safe(one_pair, one_pair2, exchange_list, list) {
+		struct page *from_page = one_pair->from_page;
+		struct page *to_page = one_pair->to_page;
+		int rc;
+		int retry = 0;
+
+again:
+		if (page_count(from_page) == 1) {
+			/* page was freed from under us. So we are done  */
+			ClearPageActive(from_page);
+			ClearPageUnevictable(from_page);
+
+			mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+					page_is_file_cache(from_page),
+					-hpage_nr_pages(from_page));
+			put_page(from_page);
+
+			if (page_count(to_page) == 1) {
+				ClearPageActive(to_page);
+				ClearPageUnevictable(to_page);
+				put_page(to_page);
+				mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+						page_is_file_cache(to_page),
+						-hpage_nr_pages(to_page));
+			} else
+				goto putback_to_page;
+
+			continue;
+		}
+
+		if (page_count(to_page) == 1) {
+			/* page was freed from under us. So we are done  */
+			ClearPageActive(to_page);
+			ClearPageUnevictable(to_page);
+
+			mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+					page_is_file_cache(to_page),
+					-hpage_nr_pages(to_page));
+			put_page(to_page);
+
+			mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+					page_is_file_cache(from_page),
+					-hpage_nr_pages(from_page));
+			putback_lru_page(from_page);
+			continue;
+		}
+
+		/* TODO: compound page not supported */
+		/* to_page can be file-backed page  */
+		if (PageCompound(from_page) ||
+			page_mapping(from_page)
+			) {
+			++failed;
+			goto putback;
+		}
+
+		rc = unmap_and_exchange(from_page, to_page, mode);
+
+		if (rc == -EAGAIN && retry < 3) {
+			++retry;
+			goto again;
+		}
+
+		if (rc != MIGRATEPAGE_SUCCESS)
+			++failed;
+
+putback:
+		mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+				page_is_file_cache(from_page),
+				-hpage_nr_pages(from_page));
+
+		putback_lru_page(from_page);
+putback_to_page:
+		mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+				page_is_file_cache(to_page),
+				-hpage_nr_pages(to_page));
+
+		putback_lru_page(to_page);
+	}
+	return failed;
+}
+
+int exchange_two_pages(struct page *page1, struct page *page2)
+{
+	struct exchange_page_info page_info;
+	LIST_HEAD(exchange_list);
+	int err = -EFAULT;
+	int pagevec_flushed = 0;
+
+	VM_BUG_ON_PAGE(PageTail(page1), page1);
+	VM_BUG_ON_PAGE(PageTail(page2), page2);
+
+	if (!(PageLRU(page1) && PageLRU(page2)))
+		return -EBUSY;
+
+retry_isolate1:
+	if (!get_page_unless_zero(page1))
+		return -EBUSY;
+	err = isolate_lru_page(page1);
+	put_page(page1);
+	if (err) {
+		if (!pagevec_flushed) {
+			migrate_prep();
+			pagevec_flushed = 1;
+			goto retry_isolate1;
+		}
+		return err;
+	}
+	mod_node_page_state(page_pgdat(page1),
+			NR_ISOLATED_ANON + page_is_file_cache(page1),
+			hpage_nr_pages(page1));
+
+retry_isolate2:
+	if (!get_page_unless_zero(page2)) {
+		putback_lru_page(page1);
+		return -EBUSY;
+	}
+	err = isolate_lru_page(page2);
+	put_page(page2);
+	if (err) {
+		if (!pagevec_flushed) {
+			migrate_prep();
+			pagevec_flushed = 1;
+			goto retry_isolate2;
+		}
+		return err;
+	}
+	mod_node_page_state(page_pgdat(page2),
+			NR_ISOLATED_ANON + page_is_file_cache(page2),
+			hpage_nr_pages(page2));
+
+	page_info.from_page = page1;
+	page_info.to_page = page2;
+	INIT_LIST_HEAD(&page_info.list);
+	list_add(&page_info.list, &exchange_list);
+
+
+	return exchange_pages(&exchange_list, MIGRATE_SYNC, 0);
+
+}
diff --git a/mm/internal.h b/mm/internal.h
index f4a7bb02decf..77e205c423ce 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -543,4 +543,10 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 
 void setup_zone_pageset(struct zone *zone);
 extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
+
+bool buffer_migrate_lock_buffers(struct buffer_head *head,
+							enum migrate_mode mode);
+int writeout(struct address_space *mapping, struct page *page);
+extern int exchange_two_pages(struct page *page1, struct page *page2);
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/ksm.c b/mm/ksm.c
index 6c48ad13b4c9..dc1ec06b71a0 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2665,6 +2665,41 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 		set_page_stable_node(oldpage, NULL);
 	}
 }
+
+void ksm_exchange_page(struct page *to_page, struct page *from_page)
+{
+	struct stable_node *to_stable_node, *from_stable_node;
+
+	VM_BUG_ON_PAGE(!PageLocked(to_page), to_page);
+	VM_BUG_ON_PAGE(!PageLocked(from_page), from_page);
+
+	to_stable_node = page_stable_node(to_page);
+	from_stable_node = page_stable_node(from_page);
+	if (to_stable_node) {
+		VM_BUG_ON_PAGE(to_stable_node->kpfn != page_to_pfn(from_page),
+					from_page);
+		to_stable_node->kpfn = page_to_pfn(to_page);
+		/*
+		 * newpage->mapping was set in advance; now we need smp_wmb()
+		 * to make sure that the new stable_node->kpfn is visible
+		 * to get_ksm_page() before it can see that oldpage->mapping
+		 * has gone stale (or that PageSwapCache has been cleared).
+		 */
+		smp_wmb();
+	}
+	if (from_stable_node) {
+		VM_BUG_ON_PAGE(from_stable_node->kpfn != page_to_pfn(to_page),
+					to_page);
+		from_stable_node->kpfn = page_to_pfn(from_page);
+		/*
+		 * newpage->mapping was set in advance; now we need smp_wmb()
+		 * to make sure that the new stable_node->kpfn is visible
+		 * to get_ksm_page() before it can see that oldpage->mapping
+		 * has gone stale (or that PageSwapCache has been cleared).
+		 */
+		smp_wmb();
+	}
+}
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..b8c79aa62134 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -701,7 +701,7 @@ EXPORT_SYMBOL(migrate_page);
 
 #ifdef CONFIG_BLOCK
 /* Returns true if all buffers are successfully locked */
-static bool buffer_migrate_lock_buffers(struct buffer_head *head,
+bool buffer_migrate_lock_buffers(struct buffer_head *head,
 							enum migrate_mode mode)
 {
 	struct buffer_head *bh = head;
@@ -849,7 +849,7 @@ int buffer_migrate_page_norefs(struct address_space *mapping,
 /*
  * Writeback a page to clean the dirty state
  */
-static int writeout(struct address_space *mapping, struct page *page)
+int writeout(struct address_space *mapping, struct page *page)
 {
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_NONE,
-- 
2.20.1

