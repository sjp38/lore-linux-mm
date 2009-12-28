Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 61EE160021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 05:09:02 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBSA90Nj027215
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 19:09:00 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 97B1945DE56
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 19:08:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B3D945DE4F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 19:08:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2578E1DB8046
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 19:08:59 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CF7CB1DB803F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 19:08:58 +0900 (JST)
Message-ID: <7bf10ff685a06b28084a61dad0740015.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <1261990533.7135.34.camel@laptop>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
    <1261915391.15854.31.camel@laptop>
    <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
    <1261990533.7135.34.camel@laptop>
Date: Mon, 28 Dec 2009 19:08:58 +0900 (JST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Mon, 2009-12-28 at 09:36 +0900, KAMEZAWA Hiroyuki wrote:
>> Hmm ? for single-thread apps ? This patch's purpose is not for lockless
>> lookup, it's just a part of work. My purpose is avoiding false-sharing.
>
> False sharing in the sense of the mmap_sem cacheline containing other
> variables?  How could that ever be a problem for a single threaded
> application?
>
No problem at all. I just couldn't catch what you mean.


> For multi-threaded apps the contention on that cacheline is the largest
> issue, and moving it to a vma cacheline doesn't seem like a big
> improvement.
>
I feel mmap_sem's cacheline ping-pong is more terrible than
simple atomic_inc().
__down_read() does
  write (spinlock)
  write (->sem_activity)
  write (unlock)


> You want something much finer grained than vmas, there's lots of apps
> working on a single (or very few) vma(s). Leaving you with pretty much
> the same cacheline contention. Only now its a different cacheline.
>
Ya, maybe. I hope I can find some magical one.
Using per-cpu counter here as Christoph did may be an idea...

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
