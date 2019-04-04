Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D60E0C10F06
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75BBE2133D
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="dFVS7mRN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="wDoNd3M3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75BBE2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC9666B0276; Wed,  3 Apr 2019 22:01:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9F336B0277; Wed,  3 Apr 2019 22:01:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3EFB6B0278; Wed,  3 Apr 2019 22:01:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD436B0276
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:45 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k13so921858qtc.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=XrMS+H78cvhwFXbC0E6g3rjtcoxdIYJ+GaG+5au9LuY=;
        b=BUYo9c8s8s6zDrIzkk80hpHx42Tf0syoKPtQ9YjZJh5dk+nlVunHR5Jbl3701M1N0z
         fKOUyGbKZMmN4hhNrhmgy0eSmx/m6B3izSNcJ5ntejtANicaJsNA+q4+P3yTaRGOU/Qm
         fg2I7pYGe0x0qNsTSMdVL6fKR8/HcmmWSNqZbXMDmj2FFug1fXPcFeCJWK5/kfhypz63
         ugXcibVdTnrcfVVoJZim6N03RNFWedahYEupFkMDnwKBqrhn8LELlhVQ2NWOGLeQbeTR
         VqEHX1njKzel+aajMXtMTNB6AwRcvL5TMTxZQnwRTRV0DL/jJkNnv0HHG1vY4q2nLVC3
         EbsA==
X-Gm-Message-State: APjAAAUAiGUHKigzO8KWU1nVQJH1O3prfBk8V02B6ije/jBk+dGy2pmL
	qIFZkjg+2b9kOKJsxMyyfroFum3K5lzdne7ebXo5NV0yjCT/fqqMtrse+JcSk7h57akqdTHg3i4
	1cyQwxo4ECvL2cyiAmjyP/BaOEHzIl9qg8OdTQFPx3reJduxKzmVojsP42JObEq86Eg==
X-Received: by 2002:ac8:f24:: with SMTP id e33mr3149416qtk.256.1554343305237;
        Wed, 03 Apr 2019 19:01:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCtuJAxdEdYJXc3MSLye3Z0ngdsUph/QWg18BElHqAMmZuFFIg6c35memw1Axgyfrrbg3G
X-Received: by 2002:ac8:f24:: with SMTP id e33mr3149362qtk.256.1554343304308;
        Wed, 03 Apr 2019 19:01:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343304; cv=none;
        d=google.com; s=arc-20160816;
        b=CHhH4G0G/z9cN1ra0N8sxAEqsXgNKqJl1umQuWbc4secgA1z20Fv4/V9nK/gzlPJvt
         2/rRBR5g4KP6b1gFrJB51fNUszBnIUaL4R5qCHJ4I5u1TmC8MHe8t36oz2vxtcu7APBw
         I0PZTPNYQTmBbHMxP1WXzJ16jp8SbrwdCE+owsgGaU4uCeU0S9XCzxc8VCMbV7NpkNIO
         RspTuWPqZQgJtk/outZMLybrPwU0aYB9MS+h2/qYAG+iaJzQ4ViSftkAuxTlCn5gloYL
         uhwxBZVMF33nObkEKyQCI6sCYahhUdKM9YKyQ7yNLKdHE+AMQ4qVGXY3zd3kWagF/1c+
         D8Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=XrMS+H78cvhwFXbC0E6g3rjtcoxdIYJ+GaG+5au9LuY=;
        b=XJPb5WLSin+A0CVhUyYCn3gvB9TmeIbG91aSOIfYruFWd0h6oNH3OAUkWZtlV9SM9r
         EGFzu7cth+cUiZSXwFSjzjAAqyFvyMjhNDRy9Sd4+6qgegiZ0FBK18A2CA9qIjMkRasn
         Dq1o6cETgLpVrSczkHcIHbGczwxkDS7oj/LJSL8gOjQZWfzA+Zn3M+ESsfNjzZBEVxfa
         ajPIX3ZJfPl9CWBG2AyRenZkf6hWMNAOCIFVFvM+8yzrovp8BDp/tsu7zi7Qsw8irHO4
         xIcZRpfzxph6Ri2/+I4n6MFyAUuluvDynB6vqTxdikSTWQskvlFzWcE3+RsOWwGKgq5m
         MNlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=dFVS7mRN;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wDoNd3M3;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id d1si2281346qkf.152.2019.04.03.19.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=dFVS7mRN;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wDoNd3M3;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 0B22A22585;
	Wed,  3 Apr 2019 22:01:44 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=XrMS+H78cvhwF
	XbC0E6g3rjtcoxdIYJ+GaG+5au9LuY=; b=dFVS7mRNn0EutfXNuwXinLqM4jsU0
	/G4Zfj5zPHgFLq4R45ZAwVO7wdd+4qeo+pNxUUt9RGp4RyQVOrBFfTlaZhap89mz
	GoEsvVhtqGntAJex0/3NiAsqKfcCAV5EKXzKZ6I9HeBQlP6OgLgjnbieNhUT+gyj
	0B7we6pmbNbhBm8HKSiux8kyIpIq1508GQR6EBYolxpuk466prBlkBzxVR8PGDAr
	wklMI4S+HQIX1tba6rOZOGcPb7gTTpXY1zli5s5Wp9qBXc/67SjhgRmjYJ47qbod
	dRl4t+b4q53xMBZY5i7+Zr+lc0/tOYHIDkfG7PSSNwvY0v05Ap6Yq2/1Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=XrMS+H78cvhwFXbC0E6g3rjtcoxdIYJ+GaG+5au9LuY=; b=wDoNd3M3
	aDj4rPP1tCcvD31CntXlDuJxGD+XgVLa1OLqTR62VjQ4UzUtUxt/DiZwcZzcLQ2S
	02/rrlNA7xHgrXIvbUoegmUWnowjYGR8JZX7soycQgK3FQ/2TOnI3t1O+pZNG3fX
	aCiELZddV0qMktf34aBGO93JbBvQN5Qed7nhbyuaEWThSfQ1+3K4/ZPPR2rfRuiQ
	FIhX8XmTJAr/bJWavxyPXAN2mIiDDjEQCTv4IvYHYzo+cQJVftvnDLqLOkUyy2W5
	aXCbwv5hnNZHJ21cGJTDDfCOoZdpx8yqh8MSklrhaZhnlbF1LUxSG1OaT17PCESi
	tDRkdKorKlcFKw==
X-ME-Sender: <xms:h2WlXFAn1vYfDv7c0WYlMjM-pDGjm-Ajskbkkw6xYsQ8r07lyJZVHg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepudeg
X-ME-Proxy: <xmx:h2WlXHySZb_F1If-16jluI0ifXBV456RqruGLzwiEoB8hiIwrQ6B1A>
    <xmx:h2WlXLmz1RPoH3XdWAN_O_b9NlOZPXh95fK4FqPGIW9Z7zOR_-014A>
    <xmx:h2WlXEHFAJ0bQKbqI1-SAd8oK2TWWLyhLJWCIkOisKp1Qe8YbuO_TA>
    <xmx:h2WlXIK1mT2CcQ1VDIBcB8r52U16tUSsxZgiGApurauWX61DxHebyA>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 13C5110310;
	Wed,  3 Apr 2019 22:01:42 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 17/25] exchange page: Add exchange_page() syscall.
Date: Wed,  3 Apr 2019 19:00:38 -0700
Message-Id: <20190404020046.32741-18-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Users can use the syscall to exchange two lists of pages, similar
to move_pages() syscall.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 include/linux/syscalls.h               |   5 +
 mm/exchange.c                          | 346 +++++++++++++++++++++++++++++++++
 3 files changed, 352 insertions(+)

diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 92ee0b4..863a21e 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -343,6 +343,7 @@
 332	common	statx			__x64_sys_statx
 333	common	io_pgetevents		__x64_sys_io_pgetevents
 334	common	rseq			__x64_sys_rseq
+335	common	exchange_pages	__x64_sys_exchange_pages
 # don't use numbers 387 through 423, add new calls after the last
 # 'common' entry
 424	common	pidfd_send_signal	__x64_sys_pidfd_send_signal
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index e446806..2c1eb49 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -1203,6 +1203,11 @@ asmlinkage long sys_mmap_pgoff(unsigned long addr, unsigned long len,
 			unsigned long fd, unsigned long pgoff);
 asmlinkage long sys_old_mmap(struct mmap_arg_struct __user *arg);
 
+asmlinkage long sys_exchange_pages(pid_t pid, unsigned long nr_pages,
+				const void __user * __user *from_pages,
+				const void __user * __user *to_pages,
+				int __user *status,
+				int flags);
 
 /*
  * Not a real system call, but a placeholder for syscalls which are
diff --git a/mm/exchange.c b/mm/exchange.c
index 45c7013..48e344e 100644
--- a/mm/exchange.c
+++ b/mm/exchange.c
@@ -22,6 +22,7 @@
 #include <linux/buffer_head.h>
 #include <linux/fs.h> /* buffer_migrate_page  */
 #include <linux/backing-dev.h>
+#include <linux/sched/mm.h>
 
 
 #include "internal.h"
@@ -1212,3 +1213,348 @@ int exchange_pages_concur(struct list_head *exchange_list,
 
 	return nr_failed?-EFAULT:0;
 }
+
+static int store_status(int __user *status, int start, int value, int nr)
+{
+	while (nr-- > 0) {
+		if (put_user(value, status + start))
+			return -EFAULT;
+		start++;
+	}
+
+	return 0;
+}
+
+static int do_exchange_page_list(struct mm_struct *mm,
+		struct list_head *from_pagelist, struct list_head *to_pagelist,
+		bool migrate_mt, bool migrate_concur)
+{
+	int err;
+	struct exchange_page_info *one_pair;
+	LIST_HEAD(exchange_page_list);
+
+	while (!list_empty(from_pagelist)) {
+		struct page *from_page, *to_page;
+
+		from_page = list_first_entry_or_null(from_pagelist, struct page, lru);
+		to_page = list_first_entry_or_null(to_pagelist, struct page, lru);
+
+		if (!from_page || !to_page)
+			break;
+
+		one_pair = kzalloc(sizeof(struct exchange_page_info), GFP_ATOMIC);
+		if (!one_pair) {
+			err = -ENOMEM;
+			break;
+		}
+
+		list_del(&from_page->lru);
+		list_del(&to_page->lru);
+
+		one_pair->from_page = from_page;
+		one_pair->to_page = to_page;
+
+		list_add_tail(&one_pair->list, &exchange_page_list);
+	}
+
+	if (migrate_concur)
+		err = exchange_pages_concur(&exchange_page_list,
+			MIGRATE_SYNC | (migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD),
+			MR_SYSCALL);
+	else
+		err = exchange_pages(&exchange_page_list,
+			MIGRATE_SYNC | (migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD),
+			MR_SYSCALL);
+
+	while (!list_empty(&exchange_page_list)) {
+		struct exchange_page_info *one_pair =
+			list_first_entry(&exchange_page_list,
+							 struct exchange_page_info, list);
+
+		list_del(&one_pair->list);
+		kfree(one_pair);
+	}
+
+	if (!list_empty(from_pagelist))
+		putback_movable_pages(from_pagelist);
+
+	if (!list_empty(to_pagelist))
+		putback_movable_pages(to_pagelist);
+
+	return err;
+}
+
+static int add_page_for_exchange(struct mm_struct *mm,
+		unsigned long from_addr, unsigned long to_addr,
+		struct list_head *from_pagelist, struct list_head *to_pagelist,
+		bool migrate_all)
+{
+	struct vm_area_struct *from_vma, *to_vma;
+	struct page *from_page, *to_page;
+	LIST_HEAD(err_page_list);
+	unsigned int follflags;
+	int err;
+
+	err = -EFAULT;
+	from_vma = find_vma(mm, from_addr);
+	if (!from_vma || from_addr < from_vma->vm_start ||
+		!vma_migratable(from_vma))
+		goto set_from_status;
+
+	/* FOLL_DUMP to ignore special (like zero) pages */
+	follflags = FOLL_GET | FOLL_DUMP;
+	from_page = follow_page(from_vma, from_addr, follflags);
+
+	err = PTR_ERR(from_page);
+	if (IS_ERR(from_page))
+		goto set_from_status;
+
+	err = -ENOENT;
+	if (!from_page)
+		goto set_from_status;
+
+	err = -EACCES;
+	if (page_mapcount(from_page) > 1 && !migrate_all)
+		goto put_and_set_from_page;
+
+	if (PageHuge(from_page)) {
+		if (PageHead(from_page))
+			if (isolate_huge_page(from_page, &err_page_list)) {
+				err = 0;
+			}
+		goto put_and_set_from_page;
+	} else if (PageTransCompound(from_page)) {
+		if (PageTail(from_page)) {
+			err = -EACCES;
+			goto put_and_set_from_page;
+		}
+	}
+
+	err = isolate_lru_page(from_page);
+	if (!err)
+		mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+					page_is_file_cache(from_page), hpage_nr_pages(from_page));
+put_and_set_from_page:
+	/*
+	 * Either remove the duplicate refcount from
+	 * isolate_lru_page() or drop the page ref if it was
+	 * not isolated.
+	 *
+	 * Since FOLL_GET calls get_page(), and isolate_lru_page()
+	 * also calls get_page()
+	 */
+	put_page(from_page);
+set_from_status:
+	if (err)
+		goto out;
+
+	/* to pages  */
+	err = -EFAULT;
+	to_vma = find_vma(mm, to_addr);
+	if (!to_vma ||
+		to_addr < to_vma->vm_start ||
+		!vma_migratable(to_vma))
+		goto set_to_status;
+
+	/* FOLL_DUMP to ignore special (like zero) pages */
+	to_page = follow_page(to_vma, to_addr, follflags);
+
+	err = PTR_ERR(to_page);
+	if (IS_ERR(to_page))
+		goto set_to_status;
+
+	err = -ENOENT;
+	if (!to_page)
+		goto set_to_status;
+
+	err = -EACCES;
+	if (page_mapcount(to_page) > 1 &&
+			!migrate_all)
+		goto put_and_set_to_page;
+
+	if (PageHuge(to_page)) {
+		if (PageHead(to_page))
+			if (isolate_huge_page(to_page, &err_page_list)) {
+				err = 0;
+			}
+		goto put_and_set_to_page;
+	} else if (PageTransCompound(to_page)) {
+		if (PageTail(to_page)) {
+			err = -EACCES;
+			goto put_and_set_to_page;
+		}
+	}
+
+	err = isolate_lru_page(to_page);
+	if (!err)
+		mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+					page_is_file_cache(to_page), hpage_nr_pages(to_page));
+put_and_set_to_page:
+	/*
+	 * Either remove the duplicate refcount from
+	 * isolate_lru_page() or drop the page ref if it was
+	 * not isolated.
+	 *
+	 * Since FOLL_GET calls get_page(), and isolate_lru_page()
+	 * also calls get_page()
+	 */
+	put_page(to_page);
+set_to_status:
+	if (!err) {
+		if ((PageHuge(from_page) != PageHuge(to_page)) ||
+			(PageTransHuge(from_page) != PageTransHuge(to_page))) {
+			list_add(&from_page->lru, &err_page_list);
+			list_add(&to_page->lru, &err_page_list);
+		} else {
+			list_add_tail(&from_page->lru, from_pagelist);
+			list_add_tail(&to_page->lru, to_pagelist);
+		}
+	} else
+		list_add(&from_page->lru, &err_page_list);
+out:
+	if (!list_empty(&err_page_list))
+		putback_movable_pages(&err_page_list);
+	return err;
+}
+/*
+ * Migrate an array of page address onto an array of nodes and fill
+ * the corresponding array of status.
+ */
+static int do_pages_exchange(struct mm_struct *mm, nodemask_t task_nodes,
+			 unsigned long nr_pages,
+			 const void __user * __user *from_pages,
+			 const void __user * __user *to_pages,
+			 int __user *status, int flags)
+{
+	LIST_HEAD(from_pagelist);
+	LIST_HEAD(to_pagelist);
+	int start, i;
+	int err = 0, err1;
+
+	migrate_prep();
+
+	down_read(&mm->mmap_sem);
+	for (i = start = 0; i < nr_pages; i++) {
+		const void __user *from_p, *to_p;
+		unsigned long from_addr, to_addr;
+
+		err = -EFAULT;
+		if (get_user(from_p, from_pages + i))
+			goto out_flush;
+		if (get_user(to_p, to_pages + i))
+			goto out_flush;
+
+		from_addr = (unsigned long)from_p;
+		to_addr = (unsigned long)to_p;
+
+		err = -EACCES;
+		/*
+		 * Errors in the page lookup or isolation are not fatal and we simply
+		 * report them via status
+		 */
+		err = add_page_for_exchange(mm, from_addr, to_addr,
+				&from_pagelist, &to_pagelist,
+				flags & MPOL_MF_MOVE_ALL);
+
+		if (!err)
+			continue;
+
+		err = store_status(status, i, err, 1);
+		if (err)
+			goto out_flush;
+
+		err = do_exchange_page_list(mm, &from_pagelist, &to_pagelist,
+				flags & MPOL_MF_MOVE_MT,
+				flags & MPOL_MF_MOVE_CONCUR);
+		if (err)
+			goto out;
+		if (i > start) {
+			err = store_status(status, start, 0, i - start);
+			if (err)
+				goto out;
+		}
+		start = i;
+	}
+out_flush:
+	/* Make sure we do not overwrite the existing error */
+	err1 = do_exchange_page_list(mm, &from_pagelist, &to_pagelist,
+				flags & MPOL_MF_MOVE_MT,
+				flags & MPOL_MF_MOVE_CONCUR);
+	if (!err1)
+		err1 = store_status(status, start, 0, i - start);
+	if (!err)
+		err = err1;
+out:
+	up_read(&mm->mmap_sem);
+	return err;
+}
+
+SYSCALL_DEFINE6(exchange_pages, pid_t, pid, unsigned long, nr_pages,
+		const void __user * __user *, from_pages,
+		const void __user * __user *, to_pages,
+		int __user *, status, int, flags)
+{
+	const struct cred *cred = current_cred(), *tcred;
+	struct task_struct *task;
+	struct mm_struct *mm;
+	int err;
+	nodemask_t task_nodes;
+
+	/* Check flags */
+	if (flags & ~(MPOL_MF_MOVE|
+				  MPOL_MF_MOVE_ALL|
+				  MPOL_MF_MOVE_MT|
+				  MPOL_MF_MOVE_CONCUR))
+		return -EINVAL;
+
+	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
+		return -EPERM;
+
+	/* Find the mm_struct */
+	rcu_read_lock();
+	task = pid ? find_task_by_vpid(pid) : current;
+	if (!task) {
+		rcu_read_unlock();
+		return -ESRCH;
+	}
+	get_task_struct(task);
+
+	/*
+	 * Check if this process has the right to modify the specified
+	 * process. The right exists if the process has administrative
+	 * capabilities, superuser privileges or the same
+	 * userid as the target process.
+	 */
+	tcred = __task_cred(task);
+	if (!uid_eq(cred->euid, tcred->suid) && !uid_eq(cred->euid, tcred->uid) &&
+	    !uid_eq(cred->uid,  tcred->suid) && !uid_eq(cred->uid,  tcred->uid) &&
+	    !capable(CAP_SYS_NICE)) {
+		rcu_read_unlock();
+		err = -EPERM;
+		goto out;
+	}
+	rcu_read_unlock();
+
+	err = security_task_movememory(task);
+	if (err)
+		goto out;
+
+	task_nodes = cpuset_mems_allowed(task);
+	mm = get_task_mm(task);
+	put_task_struct(task);
+
+	if (!mm)
+		return -EINVAL;
+
+	err = do_pages_exchange(mm, task_nodes, nr_pages, from_pages,
+				    to_pages, status, flags);
+
+	mmput(mm);
+
+	return err;
+
+out:
+	put_task_struct(task);
+
+	return err;
+}
-- 
2.7.4

