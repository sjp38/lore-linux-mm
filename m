Date: Tue, 30 Jan 2007 14:58:50 +0000 (GMT)
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: page_mkwrite caller is racy?
In-Reply-To: <20070130015159.GA14799@ca-server1.us.oracle.com>
Message-ID: <Pine.LNX.4.64.0701301456250.6541@hermes-1.csi.cam.ac.uk>
References: <45BDCA8A.4050809@yahoo.com.au> <Pine.LNX.4.64.0701291521540.24726@blonde.wat.veritas.com>
 <45BE9BF0.10202@yahoo.com.au> <20070130015159.GA14799@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fasheh <mark.fasheh@oracle.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Mark Fasheh wrote:
> On Tue, Jan 30, 2007 at 12:14:24PM +1100, Nick Piggin wrote:
> > This is another discussion, but do we want the page locked here? Or
> > are the filesystems happy to exclude truncate themselves?
> 
> No page lock please. Generally, Ocfs2 wants to order cluster locks outside
> of page locks. Also, the sparse b-tree support I'm working on right now will
> need to be able to allocate in ->page_mkwrite() which would become very
> nasty if we came in with the page lock - aside from the additional cluster
> locks taken, ocfs2 will want to zero some adjacent pages (because we support
> atomic allocation up to 1 meg).

Ditto for NTFS.  I will need to lock pages on both sides of the page for 
large volume cluster sizes thus I will have to drop the page lock if it is 
already taken so it might as well not be...  Although I do not feel 
strongly about it.  If the page is locked I will just drop the lock and 
then take it again.  If possible to not have the page locked that would 
make my code a little easier/more efficient I expect...

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer, http://www.linux-ntfs.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
