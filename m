Date: Fri, 16 Jul 2004 00:21:11 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] /dev/zero page fault scaling
In-Reply-To: <Pine.SGI.4.58.0407151647100.116400@kzerza.americas.sgi.com>
Message-ID: <Pine.LNX.4.44.0407160010450.8668-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jul 2004, Brent Casavant wrote:
> On Thu, 15 Jul 2004, Hugh Dickins wrote:
> 
> > +	/* Keep it simple: disallow limited <-> unlimited remount */
> > +	if ((max_blocks || max_inodes) == !sbinfo)
> > +		return -EINVAL;
> 
> Just caught this one.
> 
> Shouldn't this be:
> 
> 	if ((max_blocks || max_inodes) && !sbinfo)
> 		return -EINVAL;

That's only one half of what I'm trying to disable there, certainly
the more justifiable half, unlimited -> limited.  At the same time
I'm trying to say

	if (!(max_blocks || max_inodes) && sbinfo)
		return -EINVAL;

that is, also disable limited -> unlimited.  Why?  To save bloating
the code, really.  If that's allowed then (a) we need to add in
kfreeing the old sbinfo and (b) we ought really to go through the
existing inodes changing i_blocks (maintained while sbinfo) to 0
(as always while !sbinfo).  Not worth the bother, I thought.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
