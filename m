Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 744C46B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 17:33:01 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so171100861pac.1
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 14:33:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y126si8819776pfy.49.2016.04.22.14.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 14:33:00 -0700 (PDT)
Date: Fri, 22 Apr 2016 14:32:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm, kasan: don't call kasan_krealloc() from
 ksize().
Message-Id: <20160422143259.b2d2c253da7ea6fa4b425269@linux-foundation.org>
In-Reply-To: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
References: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, dvyukov@google.com, cl@linux.com, ryabinin.a.a@gmail.com, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 13 Apr 2016 13:20:09 +0200 Alexander Potapenko <glider@google.com> wrote:

> Instead of calling kasan_krealloc(), which replaces the memory allocation
> stack ID (if stack depot is used), just unpoison the whole memory chunk.

I don't understand why these two patches exist.  Bugfix?  Cleanup? 
Optimization?


I had to change kmalloc_tests_init() a bit due to
mm-kasan-initial-memory-quarantine-implementation.patch:

        kasan_stack_oob();
        kasan_global_oob();
 #ifdef CONFIG_SLAB
        kasan_quarantine_cache();
 #endif
+       ksize_unpoisons_memory();
        return -EAGAIN;
 }

Please check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
