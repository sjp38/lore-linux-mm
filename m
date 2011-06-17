Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 029E06B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 19:38:59 -0400 (EDT)
Date: Fri, 17 Jun 2011 16:38:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/12] radix_tree: exceptional entries and indices
Message-Id: <20110617163854.49225203.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1106140341070.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
	<alpine.LSU.2.00.1106140341070.29206@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 14 Jun 2011 03:42:27 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> The radix_tree is used by several subsystems for different purposes.
> A major use is to store the struct page pointers of a file's pagecache
> for memory management.  But what if mm wanted to store something other
> than page pointers there too?
> 
> The low bit of a radix_tree entry is already used to denote an indirect
> pointer, for internal use, and the unlikely radix_tree_deref_retry() case.
> Define the next bit as denoting an exceptional entry, and supply inline
> functions radix_tree_exception() to return non-0 in either unlikely case,
> and radix_tree_exceptional_entry() to return non-0 in the second case.
> 
> If a subsystem already uses radix_tree with that bit set, no problem:
> it does not affect internal workings at all, but is defined for the
> convenience of those storing well-aligned pointers in the radix_tree.
> 
> The radix_tree_gang_lookups have an implicit assumption that the caller
> can deduce the offset of each entry returned e.g. by the page->index of
> a struct page.  But that may not be feasible for some kinds of item to
> be stored there.
> 
> radix_tree_gang_lookup_slot() allow for an optional indices argument,
> output array in which to return those offsets.  The same could be added
> to other radix_tree_gang_lookups, but for now keep it to the only one
> for which we need it.

Yes, the RADIX_TREE_INDIRECT_PTR hack is internal-use-only, and doesn't
operate on (and hence doesn't corrupt) client-provided items.

This patch uses bit 1 and uses it against client items, so for
practical purpoese it can only be used when the client is storing
addresses.  And it needs new APIs to access that flag.

All a bit ugly.  Why not just add another tag for this?  Or reuse an
existing tag if the current tags aren't all used for these types of
pages?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
