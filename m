Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4EC436B00CC
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 23:34:21 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA94YH74018530
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 13:34:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46BA645DE51
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 13:34:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 205C945DE4E
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 13:34:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06280E18001
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 13:34:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B7402E08001
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 13:34:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC: reviving mlock isolation dead code
In-Reply-To: <20101101015311.6062.A69D9226@jp.fujitsu.com>
References: <AANLkTik4NM5YOgh48bOWDQZuUKmEHLH6Ja10eOzn-_tj@mail.gmail.com> <20101101015311.6062.A69D9226@jp.fujitsu.com>
Message-Id: <20101109115540.BC3F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 13:34:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Michel,

> Hello,
> 
> > I would like to resurect this, as I am seeing problems during a large
> > mlock (many GB). The mlock takes a long time to complete
> > (__mlock_vma_pages_range() is loading pages from disk), there is
> > memory pressure as some pages have to be evicted to make room for the
> > large mlock, and the LRU algorithm performs badly with the high amount
> > of pages still on LRU list - PageMlocked has not been set yet - while
> > their VMA is already VM_LOCKED.
> > 
> > One approach I am considering would be to modify
> > __mlock_vma_pages_range() and it call sites so the mmap sem is only
> > read-owned while __mlock_vma_pages_range() runs. The mlock handling
> > code in try_to_unmap_one() would then be able to acquire the
> > mmap_sem() and help, as it is designed to do.
> 
> I would like to talk historical story a bit. Originally, Lee designed it as you proposed. 
> but Linus refused it. He thought ro-rwsem is bandaid fix. That is one of reason that
> some developers seeks proper mmap_sem dividing way.

While in airplane to come back from KS and LPC, I was thinking this issue. now I think
we can solve this issue. can you please hear my idea?

Now, mlock has following call flow

sys_mlock
	down_write(mmap_sem)
	do_mlock()
		for-each-vma
			mlock_fixup()
				__mlock_vma_pages_range()
					__get_user_pages()
	up_write(mmap_sem)


And, someone tried following change and Linus refuse it because releasing mmap_sem
while mlock() syscall can makes nasty race issue. He storongly requested we don't release
mmap_sem while processing mlock().


sys_mlock
	down_write(mmap_sem)
	do_mlock()
		for-each-vma
			downgrade_write(mmap_sem)
			mlock_fixup()
				__mlock_vma_pages_range()
					__get_user_pages()
			up_read(mmap_sem)
			// race here
			down_write(mmap_sem)
	up_write(mmap_sem)


Then, I'd propose two phase mlock. that said,

sys_mlock
	down_write(mmap_sem)
	do_mlock()
		for-each-vma
			turn on VM_LOCKED and merge/split vma
	downgrade_write(mmap_sem)
		for-each-vma
			mlock_fixup()
				__mlock_vma_pages_range()
	up_read(mmap_sem)


Usually, kernel developers strongly dislike two phase thing beucase it's slow. but at least
_I_ think it's ok in this case. because mlock is really really slow syscall, it often take a few
*miniture*. then, A few microsecond slower is not big matter.

What do you think?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
