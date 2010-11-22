Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 54C1E6B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 19:10:18 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAM0AFOn011582
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 22 Nov 2010 09:10:15 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 51F4E45DE5A
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 09:10:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 220A945DE52
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 09:10:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EDFBE1DB805B
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 09:10:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 955451DB803C
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 09:10:14 +0900 (JST)
Date: Mon, 22 Nov 2010 09:04:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] big chunk memory allocator v4
Message-Id: <20101122090431.4ff9c941.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101119125653.16dd5452.akpm@linux-foundation.org>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119125653.16dd5452.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, minchan.kim@gmail.com, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2010 12:56:53 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 19 Nov 2010 17:10:33 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Hi, this is an updated version. 
> > 
> > No major changes from the last one except for page allocation function.
> > removed RFC.
> > 
> > Order of patches is
> > 
> > [1/4] move some functions from memory_hotplug.c to page_isolation.c
> > [2/4] search physically contiguous range suitable for big chunk alloc.
> > [3/4] allocate big chunk memory based on memory hotplug(migration) technique
> > [4/4] modify page allocation function.
> > 
> > For what:
> > 
> >   I hear there is requirements to allocate a chunk of page which is larger than
> >   MAX_ORDER. Now, some (embeded) device use a big memory chunk. To use memory,
> >   they hide some memory range by boot option (mem=) and use hidden memory
> >   for its own purpose. But this seems a lack of feature in memory management.
> > 
> >   This patch adds 
> > 	alloc_contig_pages(start, end, nr_pages, gfp_mask)
> >   to allocate a chunk of page whose length is nr_pages from [start, end)
> >   phys address. This uses similar logic of memory-unplug, which tries to
> >   offline [start, end) pages. By this, drivers can allocate 30M or 128M or
> >   much bigger memory chunk on demand. (I allocated 1G chunk in my test).
> > 
> >   But yes, because of fragmentation, this cannot guarantee 100% alloc.
> >   If alloc_contig_pages() is called in system boot up or movable_zone is used,
> >   this allocation succeeds at high rate.
> 
> So this is an alternatve implementation for the functionality offered
> by Michal's "The Contiguous Memory Allocator framework".
> 

Yes, this will be a backends for that kind of works.

I think there are two ways to allocate contiguous pages larger than MAX_ORDER.

1) hide some memory at boot and add an another memory allocator.
2) support a range allocator as [start, end)

This is an trial from 2). I used memory-hotplug technique because I know some.
This patch itself has no "map" and "management" function, so it should be
developped in another patch (but maybe it will be not my work.)

> >   I tested this on x86-64, and it seems to work as expected. But feedback from
> >   embeded guys are appreciated because I think they are main user of this
> >   function.
> 
> From where I sit, feedback from the embedded guys is *vital*, because
> they are indeed the main users.
> 
> Michal, I haven't made a note of all the people who are interested in
> and who are potential users of this code.  Your patch series has a
> billion cc's and is up to version 6.  Could I ask that you review and
> test this code, and also hunt down other people (probably at other
> organisations) who can do likewise for us?  Because until we hear from
> those people that this work satisfies their needs, we can't really
> proceed much further.
> 

yes. please.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
