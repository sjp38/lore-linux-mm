Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AD4538D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 08:13:51 -0400 (EDT)
Received: by wyf19 with SMTP id 19so2848138wyf.14
        for <linux-mm@kvack.org>; Thu, 07 Apr 2011 05:13:49 -0700 (PDT)
Subject: Re: Regression from 2.6.36
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1302177428.3357.25.camel@edumazet-laptop>
References: <20110315132527.130FB80018F1@mail1005.cent>
	 <20110317001519.GB18911@kroah.com> <20110407120112.E08DCA03@pobox.sk>
	 <4D9D8FAA.9080405@suse.cz>
	 <BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
	 <1302177428.3357.25.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Apr 2011 14:13:46 +0200
Message-ID: <1302178426.3357.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Cc: Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

Le jeudi 07 avril 2011 A  13:57 +0200, Eric Dumazet a A(C)crit :

> We had a similar memory problem in fib_trie in the past  : We force a
> synchronize_rcu() every XXX Mbytes allocated to make sure we dont have
> too much ram waiting to be freed in rcu queues.

This was done in commit c3059477fce2d956
(ipv4: Use synchronize_rcu() during trie_rebalance())

It was possible in fib_trie because we hold RTNL lock, so managing
a counter was free.

In fs case, we might use a percpu_counter if we really want to limit the
amount of space.

Now, I am not even sure we should care that much and could just forget
about this high order pages use.


diff --git a/fs/file.c b/fs/file.c
index 0be3447..7ba26fe 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -41,12 +41,6 @@ static DEFINE_PER_CPU(struct fdtable_defer,
fdtable_defer_list);
 
 static inline void *alloc_fdmem(unsigned int size)
 {
-	void *data;
-
-	data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
-	if (data != NULL)
-	return data;
-
 	return vmalloc(size);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
