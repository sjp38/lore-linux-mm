Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B96096B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 06:52:22 -0400 (EDT)
Date: Wed, 11 Mar 2009 11:52:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] mm: use list.h for vma list
Message-ID: <20090311105210.GB2282@elte.hu>
References: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com> <20090311104018.GA2376@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311104018.GA2376@x200.localdomain>
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Daniel Lowengrub <lowdanie@gmail.com>, linux-mm@kvack.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Wed, Mar 11, 2009 at 11:55:48AM +0200, Daniel Lowengrub wrote:
> > Use the linked list defined list.h for the list of vmas that's stored
> > in the mm_struct structure.  Wrapper functions "vma_next" and
> > "vma_prev" are also implemented.  Functions that operate on more than
> > one vma are now given a list of vmas as input.
> 
> > Signed-off-by: Daniel Lowengrub
> 
> That's not how S-o-b line should look like.
> 
> > --- linux-2.6.28.7.vanilla/arch/alpha/kernel/osf_sys.c
> > +++ linux-2.6.28.7/arch/alpha/kernel/osf_sys.c
> > @@ -1197,7 +1197,7 @@
> >  		if (!vma || addr + len <= vma->vm_start)
> >  			return addr;
> >  		addr = vma->vm_end;
> > -		vma = vma->vm_next;
> > +		vma = vma_next(vma);
> 
> Well, this bloats both mm_struct and vm_area_struct.

here's some hard numbers from an earlier submission:

| I made a script that runs 'time ./mmap-perf' 100 times and 
| outputs the average.
|
| The output on the standard kernel was:
|
|   real: 1.022600
|   user: 0.135900
| system: 0.852600
|
| The output after the patch was:
|
|   real: 0.815400
|   user: 0.113200
| system: 0.622200

Which is a 25% speedup in MM performance - which looks very 
significant.

Note: i have not repeated the measurements, and it still looks a 
bit too good - i'd have expected if there's such a low hanging 
25% fruit in the MM we'd have fixed it already.

( Daniel - please preserve such measurements in changelogs. )

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
