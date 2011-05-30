Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id ABB366B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 21:12:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9945D3EE081
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:12:35 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F3B345DE69
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:12:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6443D45DE61
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:12:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 504661DB8038
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:12:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 169C81DB803C
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:12:35 +0900 (JST)
Message-ID: <4DE2EEFB.1080803@jp.fujitsu.com>
Date: Mon, 30 May 2011 10:12:27 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix boot crash in mm_alloc()
References: <20110529072256.GA20983@elte.hu> <BANLkTikHejgEyz9LfJ962Bu89vn1cBP+WQ@mail.gmail.com> <BANLkTimqhkiBSArm7n0_9FD+LW6hWBWxFA@mail.gmail.com> <BANLkTin8yxh=Bjwf7AEyzPCoghnYO2brLQ@mail.gmail.com>
In-Reply-To: <BANLkTin8yxh=Bjwf7AEyzPCoghnYO2brLQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: mingo@elte.hu, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl, linux-mm@kvack.org

(2011/05/30 3:43), Linus Torvalds wrote:
> On Sun, May 29, 2011 at 10:19 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> STILL TOTALLY UNTESTED! The fixes were just from eyeballing it a bit
>> more, not from any actual testing.
> 
> Ok, I eyeballed it some more, and tested both the OFFSTACK and ONSTACK
> case, and decided that I had better commit it now rather than wait any
> later since I'll do the -rc1 later today, and will be on an airplane
> most of tomorrow.
> 
> The exact placement of the cpu_vm_mask_var is up for grabs. For
> example, I started thinking that it might be better to put it *after*
> the mm_context_t, since for the non-OFFSTACK case it's generally
> touched at the beginning rather than the end.
> 
> And the actual change to make the mm_cachep kmem_cache_create() use a
> variable-sized allocation for the OFFSTACK case is similarly left as
> an exercise for the the reader. So effectively, this reverts a lot of
> de03c72cfce5, but does so in a way that should make very it easy to
> get back to where KOSAKI was aiming for.
> 
> Whatever. I was hoping to get comments on it, but I think I need to
> rather push it out to get tested and public than wait any longer. The
> patch *looks* fine, tests ok on my machine, and removes more lines
> than it adds despite the new big comment.

Hi

Thank you Linus and I'm sorry for bother you and guys. So, if I understand
this thread correctly, rest my homework is 1) make cpumask_allocation variable
size 2) remove NR_CPUS bit fill/copy from fork/exec path. Right?

I think (2) is big matter than (1). NR_CPUS(=4096) bits copy easily screw up
cache behavior. Anyway, will do. Thank you!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
