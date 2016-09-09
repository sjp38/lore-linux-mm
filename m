Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C99B6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 16:35:05 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ex14so38272231pac.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 13:35:05 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0091.outbound.protection.outlook.com. [104.47.34.91])
        by mx.google.com with ESMTPS id e125si5474733pfa.186.2016.09.09.13.35.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 13:35:04 -0700 (PDT)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Date: Fri, 9 Sep 2016 20:35:01 +0000
Message-ID: <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org>
 <20160909164808.GC18554@linux.intel.com>
In-Reply-To: <20160909164808.GC18554@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan
 Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

I feel like we're not only building on shifting sands, but we haven't decid=
ed whether we're building a Pyramid or a Sphinx.

I thought after Storage Summit, we had broad agreement that we were moving =
to a primary DAX API that was not BH (nor indeed iomap) based.  We would st=
ill have DAX helpers for block based filesystems (because duplicating all t=
hat code between filesystems is pointless), but I now know of three filesys=
tems which are not block based that are interested in using DAX.  Jared Hul=
bert's AXFS is a nice public example.

I posted a prototype of this here:

https://groups.google.com/d/msg/linux.kernel/xFFHVCQM7Go/ZQeDVYTnFgAJ

It is, of course, woefully out of date, but some of the principles in it ar=
e still good (and I'm working to split it into digestible chunks).

The essence:

1. VFS or VM calls filesystem (eg ->fault())=20
2. Filesystem calls DAX (eg dax_fault())=20
3. DAX looks in radix tree, finds no information.=20
4. DAX calls (NEW!) mapping->a_ops->populate_pfns=20
5a. Filesystem (if not block based) does its own thing to find out the PFNs=
 corresponding to the requested range, then inserts them into the radix tre=
e (possible helper in DAX code)
5b. Filesystem (if block based) looks up its internal data structure (eg ex=
tent tree) and=20
=A0 =A0calls dax_create_pfns() (see giant patch from yesterday, only instea=
d of=20
=A0 =A0passing a get_block_t, the filesystem has already filled in a bh whi=
ch=20
=A0 =A0describes the entire extent that this access happens to land in).=20
6b. DAX takes care of calling bdev_direct_access() from=A0dax_create_pfns()=
.

Now, notice that there's no interaction with the rest of the filesystem her=
e.  We can swap out BHs and iomaps relatively trivially; there's no call fo=
r making grand changes, like converting ext2 over to iomap.  The BH or ioma=
p is only used for communicating the extent from the filesystem to DAX.

Do we have agreement that this is the right way to go?

-----Original Message-----
From: Ross Zwisler [mailto:ross.zwisler@linux.intel.com]=20
Sent: Friday, September 9, 2016 12:48 PM
To: Theodore Ts'o <tytso@mit.edu>; Christoph Hellwig <hch@infradead.org>; R=
oss Zwisler <ross.zwisler@linux.intel.com>; linux-kernel@vger.kernel.org; A=
ndrew Morton <akpm@linux-foundation.org>; linux-nvdimm@ml01.01.org; Matthew=
 Wilcox <mawilcox@microsoft.com>; Dave Chinner <david@fromorbit.com>; linux=
-mm@kvack.org; Andreas Dilger <adilger.kernel@dilger.ca>; Alexander Viro <v=
iro@zeniv.linux.org.uk>; Jan Kara <jack@suse.com>; linux-fsdevel@vger.kerne=
l.org; linux-ext4@vger.kernel.org
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes

On Mon, Aug 29, 2016 at 08:57:41AM -0400, Theodore Ts'o wrote:
> On Mon, Aug 29, 2016 at 12:41:16AM -0700, Christoph Hellwig wrote:
> >=20
> > We're going to move forward killing buffer_heads in XFS.  I think ext4
> > would dramatically benefit from this a well, as would ext2 (although I
> > think all that DAX work in ext2 is a horrible idea to start with).
>=20
> It's been on my todo list.  The only reason why I haven't done it yet
> is because I knew you were working on a solution, and I didn't want to
> do things one way for buffered I/O, and a different way for Direct
> I/O, and disentangling the DIO code and the different assumptions of
> how different file systems interact with the DIO code is a *mess*.
>=20
> It may have gotten better more recently, but a few years ago I took a
> look at it and backed slowly away.....

Ted, what do you think of the idea of moving to struct iomap in ext2?

If ext2 stays with the current struct buffer_head + get_block_t interface,
then it looks like DAX basically has three options:

1) Support two I/O paths and two versions of each of the fault paths (PTE,
PMD, etc).  One of each of these would be based on struct iomap and would b=
e
used by xfs and potentially ext4, and the other would be based on struct
buffer_head + get_block_t and would be used by ext2.

2) Only have a single struct iomap based I/O path and fault path, and add
shim/support code so that ext2 can use it, leaving the rest of ext2 to be
struct buffer_head + get_block_t based.

3) Only have a single struct buffer_head + get_block_t based DAX I/O and fa=
ult
path, and have XFS and potentially ext4 do the translation from their nativ=
e
struct iomap interface.

It seems ideal for ext2 to switch along with everyone else, if getting rid =
of
struct buffer_head is a global goal.  If not, I guess barring technical iss=
ues
#2 above seems cleanest - move DAX to the new structure, and provide backwa=
rds
compatibility to ext2.  Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
