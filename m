Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA0D46B000A
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 07:24:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i14so666175pgp.23
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 04:24:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b184si1166609pgc.786.2018.02.21.04.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Feb 2018 04:24:52 -0800 (PST)
Date: Wed, 21 Feb 2018 04:24:45 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/4] vmalloc: add vm_flags argument to internal
 __vmalloc_node()
Message-ID: <20180221122444.GA11791@bombadil.infradead.org>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151670492223.658225.4605377710524021456.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com

On Tue, Jan 23, 2018 at 01:55:22PM +0300, Konstantin Khlebnikov wrote:
> This allows to set VM_USERMAP in vmalloc_user() and vmalloc_32_user()
> directly at allocation and avoid find_vm_area() call.

While reviewing this patch, I came across this infelicity ...

have I understood correctly?

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index e13d911251e7..9060f80b4a41 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -631,11 +631,10 @@ int kasan_module_alloc(void *addr, size_t size)
 	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
 			shadow_start + shadow_size,
 			GFP_KERNEL | __GFP_ZERO,
-			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
+			PAGE_KERNEL, VM_NO_GUARD | VM_KASAN, NUMA_NO_NODE,
 			__builtin_return_address(0));
 
 	if (ret) {
-		find_vm_area(addr)->flags |= VM_KASAN;
 		kmemleak_ignore(ret);
 		return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
