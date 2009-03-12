Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E19366B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:06:58 -0400 (EDT)
Date: Thu, 12 Mar 2009 19:06:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090312180648.GV27823@random.random>
References: <20090311170611.GA2079@elte.hu> <200903130323.41193.nickpiggin@yahoo.com.au> <20090312170010.GT27823@random.random> <200903130420.28772.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903130420.28772.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 13, 2009 at 04:20:27AM +1100, Nick Piggin wrote:
> Well the main point is to avoid atomics and barriers and stuff like
> that especially in the fast gup path. It also seems very much smaller
> (the vast majority of the change is the addition of decow function).

Well if you remove the hugetlb part and you remove the pass of src/dst
vma that is needed anyway to fix PAT bugs, my patch will get quite
smaller too.

Agree about the gup-fast path, but frankly I miss how you avoid having
to change gup-fast... I wanted to asked about that...

> Hmm, maybe. It probably can possibly work entirely without the vm_flag
> and just use the page flag, however. Yes I think it could, and that

Right I only use the page flag, and you seem to have a page flag
PG_dontcow too after all.

> might just avoid the whole problem of modifying vm_flags in gup. I'll
> have to consider it more tomorrow.

Ok.

> But this case is just if we want to transparently support this without
> too much intrusive. Apps that know and care very much could use
> MADV_DONTFORK to avoid the copy completely.

Well those apps aren't the problem.

> My complaint is not decow / pre cow (I think I suggested it as the
> fix for the problem in the first place). I think the patch is quite

I'm sure that's not your complaint right. I thought it was the primary
complaint in discussion so far though.

> complex and is quite a slowdown for fast gup (especially with
> hugepages). I'm just trying to explore different approach.

I think we could benchmark this. Also once I'll get how you avoid to
touch gup-fast fast path, without sending a flood of ipis in fork,
I'll understand better how your patch work.

> Oh, we need to do that? OK, then just take out that statement, and
> change VM_BUG_ON(PageDontCOW()) in do_wp_page to
> VM_BUG_ON(PageDontCOW() && !reuse);

Not sure how do_wp_page is relevant, the problem I pointed out is in
the fork_pre_cow/decow_pte only. If do_wp_page runs it means the page
was already wrprotected in the parent or it couldn't be shared, no
problem in do_wp_page in that respect.

The only thing required is that cow_user_page is copying a page that
can't be modified by the parent thread pool during the copy. So
marking parent pte wrprotected and flushing tlb is required. Then
after the copy like in my fork_pre_cow we set the parent pte writable
again. BTW, I start to think I forgot a tlb flush after setting the
pte writable again, that could generate a minor fault that we can
avoid by flushing the tlb, right? But this is a minor thing, and it'd
only trigger if parent only reads the parent pte, otherwise the parent
thread will wait fork in mmap_sem if it did a write, or it won't have
the tlb loaded in the first place if it didn't touch the page while
the pte was temporarily wrprotected.

> I'll see if it can be made per-page. But I still don't know if it
> is a big problem. It's hard to know exactly what crazy things apps
> require to be fast.

The thing is quite simple, if an app has a 1G of vma loaded, you'll
allocate 1G of ram for no good reason. It can even OOM, it's not just
a performance issue. While doing it per-page like I do, won't be
noticeable, as the in-flight I/O will be minor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
