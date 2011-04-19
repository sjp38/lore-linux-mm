Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4D0BD8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 15:29:23 -0400 (EDT)
Subject: Re: Regression from 2.6.36
Date: Tue, 19 Apr 2011 21:29:20 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20110315132527.130FB80018F1@mail1005.cent>	<20110317001519.GB18911@kroah.com>	<20110407120112.E08DCA03@pobox.sk>	<4D9D8FAA.9080405@suse.cz>	<BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>	<1302177428.3357.25.camel@edumazet-laptop>	<1302178426.3357.34.camel@edumazet-laptop>	<BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>	<1302190586.3357.45.camel@edumazet-laptop>	<20110412154906.70829d60.akpm@linux-foundation.org>	<BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>	<20110412183132.a854bffc.akpm@linux-foundation.org>	<1302662256.2811.27.camel@edumazet-laptop>	<20110413141600.28793661.akpm@linux-foundation.org> <20110413142416.507e3ed0.akpm@linux-foundation.org>
In-Reply-To: <20110413142416.507e3ed0.akpm@linux-foundation.org>
MIME-Version: 1.0
Message-Id: <20110419212920.AFE7DD8D@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, =?UTF-8?Q?Am=C3=A9rico=20Wang?= <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Mel Gorman <mel@csn.ul.ie>


Andrew,

which kernel versions will include this patch ? Thank you.

azur



______________________________________________________________
> Od: "Andrew Morton" <akpm@linux-foundation.org>
> Komu: Eric Dumazet <eric.dumazet@gmail.com>,Changli Gao <xiaosuo@gmail.com>,AmA(C)rico Wang <xiyou.wangcong@gmail.com>,Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>,linux-kernel@vger.kernel.org, linux-mm@kvack.org,linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>,Mel Gorman <mel@csn.ul.ie>
> DA!tum: 13.04.2011 23:26
> Predmet: Re: Regression from 2.6.36
>
>On Wed, 13 Apr 2011 14:16:00 -0700
>Andrew Morton <akpm@linux-foundation.org> wrote:
>
>>  fs/file.c |   17 ++++++++++-------
>>  1 file changed, 10 insertions(+), 7 deletions(-)
>
>bah, stupid compiler.
>
>
>--- a/fs/file.c~vfs-avoid-large-kmallocs-for-the-fdtable
>+++ a/fs/file.c
>@@ -9,6 +9,7 @@
> #include <linux/module.h>
> #include <linux/fs.h>
> #include <linux/mm.h>
>+#include <linux/mmzone.h>
> #include <linux/time.h>
> #include <linux/sched.h>
> #include <linux/slab.h>
>@@ -39,14 +40,17 @@ int sysctl_nr_open_max = 1024 * 1024; /*
>  */
> static DEFINE_PER_CPU(struct fdtable_defer, fdtable_defer_list);
> 
>-static inline void *alloc_fdmem(unsigned int size)
>+static void *alloc_fdmem(unsigned int size)
> {
>-	void *data;
>-
>-	data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
>-	if (data != NULL)
>-		return data;
>-
>+	/*
>+	 * Very large allocations can stress page reclaim, so fall back to
>+	 * vmalloc() if the allocation size will be considered "large" by the VM.
>+	 */
>+	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
>+		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
>+		if (data != NULL)
>+			return data;
>+	}
> 	return vmalloc(size);
> }
> 
>_
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
