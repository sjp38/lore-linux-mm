Date: Sat, 18 Oct 2008 07:18:01 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: no way to swapoff a deleted swap file?
Message-ID: <20081018051800.GO24654@1wt.eu>
References: <bnlDw-5vQ-7@gated-at.bofh.it> <bnwpg-2EA-17@gated-at.bofh.it> <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it> <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org> <Pine.LNX.4.64.0810171250410.22374@blonde.site> <20081018003117.GC26067@cordes.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081018003117.GC26067@cordes.ca>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Cordes <peter@cordes.ca>
Cc: Hugh Dickins <hugh@veritas.com>, Bodo Eggert <7eggert@gmx.de>, David Newall <davidn@davidnewall.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 09:31:17PM -0300, Peter Cordes wrote:
> On Fri, Oct 17, 2008 at 01:17:17PM +0100, Hugh Dickins wrote:
> > On Fri, 17 Oct 2008, Bodo Eggert wrote:
> > > 
> > > Somebody might want their swapfiles to have zero links,
> > > _and_ the possibility of doing swapoff.
> > 
> > You're right, they might, and it's not an unreasonable wish.
> > But we've not supported it in the past, and I still don't
> > think it's worth adding special kernel support for it now.
> 
>  I'd be inclined to agree with not bloating the kernel to support
> this, even though it would have been convenient for me in one case.  I
> do have an idea for supporting this without bloat, see below.  In case
> anyone wants more details about how I painted myself into that corner,
> here's the backstory to my feature request.

(...)
I have another idea which might be simpler to implement in userspace.
What happened to you is a typical accident, you did not run on purpose
on a deleted swap file. So we should at least ensure that such types
of accidents could not happen easily.

If swapon did set the immutable bit on a file just after enabling swap
to it, it would at least prevent accidental removal of that file. Swapoff
would have to clean that bit, and swapon would have to clean it upon
startup too (in case of unplanned reboots).

That way, you could still remove such files on purpose provided you do
a preliminary "chattr -i" on them, but "rm -rf" would keep them intact.
It would also prevent accidental modifications, such as "ls .>swapfile"
instead of "ls ./swapfile".

Regards,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
