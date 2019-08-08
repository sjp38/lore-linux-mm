Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B096FC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5960621773
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:14:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="b+zT0f9f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5960621773
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1EA66B0008; Thu,  8 Aug 2019 19:13:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA6DF6B000A; Thu,  8 Aug 2019 19:13:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D47B86B000C; Thu,  8 Aug 2019 19:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF0246B0008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:13:59 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id f22so2864010qkg.0
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=1e5Y+e42KorvbcxGXpQwcEigXZeGV0ULHZdDaD0hvA4=;
        b=mTQgQroyXFPdDozBxJGxYcr3OdD7NU7MLKyDSS0fXZ5W1OfwLRJ79HNGkVvE/UfaDO
         rFtyOejXfN6Lx3u40FYqspXVwH7V+mBTcEwiw7DzRh1uRLr0J/5xavVnOcVARf52RqAn
         TnYupJCQNAxQdDEb939OXZG/QEywftByl7r3VcsT4us7ydj9vv/k+D5A2UjfdzXPKF7h
         g/jT0AKtekiN8xLgJrn+DytyEV/CHCsJiA7lAo6C/moa8LWkDav6EtRE8VyMTUM8sBUn
         urGUfcXCFgak9V/Cw8hoJ95KqW6gYcIUNXSPnGz4yPl0tc8yBWAELSrKz96HtKognUyz
         ww5Q==
X-Gm-Message-State: APjAAAVqjCx136fJ9/Y4tg8jxpIZUXAT8LifYutFhn20Dn/Our7nq6Cs
	r1D0zXt8YyZFEFJ4bTvxSll2VggfLGZ4mmPJhFlC3FiEBZ8IAc9Db5yPsuApu5VTABsQsKJlnHR
	+S6XW7/W9iMylnNh+QIinQwVcqZsCRrqRWiQFHFCM3PdNBEW948PXUyj+dpE0xBq5QQ==
X-Received: by 2002:a05:620a:5a7:: with SMTP id q7mr16047454qkq.477.1565306039427;
        Thu, 08 Aug 2019 16:13:59 -0700 (PDT)
X-Received: by 2002:a05:620a:5a7:: with SMTP id q7mr16047414qkq.477.1565306038697;
        Thu, 08 Aug 2019 16:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565306038; cv=none;
        d=google.com; s=arc-20160816;
        b=WnXfeaiSv8seAhGZ4V00DWqdo/b0FwzGFX+MQQ+fYAq9BaGbsuxjVDRAWzCz4Gqmkp
         tgX0pxE9L2NspDvI9yewo0V6m4Rpb9ypfu3qr0NQD71qXm5M5yxrVMhBJL1BWsplDxXA
         5M+AnmPV3/0v+r1ViKdxz3tNCawt2BiFVZgkx1LxFSKuBfg59F2e6Or8sX42VuPt2iKi
         vVP2+bOOgcWIJPm5wDaA9CSgjrPWSaj2JR52TB6di+KbX5KKXTkr0MUdQzEoobLjLnn7
         BhDWWY16FCnFjxxvH/VdsQ8PXM0PbqPsTkUSpgSk3EGGnUOH4oHIZS/K4HZ0jEkacs3T
         LQvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=1e5Y+e42KorvbcxGXpQwcEigXZeGV0ULHZdDaD0hvA4=;
        b=eCnukQq+vvD1x4ViCpcAoP2zjcXya1z1HbMLgTQCEJBMp4EKpoTci6FS4tw/nx8rBi
         MyMHrxEyKBlMSmMXlMYFFahY0S+4UnT7rMcdrvQhUctqCjnGqhagD/fjUaap/GcwolXW
         ItXMnZ8fhLCAeJtReOyU5paw9Lz7t4gwyXOpjX17Iru8O0Ui9ikyO75L1qIN8mTN1MyF
         1NdvM5EeJtzJ1FAI6E0EMPR9STOqS8Cdjj9mcY2BdyecGyjE5KVXQvcdKT6m2+QyX2Ph
         F7dq+DaLeRXLS6Wi5rAmrPSUuAun2KZBjBgLOoY4D4jfDJpoDV8eehm71aUYwEgw7eCV
         z4Vg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=b+zT0f9f;
       spf=pass (google.com: domain of 3tqxmxqskcdmpabphgnbxcpvddvat.rdbaxcjm-bbzkprz.dgv@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tqxMXQsKCDMPabPhgnbXcPVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--almasrymina.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f4sor7235673qti.68.2019.08.08.16.13.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 16:13:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tqxmxqskcdmpabphgnbxcpvddvat.rdbaxcjm-bbzkprz.dgv@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=b+zT0f9f;
       spf=pass (google.com: domain of 3tqxmxqskcdmpabphgnbxcpvddvat.rdbaxcjm-bbzkprz.dgv@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tqxMXQsKCDMPabPhgnbXcPVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--almasrymina.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=1e5Y+e42KorvbcxGXpQwcEigXZeGV0ULHZdDaD0hvA4=;
        b=b+zT0f9fu3ULZ0gkfmCIj5ZnufLu5TrTyMwWV6AJcHZSMmCx7vDSJ678HGyeAZNvNR
         HRmHfd11DfakQ4WibruAurLDZaAKlglidQFRwRel4tJ021LGCoozToPmLIDFt7zHH1OO
         lsli6SbS7zTH9Mz7jEgwSq3wYd0RJVOM0WEkDUb6HeLaw3d1WT5JQ1gPstZbdXAIjhkT
         Zk31JWtZT3EoPeJJmuV6/efvk9XKcRoc9S2YhR65FM7YW6fHe5K9v2lNn3b3c6YPzlv6
         B2F7+oVMu6Kf7+vPrHz/b7G9vi4mbpKh2MPYppFHPiPJAjkAl/4VKB1CUO2o15wdpHSt
         CuZQ==
X-Google-Smtp-Source: APXvYqxZsZORtAFxvo/GCCxeazLSDeTloGwWD2nvNdmwV7J3BRRl3Vegc7pnzWtMZdZFgg0hWgmiIgFkIB0uV5GRKw==
X-Received: by 2002:aed:3461:: with SMTP id w88mr15451018qtd.13.1565306038224;
 Thu, 08 Aug 2019 16:13:58 -0700 (PDT)
Date: Thu,  8 Aug 2019 16:13:36 -0700
In-Reply-To: <20190808231340.53601-1-almasrymina@google.com>
Message-Id: <20190808231340.53601-2-almasrymina@google.com>
Mime-Version: 1.0
References: <20190808231340.53601-1-almasrymina@google.com>
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [RFC PATCH v2 1/5] hugetlb_cgroup: Add hugetlb_cgroup reservation counter
From: Mina Almasry <almasrymina@google.com>
To: mike.kravetz@oracle.com
Cc: shuah@kernel.org, almasrymina@google.com, rientjes@google.com, 
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These counters will track hugetlb reservations rather than hugetlb
memory faulted in. This patch only adds the counter, following patches
add the charging and uncharging of the counter.
---
 include/linux/hugetlb.h |  2 +-
 mm/hugetlb_cgroup.c     | 86 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 80 insertions(+), 8 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edfca42783192..6777b3013345d 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -340,7 +340,7 @@ struct hstate {
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 #ifdef CONFIG_CGROUP_HUGETLB
 	/* cgroup control files */
-	struct cftype cgroup_files[5];
+	struct cftype cgroup_files[9];
 #endif
 	char name[HSTATE_NAME_LEN];
 };
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 68c2f2f3c05b7..708103663988a 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -25,6 +25,10 @@ struct hugetlb_cgroup {
 	 * the counter to account for hugepages from hugetlb.
 	 */
 	struct page_counter hugepage[HUGE_MAX_HSTATE];
+	/*
+	 * the counter to account for hugepage reservations from hugetlb.
+	 */
+	struct page_counter reserved_hugepage[HUGE_MAX_HSTATE];
 };

 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
@@ -33,6 +37,15 @@ struct hugetlb_cgroup {

 static struct hugetlb_cgroup *root_h_cgroup __read_mostly;

+static inline
+struct page_counter *get_counter(struct hugetlb_cgroup *h_cg, int idx,
+				 bool reserved)
+{
+	if (reserved)
+		return  &h_cg->reserved_hugepage[idx];
+	return &h_cg->hugepage[idx];
+}
+
 static inline
 struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
 {
@@ -256,28 +269,42 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,

 enum {
 	RES_USAGE,
+	RES_RESERVATION_USAGE,
 	RES_LIMIT,
+	RES_RESERVATION_LIMIT,
 	RES_MAX_USAGE,
+	RES_RESERVATION_MAX_USAGE,
 	RES_FAILCNT,
+	RES_RESERVATION_FAILCNT,
 };

 static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
 				   struct cftype *cft)
 {
 	struct page_counter *counter;
+	struct page_counter *reserved_counter;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);

 	counter = &h_cg->hugepage[MEMFILE_IDX(cft->private)];
+	reserved_counter = &h_cg->reserved_hugepage[MEMFILE_IDX(cft->private)];

 	switch (MEMFILE_ATTR(cft->private)) {
 	case RES_USAGE:
 		return (u64)page_counter_read(counter) * PAGE_SIZE;
+	case RES_RESERVATION_USAGE:
+		return (u64)page_counter_read(reserved_counter) * PAGE_SIZE;
 	case RES_LIMIT:
 		return (u64)counter->max * PAGE_SIZE;
+	case RES_RESERVATION_LIMIT:
+		return (u64)reserved_counter->max * PAGE_SIZE;
 	case RES_MAX_USAGE:
 		return (u64)counter->watermark * PAGE_SIZE;
+	case RES_RESERVATION_MAX_USAGE:
+		return (u64)reserved_counter->watermark * PAGE_SIZE;
 	case RES_FAILCNT:
 		return counter->failcnt;
+	case RES_RESERVATION_FAILCNT:
+		return reserved_counter->failcnt;
 	default:
 		BUG();
 	}
@@ -291,6 +318,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 	int ret, idx;
 	unsigned long nr_pages;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
+	bool reserved = false;

 	if (hugetlb_cgroup_is_root(h_cg)) /* Can't set limit on root */
 		return -EINVAL;
@@ -303,10 +331,16 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 	idx = MEMFILE_IDX(of_cft(of)->private);
 	nr_pages = round_down(nr_pages, 1 << huge_page_order(&hstates[idx]));

+	if (MEMFILE_ATTR(of_cft(of)->private) == RES_RESERVATION_LIMIT) {
+		reserved = true;
+	}
+
 	switch (MEMFILE_ATTR(of_cft(of)->private)) {
+	case RES_RESERVATION_LIMIT:
 	case RES_LIMIT:
 		mutex_lock(&hugetlb_limit_mutex);
-		ret = page_counter_set_max(&h_cg->hugepage[idx], nr_pages);
+		ret = page_counter_set_max(get_counter(h_cg, idx, reserved),
+					   nr_pages);
 		mutex_unlock(&hugetlb_limit_mutex);
 		break;
 	default:
@@ -320,18 +354,26 @@ static ssize_t hugetlb_cgroup_reset(struct kernfs_open_file *of,
 				    char *buf, size_t nbytes, loff_t off)
 {
 	int ret = 0;
-	struct page_counter *counter;
+	struct page_counter *counter, *reserved_counter;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));

 	counter = &h_cg->hugepage[MEMFILE_IDX(of_cft(of)->private)];
+	reserved_counter = &h_cg->reserved_hugepage[
+		MEMFILE_IDX(of_cft(of)->private)];

 	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_MAX_USAGE:
 		page_counter_reset_watermark(counter);
 		break;
+	case RES_RESERVATION_MAX_USAGE:
+		page_counter_reset_watermark(reserved_counter);
+		break;
 	case RES_FAILCNT:
 		counter->failcnt = 0;
 		break;
+	case RES_RESERVATION_FAILCNT:
+		reserved_counter->failcnt = 0;
+		break;
 	default:
 		ret = -EINVAL;
 		break;
@@ -357,7 +399,7 @@ static void __init __hugetlb_cgroup_file_init(int idx)
 	struct hstate *h = &hstates[idx];

 	/* format the size */
-	mem_fmt(buf, 32, huge_page_size(h));
+	mem_fmt(buf, sizeof(buf), huge_page_size(h));

 	/* Add the limit file */
 	cft = &h->cgroup_files[0];
@@ -366,28 +408,58 @@ static void __init __hugetlb_cgroup_file_init(int idx)
 	cft->read_u64 = hugetlb_cgroup_read_u64;
 	cft->write = hugetlb_cgroup_write;

-	/* Add the usage file */
+	/* Add the reservation limit file */
 	cft = &h->cgroup_files[1];
+	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.reservation_limit_in_bytes",
+		 buf);
+	cft->private = MEMFILE_PRIVATE(idx, RES_RESERVATION_LIMIT);
+	cft->read_u64 = hugetlb_cgroup_read_u64;
+	cft->write = hugetlb_cgroup_write;
+
+	/* Add the usage file */
+	cft = &h->cgroup_files[2];
 	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.usage_in_bytes", buf);
 	cft->private = MEMFILE_PRIVATE(idx, RES_USAGE);
 	cft->read_u64 = hugetlb_cgroup_read_u64;

+	/* Add the reservation usage file */
+	cft = &h->cgroup_files[3];
+	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.reservation_usage_in_bytes",
+			buf);
+	cft->private = MEMFILE_PRIVATE(idx, RES_RESERVATION_USAGE);
+	cft->read_u64 = hugetlb_cgroup_read_u64;
+
 	/* Add the MAX usage file */
-	cft = &h->cgroup_files[2];
+	cft = &h->cgroup_files[4];
 	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.max_usage_in_bytes", buf);
 	cft->private = MEMFILE_PRIVATE(idx, RES_MAX_USAGE);
 	cft->write = hugetlb_cgroup_reset;
 	cft->read_u64 = hugetlb_cgroup_read_u64;

+	/* Add the MAX reservation usage file */
+	cft = &h->cgroup_files[5];
+	snprintf(cft->name, MAX_CFTYPE_NAME,
+			"%s.reservation_max_usage_in_bytes", buf);
+	cft->private = MEMFILE_PRIVATE(idx, RES_RESERVATION_MAX_USAGE);
+	cft->write = hugetlb_cgroup_reset;
+	cft->read_u64 = hugetlb_cgroup_read_u64;
+
 	/* Add the failcntfile */
-	cft = &h->cgroup_files[3];
+	cft = &h->cgroup_files[6];
 	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.failcnt", buf);
 	cft->private  = MEMFILE_PRIVATE(idx, RES_FAILCNT);
 	cft->write = hugetlb_cgroup_reset;
 	cft->read_u64 = hugetlb_cgroup_read_u64;

+	/* Add the reservation failcntfile */
+	cft = &h->cgroup_files[7];
+	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.reservation_failcnt", buf);
+	cft->private  = MEMFILE_PRIVATE(idx, RES_FAILCNT);
+	cft->write = hugetlb_cgroup_reset;
+	cft->read_u64 = hugetlb_cgroup_read_u64;
+
 	/* NULL terminate the last cft */
-	cft = &h->cgroup_files[4];
+	cft = &h->cgroup_files[8];
 	memset(cft, 0, sizeof(*cft));

 	WARN_ON(cgroup_add_legacy_cftypes(&hugetlb_cgrp_subsys,
--
2.23.0.rc1.153.gdeed80330f-goog

