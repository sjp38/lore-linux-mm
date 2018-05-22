Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9D856B000C
	for <linux-mm@kvack.org>; Tue, 22 May 2018 06:08:04 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y7-v6so18535255qtn.3
        for <linux-mm@kvack.org>; Tue, 22 May 2018 03:08:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r10-v6si4572707qvb.223.2018.05.22.03.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 03:08:04 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 2/2] kasan: fix memory hotplug during boot
Date: Tue, 22 May 2018 12:07:56 +0200
Message-Id: <20180522100756.18478-3-david@redhat.com>
In-Reply-To: <20180522100756.18478-1-david@redhat.com>
References: <20180522100756.18478-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>

Using module_init() is wrong. E.g. ACPI adds and onlines memory before
our memory notifier gets registered.

This makes sure that ACPI memory detected during boot up will not
result in a kernel crash.

Easily reproducable with QEMU, just specify a DIMM when starting up.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/kasan/kasan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 53564229674b..a8b85706e2d6 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -892,5 +892,5 @@ static int __init kasan_memhotplug_init(void)
 	return 0;
 }
 
-module_init(kasan_memhotplug_init);
+core_initcall(kasan_memhotplug_init);
 #endif
-- 
2.17.0
