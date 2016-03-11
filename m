Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C72016B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 15:19:25 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id td3so80730800pab.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 12:19:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kx15si6257408pab.43.2016.03.11.12.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 12:19:24 -0800 (PST)
Date: Fri, 11 Mar 2016 12:19:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 11691/11963] mm/kasan/kasan.c:429:12: error:
 dereferencing pointer to incomplete type 'struct stack_trace'
Message-Id: <20160311121923.656fbcc79b5490109573c65a@linux-foundation.org>
In-Reply-To: <201603111844.8T3LiLoa%fengguang.wu@intel.com>
References: <201603111844.8T3LiLoa%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Alexander Potapenko <glider@google.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 11 Mar 2016 18:38:47 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   bb17bf337db5c5af7e75ec5916772c9bffcaf981
> commit: d5e0cb037c3f7a9cc54b9427e0281c7877d62ff3 [11691/11963] mm, kasan: stackdepot implementation. Enable stackdepot for SLAB
> config: x86_64-randconfig-v0-03111742 (attached as .config)
> reproduce:
>         git checkout d5e0cb037c3f7a9cc54b9427e0281c7877d62ff3
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    mm/kasan/kasan.c: In function 'filter_irq_stacks':
> >> mm/kasan/kasan.c:429:12: error: dereferencing pointer to incomplete type 'struct stack_trace'
>      if (!trace->nr_entries)

Yeah, that's a bit screwed up.  The code needs CONFIG_STACKTRACE but this:

--- a/lib/Kconfig.kasan~mm-kasan-stackdepot-implementation-enable-stackdepot-for-slab-fix-fix
+++ a/lib/Kconfig.kasan
@@ -8,6 +8,7 @@ config KASAN
 	depends on SLUB_DEBUG || (SLAB && !DEBUG_SLAB)
 	select CONSTRUCTORS
 	select STACKDEPOT if SLAB
+	select STACKTRACE if SLAB
 	help
 	  Enables kernel address sanitizer - runtime memory debugger,
 	  designed to find out-of-bounds accesses and use-after-free bugs.

doesn't work because CONFIG_SLAB=n.  And I don't think we want to
enable all this extra stuff for slub/slob/etc.

Over to you, Alexander.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
