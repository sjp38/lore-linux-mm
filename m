Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD1FadB021901
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 10:15:37 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD33245DD78
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:15:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E05845DD7A
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:15:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 611CB1DB803A
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:15:36 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D77AB1DB8040
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:15:35 +0900 (JST)
Date: Thu, 13 Nov 2008 10:13:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
Message-Id: <20081113101344.6882c209.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112160758.3dca0b22.akpm@linux-foundation.org>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112160758.3dca0b22.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, menage@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 16:07:58 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 12 Nov 2008 12:26:56 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > +5.1 on_rmdir
> > +set behavior of memcg at rmdir (Removing cgroup) default is "drop".
> > +
> > +5.1.1 drop
> > +       #echo on_rmdir drop > memory.attribute
> > +       This is default. All pages on the memcg will be freed.
> > +       If pages are locked or too busy, they will be moved up to the parent.
> > +       Useful when you want to drop (large) page caches used in this memcg.
> > +       But some of in-use page cache can be dropped by this.
> > +
> > +5.1.2 keep
> > +       #echo on_rmdir keep > memory.attribute
> > +       All pages on the memcg will be moved to its parent.
> > +       Useful when you don't want to drop page caches used in this memcg.
> > +       You can keep page caches from some library or DB accessed by this
> > +       memcg on memory.
> 
> Would it not be more useful to implement a per-memcg version of
> /proc/sys/vm/drop_caches?  (One without drop_caches' locking bug,
> hopefully).
> 
> If we do this then we can make the above "keep" behaviour non-optional,
> and the operator gets to choose whether or not to drop the caches
> before doing the rmdir.
> 
> Plus, we get a new per-memcg drop_caches capability.  And it's a nicer
> interface, and it doesn't have the obvious races which on_rmdir has,
> etc.
> 
> hm?
> 
In my plan, I'll add

memory.shrink_usage interface to do and allows

#echo 0M > memory.shrink_memory_usage
(you may swap tasks out if there is task..)

to drop pages.

Balbir, how do you think ? I've already removed "force_empty".

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
