Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA11493
	for <linux-mm@kvack.org>; Wed, 22 Apr 1998 17:29:39 -0400
Subject: filemap_nopage is broken!!
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 22 Apr 1998 15:51:07 -0500
Message-ID: <m1vhs1oa10.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


While looking at what is needs to happen to get large file support
working on linux-intel, I discovered an interesting twist with
generic_file_mmap.

mmap being the most interesting case to port, because the generic
interface allows for non aligned mappings.  Making it the most
intersting case to handle.

generic_file_mmap allows filesystem block aligned mappings if the
mapping is private.  The way it implements this, after I finally
tracked it is broken.

For private mappings the same filemap_nopage function that is used for
shared mappings is used.  The filemap_nopage function alwasy make sure
it's pages are in the page cache before it uses them.

For a private mapping (not page aligned) this results in a non-aligned
page to be created in the page cache.

Now if the following sequence of actions occure.
a) A page is mapped privately with poor alignment.
b) That part of the file is written again.
c) The page is again mapped privately with poor alignment.

When the page cache page is not scavenged between a and c, the same
data is read, despite the fact it has changed on disk, and in the
aligned page cache page!

That is broken behavior.

Does anyone know where it comes from?

Eric
