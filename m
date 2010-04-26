Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D0C9A6B01E3
	for <linux-mm@kvack.org>; Sun, 25 Apr 2010 22:57:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3Q2vjIA016734
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 26 Apr 2010 11:57:46 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D3C2F45DE51
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 11:57:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AABEC45DE4E
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 11:57:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 912721DB8038
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 11:57:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E4831DB803A
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 11:57:45 +0900 (JST)
Date: Mon, 26 Apr 2010 11:53:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-Id: <20100426115347.2ee2a917.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100426084901.15c09a29.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423095922.GJ30306@csn.ul.ie>
	<20100423155801.GA14351@csn.ul.ie>
	<20100424110200.b491ec5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100424104324.GD14351@csn.ul.ie>
	<20100426084901.15c09a29.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Apr 2010 08:49:01 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Sat, 24 Apr 2010 11:43:24 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:

> > It looks nice but it still broke after 28 hours of running. The
> > seq-counter is still insufficient to catch all changes that are made to
> > the list. I'm beginning to wonder if a) this really can be fully safely
> > locked with the anon_vma changes and b) if it has to be a spinlock to
> > catch the majority of cases but still a lazy cleanup if there happens to
> > be a race. It's unsatisfactory and I'm expecting I'll either have some
> > insight to the new anon_vma changes that allow it to be locked or Rik
> > knows how to restore the original behaviour which as Andrea pointed out
> > was safe.
> > 
> Ouch. Hmm, how about the race in fork() I pointed out ?
> 
Forget this. Sorry for noise.

==
This is a memo for myself.

*) at fork, when copying a vma for file, vma_prio_tree_add() is called
   before copying page tables.
   There are several patterns.

Assume tasks named as t1,t2,t3,t4,t5 and their own vmas v1,v2,v3,v4,v5 which map
a range in address spaces.

(a) t1 forks t2.
   v1 is in prio_tree, v2 for t2 will be pointed by ->head pointer.

   \
    v1  --(head)---> v2 
   /  \
  ?    ?

  vma_prio_tree_foreach() order : v1->v2.


(b) after (a), t2 forks t3. (list_add() is used.)
 
    \
     v1 --(head)--> v2 ->(list.next)->v3
    /  \
   ?    ?

   vma_prio_tree_foreach() order : v1->v2->v3

(c) after (b), t1 forks t4.

    \
     v1 --(head)--> v2 ->(list.next)->v3->v4
    /  \              
   ?    ?

    vma_prio_tree_foreach() order : v1->v2->v3->v4

(d) after (c), t4 forks t5.

    \
     v1 --(head)--> v2 ->(list.next)->v3->v4->v5
    /  \               
   ?    ?
    vma_prio_tree_foreach() order : v1->v2->v3->v4->v5

(e) after (c), t3 forks t5.
    \
     v1 --(head)--> v2 ->(list.next)->v3->v5->v4-
    /  \               
   ?    ?
    vma_prio_tree_foreach() order : v1->v2->v3->v5->v4

.....in any case, it seems vma_prio_tree_foreach() finds
the parent's vma 1st.

Thx,
-Kame















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
