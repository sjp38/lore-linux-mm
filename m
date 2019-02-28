Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FFF0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9916218A2
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9916218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBB198E0007; Wed, 27 Feb 2019 21:18:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B46C78E0001; Wed, 27 Feb 2019 21:18:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 972EE8E0007; Wed, 27 Feb 2019 21:18:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67AC68E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:49 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a11so14785166qkk.10
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Zob00SAWeBYh4oEQ8sirU3S+Sks7fCNmhlxQAAwLhMs=;
        b=D0a2B8b8aATx2MfMXdDyBeJ57zE8q8zG04gsbKYrPlz5hc7nexA5KRAM8YHyjFyCtM
         at3sgyNvHTbzJ4fuWL+1JhPa/zUS0a8AJgTSfc2r25SniOzDVMJX+551vLSs1VYe5ut0
         mJ1RS9myOYrwmdfNoLy21JFh997DULoHarcNj85wmDyNtvwBpYEfIKwu365jxluFJk4J
         fgsQ0OP321O3Mxh4U8936JFqUKPjPe3GHAPLTKv+wLFL8sGmTBsx16gLchjEgqWxh/Jc
         ok9b8QM+88Dnl9WcT5Xz6ny92NWmAQKc1oazo+Rp5JrfD7jW4/wk5dAZpefmPNa1qBps
         YqMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuY95ps6Hjwt9PFJM9K5PnKPqufQZ2p8cMAjzXC58HsvMJrJ7Csm
	k+/f9cEVvKvLvJTjC30ljU5COQehrb7QT9NSU5rgMvqTr8mK6qAwrTHjZCMTHAfxXcw8A6xtG7l
	ntqJBu9alShMTcFs3MJohyMWimf+YVLtOyJmB4HsLM5RpGZc1lAnrlXTodAOqGn8qez4wouwfSf
	nUpqFukNlPi2oicFe1P5BPpKJjKIYo91IGizI1BeM2iLefvGsj5xDQKX6SYN/6qfAe1/LX6Qjnl
	gNQOukTLJ78GYI0+gZwTxtmwUsUKS2jfZanpW4IoYIaFmPcdbvJytQ6q9Jdff7il0qYe3er9iWe
	kgdU0Om4zw+HELyCv2I/wnF8gLzTML7Bkg7Tz0om9v5qlBjffQjl7PJKV3GwameKQWCeSWy5aQ=
	=
X-Received: by 2002:a37:a42:: with SMTP id 63mr4673599qkk.269.1551320329170;
        Wed, 27 Feb 2019 18:18:49 -0800 (PST)
X-Received: by 2002:a37:a42:: with SMTP id 63mr4673577qkk.269.1551320328457;
        Wed, 27 Feb 2019 18:18:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320328; cv=none;
        d=google.com; s=arc-20160816;
        b=ic7BZCwO7eDcZZI2JLfzEnQZw/46Uyj2E3aOvooVL0aHxblLri0d2yTVNH8yTaIs0k
         hbf8hKZn55cRnUsHG+JVvuGtjA1+caBqetY4zAJXsTBI8AKuqa8Q9WZkymbVrTJFMHZi
         zfU9Q3A4zx2fjEvg78IPQgoUgLyRdjXSp/9RtUWjDWrdS6MIjBwb44PWTt9FRv7w+xpK
         8GD9KwgPgYcgW6hL1Kug7eNz4yG2KiVa7dDwAJhPFrTYxrZtzYyiz9gxIpYE0vsy5jmZ
         45PVGhte4SOx2/6O1DIBncDC63on3oM+rNOtsPj0waMIWer5N422jf3pSrCztt4ZwFYW
         6RKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Zob00SAWeBYh4oEQ8sirU3S+Sks7fCNmhlxQAAwLhMs=;
        b=apN1RFpeEUEAzwpCZdzTnLkiPMNWamANnQfKshUrH4wGWZIIB2UshcWSwqQMz2fNzh
         uALtPxdGEuMAXES4EIN+6oPEchVhg2h5cSzp7JPK2UMF8xqwWXwAdfLf6k1EBcB3+WM9
         xL8F4boiPv/XpM/nxGNRuNo8fUDEGnvabbn3SthMaXoQLQzsHPXy+ImNItPRbfaKZwkx
         vGFMvLdzJahkacjisXOkr65jjSJL5qaXIalUyeQNrEi+AGHZ3LekK0xQ0ySTfZHEcJXM
         QrB6K6+2Y61JT5c8lIvWpqvUOjcyXrt3QSB+SfhN66ILnJ9jSWh8DpB2C9FveEHQLoZ4
         xdXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a71sor5619271qkj.43.2019.02.27.18.18.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:48 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxz8+gxkBV2tfV0g1NRbjVNK+SA9NVlrl0RNozpYzGlY83nUOmtsMtX9iAm89FyNgTCaf4oQg==
X-Received: by 2002:a37:4701:: with SMTP id u1mr4545594qka.357.1551320328211;
        Wed, 27 Feb 2019 18:18:48 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:47 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 03/12] percpu: introduce helper to determine if two regions overlap
Date: Wed, 27 Feb 2019 21:18:30 -0500
Message-Id: <20190228021839.55779-4-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

While block hints were always accurate, it's possible when spanning
across blocks that we miss updating the chunk's contig_hint. Rather than
rely on correctness of the boundaries of hints, do a full overlap
comparison.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu.c | 31 +++++++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 69ca51d238b5..b40112b2fc59 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -546,6 +546,24 @@ static inline int pcpu_cnt_pop_pages(struct pcpu_chunk *chunk, int bit_off,
 	       bitmap_weight(chunk->populated, page_start);
 }
 
+/*
+ * pcpu_region_overlap - determines if two regions overlap
+ * @a: start of first region, inclusive
+ * @b: end of first region, exclusive
+ * @x: start of second region, inclusive
+ * @y: end of second region, exclusive
+ *
+ * This is used to determine if the hint region [a, b) overlaps with the
+ * allocated region [x, y).
+ */
+static inline bool pcpu_region_overlap(int a, int b, int x, int y)
+{
+	if ((x >= a && x < b) || (y > a && y <= b) ||
+	    (x <= a && y >= b))
+		return true;
+	return false;
+}
+
 /**
  * pcpu_chunk_update - updates the chunk metadata given a free area
  * @chunk: chunk of interest
@@ -710,8 +728,11 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 					PCPU_BITMAP_BLOCK_BITS,
 					s_off + bits);
 
-	if (s_off >= s_block->contig_hint_start &&
-	    s_off < s_block->contig_hint_start + s_block->contig_hint) {
+	if (pcpu_region_overlap(s_block->contig_hint_start,
+				s_block->contig_hint_start +
+				s_block->contig_hint,
+				s_off,
+				s_off + bits)) {
 		/* block contig hint is broken - scan to fix it */
 		pcpu_block_refresh_hint(chunk, s_index);
 	} else {
@@ -764,8 +785,10 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 	 * contig hint is broken.  Otherwise, it means a smaller space
 	 * was used and therefore the chunk contig hint is still correct.
 	 */
-	if (bit_off >= chunk->contig_bits_start  &&
-	    bit_off < chunk->contig_bits_start + chunk->contig_bits)
+	if (pcpu_region_overlap(chunk->contig_bits_start,
+				chunk->contig_bits_start + chunk->contig_bits,
+				bit_off,
+				bit_off + bits))
 		pcpu_chunk_refresh_hint(chunk);
 }
 
-- 
2.17.1

