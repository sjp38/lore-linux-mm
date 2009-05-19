Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9A2426B004D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 00:43:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J4iLTm003010
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 May 2009 13:44:21 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 67F4745DE53
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:44:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A35045DE51
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:44:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 435EA1DB803F
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:44:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E11D41DB803A
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:44:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class citizen
In-Reply-To: <20090519133422.4ECC.A69D9226@jp.fujitsu.com>
References: <20090519032759.GA7608@localhost> <20090519133422.4ECC.A69D9226@jp.fujitsu.com>
Message-Id: <20090519134253.4ECF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 May 2009 13:44:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> > begin:       2479             2344             9659              210                0           579643
> > end:          284           232010           234142              260           772776         20917184
> > restore:      379           232159           234371              301           774888         20967849
> > 
> > The numbers show that
> > 
> > - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
> >   I'd attribute that improvement to the mmap readahead improvements :-)
> > 
> > - The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
> >   That's a huge improvement - which means with the VM_EXEC protection logic,
> >   active mmap pages is pretty safe even under partially cache hot streaming IO.
> > 
> > - when active:inactive file lru size reaches 1:1, their scan rates is 1:20.8
> >   under 10% cache hot IO. (computed with formula Dpgdeactivate:Dpgfree)
> >   That roughly means the active mmap pages get 20.8 more chances to get
> >   re-referenced to stay in memory.
> > 
> > - The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
> >   dropped pages are mostly inactive ones. The patch has almost no impact in
> >   this aspect, that means it won't unnecessarily increase memory pressure.
> >   (In contrast, your 20% mmap protection ratio will keep them all, and
> >   therefore eliminate the extra 41 major faults to restore working set
> >   of zsh etc.)
> 
> I'm surprised this.
> Why your patch don't protect mapped page from streaming io?

I guess you use initlevel=5 and use only terminal, right?
if so, dropping some graphics component makes sense.


> 
> I strongly hope reproduce myself, please teach me reproduce way.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
