Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5FD926B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:14:19 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBB0EGll010315
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Dec 2009 09:14:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F1D645DE53
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:14:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1ABCD45DE4D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:14:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F38401DB8042
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:14:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A90D21DB803A
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:14:15 +0900 (JST)
Date: Fri, 11 Dec 2009 09:11:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
Message-Id: <20091211091114.c5fa4371.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091210185459.GA8697@elte.hu>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210075454.GB25549@elte.hu>
	<20091210172040.37d259d3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210083310.GB6834@elte.hu>
	<alpine.DEB.2.00.0912101134220.5481@router.home>
	<20091210173819.GA5256@elte.hu>
	<alpine.DEB.2.00.0912101203320.5481@router.home>
	<20091210185459.GA8697@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009 19:54:59 +0100
Ingo Molnar <mingo@elte.hu> wrote:
> > [...] Exposing via perf is outside of the scope of his work.
> 
> Please make thoughts about intelligent instrumentation solutions, and 
> please think "outside of the scope" of your usual routine.
> 

I'm sorry that I don't fully understand your suggestion...

This patch is for _usage_ counters (those can increase/decrease and can be
modified in batched manner), but you don't talk about usage counter
but about lack of (useful) _event_ counters under page fault path.

If so, yes, I agree that current events are not enough.
If not, hmm ? 

More event counters I can think of around mm/page-fault is following..

  - fault to new anon pages
    + a new anon page is from remote node.
  - fault to file-backed area
    + a file page is from remote node.
  - copy_on_write
    +  a new anon page is from remote node.
    +  copy-on-write to zero page.
  - make page write (make page dirty)
  - search vma. (find_vma() is called and goes into rb-tree lookup)
  - swap-in (necessary ?)
  - get_user_page() is called to snoop other process's memory.

I wonder adding event and inserting perf_sw_event(PERF_COUNT_SW....) is
enough for adding event coutners...but is there good documentation of
this hook ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
