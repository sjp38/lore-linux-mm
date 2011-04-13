Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 27CCA900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:25:09 -0400 (EDT)
Date: Wed, 13 Apr 2011 14:24:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Regression from 2.6.36
Message-Id: <20110413142416.507e3ed0.akpm@linux-foundation.org>
In-Reply-To: <20110413141600.28793661.akpm@linux-foundation.org>
References: <20110315132527.130FB80018F1@mail1005.cent>
	<20110317001519.GB18911@kroah.com>
	<20110407120112.E08DCA03@pobox.sk>
	<4D9D8FAA.9080405@suse.cz>
	<BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
	<1302177428.3357.25.camel@edumazet-laptop>
	<1302178426.3357.34.camel@edumazet-laptop>
	<BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
	<1302190586.3357.45.camel@edumazet-laptop>
	<20110412154906.70829d60.akpm@linux-foundation.org>
	<BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>
	<20110412183132.a854bffc.akpm@linux-foundation.org>
	<1302662256.2811.27.camel@edumazet-laptop>
	<20110413141600.28793661.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Mel Gorman <mel@csn.ul.ie>

On Wed, 13 Apr 2011 14:16:00 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

>  fs/file.c |   17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)

bah, stupid compiler.


--- a/fs/file.c~vfs-avoid-large-kmallocs-for-the-fdtable
+++ a/fs/file.c
@@ -9,6 +9,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/mmzone.h>
 #include <linux/time.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -39,14 +40,17 @@ int sysctl_nr_open_max = 1024 * 1024; /*
  */
 static DEFINE_PER_CPU(struct fdtable_defer, fdtable_defer_list);
 
-static inline void *alloc_fdmem(unsigned int size)
+static void *alloc_fdmem(unsigned int size)
 {
-	void *data;
-
-	data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
-	if (data != NULL)
-		return data;
-
+	/*
+	 * Very large allocations can stress page reclaim, so fall back to
+	 * vmalloc() if the allocation size will be considered "large" by the VM.
+	 */
+	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
+		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
+		if (data != NULL)
+			return data;
+	}
 	return vmalloc(size);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
