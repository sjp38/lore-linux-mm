Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: page_add/remove_rmap costs
Date: Fri, 26 Jul 2002 09:33:50 +0200
References: <3D3E4A30.8A108B45@zip.com.au>
In-Reply-To: <3D3E4A30.8A108B45@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17Xzbj-0006Uf-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 24 July 2002 08:33, Andrew Morton wrote:
> With rmap oprofile says:
> 
> ./doitlots.sh 10  41.67s user 95.04s system 398% cpu 34.338 total
> 
> [...]
>
> And without rmap it says:
> 
> ./doitlots.sh 10  43.01s user 76.19s system 394% cpu 30.222 total
>
> [...]
>
> What we see here is:
> 
> - We did 12477 forks
> - those forks called copy_page_range() 174,521 times in total
> - Of the 4,106,673 calls to page_add_rmap, 2,774,954 came from
>   copy_page_range and 1,029,498 came from do_no_page.
> - Of the 4,119,825 calls to page_remove_rmap(), 3,863,194 came
>   from zap_page_range().
> 
> [...]
>
> So it's pretty much all happening in fork() and exit().
> My gut feel here is that this will be hard to tweak - some algorithmic
> change will be needed.

Indeed.  This is I developed the refcount-based page table sharing technique 
earlier this year: to eliminate the cost of setting up and tearing down 
pte_chains that never get called upon to do anything useful.  There's still 
some work to do on the patch:

   nl.linux.org/~phillips/patches/ptab-2.4.17-3

But the interesting part works.

I now know how to do the tlb invalidte on unmap efficiently, in fact Linus 
knew right away at the time, but I had to work my way through some basics to 
understand what he was going on about.  In short, we need to chain the pte 
pages to the mm's they belong.  Each mm (already) carries a bitmap of 
processors the mm is active on, so we just or all those bitmaps together and 
call the flavor of interprocessor tlb invalidate that operates on the 
resulting bitmap.

The same optimization as for pte_chains applies: if the pte page isn't 
shared, we can set a bit in the page->flags and point directly at the mm, or 
we can use the vma, which is conveniently hanging around when needed.  I 
prefer the former because it's more forward looking: we should be able to 
dispense entirely with looking up the vma in some common situations.  Also, 
it's more symmetric with the existing page pte_chain code.

There is also Linus's suggestion for eliminating most (all?) of the locking 
in my patch, which has the side effect of doing early reclaim of page tables. 

Paul Mackerras did some work on this patch and was easily able to produce a 
functional version of it, though I wouldn't call it the most elegant thing in 
the world: he unshares the page tables on swap-out (ugh) and swapoff (who 
cares).  But I don't think he really knew the relationship between page table 
sharing and rmap.  It should be clear now.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
