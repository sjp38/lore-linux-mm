Date: Wed, 19 Jan 2005 12:37:54 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: BUG in shared_policy_replace() ?
In-Reply-To: <41EDAA6E.5000900@mvista.com>
Message-ID: <Pine.LNX.4.44.0501191221400.4795-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Longerbeam <stevel@mvista.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2005, Steve Longerbeam wrote:
> 
> Why free the shared policy created to split up an old
> policy that spans the whole new range? Ie, see patch.

I think you're misreading it.  That code comes from when I changed it
over from sp->sem to sp->lock.  If it finds that it needs to split an
existing range, so needs to allocate a new2, then it has to drop and
reacquire the spinlock around that.  It's conceivable that a racing
task could change the tree while the spinlock is dropped, in such a
way that this split is no longer necessary once we reacquire the
spinlock.  The code you're looking at frees up new2 in that case;
whereas in the normal case, where it is still needed, there's a
new2 = NULL after inserting it, so that it won't be freed below.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
