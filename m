Date: Thu, 19 Jun 2008 14:49:50 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <20080619133809.GC10123@sgi.com>
Message-ID: <Pine.LNX.4.64.0806191441040.25832@blonde.site>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806191154270.7324@blonde.site> <20080619133809.GC10123@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008, Robin Holt wrote:
> On Thu, Jun 19, 2008 at 12:09:15PM +0100, Hugh Dickins wrote:
> > 
> > (I assume Robin is not forking, we do know that causes this kind
> > of problem, but he didn't mention any forking so I assume not.)
> 
> There has been a fork long before this mapping was created.  There was a
> hole at this location and the mapping gets established and pages populated
> following all ranks of the MPI job getting initialized.

There's usually been a fork somewhen in the past!  That's no problem.

The fork problem comes when someone has done a get_user_pages to break
all the COWs, then another thread does a fork which writeprotects and
raises page_mapcount, so the next write from userspace breaks COW again
and writes to a different page from that which the kernel is holding.

That one kept on coming up, but I've not heard of it again since we
added madvise MADV_DONTFORK so apps could exclude such parts of the
address space from copy_page_range.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
