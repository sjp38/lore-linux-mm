Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2036B6B007B
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 20:24:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1O1OBCg018148
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Feb 2010 10:24:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 23E5B45DE4F
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:24:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 041C045DE57
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:24:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC3D8E38007
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:24:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EBDDE38008
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:24:10 +0900 (JST)
Date: Wed, 24 Feb 2010 10:20:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: s2disk hang update
Message-Id: <20100224102037.2cca4f83.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <201002232213.56455.rjw@sisk.pl>
References: <9b2b86521001020703v23152d0cy3ba2c08df88c0a79@mail.gmail.com>
	<201002222017.55588.rjw@sisk.pl>
	<9b2b86521002230624g20661564mc35093ee0423ff77@mail.gmail.com>
	<201002232213.56455.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Alan Jenkins <sourcejedi.lkml@googlemail.com>, Mel Gorman <mel@csn.ul.ie>, hugh.dickins@tiscali.co.uk, Pavel Machek <pavel@ucw.cz>, pm list <linux-pm@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 22:13:56 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> Well, it still looks like we're waiting for create_workqueue_thread() to
> return, which probably is trying to allocate memory for the thread
> structure.
> 
> My guess is that the preallocated memory pages freed by
> free_unnecessary_pages() go into a place from where they cannot be taken for
> subsequent NOIO allocations.  I have no idea why that happens though.
> 
> To test that theory you can try to change GFP_IOFS to GFP_KERNEL in the
> calls to clear_gfp_allowed_mask() in kernel/power/hibernate.c (and in
> kernel/power/suspend.c for completness).
> 

If allocation of kernel threads for stop_machine_run() is the problem,

What happens when
1. use CONIFG_4KSTACK
or
2. make use of stop_machine_create(), stop_machine_destroy().
   A new interface added by this commit.
  http://git.kernel.org/?p=linux/kernel/git/torvalds/  linux-2.6.git;a=commit;h=9ea09af3bd3090e8349ca2899ca2011bd94cda85
   You can do no-fail stop_machine_run().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
