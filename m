Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9936B0257
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 06:29:50 -0500 (EST)
Received: by wmec201 with SMTP id c201so255319302wme.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 03:29:49 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id m7si11365972wmc.120.2015.12.09.03.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 03:29:49 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
Date: Wed, 09 Dec 2015 12:29:39 +0100
Message-ID: <9558837.lN284KClUg@wuerfel>
In-Reply-To: <1449242195-16374-1-git-send-email-vbabka@suse.cz>
References: <87io4hi06n.fsf@rasmusvillemoes.dk> <1449242195-16374-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Friday 04 December 2015 16:16:33 Vlastimil Babka wrote:
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -2,15 +2,20 @@
>  #define LINUX_MM_DEBUG_H 1
>  
>  #include <linux/stringify.h>
> +#include <linux/types.h>
> +#include <linux/tracepoint.h>

8<-----
Subject: mm: fix generated/bounds.h

The inclusion of linux/tracepoint.h is causing build errors for me in ARM
randconfig:

In file included from /git/arm-soc/include/linux/ktime.h:25:0,
                 from /git/arm-soc/include/linux/rcupdate.h:47,
                 from /git/arm-soc/include/linux/tracepoint.h:19,
                 from /git/arm-soc/include/linux/mmdebug.h:6,
                 from /git/arm-soc/include/linux/page-flags.h:10,
                 from /git/arm-soc/kernel/bounds.c:9:
/git/arm-soc/include/linux/jiffies.h:10:33: fatal error: generated/timeconst.h: No such file or directory
compilation terminated.

To work around this, we can stop including linux/mmdebug.h from linux/page_flags.h
while generating bounds.h, as we do for mm_types.h already.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 8c0d593d0f8f ("mm, printk: introduce new format string for flags")

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 19724e6ebd26..4efad0578a28 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -7,8 +7,8 @@
 
 #include <linux/types.h>
 #include <linux/bug.h>
-#include <linux/mmdebug.h>
 #ifndef __GENERATING_BOUNDS_H
+#include <linux/mmdebug.h>
 #include <linux/mm_types.h>
 #include <generated/bounds.h>
 #endif /* !__GENERATING_BOUNDS_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
