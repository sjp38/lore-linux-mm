Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F17B6B02A4
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:57:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25-v6so3562768pfi.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:57:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v1-v6si1825227ply.458.2018.06.07.07.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Jun 2018 07:57:27 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 6/6] Convert intel uncore to struct_size
Date: Thu,  7 Jun 2018 07:57:20 -0700
Message-Id: <20180607145720.22590-7-willy@infradead.org>
In-Reply-To: <20180607145720.22590-1-willy@infradead.org>
References: <20180607145720.22590-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

From: Matthew Wilcox <mawilcox@microsoft.com>

Need to do a bit of rearranging to make this work.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 arch/x86/events/intel/uncore.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/arch/x86/events/intel/uncore.c b/arch/x86/events/intel/uncore.c
index 15b07379e72d..e15cfad4f89b 100644
--- a/arch/x86/events/intel/uncore.c
+++ b/arch/x86/events/intel/uncore.c
@@ -865,8 +865,6 @@ static void uncore_types_exit(struct intel_uncore_type **types)
 static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
 {
 	struct intel_uncore_pmu *pmus;
-	struct attribute_group *attr_group;
-	struct attribute **attrs;
 	size_t size;
 	int i, j;
 
@@ -891,21 +889,24 @@ static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
 				0, type->num_counters, 0, 0);
 
 	if (type->event_descs) {
+		struct {
+			struct attribute_group group;
+			struct attribute *attrs[];
+		} *attr_group;
 		for (i = 0; type->event_descs[i].attr.attr.name; i++);
 
-		attr_group = kzalloc(sizeof(struct attribute *) * (i + 1) +
-					sizeof(*attr_group), GFP_KERNEL);
+		attr_group = kzalloc(struct_size(attr_group, attrs, i + 1),
+								GFP_KERNEL);
 		if (!attr_group)
 			goto err;
 
-		attrs = (struct attribute **)(attr_group + 1);
-		attr_group->name = "events";
-		attr_group->attrs = attrs;
+		attr_group->group.name = "events";
+		attr_group->group.attrs = attr_group->attrs;
 
 		for (j = 0; j < i; j++)
-			attrs[j] = &type->event_descs[j].attr.attr;
+			attr_group->attrs[j] = &type->event_descs[j].attr.attr;
 
-		type->events_group = attr_group;
+		type->events_group = &attr_group->group;
 	}
 
 	type->pmu_group = &uncore_pmu_attr_group;
-- 
2.17.0
