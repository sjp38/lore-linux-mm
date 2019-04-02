Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AE6DC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:25:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6AD22075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:25:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tCTRiPl7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6AD22075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52CF06B026A; Tue,  2 Apr 2019 12:25:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DDF96B026C; Tue,  2 Apr 2019 12:25:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 357486B026E; Tue,  2 Apr 2019 12:25:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBE4F6B026A
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 12:25:45 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id t17so3619879ljt.21
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 09:25:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=jOaodrjzogu+AiOzT8YUkjwGghPStMHrCGiELyRiUjU=;
        b=jVFN+LWeOprRIwROiTK8Z0Y6H9O9stgKl5/r89BmN6Thd5Srp4gAho0EzsYv7BME5t
         HrhxdunI2r4vFnlWzKDLgbLzVzEuVcV8xlr9YIanS3+g9inz5iJC3Uv2jiCjo61qTZOM
         9VLzGpv1l06fG1fWoIm8tEmPf3rwRLJrxVlgctAkelZA7RaQNdfasfVHvgLHuIt1I33/
         7WWP/Q3WYO9PrLwqEfctoXazJ8OQXKzDkevaKtyi6+4ictmv62oMwaZEsoSP0jI1jmdE
         qsGTVOETRigDehPqUbxrQxqT5dXYbYnqhVtI1Mry3YWPU6aCH05vxD4yJCVZcv0rCZsq
         4b1Q==
X-Gm-Message-State: APjAAAXQWeLrHnmgO0oTlgFFXTqMwkK0pnNdKsN/EeUUVBJ0pNFCI6D8
	l00HD3P1aBJSXn4pGohROwVPfg48DsmTs5uZ280SygrYRD0ErJwqJlWCilCBvc0C+lzS6t3D8C4
	sc5XN1LAcxKa7MvJkm9Dwyf237MMVeY92DtZSKwjug+gDSOtrg5EpHIztBty5qDRjng==
X-Received: by 2002:a19:2789:: with SMTP id n131mr35800053lfn.142.1554222345215;
        Tue, 02 Apr 2019 09:25:45 -0700 (PDT)
X-Received: by 2002:a19:2789:: with SMTP id n131mr35799992lfn.142.1554222343925;
        Tue, 02 Apr 2019 09:25:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554222343; cv=none;
        d=google.com; s=arc-20160816;
        b=qEZHOMtUDnNDuWOe9ak091sfjLiyNfSQQHznFNvCTp8dxIBNl8/DJkqN6gv+o1yaDc
         V8bxmdN78QsZKSNnUff23jU76QwKEBXkFGdutuUBqqW93JMA+v0VeGFvxrQYCbpDl3HK
         55mJLKM/RkssW/OWRKoyrhk13ROqXLv6TNxcF/Gk1JjLX1lLhEjPFCC7D+0mS4RcPxnU
         Ww2aToCiVQH3+Btf0Lg6wythxmvw9H+3trHiHpJPwH6XHMgwPI86ZFp1HvY06UA5A9L2
         uno50Bttsjg2ZXFZebQpbpeOKHsLAlHnUBKbnhQ2JYLFcrGLcP3jwiIyyumJQkCwtkGr
         8o/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=jOaodrjzogu+AiOzT8YUkjwGghPStMHrCGiELyRiUjU=;
        b=gmpTni3G1oWfIpSZ+GqV5SsU2oXHFDzFFHRz4AuVhkJZpQYQjqc1QpiR8bsdm4XYy/
         JWu3LhsC4q46sBkOi6XxcFmW4OCWSCiV86T9JJZbKe0I94CLOdIO8s7GFtTHiu5IIiCX
         eUTya8+69B5jk3+Qe69NFzC3pWRS8JL9qfTCmKPm64i++YK2r3vcjSFeQ/BXzgPgteBm
         rEKtKfBIyj3XNENbqAqX3ZWst9BW1s83FwnOUBzWguCt8CmSMinikIW/BqAviEl8cGwm
         iy35GYBmUR6u7AwqZPsMNnjkCIY0DwWQfO+fjepd4pK4dfuc5dCvmw1XjJzMX7F65/4h
         TI8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tCTRiPl7;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor8534300lja.22.2019.04.02.09.25.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 09:25:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tCTRiPl7;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=jOaodrjzogu+AiOzT8YUkjwGghPStMHrCGiELyRiUjU=;
        b=tCTRiPl7RlRiNVO6+7kzd5kmFCdVxV7fp9hmAOiYAMGxwEfVnmjO1Q0i/P2vxA8jiD
         wkYMAASKMBlDYneQEHhjdXSDUp/mI56KUdJVE7ba52w0/cug9CHYTEOLl2o5ZCrj+ok+
         V/VXj3xj1ADW1mRDy2y9QKItT3dj21kU0OlWbju+NjXJsMj63APgLLZz5ZdbUAB/nRXZ
         4IDwdYtm1oNxRgrL8rg3ZmjxtE4PmGu+I3oWnfodhQf5Dzy5+uLZ4o8MvG1LDLR2Fh9v
         THhc1B5B+e4hT+feLzv9TXuhX5bUOdkAfC4edU2WEAE3tBeLKn/E6x+o+dEzcI9IUux4
         DNxg==
X-Google-Smtp-Source: APXvYqxIvgt166YyuxYqS2vsjdjC8Q17H5Dq3Pgp4uuVl85W3LEQFMG3xqyqh3fitVUfKKypxQ4DFg==
X-Received: by 2002:a2e:9ac8:: with SMTP id p8mr22952891ljj.79.1554222343527;
        Tue, 02 Apr 2019 09:25:43 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id 13sm2550377lfy.2.2019.04.02.09.25.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 09:25:42 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RESEND PATCH 2/3] mm/vmap: add DEBUG_AUGMENT_PROPAGATE_CHECK macro
Date: Tue,  2 Apr 2019 18:25:30 +0200
Message-Id: <20190402162531.10888-3-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190402162531.10888-1-urezki@gmail.com>
References: <20190402162531.10888-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This macro adds some debug code to check that the augment tree
is maintained correctly, meaning that every node contains valid
subtree_max_size value.

By default this option is set to 0 and not active. It requires
recompilation of the kernel to activate it. Set to 1, compile
the kernel.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3adbad3fb6c1..1449a8c43aa2 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -322,6 +322,8 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
 EXPORT_SYMBOL(vmalloc_to_pfn);
 
 /*** Global kva allocator ***/
+#define DEBUG_AUGMENT_PROPAGATE_CHECK 0
+
 #define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
 
@@ -544,6 +546,53 @@ __unlink_va(struct vmap_area *va, struct rb_root *root)
 	}
 }
 
+#if DEBUG_AUGMENT_PROPAGATE_CHECK
+static void
+augment_tree_propagate_do_check(struct rb_node *n)
+{
+	struct vmap_area *va;
+	struct rb_node *node;
+	unsigned long size;
+	bool found = false;
+
+	if (n == NULL)
+		return;
+
+	va = rb_entry(n, struct vmap_area, rb_node);
+	size = va->subtree_max_size;
+	node = n;
+
+	while (node) {
+		va = rb_entry(node, struct vmap_area, rb_node);
+
+		if (get_subtree_max_size(node->rb_left) == size) {
+			node = node->rb_left;
+		} else {
+			if (__va_size(va) == size) {
+				found = true;
+				break;
+			}
+
+			node = node->rb_right;
+		}
+	}
+
+	if (!found) {
+		va = rb_entry(n, struct vmap_area, rb_node);
+		pr_emerg("tree is corrupted: %lu, %lu\n",
+			__va_size(va), va->subtree_max_size);
+	}
+
+	augment_tree_propagate_do_check(n->rb_left);
+	augment_tree_propagate_do_check(n->rb_right);
+}
+
+static void augment_tree_propagate_from_check(void)
+{
+	augment_tree_propagate_do_check(free_vmap_area_root.rb_node);
+}
+#endif
+
 /*
  * This function populates subtree_max_size from bottom to upper
  * levels starting from VA point. The propagation must be done
@@ -593,6 +642,10 @@ __augment_tree_propagate_from(struct vmap_area *va)
 		va->subtree_max_size = new_va_sub_max_size;
 		node = rb_parent(&va->rb_node);
 	}
+
+#if DEBUG_AUGMENT_PROPAGATE_CHECK
+	augment_tree_propagate_from_check();
+#endif
 }
 
 static void
-- 
2.11.0

