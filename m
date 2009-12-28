Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 568DA60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 20:22:14 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS1MBsG029208
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 10:22:11 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 03F582B6A41
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:22:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BDB1C45DE4C
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:22:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A0DD91DB8045
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:22:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53EE11DB8041
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:22:10 +0900 (JST)
Date: Mon, 28 Dec 2009 10:19:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-Id: <20091228101902.4a7feac1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	<1261915391.15854.31.camel@laptop>
	<20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 09:36:06 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> == one vma ==
> # Samples: 1338964273489
> #
> # Overhead          Command             Shared Object  Symbol
> # ........  ...............  ........................  ......
> #
>     26.90%  multi-fault-all  [kernel]                  [k] clear_page_c
>             |
>             --- clear_page_c
>                 __alloc_pages_nodemask
>                 handle_mm_fault
>                 do_page_fault
>                 page_fault
>                 0x400940
>                |
>                 --100.00%-- (nil)
> 
>     20.65%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
>             |
>             --- _raw_spin_lock
>                |
>                |--85.07%-- free_pcppages_bulk
>                |          free_hot_cold_page
> 
>     ....<snip>
>     3.94%  multi-fault-all  [kernel]                  [k] find_vma_speculative
>             |
>             --- find_vma_speculative
>                |
>                |--99.40%-- do_page_fault
>                |          page_fault
>                |          0x400940
>                |          |
>                |           --100.00%-- (nil)
>                |
>                 --0.60%-- page_fault
>                           0x400940
>                           |
>                            --100.00%-- (nil)
> ==
> 
A small modification for avoiding atomic_add_unless() makes following score.
(used atomic_inc()->atomic_read() instead of that.)
==
     2.55%  multi-fault-all  [kernel]                  [k] vma_put
            |
            --- vma_put
               |
               |--98.87%-- do_page_fault
               |          page_fault
               |          0x400940
               |          (nil)
               |
                --1.13%-- page_fault
                          0x400940
                          (nil)
     0.65%  multi-fault-all  [kernel]                  [k] find_vma_speculative
            |
            --- find_vma_speculative
               |
               |--95.55%-- do_page_fault
               |          page_fault
               |          0x400940
               |          |
               |           --100.00%-- (nil)
               |
                --4.45%-- page_fault
                          0x400940
                          (nil)
==
Hmm...maybe worth to consider some.
I hope something good pops up to me after new year vacation.

Regards,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
