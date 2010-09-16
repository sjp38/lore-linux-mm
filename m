Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9FF346B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 21:38:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G1cZ68003403
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Sep 2010 10:38:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 486AF45DE4E
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:38:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 22C3145DE55
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:38:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 09B0D1DB803C
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:38:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A60F1E08003
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:38:34 +0900 (JST)
Date: Thu, 16 Sep 2010 10:33:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
Message-Id: <20100916103326.026ca03f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1284600107.20776.640.camel@nimitz>
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
	<20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
	<20100915192454.GD5585@tpepper-t61p.dolavim.us>
	<20100916091215.ef59acd7.kamezawa.hiroyu@jp.fujitsu.com>
	<1284600107.20776.640.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Tim Pepper <lnxninja@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010 18:21:47 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Thu, 2010-09-16 at 09:12 +0900, KAMEZAWA Hiroyuki wrote:
> > I hear a customer's case. His server generates 3-80000+ new dentries per day
> > and dentries will be piled up to 1000000+ in a month. This makes open()'s 
> > performance very bad because Hash-lookup will be heavy. (He has very big memory.)
> > 
> > What we could ask him was
> >   - rewrite your application. or
> >   - reboot once in a month (and change hash size) or
> >   - drop_cache once in a month
> > 
> > Because their servers cannot stop, he used drop_caches once in a month
> > while his server is idle, at night. Changing HashSize cannot be a permanent
> > fix because he may not stop the server for years.
> 
> That is a really interesting case.
> 
> They must have a *ton* of completely extra memory laying around.  Do
> they not have much page cache activity? 

I hear they have a ton of extra memory. Just open() slows down.

> It usually balances out the  dentry/inode caches.
> 
> Would this user be better off with a smaller dentry hash in general? 

Maybe. I hear most of files were created-but-never-used data and logs.

> Is it special hardware that should _have_ a lower default hash size?
> 

I'm not sure. I think they have no boot option of hash size.


> > For rare users who have 10000000+ of files and tons of free memory, drop_cache
> > can be an emergency help. 
> 
> In this case, though, would a WARN_ON() in an emergency be such a bad
> thing?  They evidently know what they're doing, and shouldn't be put off
> by it.
> 

Showing "Warning" means ", it's possibly bug." for almost all customers.
We'll get tons of "regression" report ;)

If you really want to add messages, please raise log level.
NOTICE or INFO sounds better(and moderate) to me because it's easy to explain
"Don't worry about the message, your kernel is stable and don't need to reboot.
 But please check the peformance, it tends to go bad. You lose cache.".
BTW, what(1or2or3) was writtern to "drop_cache" is important. please show.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
