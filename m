Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 457256B0276
	for <linux-mm@kvack.org>; Sun,  9 May 2010 21:44:50 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4A1il8c004861
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 May 2010 10:44:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D70845DE51
	for <linux-mm@kvack.org>; Mon, 10 May 2010 10:44:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C35C45DE4F
	for <linux-mm@kvack.org>; Mon, 10 May 2010 10:44:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 368C11DB803F
	for <linux-mm@kvack.org>; Mon, 10 May 2010 10:44:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E76981DB8038
	for <linux-mm@kvack.org>; Mon, 10 May 2010 10:44:46 +0900 (JST)
Date: Mon, 10 May 2010 10:40:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
 rmap_walk by guaranteeing rmap_walk finds PTEs created within the temporary
 stack
Message-Id: <20100510104039.98332e67.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1005091831140.3711@i5.linux-foundation.org>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
	<1273188053-26029-3-git-send-email-mel@csn.ul.ie>
	<alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org>
	<20100507105712.18fc90c4.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org>
	<20100509192145.GI4859@csn.ul.ie>
	<alpine.LFD.2.00.1005091245000.3711@i5.linux-foundation.org>
	<20100510094050.8cb79143.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1005091827500.3711@i5.linux-foundation.org>
	<alpine.LFD.2.00.1005091831140.3711@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sun, 9 May 2010 18:32:32 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Sun, 9 May 2010, Linus Torvalds wrote:
> > 
> > So I never disliked that patch. I'm perfectly happy with a "don't migrate 
> > these pages at all, because they are in a half-way state in the middle of 
> > execve stack magic".
> 
> Btw, I also think that Mel's patch could be made a lot _less_ magic by 
> just marking that initial stack vma with a VM_STACK_INCOMPLETE_SETUP bit, 
> instead of doing that "maybe_stack" thing. We could easily make that 
> initial vma setup very explicit indeed, and then just clear that bit when 
> we've moved the stack to its final position.
> 

Hmm. vm_flags is still 32bit..(I think it should be long long)

Using combination of existing flags...

#define VM_STACK_INCOMPLETE_SETUP (VM_RAND_READ | VM_SEC_READ)

Can be used instead of checking mapcount, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
