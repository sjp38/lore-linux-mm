Date: Fri, 19 May 2000 16:09:58 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re: Request splits]
Message-ID: <20000519160958.C9961@redhat.com>
References: <00c201bfc0d7$56664db0$4d0310ac@fairfax.datafocus.com> <200005181955.MAA71492@getafix.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200005181955.MAA71492@getafix.engr.sgi.com>; from chait@getafix.engr.sgi.com on Thu, May 18, 2000 at 12:55:04PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chaitanya Tumuluri <chait@getafix.engr.sgi.com>
Cc: Eric Youngdale <eric@andante.org>, sct@redhat.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, Brian Pomerantz <bapper@piratehaven.org>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 18, 2000 at 12:55:04PM -0700, Chaitanya Tumuluri wrote:
 
> I've had the same question in my mind. I've also wondered why raw I/O was
> restricted to only KIO_MAX_SECTORS at a time.

Mainly for resource limiting --- you don't want to have too much user
memory pinned permanently at once.

The real solution is probably not to increase the atomic I/O size, but
rather to pipeline I/Os.  That is planned for the future, and now there
are other people interested in it, I'll bump that work up the queue a 
bit!  The idea is to allow brw_kiovec to support fully async operation,
and for the raw device driver to work with multiple kiobufs.  That way
we can keep 2 or 3 kiobufs streaming at all times, eliminating the 
stalls between raw I/O segments, without having to increase the max
segment size.

In the future we'll also need to charge these I/Os against a per-user
limit on pinned memory to control resources.  We can't really offer
O_DIRECT I/O to unprivileged user processes until we have eliminated
that possible DOS attack.  Right now raw devices can only be created
by root and are protected by normal filesystem modes, so we don't
have too much of a problem.

> So, I enhanced Stephen Tweedie's
> raw I/O and the queueing/scsi layers to handle kiobufs-based requests. This is
> in addition to the current buffer_head based request processing.

The "current" kiobuf code is in ftp.uk.linux.org:/pub/linux/sct/fs/raw-io/.
It includes a number of bug fixes (mainly rationalising the error returns),
plus a few new significant bits of functionality.  If you can get me a 
patch against those diffs, I'll include your new code in the main kiobuf
patchset.  (I'm still maintaining the different kiobuf patches as
separate patches within that patchset tarball.)

> Thus, ll_rw_blk.c has two new functions: 
> 	o ll_rw_kio()
> 	o __make_kio_request()

Oh, *thankyou*.  This has been needed for a while.

> Here's the patch against a 2.3.99-pre2 kernel. To recap, two primary reasons
> for this patch:
> 	1. To enhance the queueing and scsi-mid layers to handle kiobuf-based 
> 	   requests as well,
> 
> 	2. Remove request size limits on the upper layers (above ll_rw_blk.c). 
> 	   The KIO_MAX_SECTORS seems to have been inspired by MAX_SECTORS 
> 	   (128 per request) in ll_rw_blk.c. The scsi mid-layer should handle 
> 	   `oversize' requests based on the HBA sg_tablesize.
> 
> I'm not too sure about 2. above; so I'd love to hear from more knowledgeable
> people on that score.

It shouldn't be too much of a problem to retain this limit if the 
brw_kiovec code can stream properly.

> I'd highly appreciate any feedback before I submit this patch `officially'.

There needs to be some mechanism for dealing with drivers which do
not have kiobuf request handling implemented.

I also think that the code is too dependent on request->buffer.  We
_really_ need to treat this as an opportunity to eliminate that field
entirely for kiobuf-based I/Os.  kiobufs refer to struct page *s, not
individual data pointers, and so they can easily represent pages above
the 4GB limit on large memory machines using PAE36.  If we want to be
able to add dual-address-cycle or PCI64 support to the individual scsi
drivers at all, then we need to be able to preserve addresses above
4GB, and kiobufs would seem to be a sensible way to do this if we're
going to have them in the struct request at all.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
