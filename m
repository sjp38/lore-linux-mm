Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BB72A5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 02:15:33 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E6FjOR027408
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 15:15:46 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A5E445DD7B
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:15:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E25545DD78
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:15:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B20EE08006
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:15:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 016B6E08001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:15:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 0/6] IO pinning(get_user_pages()) vs fork race fix
Message-Id: <20090414151204.C647.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 15:15:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Linux Device Drivers, Third Edition, Chapter 15: Memory Mapping and DMA says

	get_user_pages is a low-level memory management function, with a suitably complex
	interface. It also requires that the mmap reader/writer semaphore for the address
	space be obtained in read mode before the call. As a result, calls to get_user_pages
	usually look something like:

		down_read(&current->mm->mmap_sem);
		result = get_user_pages(current, current->mm, ...);
		up_read(&current->mm->mmap_sem);

	The return value is the number of pages actually mapped, which could be fewer than
	the number requested (but greater than zero).

but, it isn't true. mmap_sem isn't only used for vma traversal, but also prevent vs-fork race.
up_read(mmap_sem) mean end of critical section, IOW after up_read() code is fork unsafe.
(access_process_vm() explain proper get_user_pages() usage)

Oh well, We have many wrong caller now. What is the best fix method?

Nick Piggin and Andrea Arcangeli proposed to change get_user_pages() semantics as caller expected.
  see "[PATCH] fork vs gup(-fast) fix" thead in linux-mm
but Linus NACKed it.

Thus I made caller change approach patch series. it is made for discuss to compare Nick's approach.
I don't hope submit it yet.

Nick, This version fixed vmsplice and aio issue (you pointed). I hope to hear your opiniton ;)



ChangeLog:
  V2 -> V3
   o remove early decow logic
   o introduce prevent unmap logic
   o fix nfs-directio
   o fix aio
   o fix bio (only bandaid fix)

  V1 -> V2
   o fix aio+dio case

TODO
  o implement down_write_killable()
  o fix kvm (need?)
  o fix get_arg_page() (Why this function don't use mmap_sem?)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
