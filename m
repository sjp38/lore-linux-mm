Message-Id: <200005191738.KAA73862@getafix.engr.sgi.com>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re: Request splits] 
In-reply-to: Your message of "Fri, 19 May 2000 16:09:58 BST."
             <20000519160958.C9961@redhat.com>
Date: Fri, 19 May 2000 10:38:45 -0700
From: Chaitanya Tumuluri <chait@getafix.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, Brian Pomerantz <bapper@piratehaven.org>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 May 2000 16:09:58 BST, "Stephen C. Tweedie" <sct@redhat.com> wrote:
>Hi,
>
>On Thu, May 18, 2000 at 12:55:04PM -0700, Chaitanya Tumuluri wrote:
> 
>> I've had the same question in my mind. I've also wondered why raw I/O was
>> restricted to only KIO_MAX_SECTORS at a time.
>
>Mainly for resource limiting --- you don't want to have too much user
>memory pinned permanently at once.

The flip side of this argument being that raw I/O is "raw" access to a
device and such access is usually needed by systems (e.g. databases) 
that know what they are doing. I would like to think that in the raw I/O
path at least, we shouldn't be posting such limits. Besides, things like
databases have their "buffer caches" allocated during startup and pinned
till the next reboot.

>The real solution is probably not to increase the atomic I/O size, but
>rather to pipeline I/Os.  That is planned for the future, and now there
>are other people interested in it, I'll bump that work up the queue a 
>bit!  The idea is to allow brw_kiovec to support fully async operation,
>and for the raw device driver to work with multiple kiobufs.  That way
>we can keep 2 or 3 kiobufs streaming at all times, eliminating the 
>stalls between raw I/O segments, without having to increase the max
>segment size.

Sounds good; and its pretty much what I have in mind. And that is why
I've added the following field to the kiobuf struct, to allow the issue
of multiple kiobuf requests from the `parent' kiovec. This would be useful
in the completion functions for the individual kiobufs:

+#if CONFIG_KIOBUF_IO
+       void *k_dev_id;                 /* Store kiovec (or pagebuf) here */
+#endif

However, I'd still like to draw the focus away from the limits imposed at 
the raw I/O (i.e raw.c / buffer.c) layers and say that we should work with 
the real h/w limits. The HBA scatter-gather memory size is the limiting 
factor here. There are two ways of dealing with I/O requests larger than 
this limit:

	1. Repeatedly queue scsi-cmnds against the HBA/device till all
	   the I/O is done. This requeuing is done at the scsi midlayer.

	2. Provide for a "continuation" field in the Scsi_Cmnd struct
	   that low-level HBA drivers understand and use to re-issue
	   the I/Os in chunks of the sg_tablesize. 

The advantage of 2. is obvious in that it doesn't pump the system with
completion interrupts. However, the easiest solution at this point is
1. above (given the mechanism already exists in the scsi midlayers).


>In the future we'll also need to charge these I/Os against a per-user
>limit on pinned memory to control resources.  We can't really offer
>O_DIRECT I/O to unprivileged user processes until we have eliminated
>that possible DOS attack.  Right now raw devices can only be created
>by root and are protected by normal filesystem modes, so we don't
>have too much of a problem.

I hadn't thought that far; but I can see your point, yes.

>> So, I enhanced Stephen Tweedie's
>> raw I/O and the queueing/scsi layers to handle kiobufs-based requests. This is
>> in addition to the current buffer_head based request processing.
>
>The "current" kiobuf code is in ftp.uk.linux.org:/pub/linux/sct/fs/raw-io/.
>It includes a number of bug fixes (mainly rationalising the error returns),
>plus a few new significant bits of functionality.  If you can get me a 
>patch against those diffs, I'll include your new code in the main kiobuf
>patchset.  (I'm still maintaining the different kiobuf patches as
>separate patches within that patchset tarball.)

Great...I'll work on it shortly. 

>> Thus, ll_rw_blk.c has two new functions: 
>> 	o ll_rw_kio()
>> 	o __make_kio_request()
>
>Oh, *thankyou*.  This has been needed for a while.

Now there's a real gratifying response for you! Thank _you_! :^)
Will you consider including these changes also (i.e. queueing/scsi midlayers)
in your patchset as well?

>> Here's the patch against a 2.3.99-pre2 kernel. To recap, two primary reasons
>> for this patch:
>> 	1. To enhance the queueing and scsi-mid layers to handle kiobuf-based 
>> 	   requests as well,
>> 
>> 	2. Remove request size limits on the upper layers (above ll_rw_blk.c). 
>> 	   The KIO_MAX_SECTORS seems to have been inspired by MAX_SECTORS 
>> 	   (128 per request) in ll_rw_blk.c. The scsi mid-layer should handle 
>> 	   `oversize' requests based on the HBA sg_tablesize.
>> 
>> I'm not too sure about 2. above; so I'd love to hear from more knowledgeable
>> people on that score.
>
>It shouldn't be too much of a problem to retain this limit if the 
>brw_kiovec code can stream properly.
>
>> I'd highly appreciate any feedback before I submit this patch `officially'.
>
>There needs to be some mechanism for dealing with drivers which do
>not have kiobuf request handling implemented.

They will continue working with the current buffer_head path. That is why
as far as possible, I've separated the buffer_head and kiobuf request
handling into separate functions in the code. This is also the reason I
still have the #ifdefs in the code.....it enables easier surgery when the
time comes (if and when!) to remove the buffer_head I/O paths completely.

<plug>
I've experimented with XFS performance using kiobuf-based requests and it
has shown performance improvements ... data is still not stable yet. The
main improvements (as expected) is in lowered CPU overheads and slightly
improved disk thro'puts.

It'd be great if we could sit down and convert ext2 to use kiobufs/kiovecs
and see the difference.
<\plug>

>I also think that the code is too dependent on request->buffer.  We
>_really_ need to treat this as an opportunity to eliminate that field
>entirely for kiobuf-based I/Os.  kiobufs refer to struct page *s, not
>individual data pointers, and so they can easily represent pages above
>the 4GB limit on large memory machines using PAE36.  If we want to be
>able to add dual-address-cycle or PCI64 support to the individual scsi
>drivers at all, then we need to be able to preserve addresses above
>4GB, and kiobufs would seem to be a sensible way to do this if we're
>going to have them in the struct request at all.

True and thats been the reasoning behind the "pagebuf" efforts currently
being used in the XFS work. 

I'll download your rawio source and merge my changes into that source.

Cheers,
-Chait.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
