Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id C10E082FD8
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 01:39:43 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id a85so4371789ykb.1
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 22:39:43 -0800 (PST)
Received: from mail-yk0-x242.google.com (mail-yk0-x242.google.com. [2607:f8b0:4002:c07::242])
        by mx.google.com with ESMTPS id g129si38601833ywf.371.2015.12.26.22.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 22:39:43 -0800 (PST)
Received: by mail-yk0-x242.google.com with SMTP id k129so7183682yke.3
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 22:39:42 -0800 (PST)
From: Joshua Clayton <stillcompiling@gmail.com>
Subject: [PATCH v2] mm: fix noisy sparse warning in LIBCFS_ALLOC_PRE()
Date: Sat, 26 Dec 2015 22:39:31 -0800
Message-ID: <2945911.XxDChhFj7Z@diplodocus>
In-Reply-To: <20151227054117.GG20997@ZenIV.linux.org.uk>
References: <1451193162-20057-1-git-send-email-stillcompiling@gmail.com> <20151227054117.GG20997@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

running sparse on drivers/staging/lustre results in dozens of warnings:
include/linux/gfp.h:281:41: warning:
odd constant _Bool cast (400000 becomes 1)

Use "!!" to explicitly convert to bool and get rid of the warning.

Signed-off-by: Joshua Clayton <stillcompiling@gmail.com>
---

On Sunday, December 27, 2015 05:41:17 AM Al Viro wrote:
> On Sat, Dec 26, 2015 at 09:12:42PM -0800, Joshua Clayton wrote:
> > running sparse on drivers/staging/lustre results in dozens of warnings:
> > include/linux/gfp.h:281:41: warning:
> > odd constant _Bool cast (400000 becomes 1)
> > 
> > Use "!!" to explicitly convert the result to bool range.
> 
> ... and the cast to bool is left in order to...?
> 
> > -	return (bool __force)(gfp_flags & __GFP_DIRECT_RECLAIM);
> > +	return (bool __force)!!(gfp_flags & __GFP_DIRECT_RECLAIM);
to embarrass me, I suppose. :(
I didn't think about the redundancy of the cast.
Lets try that again.

 include/linux/gfp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 91f74e7..28ad5f6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -278,7 +278,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 
 static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 {
-	return (bool __force)(gfp_flags & __GFP_DIRECT_RECLAIM);
+	return !!(gfp_flags & __GFP_DIRECT_RECLAIM);
 }
 
 #ifdef CONFIG_HIGHMEM
-- 
2.6.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
