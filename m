Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 78B03828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 18:21:53 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id q21so269536897iod.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 15:21:53 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id k91si7638518ioi.176.2016.01.07.15.21.51
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 15:21:52 -0800 (PST)
Date: Fri, 8 Jan 2016 10:10:00 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 1/9] dax: fix NULL pointer dereference in __dax_dbg()
Message-ID: <20160107231000.GO21461@dastard>
References: <1452103263-1592-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452103263-1592-2-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4h3NcXHHQAWL=HwgGxTbFTeOa98S9fxWu7dA3nTEcFxxA@mail.gmail.com>
 <20160107093402.GA8380@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107093402.GA8380@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>

On Thu, Jan 07, 2016 at 10:34:02AM +0100, Jan Kara wrote:
> On Wed 06-01-16 11:14:09, Dan Williams wrote:
> > On Wed, Jan 6, 2016 at 10:00 AM, Ross Zwisler
> > <ross.zwisler@linux.intel.com> wrote:
> > > __dax_dbg() currently assumes that bh->b_bdev is non-NULL, passing it into
> > > bdevname() where is is dereferenced.  This assumption isn't always true -
> > > when called for reads of holes, ext4_dax_mmap_get_block() returns a buffer
> > > head where bh->b_bdev is never set.  I hit this BUG while testing the DAX
> > > PMD fault path.
> > >
> > > Instead, verify that we have a valid bh->b_bdev, else just say "unknown"
> > > for the block device.
> > >
> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > ---
> > >  fs/dax.c | 7 ++++++-
> > >  1 file changed, 6 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/fs/dax.c b/fs/dax.c
> > > index 7af8797..03cc4a3 100644
> > > --- a/fs/dax.c
> > > +++ b/fs/dax.c
> > > @@ -563,7 +563,12 @@ static void __dax_dbg(struct buffer_head *bh, unsigned long address,
> > >  {
> > >         if (bh) {
> > >                 char bname[BDEVNAME_SIZE];
> > > -               bdevname(bh->b_bdev, bname);
> > > +
> > > +               if (bh->b_bdev)
> > > +                       bdevname(bh->b_bdev, bname);
> > > +               else
> > > +                       snprintf(bname, BDEVNAME_SIZE, "unknown");
> > > +
> > >                 pr_debug("%s: %s addr: %lx dev %s state %lx start %lld "
> > >                         "length %zd fallback: %s\n", fn, current->comm,
> > >                         address, bname, bh->b_state, (u64)bh->b_blocknr,
> > 
> > I'm assuming there's no danger of a such a buffer_head ever being used
> > for the bdev parameter to dax_map_atomic()?  Shouldn't we also/instead
> > go fix ext4 to not send partially filled buffer_heads?
> 
> No. The real problem is a long-standing abuse of struct buffer_head to be
> used for passing block mapping information (it's on my todo list to remove
> that at least from DAX code and use cleaner block mapping interface but
> first I want basic DAX functionality to settle down to avoid unnecessary
> conflicts). Filesystem is not supposed to touch bh->b_bdev.

That has not been true for a long, long time. e.g. XFS always
rewrites bh->b_bdev in get_blocks because the file may not reside on
the primary block device of the filesystem. i.e.:

        /*
         * If this is a realtime file, data may be on a different device.
         * to that pointed to from the buffer_head b_bdev currently.
         */
        bh_result->b_bdev = xfs_find_bdev_for_inode(inode);

> If you need
> that filled in, set it yourself in before passing bh to the block mapping
> function.

That may be true, but we cannot assume that the bdev coming back
out of get_block is the same one that was passed in.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
