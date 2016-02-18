Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 602546B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 23:40:41 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id fy10so23591032pac.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 20:40:41 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id lf12si6588554pab.207.2016.02.17.20.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 20:40:40 -0800 (PST)
Received: by mail-pa0-x232.google.com with SMTP id fl4so23661076pad.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 20:40:40 -0800 (PST)
Date: Thu, 18 Feb 2016 13:41:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160218044156.GA10776@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/18/16 12:02), Sergey Senozhatsky wrote:
[..]
> ---
>  mm/zsmalloc.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 61b1b35..0c9f117 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -74,11 +74,10 @@
>  #define ZS_ALIGN		8
>  
>  /*
> - * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
> - * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
> + * A single 'zspage' is composed of up ZS_MAX_PAGES_PER_ZSPAGE discontiguous
> + * 0-order (single) pages.
>   */
> -#define ZS_MAX_ZSPAGE_ORDER 2
> -#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
> +#define ZS_MAX_PAGES_PER_ZSPAGE	6
>  
>  #define ZS_HANDLE_SIZE (sizeof(unsigned long))
>  


I think we better switch to different logic here -- specify how many ->huge
classes we want to have, and let zsmalloc to calculate ZS_MAX_PAGES_PER_ZSPAGE.


For example, if we want to have 20 ->huge classes, the 'smallest' (or the last)
non-huge class will have CLASS_SIZE * SIZE_CLASS_DELTA of spare (wasted) space,
so  PAGE_SIZE / (CLASS_SIZE * SIZE_CLASS_DELTA)  will give us the number of pages
we need to form into a zspage to make it the last huge class.


setting ZS_MIN_HUGE_CLASSES_NUM to 32 gives us (on x86_64, PAGE_SHIFT 12) ->huge
class size range of [3648, 4096]. so all objects smaller than 3648 will not waste
an entire zspage (and order-0 page), but will share the page with another objects
of that size.


something like this:

---

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0c9f117..d5252d1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -73,12 +73,6 @@
  */
 #define ZS_ALIGN               8
 
-/*
- * A single 'zspage' is composed of up ZS_MAX_PAGES_PER_ZSPAGE discontiguous
- * 0-order (single) pages.
- */
-#define ZS_MAX_PAGES_PER_ZSPAGE        6
-
 #define ZS_HANDLE_SIZE (sizeof(unsigned long))
 
 /*
@@ -149,6 +143,21 @@
 #define ZS_SIZE_CLASS_DELTA    (PAGE_SIZE >> 8)
 
 /*
+ * We want to have at least this number of ->huge classes.
+ */
+#define ZS_MIN_HUGE_CLASSES_NUM        32
+/*
+ * A single 'zspage' is composed of up ZS_MAX_PAGES_PER_ZSPAGE discontiguous
+ * 0-order (single) pages.
+ *
+ * The smallest huge class will have CLASS_SIZE * SIZE_CLASS_DELTA of
+ * wasted space, calculate how many pages we need to fit a CLASS_SIZE
+ * object there and, thus, to save a additional zspage.
+ */
+#define ZS_MAX_PAGES_PER_ZSPAGE        \
+       (PAGE_SIZE / (ZS_MIN_HUGE_CLASSES_NUM * ZS_SIZE_CLASS_DELTA))
+
+/*
  * We do not maintain any list for completely empty or full pages
  */
 enum fullness_group {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
