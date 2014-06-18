Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8265E6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 19:20:47 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so1232749pbc.12
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:20:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ez7si3694339pab.241.2014.06.18.16.20.46
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 16:20:46 -0700 (PDT)
Date: Wed, 18 Jun 2014 16:20:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32'
 undeclared
Message-Id: <20140618162045.11cbe478dcd0b236f974f953@linux-foundation.org>
In-Reply-To: <53a21a3e.1HJ5drRU6UL26Oem%fengguang.wu@intel.com>
References: <53a21a3e.1HJ5drRU6UL26Oem%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Will Woods <wwoods@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, "Luck, Tony" <tony.luck@intel.com>

On Thu, 19 Jun 2014 07:01:18 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   e99cfa2d0634881b8a41d56c48b5956b9a3ba162
> commit: 1e2ee49f7f1b79f0b14884fe6a602f0411b39552 fanotify: fix -EOVERFLOW with large files on 64-bit
> date:   6 weeks ago
> config: make ARCH=ia64 allmodconfig
>
> All error/warnings:
> 
>    fs/notify/fanotify/fanotify_user.c: In function 'SYSC_fanotify_init':
>    fs/notify/fanotify/fanotify_user.c:701:2: error: implicit declaration of function 'personality' [-Werror=implicit-function-declaration]
>      if (force_o_largefile())
>      ^
>    In file included from include/uapi/linux/fcntl.h:4:0,
>                     from include/linux/fcntl.h:4,
>                     from fs/notify/fanotify/fanotify_user.c:2:
> >> arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32' undeclared (first use in this function)
>       (personality(current->personality) != PER_LINUX32)
>                                             ^
>    fs/notify/fanotify/fanotify_user.c:701:6: note: in expansion of macro 'force_o_largefile'
>      if (force_o_largefile())
>          ^
>    arch/ia64/include/uapi/asm/fcntl.h:9:41: note: each undeclared identifier is reported only once for each function it appears in
>       (personality(current->personality) != PER_LINUX32)
>                                             ^
>    fs/notify/fanotify/fanotify_user.c:701:6: note: in expansion of macro 'force_o_largefile'
>      if (force_o_largefile())
>          ^
>    cc1: some warnings being treated as errors

Thanks.  This works for me:


From: Andrew Morton <akpm@linux-foundation.org>
Subject: ia64: arch/ia64/include/uapi/asm/fcntl.h needs personality.h

fs/notify/fanotify/fanotify_user.c: In function 'SYSC_fanotify_init':
fs/notify/fanotify/fanotify_user.c:726: error: implicit declaration of function 'personality'
fs/notify/fanotify/fanotify_user.c:726: error: 'PER_LINUX32' undeclared (first use in this function)
fs/notify/fanotify/fanotify_user.c:726: error: (Each undeclared identifier is reported only once
fs/notify/fanotify/fanotify_user.c:726: error: for each function it appears in.)

Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Cc: Will Woods <wwoods@redhat.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: <stable@vger.kernel.org>	[3.15.x]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/include/uapi/asm/fcntl.h |    1 +
 1 file changed, 1 insertion(+)

diff -puN arch/ia64/include/uapi/asm/fcntl.h~ia64-arch-ia64-include-uapi-asm-fcntlh-needs-personalityh arch/ia64/include/uapi/asm/fcntl.h
--- a/arch/ia64/include/uapi/asm/fcntl.h~ia64-arch-ia64-include-uapi-asm-fcntlh-needs-personalityh
+++ a/arch/ia64/include/uapi/asm/fcntl.h
@@ -8,6 +8,7 @@
 #define force_o_largefile()	\
 		(personality(current->personality) != PER_LINUX32)
 
+#include <linux/personality.h>
 #include <asm-generic/fcntl.h>
 
 #endif /* _ASM_IA64_FCNTL_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
