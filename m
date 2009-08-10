Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 92E546B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 07:24:35 -0400 (EDT)
Date: Mon, 10 Aug 2009 12:24:22 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] ZERO_PAGE again v5.
In-Reply-To: <20090810091458.1e889cdc.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0908101152150.8339@sister.anvils>
References: <20090805191643.2b11ae78.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0908091753250.30153@sister.anvils>
 <20090810091458.1e889cdc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Aug 2009, KAMEZAWA Hiroyuki wrote:
> On Sun, 9 Aug 2009 18:28:48 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > 
> > Actually, I don't understand ignore_zero at all: it's used solely by
> > the mlock case, yet its effect seems to be precisely not to fault in
> > pages if they're missing - I wonder if you've got in a muddle between
> > the two very different awkward cases, mlocking and coredumps of
> > sparsely populated areas.
> > 
> Ah, then, you say mlock() should allocate 'real' page if zero page
> is mapped. Right ?

No.

(That would be a possibility if it gets us out of some difficulty
with the newer mlocking code, but it's not something we ever did or
wanted to do in the past.)

What I was saying in that paragraph was that (it appears to me that)
in your patch only __mlock_vma_pages_range sets GUP_FLAGS_IGNORE_ZERO,
that __get_user_pages sets ignore_zero according to that flag, some
conditions may clear it, but then it goes on to say
			while (!(page = follow_page(vma, start, foll_flags))) {
				/*
				 * When we ignore zero pages, no more ops to do.
				 */
				if (ignore_zero)
					break;
which means that when ignore_zero is set and follow_page returns NULL,
we emerge from the loop with NULL page, don't we?  Whereas when mlocking,
we want to fault in any pages which were not already there.

Or am I just reading this all wrong?

> > And I don't at all like the way you flush_dcache_page(page) on a
> > page which may now be NULL: okay, you're only encouraging x86 to
> > say Yes to the Kconfig option, but that's a landmine for the first
> > arch with a real flush_dcache_page(page) which says Yes to it.
> > 
> do_wp_page()
> 	-> cow_user_page()
> 		-> (src is NULL)
> Ah....ok, it's bug. I added ....Sorry, I didn't see this in older version
> and missed this.

That's an entirely different issue, and I don't see that it's a bug,
just the inefficiency I mentioned elsewhere that we'd be better off
doing a memset than trying to memcpy the ZERO_PAGE.

What I was saying in that paragraph is that when you break from the
loop in __get_user_pages with ignore_zero and NULL page, you reach
			if (IS_ERR(page))
				return i ? i : PTR_ERR(page);
			if (pages) {
				pages[i] = page;

				flush_anon_page(vma, page, start);
				flush_dcache_page(page);
			}
which inserts a NULL into pages[i] (which may be okay if the other
end is prepared for it, as I think __mlock_vma_pages_range is),
then passes a NULL page to flush_anon_page and flush_dcache_page.

I looked up one of the non-empty implementations of flush_dcache_page
and saw it testing a bit in page->flags, assuming (very reasonably!)
that the page pointer is not NULL.  Oops.

> > Because I hate reviewing things and trying to direct other people
> > by remote control: what usually happens is I send them off in some
> > direction which, once I try to do it myself, turns out to have been
> > the wrong direction.  I do need to try to do this myself, instead of
> > standing on the sidelines criticizing.
> > 
> > In fairness, I think Linus himself was a little confused when he
> > separated off use_zero_page(): I think we've all got confused around
> > there (as we noticed a month or so ago when discussing its hugetlb
> > equivalent), and I need to think it through again at last.
> > 
> > I'll get on to it now.
> > 
> 
> Thank you for comments. I'll go to a trip until Aug/17, programming-camp,

Sorry for not getting to all this sooner, yes I'd seen your warning in
another mail that you'd be away, but I just didn't get here fast enough.

> I'll be able to consider this patch and the whole things aroung paging in calm
> enviroment. I'll try to restart from scratch.

What I'm saying above is that I'd much prefer to try doing the patch
myself and have you review that, than us to keep on going back and
forth with different versions like this.

I am not confident that you've grasped all the issues, and I am sure
that there's a least one issue which I have not grasped: maybe it'll
end up irrelevant, but I do need to understand Linus's Fix ZERO_PAGE
breakage with vmware, 672ca28e300c17bf8d792a2a7a8631193e580c74

But I'll discuss that separately, probably offlist; or, if I'm lucky,
just composing the mail will bring me to answer my own question!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
