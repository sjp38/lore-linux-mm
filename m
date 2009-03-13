Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C9C656B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:09:47 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Sat, 14 Mar 2009 03:09:39 +1100
References: <20090311170611.GA2079@elte.hu> <200903130420.28772.nickpiggin@yahoo.com.au> <20090312180648.GV27823@random.random>
In-Reply-To: <20090312180648.GV27823@random.random>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903140309.39777.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 13 March 2009 05:06:48 Andrea Arcangeli wrote:
> On Fri, Mar 13, 2009 at 04:20:27AM +1100, Nick Piggin wrote:
> > Well the main point is to avoid atomics and barriers and stuff like
> > that especially in the fast gup path. It also seems very much smaller
> > (the vast majority of the change is the addition of decow function).
>
> Well if you remove the hugetlb part and you remove the pass of src/dst
> vma that is needed anyway to fix PAT bugs, my patch will get quite
> smaller too.

Possibly true. OK, it wasn't a very good argument to compare my incomplete,
RFC patch based on size alone :)


> Agree about the gup-fast path, but frankly I miss how you avoid having
> to change gup-fast... I wanted to asked about that...

It is more straightforward than your version because it does not try to
make the page re-cow-able again after the GUP is finished. The main
conceptual difference between our fixes I think (ignoring my silly
vma-wide decow), is this issue.

Of course I could have a race in fast-gup, but I don't think I can see
one. I'm working on removing the vma stuff and just making it per-page,
which might make it easier to review.


> > Oh, we need to do that? OK, then just take out that statement, and
> > change VM_BUG_ON(PageDontCOW()) in do_wp_page to
> > VM_BUG_ON(PageDontCOW() && !reuse);
>
> Not sure how do_wp_page is relevant, the problem I pointed out is in
> the fork_pre_cow/decow_pte only. If do_wp_page runs it means the page
> was already wrprotected in the parent or it couldn't be shared, no
> problem in do_wp_page in that respect.

Well, it would save having to touch the parent's pagetables after
doing the atomic copy-on-fork in the child. Just have the parent do
a do_wp_page, which will notice it is the only user of the page and
reuse it rather than COW it (now that Hugh has fixed the races in
the reuse check that should be fine).


> The only thing required is that cow_user_page is copying a page that
> can't be modified by the parent thread pool during the copy. So
> marking parent pte wrprotected and flushing tlb is required. Then
> after the copy like in my fork_pre_cow we set the parent pte writable
> again.

Yes you could do it this way too, I'm not sure which way is better...
I'll have to take another look at it after removing the per-vma code
from mine.

> > I'll see if it can be made per-page. But I still don't know if it
> > is a big problem. It's hard to know exactly what crazy things apps
> > require to be fast.
>
> The thing is quite simple, if an app has a 1G of vma loaded, you'll
> allocate 1G of ram for no good reason. It can even OOM, it's not just
> a performance issue. While doing it per-page like I do, won't be
> noticeable, as the in-flight I/O will be minor.

Yes I agree now it is a silly way to do it.

Now I also see that your patch still hasn't covered the other side of
the race, wheras my scheme should do. Hmm, I think that if we want to
go to the extent of adding all this code in and tell userspace apps
they can use zerocopy IO and not care about COW, then we really must
cover both sides of the race otherwise it is just asking for data
corruption.

Conversely, if we leave *any* holes open by design, then we may as well
leave *all* holes open and have simpler code -- because apps will have
to know about the zerocopy vs COW problem anyway. Don't you agree?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
