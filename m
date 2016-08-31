Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B76A66B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 04:28:47 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o3so148989498ita.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 01:28:47 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id h64si4776703iod.170.2016.08.31.01.28.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 01:28:35 -0700 (PDT)
Message-ID: <57C6933E.2090907@huawei.com>
Date: Wed, 31 Aug 2016 16:20:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: two questions: hugetlb, how to set huge_bootmem_page->phys before
 gather_bootmem_prealloc()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: grygorii.strashko@ti.com, santosh.shilimkar@ti.com, Andrew Morton <akpm@linux-foundation.org>, beckyb@kernel.crashing.org
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

If the system is 32 bit, usually we will have a highmem zone.

I find gather_bootmem_prealloc() will free the huge_bootmem_page and
then prep the new huge page in CONFIG_HIGHMEM.

But alloc_bootmem_huge_page() we will use the beginning of the huge page
to store the huge_bootmem_page struct, so how to set huge_bootmem_page->phys?

commit(ee8f248d266ec6966c0ce6b7dec24de43dcc1b58) add phys addr to struct
huge_bootmem_page


Another question, commit(8b89a1169437541a2a9b62c8f7b1a5c0ceb0fbde)
update the interface, and the following code actually fix a bug too, right?

We should use phys instead of virt when calling free_bootmem_late(),
But it has not reported to stable.

-               free_bootmem_late((unsigned long)m,
-                                 sizeof(struct huge_bootmem_page));
+               memblock_free_late(__pa(m),
+                                  sizeof(struct huge_bootmem_page));


Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
