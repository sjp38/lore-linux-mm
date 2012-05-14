Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id C7EFD6B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 15:42:44 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9413865pbb.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 12:42:44 -0700 (PDT)
Date: Mon, 14 May 2012 12:42:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/10] shmem: replace page if mapping excludes its zone
In-Reply-To: <4FB0C888.8070805@gmail.com>
Message-ID: <alpine.LSU.2.00.1205141219340.1623@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120453210.28861@eggly.anvils> <4FB0C888.8070805@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <ffwll.ch@google.com>, Rob Clark <rob.clark@linaro.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 14 May 2012, Cong Wang wrote:
> On 05/12/2012 07:59 PM, Hugh Dickins wrote:
> > +	VM_BUG_ON(!PageLocked(oldpage));
> > +	__set_page_locked(newpage);
> > +	VM_BUG_ON(!PageUptodate(oldpage));
> > +	SetPageUptodate(newpage);
> > +	VM_BUG_ON(!PageSwapBacked(oldpage));
> > +	SetPageSwapBacked(newpage);
> > +	VM_BUG_ON(!swap_index);
> > +	set_page_private(newpage, swap_index);
> > +	VM_BUG_ON(!PageSwapCache(oldpage));
> > +	SetPageSwapCache(newpage);
> > +
> 
> Are all of these VM_BUG_ON's necessary?

I'm really glad you asked that - thank you.

At first I was just going to brush you off with a standard reply of
something like "well, no BUG_ON should ever be necessary, but we do
find them helpful in practice".

But (a) these ones have probably outlived their usefulness: they were
certainly reassuring to me when I was testing, but perhaps now are
just cluttering up the flow.  I did make them "VM_" BUG_ONs in the
hope that distros wouldn't waste space and time switching them on, but
now I'm inclined to agree with you that they should just be removed.
Most of them are doing no more than confirm what's been checked before
calling the function (and confirming that status cannot racily change).

And (b) whereas they didn't actually catch anything for me, they have
been giving false assurance: because (I believe) there really is a bug
lurking there that they have not yet met and caught.  And I would have
missed it if you hadn't directed me back to think about these.

It is an exceedingly unlikely bug (and need not delay use of the patch),
but what I'm re-remembering is just how slippery swap is: the problem is
that a swapcache page can get freed and reused before getting the page
lock on it; and it might even get reused for swapcache.  Perhaps I need
also to be checking page->private, or perhaps I need to check for error
instead of BUG_ON(error) just before the lines you picked out, or both.

I'm not going to rush the incremental patch to fix this: need to think
about it quietly first.

If you're wondering what I'm talking about (sorry, I don't have time
to explain more right now), take a look at comment and git history of
line 2956 (in 3.4-rc7) of mm/memory.c:
	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
I don't suppose anyone ever actually hit the bug in the years before
we added that protection, but we still ought to guard against it,
there and here in shmem_replace_page().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
