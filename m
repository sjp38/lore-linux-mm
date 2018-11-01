Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4892F6B0269
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 19:00:20 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id m198-v6so706116itm.8
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 16:00:19 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id g38-v6si28109997pgl.248.2018.11.01.16.00.16
        for <linux-mm@kvack.org>;
        Thu, 01 Nov 2018 16:00:17 -0700 (PDT)
Date: Fri, 2 Nov 2018 10:00:12 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181101230012.GC19305@dastard>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <x49h8hkfhk9.fsf@segfault.boston.devel.redhat.com>
 <20181018002510.GC6311@dastard>
 <20181018145555.GS23493@quack2.suse.cz>
 <20181019004303.GI6311@dastard>
 <CAPcyv4ixoAh7HEMfm+B4sRDx1Qwm6SHGjtQ+5r3EKsxreRydrA@mail.gmail.com>
 <20181030224904.GT19305@dastard>
 <TYAPR01MB32619CCA488DD0DA86EDB17E90CD0@TYAPR01MB3261.jpnprd01.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <TYAPR01MB32619CCA488DD0DA86EDB17E90CD0@TYAPR01MB3261.jpnprd01.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "y-goto@fujitsu.com" <y-goto@fujitsu.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, jmoyer <jmoyer@redhat.com>, Johannes Thumshirn <jthumshirn@suse.de>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Oct 31, 2018 at 05:59:17AM +0000, y-goto@fujitsu.com wrote:
> > On Mon, Oct 29, 2018 at 11:30:41PM -0700, Dan Williams wrote:
> > > On Thu, Oct 18, 2018 at 5:58 PM Dave Chinner <david@fromorbit.com> wrote:
> > In summary:
> > 
> > 	MAP_DIRECT is an access hint.
> > 
> > 	MAP_SYNC provides a data integrity model guarantee.
> > 
> > 	MAP_SYNC may imply MAP_DIRECT for specific implementations,
> > 	but it does not require or guarantee MAP_DIRECT.
> > 
> > Let's compare that with O_DIRECT:
> > 
> > 	O_DIRECT in an access hint.
> > 
> > 	O_DSYNC provides a data integrity model guarantee.
> > 
> > 	O_DSYNC may imply O_DIRECT for specific implementations, but
> > 	it does not require or guarantee O_DIRECT.
> > 
> > Consistency in access and data integrity models is a good thing. DAX
> > and pmem is not an exception. We need to use a model we know works
> > and has proven itself over a long period of time.
> 
> Hmmm, then, I would like to know all of the reasons of breakage of MAP_DIRECT.
> (I'm not opposed to your opinion, but I need to know it.)
> 
> In O_DIRECT case, in my understanding, the reason of breakage of O_DIRECT is 
> "wrong alignment is specified by application", right?

O_DIRECT has defined memory and offset alignment restrictions, and
will return an error to userspace when they are violated. It does
not fall back to buffered IO in this case. MAP_DIRECT has no
equivalent restriction, so IO alignment of O_DIRECT is largely
irrelevant here.

What we are talking about here is that some filesystems can only do
certain operations through buffered IO, such as block allocation or
file extension, and so silently fall back to doing them via buffered
IO even when O_DIRECT is specified. The old direct IO code used to
be full of conditionals to allow this - I think DIO_SKIP_HOLES is
only one remaining:

                /*
                 * For writes that could fill holes inside i_size on a
                 * DIO_SKIP_HOLES filesystem we forbid block creations: only
                 * overwrites are permitted. We will return early to the caller
                 * once we see an unmapped buffer head returned, and the caller
                 * will fall back to buffered I/O.
                 *
                 * Otherwise the decision is left to the get_blocks method,
                 * which may decide to handle it or also return an unmapped
                 * buffer head.
                 */
                create = dio->op == REQ_OP_WRITE;
                if (dio->flags & DIO_SKIP_HOLES) {
                        if (fs_startblk <= ((i_size_read(dio->inode) - 1) >>
                                                        i_blkbits))
                                create = 0;
                }

Other cases like file extension cases are caught by the filesystems
before calling into the DIO code itself, so there's multiple avenues
for O_DIRECT transparently falling back to buffered IO.

This means the applications don't fail just because the filesystem
can't do a specific operation via O_DIRECT. The data writes still
succeed because they fall back to buffered IO, and the application
is blissfully unaware that the filesystem behaved that way.

> When filesystem can not use O_DIRECT and it uses page cache instead,
> then system uses more memory resource than user's expectation.

That's far better than failing unexpectedly because the app
unexpectedly came across a hole in the file (e.g. someone ran
sparsify across the filesystem).

> So, there is a side effect, and it may cause other trouble.
> (memory pressure, expected performance can not be gained, and so on ..)

Which is why people are supposed to test their systems before they
put them into production.

I've lost count of the number of times I've heard "but O_DIRECT is
supposed to make things faster!" because people don't understand
exactly what it does or means. Bypassing the page cache does not
magically make applications go faster - it puts the responsibility
for doing optimal IO on the application, not the kernel.

MAP_DIRECT will be no different. It's no guarantee that it will make
things faster, or that everything will just work as users expect
them to. It specifically places the responsibility for performing IO
in an optimal fashion on the application and the user for making
sure that it is fit for their purposes. Like O_DIRECT, using
MAP_DIRECT means "I, the application, know exactly what I'm doing,
so get out of the way as much as possible because I'm taking
responsibility for issuing IO in the most optimal manner now".

> In such case its administrator (or technical support engineer) needs to struggle to
> investigate what is the reason.

That's no different to performance problems that arise from
inappropriate use of O_DIRECT. It requires a certain level of
expertise to be able to understand and diagnose such issues.

> So, I would like to know in MAP_DIRECT case, what is the reasons? 
> I think it will be helpful for users.
> Only splice?

The filesystem can ignore MAP_DIRECT for any reason it needs to. I'm
certain that filesystem developers will try to maintain MAP_DIRECT
semantics as much as possible, but it's not going to be possible in
/all situations/ on XFS and ext4 because they simply haven't been
designed with DAX in mind. Filesystems designed specifically for
pmem and DAX might be able to provide MAP_DIRECT in all situations,
but those filesystems don't really exist yet.

This is no different to the early days of O_DIRECT. e.g.  ext3
couldn't do O_DIRECT for all operations when it was first
introduced, but over time the functionality improved as the
underlying issues were solved. If O_DIRECT was a guarantee, then
ext3 would have never supported O_DIRECT at all...

> (Maybe such document will be necessary....)

The semantics will need to be documented in the relevant man pages.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
