Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id C64C36B0256
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:05:42 -0400 (EDT)
Received: by lahh5 with SMTP id h5so11982490lah.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:05:42 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id rb8si7228648lbb.34.2015.07.24.04.05.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 04:05:40 -0700 (PDT)
Date: Fri, 24 Jul 2015 14:05:28 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [linux-next:master 3983/4215] fs/proc/page.c:453:8: note: in
 expansion of macro 'get_user'
Message-ID: <20150724110528.GA8100@esperanza>
References: <201507241406.rvBr5f4Q%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201507241406.rvBr5f4Q%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Andres Lagar-Cavilla <andreslc@google.com>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jul 24, 2015 at 02:43:07PM +0800, kbuild test robot wrote:

>    In file included from include/linux/linkage.h:4:0,
>                     from include/linux/preempt.h:9,
>                     from include/linux/spinlock.h:50,
>                     from include/linux/mmzone.h:7,
>                     from include/linux/bootmem.h:7,
>                     from fs/proc/page.c:1:
>    fs/proc/page.c: In function 'kpageidle_write':
> >> include/linux/compiler.h:447:38: error: call to '__compiletime_assert_453' declared with attribute error: BUILD_BUG failed
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>                                          ^
>    include/linux/compiler.h:430:4: note: in definition of macro '__compiletime_assert'
>        prefix ## suffix();    \
>        ^
>    include/linux/compiler.h:447:2: note: in expansion of macro '_compiletime_assert'
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>      ^
>    include/linux/bug.h:50:37: note: in expansion of macro 'compiletime_assert'
>     #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                         ^
>    include/linux/bug.h:84:21: note: in expansion of macro 'BUILD_BUG_ON_MSG'
>     #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>                         ^
> >> arch/parisc/include/asm/uaccess.h:43:26: note: in expansion of macro 'BUILD_BUG'
>     #define LDD_KERNEL(ptr)  BUILD_BUG()
>                              ^
> >> arch/parisc/include/asm/uaccess.h:93:14: note: in expansion of macro 'LDD_KERNEL'
>          case 8: LDD_KERNEL(ptr); break;   \
>                  ^
> >> arch/parisc/include/asm/uaccess.h:40:18: note: in expansion of macro '__get_user'
>     #define get_user __get_user
>                      ^
> >> fs/proc/page.c:453:8: note: in expansion of macro 'get_user'
>        if (get_user(idle_bitmap, in)) {

The following patch should fix this issue, as well as another
kbuild-test-robot report:

  [linux-next:master 3983/4215] fs/proc/page.o:undefined reference to `__user_bad'

From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] proc: kpageidle_write: use copy_from_user instead of get_user

Not all architectures support 8-byte get_user.

Fixes: proc-add-kpageidle-file
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 9daa6e92450f..4191ddb79b84 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -464,7 +464,7 @@ static ssize_t kpageidle_write(struct file *file, const char __user *buf,
 	for (; pfn < end_pfn; pfn++) {
 		bit = pfn % KPMBITS;
 		if (bit == 0) {
-			if (get_user(idle_bitmap, in)) {
+			if (copy_from_user(&idle_bitmap, in, sizeof(u64))) {
 				ret = -EFAULT;
 				break;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
