Subject: Re: VM support for transaction processing
References: <Pine.LNX.3.95.980425111213.26382B-100000@as200.spellcast.com>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 18 Jun 1998 19:45:36 -0500
In-Reply-To: "Benjamin C.R. LaHaise"'s message of Sat, 25 Apr 1998 11:33:49 -0400 (EDT)
Message-ID: <m11zsmxlqn.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "BL" == Benjamin C R LaHaise <blah@kvack.org> writes:

BL> On Fri, 24 Apr 1998, Peter J. Braam wrote:
BL> ...

BL> Hmmm, looking at filemap_swapin: shouldn't it wait for the page to become
BL> unlocked before allowing the user to make use of the mapping?

A) Yes
B) It doesn't matter because nothing currently in the kernel writes
pages directly out from the page cache yet...

BL> Should the
BL> write semantics of mmapings be cleaned up before 2.2?  I'm thinking of a
BL> small set of changes: write protect pages when beginning to write them out
BL> to disk (to avoid the performance hit on the normal case, have a hint bit
BL> in page->flags if the page has any writable mappings), and make
BL> filemap_swapin wait for the page to become !Locked && Uptodate.

Since the page is being written the page is garanteed to be Uptodate.
Since we currently don't write things through the page cache we don't
need to worry about it being locked.

For really implementing writes through the page cache I have to tackle
all of these issues.  The write protect sounds good, but you need to
watch for other code that will notice it is allowed to be a writeable
mapping and convert it.  

It also has the problem of when to decrement the page count, which is
primarily what the current mechanism gives us.  So changing it is
tricky.

Eric
