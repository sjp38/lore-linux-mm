Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0754C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:15:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FD2420848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:15:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NxDO9Mih"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FD2420848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01B756B0003; Fri, 17 May 2019 13:15:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE7B16B0005; Fri, 17 May 2019 13:15:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB0136B0006; Fri, 17 May 2019 13:15:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 89AB96B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:15:14 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k18so3077966wrl.4
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:15:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=naBDVzNGnuVxSb0pTsKKkPbTR5+S/nyhRezxbIQImGI=;
        b=gww/yplX8P8dKATuEge/B8maXH35wv9Cz5jLVNW0fKCrsiNpNMoLOQgg8hW3mdXH6t
         bG5mdZGddaB1lwZs41TlOO51hMvpIBt65jSc7XlZKj7zvduDNRtaBmkE+l1s94XRsccJ
         L0hPupi0Pcm4X2ibQ+Z7ULERLCMa3cS5IMyKkyRDqNlX/5wPoRMfKqeSdGPS0agtO6aa
         L/09bst+vvAHjnzjL7Uq1Cbe0vJWTK3Jw8jtHvtTJW1BzhgzlQZ5HcB+swvtVhcFFieR
         VqyEx7yeAIswbZinyd1daJq/gqCPzZtLpOf1rvF0sm8NGnPeAN2leGTjGbbf4MjcOBZE
         h3uA==
X-Gm-Message-State: APjAAAWIF+8Rn6tkJO0uxnCEZgM56y7pXETjEwTTjDjmCarljzaW2tPW
	WP7CI9qBv5/lPuiQkYZmmFB1X/pWQv9mptVk76S4Z/FCVBgChASHgGHTvmqYbbg4Bc8ZDpKRbTI
	hVHTgSf0XUY2PIoWN/OjPu+roiIYCqMbz7tYyVXER+RVDcZbb0ln++ZcLTFe08zkj7w==
X-Received: by 2002:a1c:7dd6:: with SMTP id y205mr2946844wmc.90.1558113313993;
        Fri, 17 May 2019 10:15:13 -0700 (PDT)
X-Received: by 2002:a1c:7dd6:: with SMTP id y205mr2946801wmc.90.1558113313012;
        Fri, 17 May 2019 10:15:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558113313; cv=none;
        d=google.com; s=arc-20160816;
        b=jyYkFaE0al38edmfIrPn+Ia9nUS9gCindv6RBW4XPoFXR3Ys5vih46cn8pG/vKLklz
         +f/2p1Z2yfjJr4THSdk75l5OzHA2sOEtEsW5jovmt+EApLmCC6/HGV7EWr1W5hBiOxlW
         I/QmSjqPx1PxfbTPQX5WpYKWj0SP8CeNPKrM3CXLmqkEm0AAy2BTolGMlJoVX6azFcGq
         mAI1P4jpUoFkpKa2gJtBluvAT6G0/G/9Q+akZc8HRjuLvmaB0JOWLIqy7oaNf77NQxeX
         /VQoo2Kk2ItEQAU2w/Cc/y2a2QnxDOvyZ37W5MVgdT4N0fa/wRzfRoyLTpkEHa14mg6K
         zkTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=naBDVzNGnuVxSb0pTsKKkPbTR5+S/nyhRezxbIQImGI=;
        b=qk7W6f1Va7woQTDcySU+dx1BKWb3RxuizUfU8hj8TQuDQ2RD7Ef/kt3eFgleVACb9F
         mvcp8E7+EOtj4IobfZ5f7bkSqLdrtM87M2vwHJX6bS/eYaFIWttIRpbxP7ds1Kj3VY4i
         mxyJMlRnzT3ouAojD8oKxw37jkYZpY0HBMl+cIFVpnVHVG6DhQjt2cve6icug/169R6b
         lz6jw9LYg2WRL9Q7c5UC+TOJa2ZIm8m8gtHi5ZPD+gU/T/x5aRK8gMVH+sI51lmonfeS
         CupNfzuAlY7X/PEGmaNU0Db5e0SZdFrtr8x56Rn0OFoSs1Ec7iY5i8jx+cp4YWJ04LYK
         ALUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NxDO9Mih;
       spf=pass (google.com: domain of dvyukov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b7sor1022077wrj.6.2019.05.17.10.15.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 10:15:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NxDO9Mih;
       spf=pass (google.com: domain of dvyukov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=naBDVzNGnuVxSb0pTsKKkPbTR5+S/nyhRezxbIQImGI=;
        b=NxDO9Mihh7z44KOHGLa6bSIJFZtx6H541W8inGiEpi2KcfUSXgBzbBn7f4uVmM+pG+
         7ta8+rCgV7E7zl2TLDmSa5qDNQMoBpBX1OvnmCWObWviXUBH0VEB9RhQOXaHUx7PbMuD
         aHeglqmIiT3aO1d85gHDKdLdPsb3QNfy58Rgwv4x5nvw3mUySlxt7fNF69QdyzULLJJn
         MiYwTrxydOHyxxcDd894x9LkF9si91JZBvx67YHxBf70PQCI19ohuVVMPdXQaBDD423n
         jBTzHlrTPaaC1tURHSGQuPVfAktXZcNxm9Fg/F6K0dW0OAcbQxZKGuweqf80DDJlY2ju
         mJ7w==
X-Google-Smtp-Source: APXvYqz7NydXbhX+o2llvFWzV+tiLQyONNyiarXtGB7cf8wB17IWMiogs4UQTD+QQ8NVDUxsy/Pq9A==
X-Received: by 2002:a5d:5506:: with SMTP id b6mr33951846wrv.221.1558113312505;
        Fri, 17 May 2019 10:15:12 -0700 (PDT)
Received: from dvyukov-desk.muc.corp.google.com ([2a00:79e0:15:13:4c1a:d2d1:436c:979b])
        by smtp.gmail.com with ESMTPSA id r2sm17816331wrr.65.2019.05.17.10.15.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 10:15:11 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@gmail.com>
To: catalin.marinas@arm.com,
	akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] kmemleak: fix check for softirq context
Date: Fri, 17 May 2019 19:15:07 +0200
Message-Id: <20190517171507.96046-1-dvyukov@gmail.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dmitry Vyukov <dvyukov@google.com>

in_softirq() is a wrong predicate to check if we are in a softirq context.
It also returns true if we have BH disabled, so objects are falsely
stamped with "softirq" comm. The correct predicate is in_serving_softirq().

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index e57bf810f7983..6584ff9778895 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -588,7 +588,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	if (in_irq()) {
 		object->pid = 0;
 		strncpy(object->comm, "hardirq", sizeof(object->comm));
-	} else if (in_softirq()) {
+	} else if (in_serving_softirq()) {
 		object->pid = 0;
 		strncpy(object->comm, "softirq", sizeof(object->comm));
 	} else {
-- 
2.21.0.1020.gf2820cf01a-goog

