Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A5F596B0047
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:20:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N0Dook019176
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Mar 2009 09:13:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 090B445DD7F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:13:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D75E645DD7E
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:13:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A756AE0800C
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:13:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A18D1DB803E
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:13:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090322205249.6801.A69D9226@jp.fujitsu.com>
References: <20090318105735.BD17.A69D9226@jp.fujitsu.com> <20090322205249.6801.A69D9226@jp.fujitsu.com>
Message-Id: <20090323091056.69DF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Mar 2009 09:13:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi
> 
> following patch is my v2 approach.
> it survive Andrea's three dio test-case.
> 
> Linus suggested to change add_to_swap() and shrink_page_list() stuff
> for avoid false cow in do_wp_page() when page become to swapcache.
> 
> I think it's good idea. but it's a bit radical. so I think it's for development
> tree tackle.
> 
> Then, I decide to use Nick's early decow in 
> get_user_pages() and RO mapped page don't use gup_fast.
> 
> yeah, my approach is extream brutal way and big hammer. but I think 
> it don't have performance issue in real world.
> 
> why?
> 
> Practically, we can assume following two thing.
> 
> (1) the buffer of passed write(2) syscall argument is RW mapped
>     page or COWed RO page.
> 
> if anybody write following code, my path cause performance degression.
> 
>    buf = mmap()
>    memset(buf, 0x11, len);
>    mprotect(buf, len, PROT_READ)
>    fd = open(O_DIRECT)
>    write(fd, buf, len)
> 
> but it's very artifactical code. nobody want this.
> ok, we can ignore this.
> 
> (2) DirectIO user process isn't short lived process.
> 
> early decow only decrease short lived process performaqnce. 
> because long lived process do decowing anyway before exec(2).
> 
> and, All DB application is definitely long lived process.
> then early decow don't cause degression.

Frankly, linus sugessted to insert one branch into do_wp_page(), 
but I remove one branch from gup_fast.

I think it's good performance trade-off.
but if anybody hate my approach, I'll drop my chicken heart and
try to linus suggested way.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
