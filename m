Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 908CA6B021D
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:44:36 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o517iT7R017817
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 16:44:29 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D57D45DE52
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:44:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F123245DE51
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:44:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D81901DB803F
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:44:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 836211DB803C
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:44:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 16/18] oom: give current access to memory reserves if it has been killed
In-Reply-To: <alpine.DEB.2.00.1006010017240.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010017240.29202@chino.kir.corp.google.com>
Message-Id: <20100601164147.247B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 16:44:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It's possible to livelock the page allocator if a thread has mm->mmap_sem
> and fails to make forward progress because the oom killer selects another
> thread sharing the same ->mm to kill that cannot exit until the semaphore
> is dropped.
> 
> The oom killer will not kill multiple tasks at the same time; each oom
> killed task must exit before another task may be killed.  Thus, if one
> thread is holding mm->mmap_sem and cannot allocate memory, all threads
> sharing the same ->mm are blocked from exiting as well.  In the oom kill
> case, that means the thread holding mm->mmap_sem will never free
> additional memory since it cannot get access to memory reserves and the
> thread that depends on it with access to memory reserves cannot exit
> because it cannot acquire the semaphore.  Thus, the page allocators
> livelocks.
> 
> When the oom killer is called and current happens to have a pending
> SIGKILL, this patch automatically gives it access to memory reserves and
> returns.  Upon returning to the page allocator, its allocation will
> hopefully succeed so it can quickly exit and free its memory.  If not, the
> page allocator will fail the allocation if it is not __GFP_NOFAIL.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

ack.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
