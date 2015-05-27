Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id B549B6B009D
	for <linux-mm@kvack.org>; Wed, 27 May 2015 03:32:01 -0400 (EDT)
Received: by wifw1 with SMTP id w1so10920714wif.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 00:32:01 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id s1si22409686wiy.52.2015.05.27.00.31.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 00:32:00 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Date: Wed, 27 May 2015 09:31:26 +0200
Message-ID: <3176422.FWpfrlzXOV@wuerfel>
In-Reply-To: <20150527062250.GD3928@swordfish>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <20150527041015.GB11609@blaptop> <20150527062250.GD3928@swordfish>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Jungseok Lee <jungseoklee85@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, barami97@gmail.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wednesday 27 May 2015 15:22:50 Sergey Senozhatsky wrote:
> On (05/27/15 13:10), Minchan Kim wrote:
> > On Tue, May 26, 2015 at 08:29:59PM +0900, Jungseok Lee wrote:
> > > 
> > > if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> > >     goto nopage;
> > > 
> > > IMHO, a reclaim operation would be not needed in this context if memory is
> > > allocated from vmalloc space. It means there is no need to traverse shrinker list. 
> > 
> > For making fork successful with using vmalloc, it's bandaid.

Right.

> > > >> This patch tries to solve the problem as allocating thread_info memory
> > > >> from vmalloc space, not 1:1 mapping one. The downside is one additional
> > > >> page allocation in case of vmalloc. However, vmalloc space is large enough,
> > > > 
> > > > The size you want to allocate is 16KB in here but additional 4K?
> > > > It increases 25% memory footprint, which is huge downside.
> > > 
> > > I agree with the point, and most people who try to use vmalloc might know the number.
> > > However, an interoperation on the number depends on a point of view.
> > > 
> > > Vmalloc is large enough and not fully utilized in case of ARM64.
> > > With the considerations, there is a room to do math as follows.
> > > 
> > > 4KB / 240GB = 1.5e-8 (4KB page + 3 level combo)
> > > 
> > > It would be not a huge downside if fork-routine is not damaged due to fragmentation.
> > 
> > Okay, address size point of view, it wouldn't be significant problem.
> > Then, let's see it performance as point of view.
> > 
> > If we use vmalloc, it needs additional data structure for vmalloc
> > management, several additional allocation request, page table hanlding
> > and TLB flush.

One upside of it is that we could in theory make THREAD_SIZE 12KB or
20KB instead of 16KB if we wanted to, as vmalloc does not have the
power-of-two requirement.

The downsides of vmalloc that you list are probably much stronger.

Another one is that /proc/vmallocinfo would become completely unreadable
on systems with lots of threads.

Finally, accessing data in vmalloc memory requires 4KB TLBs, while the
linear mapping usually uses hugepages, so we get extra page table walks
in the kernel for accessing the kernel stack, or for any kernel code
that looks at the thread_info of another thread.

> plus a guard page. I don't see VM_NO_GUARD being passed.

That's only a virtual page, which is virtually free here, it does not
consume any real memory.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
