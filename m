Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 09B5F6B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 07:49:01 -0500 (EST)
Received: by ywh3 with SMTP id 3so1398427ywh.22
        for <linux-mm@kvack.org>; Tue, 19 Jan 2010 04:49:00 -0800 (PST)
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <84144f021001190044s397c6665qb00af48235d2d818@mail.gmail.com>
References: <20100118141938.GI30698@redhat.com>
	 <20100118170816.GA22111@redhat.com>
	 <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
	 <20100118181942.GD22111@redhat.com>
	 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
	 <20100119071734.GG14345@redhat.com>
	 <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
	 <20100119075205.GI14345@redhat.com>
	 <84144f021001190007q54a334dfwed64189e6cf0b7c4@mail.gmail.com>
	 <20100119082638.GK14345@redhat.com>
	 <84144f021001190044s397c6665qb00af48235d2d818@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Jan 2010 21:48:52 +0900
Message-ID: <1263905332.2163.11.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Gleb Natapov <gleb@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hi, Pekka. 

On Tue, 2010-01-19 at 10:44 +0200, Pekka Enberg wrote:
> Hi Gleb,
> 
> On Tue, Jan 19, 2010 at 10:26 AM, Gleb Natapov <gleb@redhat.com> wrote:
> >> design would still be broken, no? Did you try using (or extending)
> >> posix_madvise(MADV_DONTNEED) for the guest address space? It seems to
> > After mlockall() I can't even allocate guest address space. Or do you mean
> > instead of mlockall()? Then how MADV_DONTNEED will help? It just drops
> > page table for the address range (which is not what I need) and does not
> > have any long time effect.
> 
> Oh right, MADV_DONTNEED is no good.
> 
> On Tue, Jan 19, 2010 at 10:26 AM, Gleb Natapov <gleb@redhat.com> wrote:
> >> me that you're trying to use a big hammer (mlock) when a polite hint
> >> for the VM would probably be sufficient for it do its job.
> >>
> > I what to tell to VM "swap this, don't swap that" and as far as I see
> > there is no other way to do it currently.
> 
> Yeah, which is why I was suggesting that maybe posix_madvise() needs
> to be extended to have a MADV_NEED_BUT_LESS_IMPORTANT flag that can be
> used as a hint by mm/vmscan.c to first swap the guest address spaces.
> 
>                         Pekka

Gleb. How about using MADV_SEQUENTIAL on guest memory?
It makes that pages of guest are moved into inactive reclaim list more
fast. It means it is likely to swap out faster than other pages if it
isn't hit during inactive list.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
