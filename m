Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0EBFC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:56:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62DD225919
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:56:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="U3p0Rwbu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62DD225919
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D51F46B026C; Thu, 30 May 2019 08:56:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D028A6B026D; Thu, 30 May 2019 08:56:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF17E6B026E; Thu, 30 May 2019 08:56:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A01D76B026C
	for <linux-mm@kvack.org>; Thu, 30 May 2019 08:56:16 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i196so4725739qke.20
        for <linux-mm@kvack.org>; Thu, 30 May 2019 05:56:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=m11j/gNOc1w/3oqxOsmN4bOzC/13TvTUCwPbj99AGq4=;
        b=to4xuxt+34uhwa4siO5QoFLbiKfNpgnKmvfFIcpAcqZ787D4RQkWAiwI4zlHQCHEB/
         hcw9+RdGSJR2s8uAp+z9WPfuHn8b5yDF5gOwJHnO2mQ9/+B9Ehl6xud3cMkkOFRPFt5G
         fuZASGfgP5GpIpKNUPzJRtVfC7xO0FcTEln8tNlbZ27ShabyKgOX6btZmAIzcAye54M/
         gbivR3KhV1GBSVjAkTs3Z60MJG0nIkDZaIYxbSGb3io40s2FS9jbEJjRktC/Kwp9ZIcM
         YpDXHvCLG8lxHHHwigLEb+GA6xvo3hopF4uyBmGl1N3ijs7ltHaNPIEe0G7ubMnw5mFa
         LzTQ==
X-Gm-Message-State: APjAAAUoJ9WrSErmQ/btqbh9UJoiRs8z5VswiraGxaG+47EZYhBYMgSq
	oXExTw3D1UBkkFHsu4jRPt4KbpAVD0UFNtRhekKrOfYpTriqrbvk5tUTkOxIiRv8iYMC45qeGe8
	vwXyTUyM/pM4mbZhXvAHRDwjZig8RvCg0qBU1zKWbDSDCKkRsw9mzqlBvFDgYXz47rw==
X-Received: by 2002:a0c:b78a:: with SMTP id l10mr3204306qve.62.1559220976353;
        Thu, 30 May 2019 05:56:16 -0700 (PDT)
X-Received: by 2002:a0c:b78a:: with SMTP id l10mr3204247qve.62.1559220975592;
        Thu, 30 May 2019 05:56:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559220975; cv=none;
        d=google.com; s=arc-20160816;
        b=AQROFkRTXg4zcZOLwymt61OBmXtJLSylZFKPfpQ+ciGJxpfa8obYZ0CCwmQ2W8LvE/
         l8ZKrehFtQs78CFMDJPoI3X4B0cOUhHKeNPOBDsEznh01cczQVVcpJ7y5s+q/SMK7t7q
         iaSP0d97aQXBt15JrhLZF2a7i7hnXBqoVvC6PfSjZJPBE8g6R8TCmB4RQZo+QQURqM/x
         faLKWsX51Ez/m+rn6J5ceNltLVwq3Xi3A4ZJIKiAQT8wPHugZ5A3OtnJK1WfZge2wAYH
         843X6g4hYxilCduVqcbR9vP06WKxkm5qZk/PHay/G+xxk6sjZe+EnJSt/bAaMpEKP/Ha
         6udA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=m11j/gNOc1w/3oqxOsmN4bOzC/13TvTUCwPbj99AGq4=;
        b=B+zKCjNzu7JZxp2s42CRp6M9/QPdgEFsiNraC5zzDlgymk1yG/I28C9N9z7mzME59p
         gnofGP5s/NuyT45vw5g0aSCqcCKdOG14dHF9L2Cf/fJnKMfuvOxOhZc7rkDI3CVUOj03
         YcNqqKYgj7WNXAbJKxOegDEqY3m0NbBn1OVdUGlfuPSnfvHonktJD3Y1qfqMSzNq8imY
         0KZueCP4S58SqpYjOgtA/MFhKha3I/PCoTQYKCBVIvzigE4IKUauDI6bP7TVyz6toIrT
         sZTdRGRWsDxKgK7Kspl42KJwSpffScIjzjk7wV0K8Etlabc+DVZ/ZYClSL2K9npVEbJB
         zkhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=U3p0Rwbu;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z40sor2171204qvg.16.2019.05.30.05.56.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 05:56:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=U3p0Rwbu;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=m11j/gNOc1w/3oqxOsmN4bOzC/13TvTUCwPbj99AGq4=;
        b=U3p0Rwbu3DOqRwv1KFoktsVBmhSaEGhbclQX96bGWiPXbTevw90DCpH9+C8OhcOg5c
         R2T0jNdN85kqdEv5h294CX8GDP0nJTdflA2WkjQ6nQoCndHvsDebT5oRxUwQP2rkNm/N
         cZlKArDW975ct+mpI/fb3R0ncTV3ePAs8qu6PBxwkZne1JhNKhw6Kr6oGHUKEDg4RTP4
         vk+xQJw4z19QtHG5f3MRgfFR5p5ZQaRIVkb6fDP+djOPO3lrL+8Kh6ROez/+xtrEMvv6
         ybBxxg6zuZvy7co5sNwvy03NtCoZ0CYjMaln3YfYQX9hrJEm0AfnV1dS4+1xyi9gKNgm
         nyig==
X-Google-Smtp-Source: APXvYqw/80cpKy1geLrXhFGd8uOHZgCtfnZyLJaTqr/FkVp7JyBWsQ16MRrRQMC9MgVB5/OPyuItfQ==
X-Received: by 2002:a0c:e7c7:: with SMTP id c7mr2011877qvo.173.1559220975275;
        Thu, 30 May 2019 05:56:15 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 22sm1532601qto.92.2019.05.30.05.56.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 05:56:14 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: vitalywool@gmail.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/z3fold: fix variable set but not used warnings
Date: Thu, 30 May 2019 08:55:52 -0400
Message-Id: <1559220952-21081-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit f41a586ddc2d ("z3fold: add inter-page compaction")
introduced a few new compilation warnings.

mm/z3fold.c: In function 'compact_single_buddy':
mm/z3fold.c:781:16: warning: variable 'newpage' set but not used
[-Wunused-but-set-variable]
mm/z3fold.c:752:13: warning: variable 'bud' set but not used
[-Wunused-but-set-variable]

It does not seem those variables are actually used, so just remove them.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/z3fold.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 2bc3dbde6255..67c29101ffc5 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -749,7 +749,6 @@ static struct z3fold_header *compact_single_buddy(struct z3fold_header *zhdr)
 	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
 	void *p = zhdr;
 	unsigned long old_handle = 0;
-	enum buddy bud;
 	size_t sz = 0;
 	struct z3fold_header *new_zhdr = NULL;
 	int first_idx = __idx(zhdr, FIRST);
@@ -761,24 +760,20 @@ static struct z3fold_header *compact_single_buddy(struct z3fold_header *zhdr)
 	 * the page lock is already taken
 	 */
 	if (zhdr->first_chunks && zhdr->slots->slot[first_idx]) {
-		bud = FIRST;
 		p += ZHDR_SIZE_ALIGNED;
 		sz = zhdr->first_chunks << CHUNK_SHIFT;
 		old_handle = (unsigned long)&zhdr->slots->slot[first_idx];
 	} else if (zhdr->middle_chunks && zhdr->slots->slot[middle_idx]) {
-		bud = MIDDLE;
 		p += zhdr->start_middle << CHUNK_SHIFT;
 		sz = zhdr->middle_chunks << CHUNK_SHIFT;
 		old_handle = (unsigned long)&zhdr->slots->slot[middle_idx];
 	} else if (zhdr->last_chunks && zhdr->slots->slot[last_idx]) {
-		bud = LAST;
 		p += PAGE_SIZE - (zhdr->last_chunks << CHUNK_SHIFT);
 		sz = zhdr->last_chunks << CHUNK_SHIFT;
 		old_handle = (unsigned long)&zhdr->slots->slot[last_idx];
 	}
 
 	if (sz > 0) {
-		struct page *newpage;
 		enum buddy new_bud = HEADLESS;
 		short chunks = size_to_chunks(sz);
 		void *q;
@@ -787,7 +782,6 @@ static struct z3fold_header *compact_single_buddy(struct z3fold_header *zhdr)
 		if (!new_zhdr)
 			return NULL;
 
-		newpage = virt_to_page(new_zhdr);
 		if (WARN_ON(new_zhdr == zhdr))
 			goto out_fail;
 
-- 
1.8.3.1

