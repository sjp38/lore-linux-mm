Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A7CBD6B0031
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 01:07:08 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so5909925pdj.22
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 22:07:08 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xu5si14628694pab.51.2013.12.23.22.07.06
        for <linux-mm@kvack.org>;
        Mon, 23 Dec 2013 22:07:07 -0800 (PST)
Date: Tue, 24 Dec 2013 15:07:05 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
Message-ID: <20131224060705.GA16140@lge.com>
References: <52B1C143.8080301@oracle.com>
 <52B871B2.7040409@oracle.com>
 <20131224025127.GA2835@lge.com>
 <52B8F8F6.1080500@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B8F8F6.1080500@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>

On Mon, Dec 23, 2013 at 10:01:10PM -0500, Sasha Levin wrote:
> On 12/23/2013 09:51 PM, Joonsoo Kim wrote:
> >On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin wrote:
> >>>Ping?
> >>>
> >>>I've also Cc'ed the "this page shouldn't be locked at all" team.
> >Hello,
> >
> >I can't find the reason of this problem.
> >If it is reproducible, how about bisecting?
> 
> While it reproduces under fuzzing it's pretty hard to bisect it with
> the amount of issues uncovered by trinity recently.
> 
> I can add any debug code to the site of the BUG if that helps.

Good!
It will be helpful to add dump_page() in migration_entry_to_page().

Thanks.

--------8<------
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index c0f7526..f695abc 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -3,6 +3,7 @@
 
 #include <linux/radix-tree.h>
 #include <linux/bug.h>
+#include <linux/mm.h>
 
 /*
  * swapcache pages are stored in the swapper_space radix tree.  We want to
@@ -128,6 +129,8 @@ static inline struct page *migration_entry_to_page(swp_entry_t entry)
         * Any use of migration entries may only occur while the
         * corresponding page is locked
         */
+       if (!PageLocked(p))
+               dump_page(p);
        BUG_ON(!PageLocked(p));
        return p;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
