Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 255C4C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:45:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDB032192B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:45:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDB032192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80D306B0006; Thu, 21 Mar 2019 17:45:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71BE56B0007; Thu, 21 Mar 2019 17:45:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 634AC6B0008; Thu, 21 Mar 2019 17:45:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38EA56B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:45:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l187so143085qkd.7
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:45:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sDxwScz+kWGUJCiNfvUIPP9qM7LiTPIkp/rllR/FZsc=;
        b=WuW2/rUl3PQbkYbE5qaYHfzlRbFzOxI0/+Irfr54psKeyDatpJwcIBhSXexqs8dHEA
         5omMz0t0SonFuQ1RZoD9H+4iacidt4/kM3JijODhgP6DpopeMZMA04hqtdHPxWb3ZdWQ
         vZPYHc2XlQBqunQtg3SiefpXKXhDvxuZ5FavKBZAvaFuO5U3xLnMs3rE72nuAn0njo+k
         N/4bcnoprrORLe8fGwmrL84F4W5NizZAjdf9eMmypfDRg6TqJ8X5q09UXRiWWqcRojxu
         4Q04k25s8pqmo3c1WVGDJFMKJBnsYvggmkZJXRJue7FTD3WY4X/4tCHYs3q65/N1YI6z
         WFfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUKdWXLW7Wz+qW2X0kmoD/uDX6go0YHDl5x3cISgOjNB6c5Y9Iu
	SRM4bdxjruQYHFWPrkGrOhgbs88/8h9P4VeEJoGk7V1Atg9aT5QQFudEc95fKgtvP7zHN0ojQJo
	ecp4x7RY70NlzkGmbtOkfaj4f3cvocEAj+cZwMYHMXw+1xxN3oxrIrFaT2Be2xj6fZQ==
X-Received: by 2002:a0c:e703:: with SMTP id d3mr5187822qvn.47.1553204739987;
        Thu, 21 Mar 2019 14:45:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeCYnDdDVAKky9kDSTYh/aUIgUtnqkOjug/J9/TWjzOG+I99Jo7817p9RYQxufEI4x3JlY
X-Received: by 2002:a0c:e703:: with SMTP id d3mr5187731qvn.47.1553204738659;
        Thu, 21 Mar 2019 14:45:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553204738; cv=none;
        d=google.com; s=arc-20160816;
        b=TuaVsu5TOWVADQLwUWsQx9N4Zu+0NGMkx7c/0uro8+TDd+OBro4SQFQl1qPetQGaY4
         dR2jU9e2mQGIDIiIul/9CQ0C9ZKM4ZQsJE2Te/xEwj5k7MgAmknxbImGlOmFb8m46Tu5
         EIiup3TwapmCUVMGVmFYtlUHTb9FGPO8IGAsh3910vY/9yn8x2UTYFt7knuGGOxed5KM
         b5ttc/mbV5VlHjSYpXsDoP6vfV1OcUCuuV9RlTxQnEGcGIZevFD4iasagflD0IRnVont
         Qq2NuZlJh7p4zFzzZaUmLHM+Csrp2kjRZrF9IvCrNwlmY6EErtICzuZuR0VxpxxHqCBK
         HrPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sDxwScz+kWGUJCiNfvUIPP9qM7LiTPIkp/rllR/FZsc=;
        b=W0s5A6pUFi4q+uLvtna1uAyTDDBPoR87Y4+4Bgca8d5RX/gc4TWRb9iUXGNYkuLW7V
         WzGMPzcNVRyUOhxkBoCw1xnaruyuUr7lwQ0A0J3s09IMQRwKftMM/tcomal/1VccHohM
         AoBf7d3ughjtTJwT3c+NYBbv8IHVEFdOKDrAheUGfZIAEu/uMtW1dK/aOAGpBCLGqgPG
         5cxbCBT5V+tPHtksXigkSWre4Ade6Glna2ABqY3zg/AZk6H20cL2sXxtoMDuwzJ1bLZ+
         khAgSFCaxM2cETutQLO9xnr1kL8FO1upLxHYpJk2x2V3j0EI+mNyJspsuk0TCjyakDnx
         k/OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k26si3284934qve.94.2019.03.21.14.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 14:45:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A087330821EC;
	Thu, 21 Mar 2019 21:45:37 +0000 (UTC)
Received: from llong.com (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 06E364B3;
	Thu, 21 Mar 2019 21:45:35 +0000 (UTC)
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
Subject: [PATCH 1/4] mm: Implement kmem objects freeing queue
Date: Thu, 21 Mar 2019 17:45:09 -0400
Message-Id: <20190321214512.11524-2-longman@redhat.com>
In-Reply-To: <20190321214512.11524-1-longman@redhat.com>
References: <20190321214512.11524-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 21 Mar 2019 21:45:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When releasing kernel data structures, freeing up the memory
occupied by those objects is usually the last step. To avoid races,
the release operation is commonly done with a lock held. However, the
freeing operations do not need to be under lock, but are in many cases.

In some complex cases where the locks protect many different memory
objects, that can be a problem especially if some memory debugging
features like KASAN are enabled. In those cases, freeing memory objects
under lock can greatly lengthen the lock hold time. This can even lead
to soft/hard lockups in some extreme cases.

To make it easer to defer freeing memory objects until after unlock,
a kernel memory freeing queue mechanism is now added. It is modelled
after the wake_q mechanism for waking up tasks without holding a lock.

Now kmem_free_q_add() can be called to add memory objects into a freeing
queue. Later on, kmem_free_up_q() can be called to free all the memory
objects in the freeing queue after releasing the lock.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/slab.h | 28 ++++++++++++++++++++++++++++
 mm/slab_common.c     | 41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 11b45f7ae405..6116fcecbd8f 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -762,4 +762,32 @@ int slab_dead_cpu(unsigned int cpu);
 #define slab_dead_cpu		NULL
 #endif
 
+/*
+ * Freeing queue node for freeing kmem_cache slab objects later.
+ * The node is put at the beginning of the memory object and so the object
+ * size cannot be smaller than sizeof(kmem_free_q_node).
+ */
+struct kmem_free_q_node {
+	struct kmem_free_q_node *next;
+	struct kmem_cache *cachep;	/* NULL if alloc'ed by kmalloc */
+};
+
+struct kmem_free_q_head {
+	struct kmem_free_q_node *first;
+	struct kmem_free_q_node **lastp;
+};
+
+#define DEFINE_KMEM_FREE_Q(name)	\
+	struct kmem_free_q_head name = { NULL, &name.first }
+
+static inline void kmem_free_q_init(struct kmem_free_q_head *head)
+{
+	head->first = NULL;
+	head->lastp = &head->first;
+}
+
+extern void kmem_free_q_add(struct kmem_free_q_head *head,
+			    struct kmem_cache *cachep, void *object);
+extern void kmem_free_up_q(struct kmem_free_q_head *head);
+
 #endif	/* _LINUX_SLAB_H */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 03eeb8b7b4b1..dba20b4208f1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1597,6 +1597,47 @@ void kzfree(const void *p)
 }
 EXPORT_SYMBOL(kzfree);
 
+/**
+ * kmem_free_q_add - add a kmem object to a freeing queue
+ * @head: freeing queue head
+ * @cachep: kmem_cache pointer (NULL for kmalloc'ed objects)
+ * @object: kmem object to be freed put into the queue
+ *
+ * Put a kmem object into the freeing queue to be freed later.
+ */
+void kmem_free_q_add(struct kmem_free_q_head *head, struct kmem_cache *cachep,
+		     void *object)
+{
+	struct kmem_free_q_node *node = object;
+
+	WARN_ON_ONCE(cachep && cachep->object_size < sizeof(*node));
+	node->next = NULL;
+	node->cachep = cachep;
+	*(head->lastp) = node;
+	head->lastp = &node->next;
+}
+EXPORT_SYMBOL_GPL(kmem_free_q_add);
+
+/**
+ * kmem_free_up_q - free all the objects in the freeing queue
+ * @head: freeing queue head
+ *
+ * Free all the objects in the freeing queue.
+ */
+void kmem_free_up_q(struct kmem_free_q_head *head)
+{
+	struct kmem_free_q_node *node, *next;
+
+	for (node = head->first; node; node = next) {
+		next = node->next;
+		if (node->cachep)
+			kmem_cache_free(node->cachep, node);
+		else
+			kfree(node);
+	}
+}
+EXPORT_SYMBOL_GPL(kmem_free_up_q);
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
-- 
2.18.1

