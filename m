Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CED87C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93F292083D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93F292083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA63E8E000C; Wed, 27 Feb 2019 21:18:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A31C28E0001; Wed, 27 Feb 2019 21:18:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 922678E000C; Wed, 27 Feb 2019 21:18:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 592C68E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:58 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z123so851683qka.20
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sHVgXKJ/dpov8r/5Fytj2IJVQNeHCHiREVwJuyicgyI=;
        b=V3ocTyXyH57guqwyRas/QCwcsLyh52Dp/mbeSraYht9Z71FsooCP1Uz9PSHqqGEO+4
         26+WvXi5JHcVKImd/H0WVt4iLdxd7IvVLWD62Sb22/NEhhQqz/SOxLPlae7vnU+ZxcbF
         WYrs/uavIgOybv+W6vF1iSXiA+j4AsHxxX3eTrmuIG4Qddod9RPHtKOno1wpCjQdJjjd
         p/gvTojU6nok/EJNYABUU2b6GcOIycBcYWShweyflD668MgqTRtSih0fPtEBRIiFukse
         NhmDCP9v3HfIT0PsD4A530iCQ7gqxq4d/XL6XygY6I3aM4FokIOro1S9hG5Ia/bueR/0
         qf7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU9XtIEQA9tuhG6ERBrPKllpJEdqxOH0a1BbAPVK9ksCl8jUiPo
	J4TIvTeV2Hna498YmptXtflvytlK1cJpnwE1BV+kVJD9LRHIXfpCCfBKEG6luiVPiigqmn6XbSj
	X86OJXn5IEljN1Z3QFk0hjS195F/cjCevNlD+LGSw8Uj/IvoQQmEWjIscV1y9W9Oog6BYL80Jg3
	5AT7fJnKYyAxyRCHWIYBOTBH+cH54CjXB0td+4KbpNxlcH/ceYpMMP0XINVDrhYbpUAYkMWxTdA
	wuuEIPoGaj1b5/erIE+ySADwMY/h4gEGLsT5+1X/yuHh1mU8Oc4rzcQYDVyJRmy2XTjV5c5nkIP
	wB0AejPX6Z6ceYwQJewbCiXN2hqAFyPjsR15JGf8PAhQ5v5tdheM244LEpYwBd98IXn/dCY1NA=
	=
X-Received: by 2002:a0c:e64f:: with SMTP id c15mr4580319qvn.16.1551320338151;
        Wed, 27 Feb 2019 18:18:58 -0800 (PST)
X-Received: by 2002:a0c:e64f:: with SMTP id c15mr4580292qvn.16.1551320337433;
        Wed, 27 Feb 2019 18:18:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320337; cv=none;
        d=google.com; s=arc-20160816;
        b=d/ucq2ScAFqNK9rnV4mpNC5okd5m1r/C3GDURs6VfGV+MzIKtNJd/pNw7f64BqcAjy
         ins/ntFgB9X5P82vNBjLhLUUJZGNjKBVMslKy9gU3kh+ZZTppD4Dfwtb2y4UpyTTyikD
         XqnE9O2cdU8tMPwub1m/BqP4bOTOEoSpVX9tEmQ4nmAOnrrOR2y1j0YSS4LQaD5HyRTj
         iAKKuHhyFieDAjRDQdCh+8MrNL3y/BiDOOH9ACEQVIZLY4sAdJwwZKD4q72/NHXsL5eb
         H+Sc8yFX6Rq8tZBUpbaI5mWpniICRck1RLZvCBbc+6AECNPUMz+Z5r+xifm0lUTecMGM
         7loQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sHVgXKJ/dpov8r/5Fytj2IJVQNeHCHiREVwJuyicgyI=;
        b=B6+4eRjW1tk2TG3hsjsW/uOvrX1tg8VVQtV+A2Tg7Za0AGVElkQ0sc0mE19Vb+zRLF
         jvxkd5AAWSVLewiXxni5ogSmk0UpHhjKGV31xkC47PhUrGHU4OoWSAEJipgJS8N1WJ7O
         +PYjwJfVFbN3AegEmCOR4q3wMuwPYL2I6kasnADDQ1x+6nX/+YAdmTDkAZG2AZMeN3/8
         hah2c7V4Jw2ELpLV5bJMbdyuwtLOquyUTGSn6Lf87Vi+U3DrsSV3isLRcBj6uAkubvbL
         yaxpp4w7KILijxUpi3uqZ+yHdZSMu4tZtQ6fQ2m+Z7TxtONfm/vla44rLwc9vXXDHrFV
         39KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n123sor9929881qkf.76.2019.02.27.18.18.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:57 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwo0bo97d7l1mZByOoZbYpzKXCP3xYjF3Kj+XUDGx0YrEYUpXA0XMb+iahfYNEOWMBz/mI7Pg==
X-Received: by 2002:a37:4d52:: with SMTP id a79mr4678440qkb.75.1551320337168;
        Wed, 27 Feb 2019 18:18:57 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:56 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 09/12] percpu: use block scan_hint to only scan forward
Date: Wed, 27 Feb 2019 21:18:36 -0500
Message-Id: <20190228021839.55779-10-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Blocks now remember the latest scan_hint. This can be used on the
allocation path as when a contig_hint is broken, we can promote the
scan_hint to the contig_hint and scan forward from there. This works
because pcpu_block_refresh_hint() is only called on the allocation path
while block free regions are updated manually in
pcpu_block_update_hint_free().

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index dac18968d79f..e51c151ed692 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -765,14 +765,23 @@ static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
 {
 	struct pcpu_block_md *block = chunk->md_blocks + index;
 	unsigned long *alloc_map = pcpu_index_alloc_map(chunk, index);
-	int rs, re;	/* region start, region end */
+	int rs, re, start;	/* region start, region end */
+
+	/* promote scan_hint to contig_hint */
+	if (block->scan_hint) {
+		start = block->scan_hint_start + block->scan_hint;
+		block->contig_hint_start = block->scan_hint_start;
+		block->contig_hint = block->scan_hint;
+		block->scan_hint = 0;
+	} else {
+		start = block->first_free;
+		block->contig_hint = 0;
+	}
 
-	/* clear hints */
-	block->contig_hint = block->scan_hint = 0;
-	block->left_free = block->right_free = 0;
+	block->right_free = 0;
 
 	/* iterate over free areas and update the contig hints */
-	pcpu_for_each_unpop_region(alloc_map, rs, re, block->first_free,
+	pcpu_for_each_unpop_region(alloc_map, rs, re, start,
 				   PCPU_BITMAP_BLOCK_BITS) {
 		pcpu_block_update(block, rs, re);
 	}
@@ -837,6 +846,8 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 				s_off,
 				s_off + bits)) {
 		/* block contig hint is broken - scan to fix it */
+		if (!s_off)
+			s_block->left_free = 0;
 		pcpu_block_refresh_hint(chunk, s_index);
 	} else {
 		/* update left and right contig manually */
@@ -870,11 +881,11 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 			if (e_off > e_block->scan_hint_start)
 				e_block->scan_hint = 0;
 
+			e_block->left_free = 0;
 			if (e_off > e_block->contig_hint_start) {
 				/* contig hint is broken - scan to fix it */
 				pcpu_block_refresh_hint(chunk, e_index);
 			} else {
-				e_block->left_free = 0;
 				e_block->right_free =
 					min_t(int, e_block->right_free,
 					      PCPU_BITMAP_BLOCK_BITS - e_off);
-- 
2.17.1

