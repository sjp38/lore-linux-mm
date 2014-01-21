Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id E3BE36B0080
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 16:44:03 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id vb8so9603663obc.31
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 13:44:03 -0800 (PST)
Received: from linux-iscsi.org (mail.linux-iscsi.org. [67.23.28.174])
        by mx.google.com with ESMTPS id kv3si3749378obb.19.2014.01.21.13.44.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 13:44:02 -0800 (PST)
Message-ID: <1390340768.5567.762.camel@haakon3.risingtidesystems.com>
Subject: Re: [LSF/MM TOPIC] Implementing a userland interface for data
 integrity passthrough
From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Date: Tue, 21 Jan 2014 13:46:08 -0800
In-Reply-To: <20140117015824.GA28465@birch.djwong.org>
References: <20140117015824.GA28465@birch.djwong.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>, Chuck Lever <chuck.lever@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org

On Thu, 2014-01-16 at 17:58 -0800, Darrick J. Wong wrote:
> Hello LSF committee,
> 

<SNIP>

> I also have my own topic -- implementing a userland interface for
> passing integrity metadata through to the storage.  This is the usage
> model that I'd set up in my head (at the kernel<->userland boundary):
> 
>  1. Program opens a file descriptor.
> 
>  2. Program sets up a aio context.
> 
>  3. Program queries the fd for supported PI profiles (probably an
>     ioctl).
> 
>  4. Program uses newly defined IO_CMD_{READV,WRITEV}_PI commands
>     to supply PI data and verify the data itself.  A new structure
>     will be defined to report the PI profile the app wants to use,
>     which fields the app is actually interested in providing or
>     verifying, a bitset of which devices should check the PI data (HBA,
>     disk, intermediate storage servers), and followed by space for the
>     actual PI data; then either we find space in struct iocb to point
>     to this buffer, or we do something naughty such as attaching it as
>     the first (or last) iovec pointer.
> 
>     libaio can take care of all this for a client program.  A separate
>     discussion could be had about the interface from libaio to client
>     programs, but let's get the kernel<->user piece done first.
> 
>  5. Error codes ... perhaps we define a IO_CMD_GET_ERROR command that
>     doesn't return an event until it has extended error data to
>     supply.  This could be more than just PI failures -- SCSI sense
>     data seems like a potential choice.  This is a stretch goal...
> 
> The raw kernel interface of course would be passing PI profiles and
> data to userspace, for anyone who wishes to bypass libaio.
> 
> As for ioctl that describes what kind of PI data the kernel will
> accept, I'd like to make it generic enough that someone could
> implement a device with any kind of 'checksum' (crc32c, sha1, or maybe
> even a cryptographic signature), while allowing for different
> geometrical requirements, or none, as in the case of byte streams over
> NFS.  It's been suggested to use unique integer values and assume that
> programs know what the values mean, but given the potential for
> variety I wonder if it should be more descriptive:
> 
> {
> 	name: "NFS-FOO-NONSTANDARD",
> 	granularity: 0,
> 	alignment: 0,
> 	profile: "tag,checksum",
> 	tag-width: u32,
> 	checksum-alg: sha256,
> 	checksum-width: u8[32],
> }
> or
> {
> 	name: "tag16-crc16-block32",
> 	granularity: 512,
> 	alignment: 512,
> 	profile: "tag,checksum,reftag",
> 	tag-width: u16,
> 	checksum-alg: crc16,
> 	checksum-width: u16,
> 	reftag-alg: blocknum,
> 	reftag-width: u32,
> }
> 
> Now, for the actual mechanics of modifying the kernel, here's my idea:
> First, enhance the block_integrity API so that we can ask it about
> supported data formats, algorithms, etc. (everything we need to supply
> the schema described in the previous section).
> 
> For buffered mode, each struct page would point to a buffer that is
> big enough to hold all the PI data for all the blocks represented by
> the page, as well as descriptors for the PI data.  This gets much
> harder for the case of arbitrary byte streams instead of disk sectors.
> Perhaps we'd have to have a descriptor that looks like this:
> 
> struct {
>   u16 start, end;
>   int flags;
>   void *buffer;
>   char[16] pi_profile;
> };
> 
> In the case of byte stream PI, I'm not sure how the NFS protocols
> would handle overlapping ranges -- send one page with the set of PIs
> that cover that page?
> 
> Anyway, when a buffered write comes in, we simply copy the user's
> buffer into the thing hanging off struct page.  When
> bio_integrity_prep is called (during submit_bio), it will either find
> no buffer and generate the PI data on its own like it does now, or
> it'll find a buffer, attach it to the bio->bip, then ask the integrity
> provider to fill in whatever's missing.  A directio write would take
> the PI data and attach it directly to the bio it submits.
> 
> For buffered reads, bio_integrity_endio can allocate the buffer and
> attach it to struct page, then fill in the fields that the disk
> returned.  The actual userland read function of course can then copy
> the data out of the thing hanging off struct page into the user's
> buffer, and then userland can do whatever it wants.  A directio read
> simply copies the data from the bio->bip into the userland buffer.
> 
> As for the GET_ERROR thing, my first (and probably only) thought was
> to find a way to attach a buffer and a description of what's in the
> buffer to a bio, so that GET_ERROR can return the buffer contents.
> A tricky part is to help out userspace by mapping an error code back
> to the iocb.  I need to think harder about this piece.  Right now I'm
> only thinking about disk storage; is anyone else interested enough in
> returning rich error data to userland to help me bikeshed? :)
> 

Big +1.

I've been salivating over having a userspace interface for attaching
protection information, and think this is a great topic for LSF.

--nab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
