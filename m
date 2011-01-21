Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 45A508D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 13:14:51 -0500 (EST)
Date: Fri, 21 Jan 2011 19:14:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG]thp: BUG at mm/huge_memory.c:1350
Message-ID: <20110121181442.GK9506@random.random>
References: <20110120154935.GA1760@barrios-desktop>
 <20110120161436.GB21494@random.random>
 <AANLkTikHNcD3aOWKJdPtCqdJi9C34iLPxj5-L8=gqBFc@mail.gmail.com>
 <20110121175843.GA1534@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110121175843.GA1534@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 22, 2011 at 02:58:43AM +0900, Minchan Kim wrote:
> I tested it again with some printk and I knew why it is out of memory.
> 
> do_page_fault(for write)
> -> do_huge_pmd_anonymous_page
>         -> alloc_hugepage_vma
> 
> Above is repeated by almost 400 times. It means 2M * 400 = 800M usage in my 2G system.
> Fragement can cause reclaim.
> Interesting one is that above is repeated by same faulty address of same process as looping.
> 
> Apparently, do_huge_pmd_anonymous_page maps pmd to entry.
> Nonetheless, page faults are repeated by same address.
> It seems set_pmd_at is nop.
> 
> Do you have any idea?

Well clearly 32bit x86 wasn't well tested... Maybe we should
temporarily disable the config option on x86 32bit.

> Sometime Xorg, Sometime kswapd, Sometime plymouthd, Sometime fsck.

That's good. So the most likely explanation of that BUG_ON you hit, is
the same bug that causes do_huge_pmd_anonymous_page to flood on the
same address (clearly if CPU can't solve the TLB miss using the
hugepmd, the rmap walk of split_huge_page will also fail to find the
page in the hugepmd, so it makes perfect sense).

That BUG_ON is by far my worst nightmare (that rmap walk of
split_huge_page must be as accurate as the
remove_migration_ptes/rmap_walk of migrate, it can't miss a hugepmd or
it'll be trouble, just like remove_migration_ptes/rmap_walk can't miss
a pte or it'll be trouble) and as far as common code is concerned I
had zero outstanding problems with it for a long time already, so
given your early debug info, I'm already optimistic and relieved that
64bit is not affected by this and this isn't a generic common code
issue and the most likely explanation is some silly arch specific bug
that sets the pmd wrong and affects the page fault too (not just the
rmap walk).

I'll try to reproduce. Checking the pagetable layout of the process at
the second page fault in the same address sounds good start to figure
out what's wrong on x86_32.

Thanks a lot for the help!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
