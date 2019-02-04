Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4A10C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 12:01:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 749662176F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 12:01:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 749662176F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD0658E003F; Mon,  4 Feb 2019 07:01:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C81778E001C; Mon,  4 Feb 2019 07:01:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B98208E003F; Mon,  4 Feb 2019 07:01:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 664A08E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 07:01:15 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so5915738edc.9
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 04:01:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DUDeaUultJTCbcVNFgMhm03+XXMrysryOdcNTXsIPJ4=;
        b=jpX3eCGU9ZhVhRyWNxtcsfoyZmAGbQKHBZPuPfUw9CtB+OzhWCWxyMPbVruSxNXWt9
         ZN1va2rE9pMIiaaUyb9pA9r0NbN39gad4KGB3ooQddmVUT2Uhuw9uB+NMptGGzu5YUOl
         ns32fIkkJrJTSdXN2LtOAcy+zsmHhiRhjWLLd5pbkgunH4LF4I51ViW7XQTp7+Ah4P8u
         HW0Ohc/YSibWXLwHM/ySiCRLfCQ8v7Z/LU+61Cf8NX3teLAhhUgX8d84pGln0A1s6CVJ
         YMVSSYJiYfweUsiRKQFFlsLc9MxaYGfaRDskjtLkRBSI/Ofeti11ck0ssho+BSs2KFRv
         hxiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.13 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AJcUukfq2sOD/5cNuUdBBJ001JzcBCMJ2gIPdMvvetVkEDJ5IxjG2Eg9
	k0Qqp++0osHT2ABQFxfuIRx6TQaXbqhsM13KVSUmQRAJaEzxyxxNq/lGx5z0Qa5yHpO6DY/BKi8
	dSmpo6pDnuxppNCv9GIcl/XXBsDBGnJ83hrCm6etELQCdrqPPAiuXUWBXkwYjLRkpqw==
X-Received: by 2002:a17:906:f146:: with SMTP id gw6mr45267904ejb.176.1549281674822;
        Mon, 04 Feb 2019 04:01:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Onc8mo1CdUIDgekit/l7f/eSfE/hPGUD0QUNp4Kf5a52ySaNzqIXtuCsQZbMF0LFw5QK6
X-Received: by 2002:a17:906:f146:: with SMTP id gw6mr45267816ejb.176.1549281673353;
        Mon, 04 Feb 2019 04:01:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549281673; cv=none;
        d=google.com; s=arc-20160816;
        b=shda0cnb0JSuJFH1KrkhZdFT7s0JZf7/PtGYymTrZGFFgbGYu0PjZsKVJCKbFwehDq
         hoaxWOmr5TzsrniglzcHTQIrV3nfJDoI4QMhTsLKCjqWpJRurl+vqBTCIoFycMaIVokI
         InlPeg+OEtAFniZorT2cH7hqUrLh+yu8SCReVFVqJ+SV7coqu3v2zPlsdi9J3omGK37K
         tffdBQ18U0wBPZSr8o3LSP4UfvIcFx6NOdQXK+6IxDoFcuftD0yqCynGDEJ9kmTnrLpT
         sw4mkJbPTpLRbXeXmykmuyIRGjT3xtIKK7dr7fqnQPTuwnBuPtezGkm9ZWUFmuyffKqi
         dmkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DUDeaUultJTCbcVNFgMhm03+XXMrysryOdcNTXsIPJ4=;
        b=N1FpQqzEy51ieriyTX5tirMC3/VTWq5EcP2J6/ICNOTialOKT/dEJ2teuPKB4IyxxX
         Xb+tAL5C9pgq1yNDOCY0NUi2uK6g5oFe4jZXOYTEulpGigrfpS7cZ85gT1cS7LqdapAQ
         dN8ncPKncAumV9Wiya+PkPyxAl9Ob5aHZ/5IqKwCc+/SjoxQ//87Dwbtc7J3/eV2OmNP
         y4VNOtguWQf9WzqZvOK+Snlutahqz95g5HYm/JjjyKyWXzzMB/hyqTNxp4TobG+tsefn
         BhK8+rMSUzoKrLf8kSxRbvyRQqJJvOzQsZr2DKxca44rQjocRQlOyfWvyIC3uCDLsekh
         BglQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.13 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id h17si1490542ejj.234.2019.02.04.04.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 04:01:13 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.13 as permitted sender) client-ip=46.22.139.13;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.13 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id D19D71C25EA
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 12:01:12 +0000 (GMT)
Received: (qmail 3119 invoked from network); 4 Feb 2019 12:01:12 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 4 Feb 2019 12:01:12 -0000
Date: Mon, 4 Feb 2019 12:01:11 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: [PATCH] mm, compaction: Use free lists to quickly locate a migration
 source -fix
Message-ID: <20190204120111.GL9565@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-12-mgorman@techsingularity.net>
 <81e45dc0-c107-015b-e167-19d7ca4b6374@suse.cz>
 <20190201145139.GI9565@techsingularity.net>
 <cb0bae2e-8628-1378-68a1-9da02a94652e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <cb0bae2e-8628-1378-68a1-9da02a94652e@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vlastimil correctly pointed out that when a fast search fails and cc->migrate_pfn
is reinitialised to the lowest PFN found that the caller does not use the updated
PFN.

He also pointed out that there is an inconsistency between
move_freelist_head and move_freelist_tail. This patch adds a new helper
and uses it in move_freelist_tail so that list manipulations are avoided
if the first list item traversed is a suitable migration source. The
end result will be that the helpers should be symmetrical and it's been
confirmed that the scan rates are slightly improved as a result of the
fix but not enough to rewrite the changelogs.

This is a fix for the mmotm patch
mm-compaction-use-free-lists-to-quickly-locate-a-migration-source.patch . It's
been provided as a combined patch as the first patch is not picked up at the
time of writing and a rolled up patch is less likely to fall through the cracks.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/gpu/drm/i915/i915_utils.h |  6 ------
 include/linux/list.h              | 11 +++++++++++
 mm/compaction.c                   | 10 ++++++----
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_utils.h b/drivers/gpu/drm/i915/i915_utils.h
index 9726df37c4c4..540e20eb032c 100644
--- a/drivers/gpu/drm/i915/i915_utils.h
+++ b/drivers/gpu/drm/i915/i915_utils.h
@@ -123,12 +123,6 @@ static inline u64 ptr_to_u64(const void *ptr)
 
 #include <linux/list.h>
 
-static inline int list_is_first(const struct list_head *list,
-				const struct list_head *head)
-{
-	return head->next == list;
-}
-
 static inline void __list_del_many(struct list_head *head,
 				   struct list_head *first)
 {
diff --git a/include/linux/list.h b/include/linux/list.h
index edb7628e46ed..79626b5ab36c 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -206,6 +206,17 @@ static inline void list_bulk_move_tail(struct list_head *head,
 	head->prev = last;
 }
 
+/**
+ * list_is_first -- tests whether @ list is the first entry in list @head
+ * @list: the entry to test
+ * @head: the head of the list
+ */
+static inline int list_is_first(const struct list_head *list,
+					const struct list_head *head)
+{
+	return list->prev == head;
+}
+
 /**
  * list_is_last - tests whether @list is the last entry in list @head
  * @list: the entry to test
diff --git a/mm/compaction.c b/mm/compaction.c
index 92d10eb3d1c7..55f7ab142af2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1062,7 +1062,7 @@ move_freelist_tail(struct list_head *freelist, struct page *freepage)
 {
 	LIST_HEAD(sublist);
 
-	if (!list_is_last(freelist, &freepage->lru)) {
+	if (!list_is_first(freelist, &freepage->lru)) {
 		list_cut_position(&sublist, freelist, &freepage->lru);
 		if (!list_empty(&sublist))
 			list_splice_tail(&sublist, freelist);
@@ -1238,14 +1238,16 @@ update_fast_start_pfn(struct compact_control *cc, unsigned long pfn)
 	cc->fast_start_pfn = min(cc->fast_start_pfn, pfn);
 }
 
-static inline void
+static inline unsigned long
 reinit_migrate_pfn(struct compact_control *cc)
 {
 	if (!cc->fast_start_pfn || cc->fast_start_pfn == ULONG_MAX)
-		return;
+		return cc->migrate_pfn;
 
 	cc->migrate_pfn = cc->fast_start_pfn;
 	cc->fast_start_pfn = ULONG_MAX;
+
+	return cc->migrate_pfn;
 }
 
 /*
@@ -1361,7 +1363,7 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 	 * that had free pages as the basis for starting a linear scan.
 	 */
 	if (pfn == cc->migrate_pfn)
-		reinit_migrate_pfn(cc);
+		pfn = reinit_migrate_pfn(cc);
 
 	return pfn;
 }

