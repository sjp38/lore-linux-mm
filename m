Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D770B6B000A
	for <linux-mm@kvack.org>; Tue, 22 May 2018 06:08:02 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f1-v6so17517297qtm.12
        for <linux-mm@kvack.org>; Tue, 22 May 2018 03:08:02 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 56-v6si1266683qvf.10.2018.05.22.03.08.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 03:08:02 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 1/2] kasan: free allocated shadow memory on MEM_CANCEL_ONLINE
Date: Tue, 22 May 2018 12:07:55 +0200
Message-Id: <20180522100756.18478-2-david@redhat.com>
In-Reply-To: <20180522100756.18478-1-david@redhat.com>
References: <20180522100756.18478-1-david@redhat.com>
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
index 135ce2838c89..53564229674b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -867,6 +867,7 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
 		kmemleak_ignore(ret);
 		return NOTIFY_OK;
 	}
+	case MEM_CANCEL_ONLINE:
 	case MEM_OFFLINE: {
 		struct vm_struct *vm;
 
-- 
2.17.0
