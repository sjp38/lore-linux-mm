Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00BDE6B000C
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 17:10:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 2so3582185pft.4
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:10:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j70si2794532pgc.81.2018.04.12.14.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Apr 2018 14:10:39 -0700 (PDT)
Date: Thu, 12 Apr 2018 14:10:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v9 07/61] xarray: Add the xa_lock to the radix_tree_root
Message-ID: <20180412211036.GB18364@bombadil.infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-8-willy@infradead.org>
 <CAOxpaSXDX1fyrOnnsehEoRgQz2_K1OmOn9TikZzJcXmwMLEfnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOxpaSXDX1fyrOnnsehEoRgQz2_K1OmOn9TikZzJcXmwMLEfnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <zwisler@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Thu, Apr 12, 2018 at 02:59:32PM -0600, Ross Zwisler wrote:
> This is causing build breakage in the radix tree test suite in the
> current linux/master:
> 
> ./linux/../../../../include/linux/idr.h: In function a??idr_init_basea??:
> ./linux/../../../../include/linux/radix-tree.h:129:2: warning:
> implicit declaration of function a??spin_lock_inita??; did you mean
> a??spinlock_ta??? [-Wimplicit-function-declaration]

Argh.  That was added two patches later in
"xarray: Add definition of struct xarray":

diff --git a/tools/include/linux/spinlock.h b/tools/include/linux/spinlock.h
index b21b586b9854..4ec4d2cbe27a 100644
--- a/tools/include/linux/spinlock.h
+++ b/tools/include/linux/spinlock.h
@@ -6,8 +6,9 @@
 #include <stdbool.h>
 
 #define spinlock_t             pthread_mutex_t
-#define DEFINE_SPINLOCK(x)     pthread_mutex_t x = PTHREAD_MUTEX_INITIALIZER;
+#define DEFINE_SPINLOCK(x)     pthread_mutex_t x = PTHREAD_MUTEX_INITIALIZER
 #define __SPIN_LOCK_UNLOCKED(x)        (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER
+#define spin_lock_init(x)      pthread_mutex_init(x, NULL)
 
 #define spin_lock_irqsave(x, f)                (void)f, pthread_mutex_lock(x)
 #define spin_unlock_irqrestore(x, f)   (void)f, pthread_mutex_unlock(x)

I didn't pick up that it was needed this early on in the patch series.
