Date: Wed, 26 Jan 2000 11:02:37 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: possible brw_page optimization
In-Reply-To: <14478.61468.943623.938788@dukat.scot.redhat.com>
Message-ID: <Pine.BSO.4.10.10001261054300.27169-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jan 2000, Stephen C. Tweedie wrote:
> On Fri, 21 Jan 2000 15:21:33 -0500 (EST), Chuck Lever <cel@monkey.org>
> said:
> > i've been exploring swap compaction and encryption, and found that
> > brw_page wants to break pages into buffer-sized pieces in order to
> > schedule I/O.  
> 
> brw_page is there explicitly to perform physical block IO to disk.  If
> you want to do compression or encription, I'd have thought you want to
> do that at a higher level.

yes, i want to make the policy decisions and do the encryption at the
rw_swap_page_base() level.  the decryption/decompression would be handled
by the exit routine.

however, somehow i'd have to guarantee that all buffers associated with a
page that is to be compressed/encrypted are read/written at once.  using a
bounce page to handle the ciphertext/compressed page might be enough to do
that, since it would have no buffers already associated with it.

however, i was wondering if the optimization i did was of general use. as
i mentioned, i don't see any place that invokes brw_page() in such a way
as to trigger the logic to read only some of the buffers.

> The clean way to do this would be to provide
> a virtual file to swap over, and to allow rw_swap_page_base() to pass
> the page read or write to that file's inode's read_/write_page methods.
> Then you can do any munging you want on the virtual swap file without
> polluting the underlying swap IO code.

using a unique swap file/device makes it easy to tell when you need to
decrypt a page.  :)

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
