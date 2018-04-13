Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63B916B0022
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:31:55 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id b7-v6so5142350ybn.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:31:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m4si107966qtc.170.2018.04.13.06.31.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:31:54 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 4/8] kdump: expose PG_offline
Date: Fri, 13 Apr 2018 15:31:51 +0200
Message-Id: <20180413133151.3199-1-david@redhat.com>
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
References: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Young <dyoung@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>

This allows user space to skip pages that are offline when dumping. This is
especially relevant when dealing with pages that have been unplugged in
the context of virtualization, and their backing storage has already
been freed.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 kernel/crash_core.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index a93590cdd9e1..d6f21b19aeb3 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -463,6 +463,9 @@ static int __init crash_save_vmcoreinfo_init(void)
 #ifdef CONFIG_HUGETLB_PAGE
 	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
 #endif
+#ifdef CONFIG_MEMORY_HOTPLUG
+	VMCOREINFO_NUMBER(PG_offline);
+#endif
 
 	arch_crash_save_vmcoreinfo();
 	update_vmcoreinfo_note();
-- 
2.14.3
