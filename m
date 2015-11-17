Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id CC9E26B0265
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 18:38:57 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so24424136pab.0
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 15:38:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d7si4529011pbu.76.2015.11.17.15.38.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 15:38:56 -0800 (PST)
Date: Tue, 17 Nov 2015 15:38:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] writeback: initialize m_dirty to avoid compile warning
Message-Id: <20151117153855.99d2acd0568d146c29defda5@linux-foundation.org>
In-Reply-To: <1447439201-32009-1-git-send-email-yang.shi@linaro.org>
References: <1447439201-32009-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Fri, 13 Nov 2015 10:26:41 -0800 Yang Shi <yang.shi@linaro.org> wrote:

> When building kernel with gcc 5.2, the below warning is raised:
> 
> mm/page-writeback.c: In function 'balance_dirty_pages.isra.10':
> mm/page-writeback.c:1545:17: warning: 'm_dirty' may be used uninitialized in this function [-Wmaybe-uninitialized]
>    unsigned long m_dirty, m_thresh, m_bg_thresh;
> 
> The m_dirty{thresh, bg_thresh} are initialized in the block of "if (mdtc)",
> so if mdts is null, they won't be initialized before being used.
> Initialize m_dirty to zero, also initialize m_thresh and m_bg_thresh to keep
> consistency.
> 
> They are used later by if condition:
> !mdtc || m_dirty <= dirty_freerun_ceiling(m_thresh, m_bg_thresh)
> 
> If mdtc is null, dirty_freerun_ceiling will not be called at all, so the
> initialization will not change any behavior other than just ceasing the compile
> warning.

Geeze I hate that warning.  gcc really could be a bit smarter about it
and this is such a case.

> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1542,7 +1542,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>  	for (;;) {
>  		unsigned long now = jiffies;
>  		unsigned long dirty, thresh, bg_thresh;
> -		unsigned long m_dirty, m_thresh, m_bg_thresh;
> +		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh = 0;
>  
>  		/*
>  		 * Unstable writes are a feature of certain networked

Adding runtime overhead to suppress a compile-time warning is Just
Wrong.

With gcc-4.4.4 the above patch actually reduces page-writeback.o's
.text by 36 bytes, lol.  With gcc-4.8.4 the patch saves 19 bytes.  No
idea what's going on there...


And initializing locals in the above fashion can hide real bugs -
looky:

--- a/mm/page-writeback.c~a
+++ a/mm/page-writeback.c
@@ -1544,6 +1544,8 @@ static void balance_dirty_pages(struct a
 		unsigned long dirty, thresh, bg_thresh;
 		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh = 0;
 
+		printk("%lu\n", m_dirty);
+
 		/*
 		 * Unstable writes are a feature of certain networked
 		 * filesystems (i.e. NFS) in which data may have been

After the fake initialization there is no warning.  Perhaps it would be
better to initialize these things to some insane value so the kernel
will at least malfunction in some observable fashion if this happens.

I think unintialized_var() is a good solution - it's self-documenting
and adds no overhead.  It still has the can-hide-real-bugs issue, but
it's better than fake initialization.

But Linus chucks a wobbly over unintialized_var() so shrug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
