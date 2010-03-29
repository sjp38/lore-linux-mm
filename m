Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A7D086B01BF
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 07:31:21 -0400 (EDT)
Date: Mon, 29 Mar 2010 19:31:13 +0800
From: anfei <anfei.zhou@gmail.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-ID: <20100329113113.GA11838@desktop>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
 <20100326150805.f5853d1c.akpm@linux-foundation.org>
 <20100326223356.GA20833@redhat.com>
 <20100328145528.GA14622@desktop>
 <20100328162821.GA16765@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100328162821.GA16765@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 28, 2010 at 06:28:21PM +0200, Oleg Nesterov wrote:
> On 03/28, anfei wrote:
> >
> > On Fri, Mar 26, 2010 at 11:33:56PM +0100, Oleg Nesterov wrote:
> >
> > > Off-topic, but we shouldn't use force_sig(), SIGKILL doesn't
> > > need "force" semantics.
> > >
> > This may need a dedicated patch, there are some other places to
> > force_sig(SIGKILL, ...) too.
> 
> Yes, yes, sure.
> 
> > > I'd wish I could understand the changelog ;)
> > >
> > Assume thread A and B are in the same group.  If A runs into the oom,
> > and selects B as the victim, B won't exit because at least in exit_mm(),
> > it can not get the mm->mmap_sem semaphore which A has already got.
> 
> I see. But still I can't understand. To me, the problem is not that
> B can't exit, the problem is that A doesn't know it should exit. All

If B can exit, its memory will be freed, and A will be able to allocate
the memory, so A won't loop here.

Regards,
Anfei.

> threads should exit and free ->mm. Even if B could exit, this is not
> enough. And, to some extent, it doesn't matter if it holds mmap_sem
> or not.
> 
> Don't get me wrong. Even if I don't understand oom_kill.c the patch
> looks obviously good to me, even from "common sense" pov. I am just
> curious.
> 
> So, my understanding is: we are going to kill the whole thread group
> but TIF_MEMDIE is per-thread. Mark the whole thread group as TIF_MEMDIE
> so that any thread can notice this flag and (say, __alloc_pages_slowpath)
> fail asap.
> 
> Is my understanding correct?
> 
> Oleg.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
