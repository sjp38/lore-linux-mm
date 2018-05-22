Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3DE46B0007
	for <linux-mm@kvack.org>; Tue, 22 May 2018 05:55:19 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t143-v6so9221845qke.18
        for <linux-mm@kvack.org>; Tue, 22 May 2018 02:55:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h4-v6si638756qva.43.2018.05.22.02.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 02:55:19 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 1/2] kasan: free allocated shadow memory on MEM_CANCEL_OFFLINE
Date: Tue, 22 May 2018 11:55:14 +0200
Message-Id: <20180522095515.2735-2-david@redhat.com>
In-Reply-To: <20180522095515.2735-1-david@redhat.com>
References: <20180522095515.2735-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>

We have to free memory again when we cancel onlining, otherwise a later
onlining attempt will fail.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/kasan/kasan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 135ce2838c89..8baefe1a674b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -867,6 +867,7 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
 		kmemleak_ignore(ret);
 		return NOTIFY_OK;
 	}
+	case MEM_CANCEL_OFFLINE:
 	case MEM_OFFLINE: {
 		struct vm_struct *vm;
 
-- 
2.17.0
