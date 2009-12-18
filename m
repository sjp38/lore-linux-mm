Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 04B9A6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 01:10:13 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBI6ABm9013328
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Dec 2009 15:10:11 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2500245DE52
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:10:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B9B3745DE57
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:10:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C54F1DB805A
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:10:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 11A8D1DB8040
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:10:08 +0900 (JST)
Date: Fri, 18 Dec 2009 15:06:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 4/4] speculative pag fault
Message-Id: <20091218150648.09276f83.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091218145449.d3fb94cd.minchan.kim@barrios-desktop>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216101107.GA15031@basil.fritz.box>
	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216102806.GC15031@basil.fritz.box>
	<28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
	<20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218094602.3dcd5a02.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218145449.d3fb94cd.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Dec 2009 14:54:49 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Kame. 
> 
Hi,

> On Fri, 18 Dec 2009 09:46:02 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >  	if (flags & FAULT_FLAG_WRITE) {
> >  		if (!pte_write(entry))
> > 
> 
> I looked over the patch series and come up to one scenario.
> 
> CPU A				CPU 2
> 
> "Thread A reads page"
> 		
> do_page_fault
> lookup_vma_cache
> vma->cache_access++
> 				"Thread B unmap the vma"
> 
> 				mm_write_lock
> 				down_write(mm->mmap_sem)
> 				mm->version++
> 				do_munmap
> 				wait_vmas_cache_access
> 				wait_event_interruptible
> mm_version_check fail
> vma_release
> wake_up(vma->cache_wait)
> 				unmap_region
> 				mm_write_unlock
> mm_read_trylock
> find_vma
> !vma
> bad_area
> 				
> As above scenario, Apparently, Thread A reads proper page in the vma at that time.
> but it would meet the segment fault by speculative page fault. 
> 
Yes, It's intentional.

> Sorry that i don't have time to review more detail. 
ya, take it easy. I'm not in hurry.

> If I miss something, Pz correct me. 
> 

In multi-threaded application, mutual-exclusion of  memory-access v.s. munmap
is the application's job. In above case, the application shouldn't unmap memory
while it's access memory. (The application can be preempted at any point.)
So, the kernel only have to take care of sanity of memory map status.
In this case, no error in kernel's object. This is correct.

Thank you for your interests.

Regards,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
