Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E7850600786
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 07:23:30 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB1CNS0l016851
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Dec 2009 21:23:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0927845DE54
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:23:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B1A8545DE4F
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:23:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C2551DB803F
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:23:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4101F1DB8038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:23:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] high system time & lock contention running large mixed workload
In-Reply-To: <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
References: <20091125133752.2683c3e4@bree.surriel.com> <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
Message-Id: <20091201102645.5C0A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  1 Dec 2009 21:23:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

(cc to some related person)

> The cause was determined to be the unconditional call to
> page_referenced() for every mapped page encountered in
> shrink_active_list().  page_referenced() takes the anon_vma->lock and
> calls page_referenced_one() for each vma.  page_referenced_one() then
> calls page_check_address() which takes the pte_lockptr spinlock.   If
> several CPUs are doing this at the same time there is a lot of
> pte_lockptr spinlock contention with the anon_vma->lock held.  This
> causes contention on the anon_vma->lock, stalling in the fo and very
> high system time.
> 
> Before the splitLRU patch shrink_active_list() would only call
> page_referenced() when reclaim_mapped got set.  reclaim_mapped only got
> set when the priority worked its way from 12 all the way to 7. This
> prevented page_referenced() from being called from shrink_active_list()
> until the system was really struggling to reclaim memory.
> 
> On way to prevent this is to change page_check_address() to execute a
> spin_trylock(ptl) when it was called by shrink_active_list() and simply
> fail if it could not get the pte_lockptr spinlock.  This will make
> shrink_active_list() consider the page not referenced and allow the
> anon_vma->lock to be dropped much quicker.
> 
> The attached patch does just that, thoughts???

At first look,

   - We have to fix this issue certenally.
   - But your patch is a bit risky. 

Your patch treat trylock(pte-lock) failure as no accessced. but
generally lock contention imply to have contention peer. iow, the page
have reference bit typically. then, next shrink_inactive_list() move it
active list again. that's suboptimal result.

However, we can't treat lock-contention as page-is-referenced simply. if it does,
the system easily go into OOM.

So, 
	if (priority < DEF_PRIORITY - 2)
		page_referenced()
	else
		page_refenced_trylock()

is better?
On typical workload, almost vmscan only use DEF_PRIORITY. then,
if priority==DEF_PRIORITY situation don't cause heavy lock contention,
the system don't need to mind the contention. anyway we can't avoid
contention if the system have heavy memory pressure.

btw, current shrink_active_list() have unnecessary page_mapping_inuse() call.
it prevent to drop page reference bit from unmapped cache page. it mean
we protect unmapped cache page than mapped page. it is strange.

Unfortunately, I don't have enough development time today. I'll
working on tommorow.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
