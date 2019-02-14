Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F433C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08642205F4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:25:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HhlIJr4F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08642205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74EFB8E0005; Wed, 13 Feb 2019 19:25:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FEF18E0001; Wed, 13 Feb 2019 19:25:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EFA78E0005; Wed, 13 Feb 2019 19:25:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 073D38E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:25:54 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id z4so1528713wrq.1
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:25:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=xv22CgztNiptmL1IpEe32/U9BVLPdU1sqDTM5ZydeiE=;
        b=KSN5ktrhMO5taWbNphcnMqZBuqfnbhHa2nOVae5i73savJSf2solgDPRz1MA2zz4/R
         GiDA796C+wqjkXUCOliTyaXjQ3MZEgQiR77MG7lb6n4Pw50TmnJScpxdDZcrWfoDjtmE
         0BvybbgvBzYrcJ/1gOfxAYZ4R8rksRWWkhYs7dnuN/SrFvExxvCEOnpdKOMlr2uQ6fdE
         51e0QcKUFMI9RSCAuzWBglPOuu6jwvU7u/PsoXijd9fvkONuHLpEYbrZoEsCs4bMI5ab
         UAjvtz2FN68tlGBa+1JHW6O9AJ/Rvk1oes6ue5SJTBfO0WEZTUMKKHP51GoDhO0YICM1
         HbTQ==
X-Gm-Message-State: AHQUAuamEzMuXj/DhkCwzLqYY8++tj4ackmuUacsZ5/0AV2YH92Da3Pl
	krtIsd1g7Cgy92z9lP8XYqMha3lA3ka4MCbCiKUhUWWSM9cVDBJuJJWAOihz7PQ1gSaw8DWlqRh
	haQCRyk5Fw81bva4t+kkDSyzAMt9NGRQTBxU0nOgRX9s71hpNEWAtb2um5MQ2NPZQ53CG8nxQ20
	c3dlilAlUIvsVJEIf8EOaIXNRR+5u9rTVi77WeO+qNZNIXZ1UVFkb2W8Ip/MjGyyxXwdwN13R8b
	yoZoxt76Q59sY8+bd0ocaq2zqkQDZdPAWHhWOSPXHsHmaPs0hodp8EYo1f3E+XRE39I2GyNheoM
	CWtQUNtyLOXzhtqTb5RCeAMO/+4V7ZRG1bGed4TU+re54FPAnwwF/RWfdUydre9CYNv2ncgOfzw
	j
X-Received: by 2002:adf:e342:: with SMTP id n2mr507815wrj.60.1550103953422;
        Wed, 13 Feb 2019 16:25:53 -0800 (PST)
X-Received: by 2002:adf:e342:: with SMTP id n2mr507784wrj.60.1550103952517;
        Wed, 13 Feb 2019 16:25:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550103952; cv=none;
        d=google.com; s=arc-20160816;
        b=BhhYpdaTDRhSdSmaxj5ra/gvvJeor6+rNsLbJznr3cwhqV1Pm2UIbkNIP/YFuDt9o+
         veg/WvbP5Swa0O2rW/Ovrorz6olN1aVHPKT1WfKCXN/Dr0ThG5Oocd+AxWN2r6qBby5l
         FeWdjbxtnqiPaVE+uRUk4sXyUxXjFYt5mQQhPqmxVbC4mMIgvkcC0S6Ad7L9YQWAlSlv
         2jKMfw4o8SLmx+wrZ72Iybu0DJnpobXvq4txPByb+49QGdfxUM7xmysUgPZxCYGURpSy
         /ibb2d+fCsv/C8fkA7115FKaMMNXHpSHe4gK8FutPAOurvRkqtcCKRpOJ9nNo+lD5z1Y
         u8JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=xv22CgztNiptmL1IpEe32/U9BVLPdU1sqDTM5ZydeiE=;
        b=sYm9BmmdXhUiwbmK2CyYZbQTbRZovYNzaO6HMuv7m70QsT52jOoxkUt60t9ef/hNt8
         GyTvi0DgLW6mSFsKuiOqJwq4vFw4hDGiBxna/l6mOdScd/ljGIrjLvjT+YWN5N7zpR3/
         qW0XWnzE1uidF9ApdLoNuZUnNA3aQ1L8co0AvyKEKkrIS7shXZZXwnZ1iGK1CnGXKo4G
         YH+wiGVT8sOG4fiGnjDb+7KWIHM4L/z8DAmppDhs/ChsI8qHuEJXkKlfxtGGLBmMOvEW
         OWLQKOBs2v5vnSwJ3QUP/+yGKGjmT7iAPvyKD3GXD5AlY7MehyM9FJk2jl7xroQpTcnw
         v0xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HhlIJr4F;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t9sor493769wrr.16.2019.02.13.16.25.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 16:25:52 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HhlIJr4F;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=xv22CgztNiptmL1IpEe32/U9BVLPdU1sqDTM5ZydeiE=;
        b=HhlIJr4FWxNaNivefuJ+bnt6Cq6HW7Q52ilE48ZsQqjbtnHgee4hlqRgSCcjUyQ3d5
         RBdZpO9q2BMCElpsu8MXwIzHOZe5OUT5V8X7obmacrhhCOGKhX8nOQwKazkEjSUND7xk
         66AtVE3HBZnXxcev29ErJipHiWd3dzL/rEqAxab/+R7IAKEDZJ8thijXd9ztOjoHl/6C
         XDXL+vWafOandWWLJMbEb6N1SIHoCLHF4ZsxnBgIJ6z7DVSB23yvsjKxRmeC5yYH+a91
         NrmImhn+jkl+ZXn5wJdNRaQrjaLJV9E0JojwqpVn7/1xHsCbw/mYOLRJqUsLR/pLYZu+
         /9CA==
X-Google-Smtp-Source: AHgI3IYd9U0Z1ZibscRpnAuj8JVl1ut7OMIRHjvQVt/fMZsv+OV+uKxcoCfJmTEmRasdp0dHRvhurg==
X-Received: by 2002:adf:9f54:: with SMTP id f20mr542834wrg.88.1550103951643;
        Wed, 13 Feb 2019 16:25:51 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id b3sm1442324wme.27.2019.02.13.16.25.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:25:50 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH] kasan, slub: fix more conflicts with CONFIG_SLAB_FREELIST_HARDENED
Date: Thu, 14 Feb 2019 01:25:47 +0100
Message-Id: <bf858f26ef32eb7bd24c665755b3aee4bc58d0e4.1550103861.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CONFIG_KASAN_SW_TAGS is enabled, ptr_addr might be tagged.
Normally, this doesn't cause any issues, as both set_freepointer()
and get_freepointer() are called with a pointer with the same tag.
However, there are some issues with CONFIG_SLUB_DEBUG code. For
example, when __free_slub() iterates over objects in a cache, it
passes untagged pointers to check_object(). check_object() in turns
calls get_freepointer() with an untagged pointer, which causes the
freepointer to be restored incorrectly.

Add kasan_reset_tag to freelist_ptr(). Also add a detailed comment.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slub.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 80da3a40b74d..c80e6699357c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -249,7 +249,18 @@ static inline void *freelist_ptr(const struct kmem_cache *s, void *ptr,
 				 unsigned long ptr_addr)
 {
 #ifdef CONFIG_SLAB_FREELIST_HARDENED
-	return (void *)((unsigned long)ptr ^ s->random ^ ptr_addr);
+	/*
+	 * When CONFIG_KASAN_SW_TAGS is enabled, ptr_addr might be tagged.
+	 * Normally, this doesn't cause any issues, as both set_freepointer()
+	 * and get_freepointer() are called with a pointer with the same tag.
+	 * However, there are some issues with CONFIG_SLUB_DEBUG code. For
+	 * example, when __free_slub() iterates over objects in a cache, it
+	 * passes untagged pointers to check_object(). check_object() in turns
+	 * calls get_freepointer() with an untagged pointer, which causes the
+	 * freepointer to be restored incorrectly.
+	 */
+	return (void *)((unsigned long)ptr ^ s->random ^
+			(unsigned long)kasan_reset_tag((void *)ptr_addr));
 #else
 	return ptr;
 #endif
-- 
2.20.1.791.gb4d0f1c61a-goog

