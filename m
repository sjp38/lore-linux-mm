Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 456FF6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 01:40:20 -0500 (EST)
Received: by ywh3 with SMTP id 3so2979090ywh.22
        for <linux-mm@kvack.org>; Thu, 17 Dec 2009 22:40:18 -0800 (PST)
Date: Fri, 18 Dec 2009 15:33:30 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC 4/4] speculative pag fault
Message-Id: <20091218153330.7f26a1bc.minchan.kim@barrios-desktop>
In-Reply-To: <20091218150648.09276f83.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216101107.GA15031@basil.fritz.box>
	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216102806.GC15031@basil.fritz.box>
	<28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
	<20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218094602.3dcd5a02.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218145449.d3fb94cd.minchan.kim@barrios-desktop>
	<20091218150648.09276f83.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Dec 2009 15:06:48 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 18 Dec 2009 14:54:49 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > Hi, Kame. 
> > 
> Hi,
> 
> > On Fri, 18 Dec 2009 09:46:02 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > >  	if (flags & FAULT_FLAG_WRITE) {
> > >  		if (!pte_write(entry))
> > > 
> > 
> > I looked over the patch series and come up to one scenario.
> > 
> > CPU A				CPU 2
> > 
> > "Thread A reads page"
> > 		
> > do_page_fault
> > lookup_vma_cache
> > vma->cache_access++
> > 				"Thread B unmap the vma"
> > 
> > 				mm_write_lock
> > 				down_write(mm->mmap_sem)
> > 				mm->version++
> > 				do_munmap
> > 				wait_vmas_cache_access
> > 				wait_event_interruptible
> > mm_version_check fail
> > vma_release
> > wake_up(vma->cache_wait)
> > 				unmap_region
> > 				mm_write_unlock
> > mm_read_trylock
> > find_vma
> > !vma
> > bad_area
> > 				
> > As above scenario, Apparently, Thread A reads proper page in the vma at that time.
> > but it would meet the segment fault by speculative page fault. 
> > 
> Yes, It's intentional.
> 
> > Sorry that i don't have time to review more detail. 
> ya, take it easy. I'm not in hurry.
> 
> > If I miss something, Pz correct me. 
> > 
> 
> In multi-threaded application, mutual-exclusion of  memory-access v.s. munmap
> is the application's job. In above case, the application shouldn't unmap memory
> while it's access memory. (The application can be preempted at any point.)
> So, the kernel only have to take care of sanity of memory map status.
> In this case, no error in kernel's object. This is correct.

Ahhh. It's my fault. I need sleeping. :)
After take a enough rest, I will review continuosly. 

Thanks. Kame. 

> Thank you for your interests.
> 
> Regards,
> -Kame
> 
> 
> 
> 
> 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
