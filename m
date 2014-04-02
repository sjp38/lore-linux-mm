Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 499CE6B0139
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 19:06:24 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so892549pbc.10
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 16:06:24 -0700 (PDT)
Date: Wed, 2 Apr 2014 16:06:12 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 2/6] io: define an interface for IO extensions
Message-ID: <20140402230612.GF10230@birch.djwong.org>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162244.10848.46322.stgit@birch.djwong.org>
 <20140402194947.GJ2394@lenny.home.zabbo.net>
 <20140402222801.GD10230@birch.djwong.org>
 <20140402225333.GO2394@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402225333.GO2394@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 02, 2014 at 03:53:33PM -0700, Zach Brown wrote:
> > > I'd just remove this generic teardown callback path entirely.  If
> > > there's PI state hanging off the iocb tear it down during iocb teardown.
> > 
> > Hmm, I thought aio_complete /was/ iocb teardown time.
> 
> Well, usually :).  If you build up before aio_run_iocb() then you nead
> to teardown in kiocb_free(), which is also called by aio_complete().

Oh, yeah.  I handle that by tearing down the extensions if stuff fails, though
I don't remember if that was in this version of the patchset.

> > > (Isn't there some allocate-and-copy-from-userspace helper now? But..)
> > 
> > <shrug> Is there?  I didn't find one when I looked, but it wasn't an exhaustive
> > search.
> 
> I could have sworn that I saw something.. ah, right, memdup_user().

Noted. :)

> > > I don't like the rudundancy of the implicit size requirement by a
> > > field's flag being set being duplicated by the explicit size argument.
> > > What does that give us, exactly?
> > 
> > Either another sanity check or another way to screw up, depending on how you
> > look at it.  I'd been considering shortening the size field to u32 and adding a
> > magic number field, but I wonder if that's really necessary.  Seems like it
> > shouldn't be -- if userland screws up, it's not hard to kill the process.
> > (Or segv it, or...)
> 
> I don't think I'd bother.  The bits should be enough and are already
> necessary to have explicit indicators of fields being set.

<nod>

> > > Fields in the iocb  As each of these are initialized I'd just
> > > test the presence bits and __get_user() the userspace arguemnts
> > > directly, or copy_from_user() something slightly more complicated on to
> > > the stack.
> > >
> > > That gets rid of us having to care about the size at all.  It stops us
> > > from allocating a kernel copy and pinning it for the duration of the IO.
> > > We'd just be sampling the present userspace arguments as we initialie
> > > the iocb during submission.
> > 
> > I like this idea.  For the PI extension, nothing particularly error-prone
> > happens in teardown, which allows the flexibility to copy_from_user any
> > arguments required, and to copy_to_user any setup errors that happen.  I can
> > get rid a lot of allocate-and-copy nonsense, as you point out.
> > 
> > Ok, I'll migrate my patches towards this strategy, and let's see how much code
> > goes away. :)
> 
> Cool :).
> 
> > I've also noticed a bug where if you make one of these PI-extended calls on a
> > file living on a filesystem, it'll extend the io request's range to be
> > filesystem block-aligned, which causes all kinds of havoc with the user
> > provided PI buffers, since they now need to be extended to fit the added
> > blocks.  Alternately, one could require PI IOs to be fs-block aligned when
> > dealing with regular files. 
> 
> I think, like O_DIRECT, it just has to be aligned or fail :(.

Heh.  O_DIRECT is a hilarious maze of twisty unobvious requirements.  Yuck.

#define O_IMNAIVEENOUGHTOTHINKIKNOWWHATTHISDOES	O_DIRECT

--D
> 
> - z
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
