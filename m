Date: Tue, 9 Oct 2007 17:25:39 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Bug 9138] New: kernel overwrites MAP_PRIVATE mmap
In-Reply-To: <470BA58F.8050907@lu.unisi.ch>
Message-ID: <Pine.LNX.4.64.0710091711450.30785@blonde.wat.veritas.com>
References: <bug-9138-27@http.bugzilla.kernel.org/>
 <20071009083913.212fb3e3.akpm@linux-foundation.org> <470BA58F.8050907@lu.unisi.ch>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bonzini@gnu.org
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Oct 2007, Paolo Bonzini wrote:
> > So can you confirm that this behaviour was not present in 2.6.8 but is
> > present in 2.6.20?
> 
> Yes.  I also have access to a Debian i686 2.6.22.9 and it shows the bug.

That's surprising, and sounds like a bug in 2.6.8 not in 2.6.20 or 2.6.22.

I may have misunderstood the steps, but you summarize:

> I believe the reason is a bad interaction between the private mmap
> established in save.c:
> 
>   buf = mmap (NULL, file_size, PROT_READ, MAP_PRIVATE, imageFd, 0);
> 
> and truncating the inode on which the mmap was done.

It is standard behaviour that truncating the inode on which an mmap
was done will generate SIGBUS on access to pages of the mmap beyond
the new end of file.  Easier to understand when MAP_SHARED, but even
when MAP_PRIVATE, and even when private pages have already been
C-O-Wed from the file.

Checking with SUSv3, I find it using the word "may" a lot, without
explicitly demanding this behaviour; but my recollection of the early
implementations of mmap in UNIX, which set the standard, is that they
behaved in this way - though I've often (like you) wished they did not.

Might it have been a different version of Smalltalk which was tested
with the 2.6.8 kernel, a version which didn't cause this to happen?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
