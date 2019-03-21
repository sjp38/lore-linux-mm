Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3867BC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:45:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1FC021934
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:45:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1FC021934
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BA5F6B000A; Thu, 21 Mar 2019 17:45:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0CCF6B000C; Thu, 21 Mar 2019 17:45:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFA936B000D; Thu, 21 Mar 2019 17:45:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C17586B000A
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:45:45 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o135so131060qke.11
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:45:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Y4YszG8UJ+yJH47v3WLGgBXhW0qq+XiWeAF5pYJLxlk=;
        b=ttcU/tjW2TIcXBoYBFJjgMEiQpyL4DHPMDLE0/5PXzp8jQw9xZ6HMfsKqS/qeM2Wok
         PWi7v8QOMui42n2ZmBjBuqND6se+9lgiiudlnr7D/ojmnfcam/KT1+oGWe6TL59dmHME
         yccryhvoxtBpGAwCr2gktscSgnFn+tyloha+853fil4N9u7A7v0QVaB9X7e+dzkgpxV4
         uIJeaNGr1n1jR97V/Sr1V0H3aXZGgHBCUvd1Lq5mVBEbCblK0kCgkledEcfCB0dKywoY
         QYGlK9fu6593MrQxvixZP6juOFyrMpbW5bvgSvHVS2ofwHsSc8b0dzcvenvAQ908ZKSb
         qg1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWcUGfBy909blCfaweMr3sVfUmvp/A0L9q+IDnO0mz66jZKJS2y
	H+hvvx7ZNQO5mJhSH1ubeO2pPpRrA2D23d/32goXAYywygIP+Dt3ujeR9UCPC3wGymfqURF9rXd
	bzlNhrCHsmcn2pMoeSTmhDbnbEtSAotLJE9RQVWBfHsXqB9Coz/TO5MkUh91YzLSuaw==
X-Received: by 2002:a0c:8a54:: with SMTP id 20mr5166163qvu.167.1553204745560;
        Thu, 21 Mar 2019 14:45:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7Ew3SsQeSmQqu9GdkfzgKJVqV5KK+3mWkLRnwiFmDcA5/8YkHIs7du8wHWmSAqACBhEFK
X-Received: by 2002:a0c:8a54:: with SMTP id 20mr5166107qvu.167.1553204744630;
        Thu, 21 Mar 2019 14:45:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553204744; cv=none;
        d=google.com; s=arc-20160816;
        b=J/Vr6CECM1iXYO3Azvc64OP3G6aKlG8Lk4Kg1t1yee1qL1DNUHSD8Hsa0vXV0cQsxY
         wJ5jiIr4IRZG8iiK3AzcZnDXWj46J+cm5wJI5EYD1aBqD9G8feRo1gRwPcHUgNTP09AL
         g4kp+6f3+SISxFoAoD6W75hcfChdFcCd6+jdcLvXqgG3YownA+BWaqY0VmkevWGq87jc
         IdunuUs4+r5KLnw46SKFYl5CtxyccfxagJlurXWD/aMbEDI/aK+SiBsBdgYkCJ5LTLu9
         fZPza4+0971sJgBnYxak426+wxENkgFeoqQYfoOsLd1zEZuLXGV9eJ+PIa5lSZYaRmFz
         Gu/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Y4YszG8UJ+yJH47v3WLGgBXhW0qq+XiWeAF5pYJLxlk=;
        b=xGAjAJ7mvs+cqiiB1b2qC9XWvslInSeqjhTacI2C7ARZdAsHEa+e6oExhOEynY8QOs
         V1Nfoaktk7YWlgH3aQyqE1AVoLEcpvEJS+mtAPsV8YgG65sbqYOWLNszCJT36w1NlRdo
         R/dFfnkZ3PTZ8o/bKLanHyKKoIt7T7F/mkNLe40OTVQM6L5iquJgGFI+klRWKAePQUk3
         /TVAbeQqWZLD2QnkCww3Z2K/fpupUgllcMhM+HsBvQ+oVorwgkc19IGS6cNcsE+I2wfJ
         LYZ44N40eF103sS23CHPIaxmAhWfl79LwwTumSsM0+5tJZK0UlhvWNdArnMCfT5R7D17
         bD/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j1si1257243qte.42.2019.03.21.14.45.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 14:45:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BC171C00735D;
	Thu, 21 Mar 2019 21:45:43 +0000 (UTC)
Received: from llong.com (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 013D75C659;
	Thu, 21 Mar 2019 21:45:40 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 4/4] mm: Do periodic rescheduling when freeing objects in kmem_free_up_q()
Date: Thu, 21 Mar 2019 17:45:12 -0400
Message-Id: <20190321214512.11524-5-longman@redhat.com>
In-Reply-To: <20190321214512.11524-1-longman@redhat.com>
References: <20190321214512.11524-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 21 Mar 2019 21:45:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If the freeing queue has many objects, freeing all of them consecutively
may cause soft lockup especially on a debug kernel. So kmem_free_up_q()
is modified to call cond_resched() if running in the process context.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 mm/slab_common.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index dba20b4208f1..633a1d0f6d20 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1622,11 +1622,14 @@ EXPORT_SYMBOL_GPL(kmem_free_q_add);
  * kmem_free_up_q - free all the objects in the freeing queue
  * @head: freeing queue head
  *
- * Free all the objects in the freeing queue.
+ * Free all the objects in the freeing queue. The caller cannot hold any
+ * non-sleeping locks.
  */
 void kmem_free_up_q(struct kmem_free_q_head *head)
 {
 	struct kmem_free_q_node *node, *next;
+	bool do_resched = !in_irq();
+	int cnt = 0;
 
 	for (node = head->first; node; node = next) {
 		next = node->next;
@@ -1634,6 +1637,12 @@ void kmem_free_up_q(struct kmem_free_q_head *head)
 			kmem_cache_free(node->cachep, node);
 		else
 			kfree(node);
+		/*
+		 * Call cond_resched() every 256 objects freed when in
+		 * process context.
+		 */
+		if (do_resched && !(++cnt & 0xff))
+			cond_resched();
 	}
 }
 EXPORT_SYMBOL_GPL(kmem_free_up_q);
-- 
2.18.1

