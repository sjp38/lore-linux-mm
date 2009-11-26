Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 009616B008C
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 05:24:15 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id nAQAOBeV017212
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:24:12 GMT
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by wpaz9.hot.corp.google.com with ESMTP id nAQAO8wd019301
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 02:24:09 -0800
Received: by pxi16 with SMTP id 16so442270pxi.29
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 02:24:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B0E50B1.20602@parallels.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
	 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091126085031.GG2970@balbir.in.ibm.com>
	 <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
	 <4B0E461C.50606@parallels.com>
	 <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>
	 <4B0E50B1.20602@parallels.com>
Date: Thu, 26 Nov 2009 02:24:08 -0800
Message-ID: <d26f1ae00911260224k6b87aaf7o9e3a983a73e6036e@mail.gmail.com>
Subject: Re: memcg: slab control
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, David Rientjes <rientjes@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/26/09, Pavel Emelyanov <xemul@parallels.com> wrote:
> KAMEZAWA Hiroyuki wrote:
>  > On Thu, 26 Nov 2009 12:10:52 +0300
>  > Pavel Emelyanov <xemul@parallels.com> wrote:
>  >
>  >>>> Anyway, I agree that we need another
>  >>>> slabcg, Pavel did some work in that area and posted patches, but they
>  >>>> were mostly based and limited to SLUB (IIRC).
>  >> I'm ready to resurrect the patches and port them for slab.
>  >> But before doing it we should answer one question.
>  >>
>  >> Consider we have two kmalloc-s in a kernel code - one is
>  >> user-space triggerable and the other one is not. From my
>  >> POV we should account for the former one, but should not
>  >> for the latter.
>  >>
>  >> If so - how should we patch the kernel to achieve that goal?
>  >>
>  >>> My point is that most of the kernel codes cannot work well when kmalloc(small area)
>  >>> returns NULL.
>  >> :) That's not so actually. As our experience shows kernel lives fine
>  >> when kmalloc returns NULL (this doesn't include drivers though).
>  >>
>  > One issue it comes to my mind is that file system can return -EIO because
>  > kmalloc() returns NULL. the kernel may work fine but terrible to users ;)
>
>
> That relates to my question above - we should not account for all
>  kmalloc-s. In particular - we don't account for bio-s and buffer-head-s
>  since their amount is not under direct user control. Yes, you can
>  request for heavy IO, but first, kernel sends your task to sleep under
>  certain conditions and second, bio-s are destroyed as soon as they are
>  finished and thus bio-s and buffer-head-s cannot be used to eat all the
>  kernel memory.

Aren't there patches to make the kernel track which cgroup caused
which disk I/O? If so, it should be possible to charge the bios to the
right cgroup.

Maybe one way to decide which kernel allocations should be accounted
would be to look at the calling context: If the allocation is done in
user context (syscall), then it could be counted towards that user,
while if the allocation is done in interrupt or kthread context, it
shouldn't be accounted.

Of course, this wouldn't be perfect, but it might be a good enough
approximation.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
