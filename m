Date: Sat, 25 Apr 1998 11:33:49 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: VM support for transaction processing
In-Reply-To: <Pine.LNX.3.96.980424174134.891C-100000@carissimi.coda.cs.cmu.edu>
Message-ID: <Pine.LNX.3.95.980425111213.26382B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Peter J. Braam" <braam@cs.cmu.edu>
Cc: torvalds@transmeta.com, linux-kernel@vger.rutgers.edu, linux-coda@TELEMANN.coda.cs.cmu.edu, Michael Callahan <mjc@stelias.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Apr 1998, Peter J. Braam wrote:
...
> Is there a method to say to the kernel: 
> 
> A)  this page is now starting to diverge from its disk copy, start
> treating it as VM.
> B)  we have now synced this page, forget about VM, it's backed by the
> file again if you need to swap it out.
> 
> If not can we do something about that easily?
...

There are two answers to the question depending on where you're asking to
get this behaviour: if you want to do this from a user space process, mmap
w/MAP_PRIVATE and msync w/MS_INVALIDATE will do what you want.  However,
if you're looking to do this within the kernel to support transaction
processing on memory mappings, life is a bit more difficult as MAP_SHARED
mappings allow user space processes to write into a page even while it is
being updated on disk (okay under most circumstances as a future update is
guarenteed).  That behavior could be changed easily enough by walking the 
i_mmap ring and invalidating any pages before actually beginning the
write.

Hmmm, looking at filemap_swapin: shouldn't it wait for the page to become
unlocked before allowing the user to make use of the mapping?  Should the
write semantics of mmapings be cleaned up before 2.2?  I'm thinking of a
small set of changes: write protect pages when beginning to write them out
to disk (to avoid the performance hit on the normal case, have a hint bit
in page->flags if the page has any writable mappings), and make
filemap_swapin wait for the page to become !Locked && Uptodate.

		-ben
