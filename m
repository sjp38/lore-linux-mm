Date: Thu, 7 Sep 2006 20:41:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: invalidate_complete_page()
In-Reply-To: <20060907120053.ccb6bb63.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609072032130.23423@blonde.wat.veritas.com>
References: <20060907120053.ccb6bb63.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Sep 2006, Andrew Morton wrote:
> 
> This is buggy, isn't it?  If someone faults the page into pagetables after
> invalidate_mapping_pages() checked page_mapped(), the faulter-inner gets an
> anonymous, not-up-to-date page which he didn't expect.

You're right.  ("anonymous" meaning "detached" rather than PageAnon.)

> 
> Locking the page in the pagefault handler will fix that,

(I thought I scared you off that?  Just for a while perhaps.
If Nick plugs the hole(s?) he noticed in his earlier patch,
and wider performance testing shows that the hit is acceptable,
then we'd all agree it's the best way to go.)

> but meanwhile I
> think we need to be checking page_count() in invalidate_complete_page(),
> after taking tree_lock?

Yes, that should do nicely: it's already happy to skip on lots of
transient circumstances, no harm in adding another such, to avoid
the more serious inconsistency you notice above.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
