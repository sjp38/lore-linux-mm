Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D78086B024D
	for <linux-mm@kvack.org>; Sun, 11 Jul 2010 21:58:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6C1w39T003543
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 12 Jul 2010 10:58:03 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AC5645DE7C
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 10:58:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E83AC45DE79
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 10:58:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDDB01DB8037
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 10:58:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 477A71DB8043
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 10:58:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Add trace events to mmap and brk
In-Reply-To: <20100709160342.GB3281@infradead.org>
References: <1278690830-22145-1-git-send-email-emunson@mgebm.net> <20100709160342.GB3281@infradead.org>
Message-Id: <20100712104602.EA1A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 12 Jul 2010 10:58:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Eric B Munson <emunson@mgebm.net>, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hmm, thinking about it a bit more, what do you trace events give us that
> the event based syscall tracer doesn't?

Yup. I think we need two tracepoint.

 1) need to know userland argument.
    -> syscall tracer
 2) need to know actual vma change.
    -> need to trace more low layer


As I said, if userland app have following code,

	mmap(0x10000, PROT_READ|PROT_WRITE)
	mmap(0x10000, PROT_NONE)

second mmap implicitly unmap firt mmap region and map another region.
so if we want to track munmap activity, syscall exiting point is not
so good place. we need to trace per-vma activity.

btw, perf_event_mmap() already take vma argument.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
