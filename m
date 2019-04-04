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
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE83BC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7498520820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="fCpfmq6r";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xXsEe6Si"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7498520820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EE396B0272; Wed,  3 Apr 2019 22:01:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49C1A6B0274; Wed,  3 Apr 2019 22:01:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 363426B0275; Wed,  3 Apr 2019 22:01:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10B2C6B0272
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:41 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c67so951225qkg.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=wYGW67q2hX0YeFGfjhSH69JcgDm6ztcqTDnUJ+CdMVc=;
        b=N+T11yND7/VXXNH+lAvAS7ecePmd8Od4hwN+gosKhBPW1kZq+MqNtmKWr01qMbcyt+
         X56UbGIVYp5ClXuiGBsGAif4IkixpzlvBunt/D65T1PNUwMR3VSOEwIu7rtMEinPZtnf
         CrPT52ezdhmLdzXKt/WW0rQnezakLa3QQ5zxRludAxLot/iOnnxzlMSP5JEZ3QJd5eZw
         EQiy2HULo4YbiVjDB8SGtR9TUyElvur7VOGL3isMCzXMZhiyTK9TtuT1wWI0eY2YWkBz
         PNPUnvME9LCSZztuYoSVpFaMH2+GUllIHtucBA0/7rM4/PuRxC5IE8UAClkFZ4fHWCKv
         1tVg==
X-Gm-Message-State: APjAAAW8D24yfQSiFeWkYoh8ZG/MPvfdqEMPr31eYEDwWxN33XyJ+/eo
	ta2xgGYT0sqpwcjKuSID3K+Om8kUmtxPH3r2msvhaI4yPpLCmfa8fCgSsxnuPKdAQq4mv9i3Vtd
	j9rMRKdIkCgvDP8btb6iU7M3MJPHOidBIXMcT9lQ3fZCRSlTAjmq765pv2hKhzSQWDw==
X-Received: by 2002:ae9:ef07:: with SMTP id d7mr3047462qkg.100.1554343300797;
        Wed, 03 Apr 2019 19:01:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzID+DxAG8H+kVhR4jJwrhHXHLA/Jm9U/7MJhCO6oNRX2QeDxlkK7WMrUHfDrC6YOqBoOkb
X-Received: by 2002:ae9:ef07:: with SMTP id d7mr3047360qkg.100.1554343299254;
        Wed, 03 Apr 2019 19:01:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343299; cv=none;
        d=google.com; s=arc-20160816;
        b=CfjGj4GskgAFLd4MZYqZi7j3qxRFY6+RmE+phzdiLY44wQ5mwWVsiLiZ2Vs2wzkMoq
         mVJDQLJj+tmSXal0upeAUPWXqqfUj7D12qvlVxJZKMvUMmluqH0qMbJSjkxUwvAL5+ZE
         rT5IU619ji/rYEfKVozH2j4A3Wrtg+nQDUH88YJdo7UGruLSRjuxx8zlvD/ExN5RorJe
         i29LQU+P4xQcuG0VpQ4ZVeCh0loQHsa3TIcrSRFxZDdDltj8Ez21hB9IxJCavg9gWbR/
         FZuXQMtxi0yPtPuIx8mJWwOmajuzPiM2Dka117xYdZWI1GkJqaYA150fjrtsuaRPo8mk
         vdIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=wYGW67q2hX0YeFGfjhSH69JcgDm6ztcqTDnUJ+CdMVc=;
        b=Qb8y+cQp6b+Gj2f1ctHpU69lzsXmC1xSq806LztLCn1beo0jBVmFcKJ39ImocH9j6A
         vOXwOX/N6TZdJ//8MvF+nn8NMblAZ9cQ9PEsOSc3Zk3U5KX7u9LjweJtNZEQoFGb9jnC
         D6g+ycCQToSROWorgBA5wX7FS+qYEodLCFVHZpI3M3mgg/1smKPj4MQDiODRUIs/MPI+
         E8Burz4YAr78kTb0VxGyXJN3UBZI+eDn9Ri0sYQYBRNTcqW05RMsfxQ46fpFR6xiynWQ
         5zZvVQ0UNLp0mmj3vMGPaAkrtYPcUvwijMzoCBHtgqn+YSC4k8jDOgl4RXmTyLhK3rBF
         njpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=fCpfmq6r;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=xXsEe6Si;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id h4si3685063qta.351.2019.04.03.19.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=fCpfmq6r;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=xXsEe6Si;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id E70A7228D4;
	Wed,  3 Apr 2019 22:01:38 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=wYGW67q2hX0Ye
	FGfjhSH69JcgDm6ztcqTDnUJ+CdMVc=; b=fCpfmq6ri4dvlPq3glhihZTgdw/hw
	y57u+VkeKxBP8eQp2qDCAalNUl2bFcPcG+Ve9QXMaA1tUHpGszvCvsnuYG7YTCDw
	qjy1kW4mGX21k0APvAHWLqMcWpB1W8Ml7PHpOJFvvtwEumCCUThHvi0YszBgtMZD
	tzzIbtMx0K8nVBkI3vN/D1blcoUge/fgWytVPLBjvZig3t3G+68jSWbOYiPexSC7
	0shMeh+zTCp/miMOrmSb94BbkaxcOhVyUXUZGOnFaqsiwrmb6MG+sHfx52+6zlat
	vObGBzHTGr0yKm4WimYoMD75+c7kFcl8JwN8DLvrqeuxc1f08OUWmVgjA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=wYGW67q2hX0YeFGfjhSH69JcgDm6ztcqTDnUJ+CdMVc=; b=xXsEe6Si
	1I8CPRa6jVORnOP1UG1J9zV9dqjQzPZvEgfE042iVdXe2PsHYWRZMFVE3Hbrwopa
	f+2YKs/HkBjAI4/ULj6tMuc532L/+pTneOm7/rr5pmiDGrkA4LAv6C0BbB7XdbzQ
	2+yRetPTS0NnCZ8Nce1z4SQbI/PImyqWsP6XhIVud4EzCRTMhcpsaZwzDlOdJ/XE
	UZzwJlpSsbzvvt3//rRdOw20NnW025+HOW5ePBYqsFaDvzxsqsctyvOWTPfvGm7d
	PTEs6huvl02cUunBGyokQTxwIfcOaKmAIb32fbOpFMDzLmL0bFym7APyDbd/o9hQ
	G/hxmkHOS+3PBQ==
X-ME-Sender: <xms:gmWlXHKMIsoQDWOcX3TfNs0F8LfH1oPqXuLL-m38NfZjRZCU0fhexA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepuddt
X-ME-Proxy: <xmx:gmWlXPYEJEKNf8tS-K03P9wEb93pnhCjaf39HSX5otNlDu3-JH545Q>
    <xmx:gmWlXMrYenYz42pjJWEXQtMsWi-zY_aE8snQoyfaGrny5miv7ah3JQ>
    <xmx:gmWlXPFK27rBuEv-BhL0zmSdBdE3nbGiXSeIWKPLIkeQQnOEQMiBZA>
    <xmx:gmWlXFa5jiHcmTMZy5xq7dHQ5LCZM7bHAKLcezKkapmBexRvIZei-w>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id D4DCF10310;
	Wed,  3 Apr 2019 22:01:36 -0400 (EDT)
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
Subject: [RFC PATCH 14/25] exchange pages: concurrent exchange pages.
Date: Wed,  3 Apr 2019 19:00:35 -0700
Message-Id: <20190404020046.32741-15-zi.yan@sent.com>
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

It unmaps two lists of pages, then exchange them in
exchange_page_lists_mthread(), and finally remaps both lists of
pages.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/exchange.h |   2 +
 mm/exchange.c            | 397 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/exchange_page.c       |   1 -
 3 files changed, 399 insertions(+), 1 deletion(-)

diff --git a/include/linux/exchange.h b/include/linux/exchange.h
index 778068e..20d2184 100644
--- a/include/linux/exchange.h
+++ b/include/linux/exchange.h
@@ -20,4 +20,6 @@ struct exchange_page_info {
 int exchange_pages(struct list_head *exchange_list,
 			enum migrate_mode mode,
 			int reason);
+int exchange_pages_concur(struct list_head *exchange_list,
+		enum migrate_mode mode, int reason);
 #endif /* _LINUX_EXCHANGE_H */
diff --git a/mm/exchange.c b/mm/exchange.c
index ce2c899..bbada58 100644
--- a/mm/exchange.c
+++ b/mm/exchange.c
@@ -600,3 +600,400 @@ int exchange_pages(struct list_head *exchange_list,
 	}
 	return failed;
 }
+
+
+static int unmap_pair_pages_concur(struct exchange_page_info *one_pair,
+				int force, enum migrate_mode mode)
+{
+	int rc = -EAGAIN;
+	struct anon_vma *anon_vma_from_page = NULL, *anon_vma_to_page = NULL;
+	struct page *from_page = one_pair->from_page;
+	struct page *to_page = one_pair->to_page;
+
+	/* from_page lock down  */
+	if (!trylock_page(from_page)) {
+		if (!force || ((mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC))
+			goto out;
+
+		lock_page(from_page);
+	}
+
+	BUG_ON(PageWriteback(from_page));
+
+	/*
+	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
+	 * we cannot notice that anon_vma is freed while we migrates a page.
+	 * This get_anon_vma() delays freeing anon_vma pointer until the end
+	 * of migration. File cache pages are no problem because of page_lock()
+	 * File Caches may use write_page() or lock_page() in migration, then,
+	 * just care Anon page here.
+	 *
+	 * Only page_get_anon_vma() understands the subtleties of
+	 * getting a hold on an anon_vma from outside one of its mms.
+	 * But if we cannot get anon_vma, then we won't need it anyway,
+	 * because that implies that the anon page is no longer mapped
+	 * (and cannot be remapped so long as we hold the page lock).
+	 */
+	if (PageAnon(from_page) && !PageKsm(from_page))
+		one_pair->from_anon_vma = anon_vma_from_page
+					= page_get_anon_vma(from_page);
+
+	/* to_page lock down  */
+	if (!trylock_page(to_page)) {
+		if (!force || ((mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC))
+			goto out_unlock;
+
+		lock_page(to_page);
+	}
+
+	BUG_ON(PageWriteback(to_page));
+
+	/*
+	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
+	 * we cannot notice that anon_vma is freed while we migrates a page.
+	 * This get_anon_vma() delays freeing anon_vma pointer until the end
+	 * of migration. File cache pages are no problem because of page_lock()
+	 * File Caches may use write_page() or lock_page() in migration, then,
+	 * just care Anon page here.
+	 *
+	 * Only page_get_anon_vma() understands the subtleties of
+	 * getting a hold on an anon_vma from outside one of its mms.
+	 * But if we cannot get anon_vma, then we won't need it anyway,
+	 * because that implies that the anon page is no longer mapped
+	 * (and cannot be remapped so long as we hold the page lock).
+	 */
+	if (PageAnon(to_page) && !PageKsm(to_page))
+		one_pair->to_anon_vma = anon_vma_to_page = page_get_anon_vma(to_page);
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
+					   !anon_vma_from_page, from_page);
+		try_to_unmap(from_page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+
+		one_pair->from_page_was_mapped = 1;
+	}
+
+	if (!to_page->mapping) {
+		VM_BUG_ON_PAGE(PageAnon(to_page), to_page);
+		if (page_has_private(to_page)) {
+			try_to_free_buffers(to_page);
+			goto out_unlock_both;
+		}
+	} else if (page_mapped(to_page)) {
+		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(to_page) && !PageKsm(to_page) &&
+					   !anon_vma_to_page, to_page);
+		try_to_unmap(to_page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+
+		one_pair->to_page_was_mapped = 1;
+	}
+
+	return MIGRATEPAGE_SUCCESS;
+
+out_unlock_both:
+	if (anon_vma_to_page)
+		put_anon_vma(anon_vma_to_page);
+	unlock_page(to_page);
+out_unlock:
+	/* Drop an anon_vma reference if we took one */
+	if (anon_vma_from_page)
+		put_anon_vma(anon_vma_from_page);
+	unlock_page(from_page);
+out:
+
+	return rc;
+}
+
+static int exchange_page_mapping_concur(struct list_head *unmapped_list_ptr,
+					   struct list_head *exchange_list_ptr,
+						enum migrate_mode mode)
+{
+	int rc = -EBUSY;
+	int nr_failed = 0;
+	struct address_space *to_page_mapping, *from_page_mapping;
+	struct exchange_page_info *one_pair, *one_pair2;
+
+	list_for_each_entry_safe(one_pair, one_pair2, unmapped_list_ptr, list) {
+		struct page *from_page = one_pair->from_page;
+		struct page *to_page = one_pair->to_page;
+
+		VM_BUG_ON_PAGE(!PageLocked(from_page), from_page);
+		VM_BUG_ON_PAGE(!PageLocked(to_page), to_page);
+
+		/* copy page->mapping not use page_mapping()  */
+		to_page_mapping = page_mapping(to_page);
+		from_page_mapping = page_mapping(from_page);
+
+		BUG_ON(from_page_mapping);
+		BUG_ON(to_page_mapping);
+
+		BUG_ON(PageWriteback(from_page));
+		BUG_ON(PageWriteback(to_page));
+
+		/* actual page mapping exchange */
+		rc = exchange_page_move_mapping(to_page_mapping, from_page_mapping,
+							to_page, from_page, mode, 0, 0);
+
+		if (rc) {
+			if (one_pair->from_page_was_mapped)
+				remove_migration_ptes(from_page, from_page, false);
+			if (one_pair->to_page_was_mapped)
+				remove_migration_ptes(to_page, to_page, false);
+
+			if (one_pair->from_anon_vma)
+				put_anon_vma(one_pair->from_anon_vma);
+			unlock_page(from_page);
+
+			if (one_pair->to_anon_vma)
+				put_anon_vma(one_pair->to_anon_vma);
+			unlock_page(to_page);
+
+			mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+					page_is_file_cache(from_page), -hpage_nr_pages(from_page));
+			putback_lru_page(from_page);
+
+			mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+					page_is_file_cache(to_page), -hpage_nr_pages(to_page));
+			putback_lru_page(to_page);
+
+			one_pair->from_page = NULL;
+			one_pair->to_page = NULL;
+
+			list_move(&one_pair->list, exchange_list_ptr);
+			++nr_failed;
+		}
+	}
+
+	return nr_failed;
+}
+
+static int exchange_page_data_concur(struct list_head *unmapped_list_ptr,
+									enum migrate_mode mode)
+{
+	struct exchange_page_info *one_pair;
+	int num_pages = 0, idx = 0;
+	struct page **src_page_list = NULL, **dst_page_list = NULL;
+	unsigned long size = 0;
+	int rc = -EFAULT;
+
+	if (list_empty(unmapped_list_ptr))
+		return 0;
+
+	/* form page list  */
+	list_for_each_entry(one_pair, unmapped_list_ptr, list) {
+		++num_pages;
+		size += PAGE_SIZE * hpage_nr_pages(one_pair->from_page);
+	}
+
+	src_page_list = kzalloc(sizeof(struct page *)*num_pages, GFP_KERNEL);
+	if (!src_page_list)
+		return -ENOMEM;
+	dst_page_list = kzalloc(sizeof(struct page *)*num_pages, GFP_KERNEL);
+	if (!dst_page_list)
+		return -ENOMEM;
+
+	list_for_each_entry(one_pair, unmapped_list_ptr, list) {
+		src_page_list[idx] = one_pair->from_page;
+		dst_page_list[idx] = one_pair->to_page;
+		++idx;
+	}
+
+	BUG_ON(idx != num_pages);
+
+
+	if (mode & MIGRATE_MT)
+		rc = exchange_page_lists_mthread(dst_page_list, src_page_list,
+				num_pages);
+
+	if (rc) {
+		list_for_each_entry(one_pair, unmapped_list_ptr, list) {
+			if (PageHuge(one_pair->from_page) ||
+				PageTransHuge(one_pair->from_page)) {
+				exchange_huge_page(one_pair->to_page, one_pair->from_page);
+			} else {
+				exchange_highpage(one_pair->to_page, one_pair->from_page);
+			}
+		}
+	}
+
+	kfree(src_page_list);
+	kfree(dst_page_list);
+
+	list_for_each_entry(one_pair, unmapped_list_ptr, list) {
+		exchange_page_flags(one_pair->to_page, one_pair->from_page);
+	}
+
+	return rc;
+}
+
+static int remove_migration_ptes_concur(struct list_head *unmapped_list_ptr)
+{
+	struct exchange_page_info *iterator;
+
+	list_for_each_entry(iterator, unmapped_list_ptr, list) {
+		remove_migration_ptes(iterator->from_page, iterator->to_page, false);
+		remove_migration_ptes(iterator->to_page, iterator->from_page, false);
+
+
+		if (iterator->from_anon_vma)
+			put_anon_vma(iterator->from_anon_vma);
+		unlock_page(iterator->from_page);
+
+
+		if (iterator->to_anon_vma)
+			put_anon_vma(iterator->to_anon_vma);
+		unlock_page(iterator->to_page);
+
+
+		putback_lru_page(iterator->from_page);
+		iterator->from_page = NULL;
+
+		putback_lru_page(iterator->to_page);
+		iterator->to_page = NULL;
+	}
+
+	return 0;
+}
+
+int exchange_pages_concur(struct list_head *exchange_list,
+		enum migrate_mode mode, int reason)
+{
+	struct exchange_page_info *one_pair, *one_pair2;
+	int pass = 0;
+	int retry = 1;
+	int nr_failed = 0;
+	int nr_succeeded = 0;
+	int rc = 0;
+	LIST_HEAD(serialized_list);
+	LIST_HEAD(unmapped_list);
+
+	for(pass = 0; pass < 1 && retry; pass++) {
+		retry = 0;
+
+		/* unmap and get new page for page_mapping(page) == NULL */
+		list_for_each_entry_safe(one_pair, one_pair2, exchange_list, list) {
+			struct page *from_page = one_pair->from_page;
+			struct page *to_page = one_pair->to_page;
+			cond_resched();
+
+			if (page_count(from_page) == 1) {
+				/* page was freed from under us. So we are done  */
+				ClearPageActive(from_page);
+				ClearPageUnevictable(from_page);
+
+				put_page(from_page);
+				dec_node_page_state(from_page, NR_ISOLATED_ANON +
+						page_is_file_cache(from_page));
+
+				if (page_count(to_page) == 1) {
+					ClearPageActive(to_page);
+					ClearPageUnevictable(to_page);
+					put_page(to_page);
+				} else {
+					mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+							page_is_file_cache(to_page), -hpage_nr_pages(to_page));
+					putback_lru_page(to_page);
+				}
+				list_del(&one_pair->list);
+
+				continue;
+			}
+
+			if (page_count(to_page) == 1) {
+				/* page was freed from under us. So we are done  */
+				ClearPageActive(to_page);
+				ClearPageUnevictable(to_page);
+
+				put_page(to_page);
+
+				dec_node_page_state(to_page, NR_ISOLATED_ANON +
+						page_is_file_cache(to_page));
+
+				mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+						page_is_file_cache(from_page), -hpage_nr_pages(from_page));
+				putback_lru_page(from_page);
+
+				list_del(&one_pair->list);
+				continue;
+			}
+		/* We do not exchange huge pages and file-backed pages concurrently */
+			if (PageHuge(one_pair->from_page) || PageHuge(one_pair->to_page)) {
+				rc = -ENODEV;
+			}
+			else if ((page_mapping(one_pair->from_page) != NULL) ||
+					 (page_mapping(one_pair->from_page) != NULL)) {
+				rc = -ENODEV;
+			}
+			else
+				rc = unmap_pair_pages_concur(one_pair, 1, mode);
+
+			switch(rc) {
+			case -ENODEV:
+				list_move(&one_pair->list, &serialized_list);
+				break;
+			case -ENOMEM:
+				goto out;
+			case -EAGAIN:
+				retry++;
+				break;
+			case MIGRATEPAGE_SUCCESS:
+				list_move(&one_pair->list, &unmapped_list);
+				nr_succeeded++;
+				break;
+			default:
+				/*
+				 * Permanent failure (-EBUSY, -ENOSYS, etc.):
+				 * unlike -EAGAIN case, the failed page is
+				 * removed from migration page list and not
+				 * retried in the next outer loop.
+				 */
+				list_move(&one_pair->list, &serialized_list);
+				nr_failed++;
+				break;
+			}
+		}
+
+		/* move page->mapping to new page, only -EAGAIN could happen  */
+		exchange_page_mapping_concur(&unmapped_list, exchange_list, mode);
+
+
+		/* copy pages in unmapped_list */
+		exchange_page_data_concur(&unmapped_list, mode);
+
+
+		/* remove migration pte, if old_page is NULL?, unlock old and new
+		 * pages, put anon_vma, put old and new pages */
+		remove_migration_ptes_concur(&unmapped_list);
+	}
+
+	nr_failed += retry;
+	rc = nr_failed;
+
+	exchange_pages(&serialized_list, mode, reason);
+out:
+	list_splice(&unmapped_list, exchange_list);
+	list_splice(&serialized_list, exchange_list);
+
+	return nr_failed?-EFAULT:0;
+}
diff --git a/mm/exchange_page.c b/mm/exchange_page.c
index 6054697..5dba0a6 100644
--- a/mm/exchange_page.c
+++ b/mm/exchange_page.c
@@ -126,7 +126,6 @@ int exchange_page_lists_mthread(struct page **to, struct page **from, int nr_pag
 	int to_node = page_to_nid(*to);
 	int i;
 	struct copy_page_info *work_items;
-	int nr_pages_per_page = hpage_nr_pages(*from);
 	const struct cpumask *per_node_cpumask = cpumask_of_node(to_node);
 	int cpu_id_list[32] = {0};
 	int cpu;
-- 
2.7.4

