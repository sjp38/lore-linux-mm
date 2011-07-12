Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 249446B0083
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 19:25:06 -0400 (EDT)
Date: Tue, 12 Jul 2011 16:24:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/12] radix_tree: exceptional entries and indices
Message-Id: <20110712162431.75bfe77b.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1107121536100.2112@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
	<alpine.LSU.2.00.1106140341070.29206@sister.anvils>
	<20110617163854.49225203.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1106171702150.1345@sister.anvils>
	<20110618144832.cfc665b0.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1107121536100.2112@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

<tries to remember what this is all about>

l 2011 15:56:14 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Sat, 18 Jun 2011, Andrew Morton wrote:
> > On Fri, 17 Jun 2011 17:13:38 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> > > On Fri, 17 Jun 2011, Andrew Morton wrote:
> > > > On Tue, 14 Jun 2011 03:42:27 -0700 (PDT)
> > > > Hugh Dickins <hughd@google.com> wrote:
> > > > 
> > > > > The low bit of a radix_tree entry is already used to denote an indirect
> > > > > pointer, for internal use, and the unlikely radix_tree_deref_retry() case.
> > > > > Define the next bit as denoting an exceptional entry, and supply inline
> > > > > functions radix_tree_exception() to return non-0 in either unlikely case,
> > > > > and radix_tree_exceptional_entry() to return non-0 in the second case.
> > > > 
> > > > Yes, the RADIX_TREE_INDIRECT_PTR hack is internal-use-only, and doesn't
> > > > operate on (and hence doesn't corrupt) client-provided items.
> > > > 
> > > > This patch uses bit 1 and uses it against client items, so for
> > > > practical purpoese it can only be used when the client is storing
> > > > addresses.  And it needs new APIs to access that flag.
> > > > 
> > > > All a bit ugly.  Why not just add another tag for this?  Or reuse an
> > > > existing tag if the current tags aren't all used for these types of
> > > > pages?
> > > 
> > > I couldn't see how to use tags without losing the "lockless" lookups:
> > 
> > So lockless pagecache broke the radix-tree tag-versus-item coherency as
> > well as the address_space nrpages-vs-radix-tree coherency.
> 
> I don't think that remark is fair to lockless pagecache at all.  If we
> want the scalability advantage of lockless lookup, yes, we don't have
> strict coherency with tagging at that time.  But those places that need
> to worry about that coherency, can lock to do so.

Nobody thought about these issues, afaik.  Things have broken and the
code has become significantly more complex/fragile.

Does the locking in mapping_tagged() make any sense?

> > Isn't it fun learning these things.
> > 
> > > because the tag is a separate bit from the entry itself, unless you're
> > > under tree_lock, there would be races when changing from page pointer
> > > to swap entry or back, when slot was updated but tag not or vice versa.
> > 
> > So...  take tree_lock?
> 
> I wouldn't call that an improvement...

I wouldn't call the proposed changes to radix-tree.c an improvement,
either.  It's an expedient, once-off, single-caller hack.

If the cost of adding locking is negligible then that is a superior fix.

> > What effect does that have?
> 
> ... but admit I have not measured: I rather assume that if we now change
> tmpfs from lockless to locked lookup, someone else will soon come up with
> the regression numbers.
> 
> > It'd better be
> > "really bad", because this patchset does nothing at all to improve core
> > MM maintainability :(
> 
> I was aiming to improve shmem.c maintainability; and you have good grounds
> to accuse me of hurting shmem.c maintainability when I highmem-ized the
> swap vector nine years ago.
> 
> I was not aiming to improve core MM maintainability, nor to harm it.
> I am extending the use to which the radix-tree can be put, but is that
> so bad?

I find it hard to believe that this wart added to the side of the
radix-tree code will find any other users.  And the wart spreads
contagion into core filemap pagecache lookup.

It's pretty nasty stuff.  Please, what is a better way of doing all this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
