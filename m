From: Neil Brown <neilb@suse.de>
Date: Tue, 24 Apr 2007 17:49:48 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17965.46748.634169.563467@notabene.brown>
Subject: Re: [patch 12/44] fs: introduce write_begin, write_end, and perform_write aops
In-Reply-To: message from Nick Piggin on Tuesday April 24
References: <20070424012346.696840000@suse.de>
	<20070424013433.975224000@suse.de>
	<17965.43747.979798.715583@notabene.brown>
	<20070424072327.GC20640@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday April 24, npiggin@suse.de wrote:
> 
> BTW. AOP_FLAG_UNINTERRUPTIBLE can be used by filesystems to avoid
> an initial read or other sequence they might be using to handle the
> case of a short write. ecryptfs uses it, others can too.
> 
> For buffered writes, this doesn't get passed in (unless they are
> coming from kernel space), so I was debating whether to have it at
> all.  However, in the previous API, _nobody_ had to worry about
> short writes, so this flag means I avoid making an API that is
> fundamentally less performant in some situations.

Ahhh I think I get it now.

  In general, the address_space must cope with the possibility that
  fewer than the expected number of bytes is copied.  This may leave
  parts of the page with invalid data.  This can be handled by
  pre-loading the page with valid data, however this may cause a
  significant performance cost.
  The write_begin/write_end interface provide two mechanism by which
  this case can be handled more efficiently.
  1/ The AOP_FLAG_UNINTERRUPTIBLE flag declares that the write will
    not be partial (maybe a different name? AOP_FLAG_NO_PARTIAL).
    If that is set, inefficient preparation can be avoided.  However the
    most common write paths will never set this flag.
  2/ The return from write_end can declare that fewer bytes have been
    accepted. e.g. part of the page may have been loaded from backing
    store, overwriting some of the newly written bytes.  If this
    return value is reduced, a new write_begin/write_end cycle
    may be called to attempt to write the bytes again.

Also
+  write_end: After a successful write_begin, and data copy, write_end must
+        be called. len is the original len passed to write_begin, and copied
+        is the amount that was able to be copied (they must be equal if
+        write_begin was called with intr == 0).
+

That should be "... called without AOP_FLAG_UNINTERRUPTIBLE being
set".
And "that was able to be copied" is misleading, as the copy is not done in
write_end.  Maybe "that was accepted".

It seems to make sense now.  I might try re-reviewing the patches based
on this improved understanding.... only a public holiday looms :-)

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
