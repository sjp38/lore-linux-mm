Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1388EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D35A12083D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D35A12083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D2508E0009; Wed, 27 Feb 2019 21:18:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12D818E0001; Wed, 27 Feb 2019 21:18:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0442E8E0009; Wed, 27 Feb 2019 21:18:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF1DD8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:52 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b6so14910405qkg.4
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=O/uMqMX1RLXk35wATf5Bntd/FX1DZTwSKmJPgUmEjAI=;
        b=gtisTRX61DG8wJ1sKNqWFwVy/zd0/5PMRSbkmkRxlZPf5z43JHfZXGVmPiekr/DIxy
         plWJ66+XbloBQ+9W1CbLRVzGk22sExQQsYFH8YCBOmmmL8i2ToDpjbym2d0iiCiIcmW5
         F4T2WwrsKrPxRrcoSDMDW1HsMH8Ibm44zb9sQEBNQ3AATJSo3R7QUpw7iYStwmGiRRM7
         mjSMEkBkdIm/hgJlFpe8XOp0JfKkeCIBoADTVb6SySqKMqoakfK1KhljhnzJQXW8aIVM
         AY0FoJJX9rgKRAJ63qNrRGGGtrMmwEUFdRlPcuYqceVtc5kQIPhC0jVyRitFtALCKv5M
         Zo/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWnTFm2LDE/+Qugj3KBaKkolXqsQz+o2e2TnNAEkMUtzfGl3xo4
	4fM+oUy8sCsnuvQieveoAm9gjjqK5GqxaHVB+A05y6c+qLdZUppol6HnQoK1usWEQbbm6EVtHU2
	QVZRifDGY9LtsvsWGiXbWQaCZuyDhZ8M18E8aMCKEOVXr0u2Lc1RFm9pP+dW/RmOcuVgJq2OLId
	3NQxIDZbOmreGwyHzZWnbyn/CMJZGfCNdRjbAkDqVESxJuKwyBma3z68GmIFBnMarliz/aLh4uk
	+9BuoHZi5ar2RCv/z34EMP9orrJ9IUnacN4pjhsuJTxBkKf9efYvAWaXdTllf3BJ1b+Zf6CgwJI
	S9JS6WfZUlUVY6nV9+w1H7k+4vcs+MVltIPFuSzM+XlVHEN3HgNyyXxSAX2eyQa43OliTk7SJw=
	=
X-Received: by 2002:a0c:94cf:: with SMTP id k15mr4534148qvk.55.1551320332607;
        Wed, 27 Feb 2019 18:18:52 -0800 (PST)
X-Received: by 2002:a0c:94cf:: with SMTP id k15mr4534100qvk.55.1551320331465;
        Wed, 27 Feb 2019 18:18:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320331; cv=none;
        d=google.com; s=arc-20160816;
        b=kFSneJFsAWT2nrtqekpsefiP1XMI5ExRewzVIzNkgIh/jhSSoK088vVVUXVFV4k5Q+
         NmKyr8XA9kmwSlTaKjsKaaipH2W8ZXekjbmphRaC4MBCk/kqDinfKb9TihzyIS1GFQGk
         +Ox3sID+PDd2//IEB37b7Ew4wDXbBoL+sMDtGdPS+y6fn2nFgUT6h9lS5F8PpjTE9yEA
         iryFv//EDqxtkLSIO3Uk/j14QxOz0RPLc85R8GHuSETuYitcYnE/wXN7sDtw7NVhRx+i
         gWKheJ5XFD9fq6L5/egtZuf1seD+AfMoWDDOPNjTL5rrB1hO7B0Ogt5khsYvfaYWffyI
         Rb7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=O/uMqMX1RLXk35wATf5Bntd/FX1DZTwSKmJPgUmEjAI=;
        b=Yp+dTE1PhNmgQKndnxjuHTSL2GA/sKw1pbDV23WeHwiXXhbtiZH0AgpUSWD2LzPCVg
         TMVXKLUXxlwZqVTGMd58E9lW8mbf7oyEcO8U70OatTFZlgELer+fifEikBqMovTwB/rN
         BYD+A2OyoLOqGNhJNDI7jk2MtQT2sxC60wK2TVZoJR5QCLyibhbsgs6JYLiTkUcNaUTu
         YgSACefFUJKEdcEmEsqWF5OnesoUaKl9VWHsjwLsbonJlm+Nn+34k2+hVSwpdayT9ML6
         jKFGdE4UcOhMKppHzkxJuxhOzjc8zlkzqhLl6Hk8KPJr+p91RuREDveiDQrYuSlBfIPo
         W+Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n4sor6235267qki.21.2019.02.27.18.18.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:51 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IYECaM0BaxRf5kUox7pcWekLOEUD4uDb49QmaHf/LLer2jiYKA1I5O2KDyJ1YPW/ofrNvgcaQ==
X-Received: by 2002:a37:d6c6:: with SMTP id p67mr4570900qkl.329.1551320331211;
        Wed, 27 Feb 2019 18:18:51 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:50 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 05/12] percpu: relegate chunks unusable when failing small allocations
Date: Wed, 27 Feb 2019 21:18:32 -0500
Message-Id: <20190228021839.55779-6-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In certain cases, requestors of percpu memory may want specific
alignments. However, it is possible to end up in situations where the
contig_hint matches, but the alignment does not. This causes excess
scanning of chunks that will fail. To prevent this, if a small
allocation fails (< 32B), the chunk is moved to the empty list. Once an
allocation is freed from that chunk, it is placed back into rotation.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index c996bcffbb2a..3d7deece9556 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -94,6 +94,8 @@
 
 /* the slots are sorted by free bytes left, 1-31 bytes share the same slot */
 #define PCPU_SLOT_BASE_SHIFT		5
+/* chunks in slots below this are subject to being sidelined on failed alloc */
+#define PCPU_SLOT_FAIL_THRESHOLD	3
 
 #define PCPU_EMPTY_POP_PAGES_LOW	2
 #define PCPU_EMPTY_POP_PAGES_HIGH	4
@@ -488,6 +490,22 @@ static void pcpu_mem_free(void *ptr)
 	kvfree(ptr);
 }
 
+static void __pcpu_chunk_move(struct pcpu_chunk *chunk, int slot,
+			      bool move_front)
+{
+	if (chunk != pcpu_reserved_chunk) {
+		if (move_front)
+			list_move(&chunk->list, &pcpu_slot[slot]);
+		else
+			list_move_tail(&chunk->list, &pcpu_slot[slot]);
+	}
+}
+
+static void pcpu_chunk_move(struct pcpu_chunk *chunk, int slot)
+{
+	__pcpu_chunk_move(chunk, slot, true);
+}
+
 /**
  * pcpu_chunk_relocate - put chunk in the appropriate chunk slot
  * @chunk: chunk of interest
@@ -505,12 +523,8 @@ static void pcpu_chunk_relocate(struct pcpu_chunk *chunk, int oslot)
 {
 	int nslot = pcpu_chunk_slot(chunk);
 
-	if (chunk != pcpu_reserved_chunk && oslot != nslot) {
-		if (oslot < nslot)
-			list_move(&chunk->list, &pcpu_slot[nslot]);
-		else
-			list_move_tail(&chunk->list, &pcpu_slot[nslot]);
-	}
+	if (oslot != nslot)
+		__pcpu_chunk_move(chunk, nslot, oslot < nslot);
 }
 
 /**
@@ -1381,7 +1395,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
 	bool do_warn = !(gfp & __GFP_NOWARN);
 	static int warn_limit = 10;
-	struct pcpu_chunk *chunk;
+	struct pcpu_chunk *chunk, *next;
 	const char *err;
 	int slot, off, cpu, ret;
 	unsigned long flags;
@@ -1443,11 +1457,14 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 restart:
 	/* search through normal chunks */
 	for (slot = pcpu_size_to_slot(size); slot < pcpu_nr_slots; slot++) {
-		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
+		list_for_each_entry_safe(chunk, next, &pcpu_slot[slot], list) {
 			off = pcpu_find_block_fit(chunk, bits, bit_align,
 						  is_atomic);
-			if (off < 0)
+			if (off < 0) {
+				if (slot < PCPU_SLOT_FAIL_THRESHOLD)
+					pcpu_chunk_move(chunk, 0);
 				continue;
+			}
 
 			off = pcpu_alloc_area(chunk, bits, bit_align, off);
 			if (off >= 0)
-- 
2.17.1

