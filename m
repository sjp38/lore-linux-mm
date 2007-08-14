Subject: Re: Minor [?] page migration bug in check_pte_range()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708141231210.30435@schroedinger.engr.sgi.com>
References: <1187105148.6281.38.camel@localhost>
	 <Pine.LNX.4.64.0708141231210.30435@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 14 Aug 2007 16:21:31 -0400
Message-Id: <1187122892.6281.91.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-14 at 12:33 -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Lee Schermerhorn wrote:
> 
> > What I see is that when you attempt to install an interleave policy and
> > migrate the pages to match that policy, any pages on nodes included in
> > the interleave node mask will not be migrated to match policy.  This
> 
> Right. The pages are already on permitted nodes.

For some definition of permitted, I guess.  They just don't follow
policy.  So, if the pages all happen to be on the same node and you want
to spread them out over a set of nodes that includes the node they're
on, you can't do it.  I suppose this isn't needed all that often.  And
the current check probably makes sense for migrate_pages().  It just
surprised me when I saw that the pages didn't migrate to follow the new
interleaved policy.

> 
> > occurs because of the clever, but overly simplistic test in
> > check_pte_range():
> > 
> > 	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
> > 		continue;
> > 
> > Fixing this would, I think, involve checking each page against the
> > location dictated by the new policy.  Altho' I don't think this is a
> > performance critical path, it is the inner-most loop of check_range().
> > 
> > Is this worth addressing, do you think?
> 
> This is not going to be easy because you would have to move each 
> individual pages to a particular node. Or setup lists for each node and 
> then do several calls to migrate page.

No, your existing migration infrastructure, since you added the
allocation function argument to migrate_pages(), "just works".
new_vma_page() allocates pages via alloc_page_vma() so that all pages on
the list follow policy for the page offset into the vma.  However,
without fancier filtering in check_pte_range() to exclude pages that
already match policy, we'd end up migrating pages within a node.  

> 
> I think we can leave it as is.
> 

OK, but it does result in another case where the APIs appear not to work
as one might expect.  We'll need to document this in the man pages, or
you'll end up having to handle one of those escalated support calls that
I know you hate ;-).

Meanwhile, I have a function in my "migrate-on-fault" a.k.a. lazy
migration patch set that checks whether a page matches the policy at a
given vma,addr.  I'll see what it would look like to use it for this
purpose.  Just in case...

Later,
Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
