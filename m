Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5EE8B6B01E3
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 20:44:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o320i1Gr013708
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 2 Apr 2010 09:44:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9696A45DE51
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:44:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D94D45DE4E
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:44:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C044E08002
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:44:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F109BE38001
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:44:00 +0900 (JST)
Date: Fri, 2 Apr 2010 09:40:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 2/5 v2] oom: give current access to memory reserves
 if it has been killed
Message-Id: <20100402094017.ee659ba0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1004011243020.13247@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1004011243020.13247@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010 12:44:31 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It's possible to livelock the page allocator if a thread has mm->mmap_sem and 
> fails to make forward progress because the oom killer selects another thread 
> sharing the same ->mm to kill that cannot exit until the semaphore is dropped.
> 
> The oom killer will not kill multiple tasks at the same time; each oom killed 
> task must exit before another task may be killed.  Thus, if one thread is 
> holding mm->mmap_sem and cannot allocate memory, all threads sharing the same 
> ->mm are blocked from exiting as well.  In the oom kill case, that means the
> thread holding mm->mmap_sem will never free additional memory since it cannot
> get access to memory reserves and the thread that depends on it with access to
> memory reserves cannot exit because it cannot acquire the semaphore.  Thus,
> the page allocators livelocks.
> 
> When the oom killer is called and current happens to have a pending SIGKILL,
> this patch automatically gives it access to memory reserves and returns.  Upon
> returning to the page allocator, its allocation will hopefully succeed so it
> can quickly exit and free its memory.  If not, the page allocator will fail
> the allocation if it is not __GFP_NOFAIL.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
