Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 657AB6B0071
	for <linux-mm@kvack.org>; Sat, 22 Mar 2014 05:43:28 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so3403471pbc.21
        for <linux-mm@kvack.org>; Sat, 22 Mar 2014 02:43:28 -0700 (PDT)
Date: Sat, 22 Mar 2014 02:43:20 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 0/5] userspace PI passthrough via AIO/DIO
Message-ID: <20140322094320.GD9074@birch.djwong.org>
References: <20140321043041.8428.79003.stgit@birch.djwong.org>
 <20140321182332.GP10561@lenny.home.zabbo.net>
 <20140321214410.GE23173@kvack.org>
 <20140321225437.GB9074@birch.djwong.org>
 <20140322002909.GT10561@lenny.home.zabbo.net>
 <20140322023216.GC9074@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140322023216.GC9074@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>, axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 21, 2014 at 07:32:16PM -0700, Darrick J. Wong wrote:
> On Fri, Mar 21, 2014 at 05:29:09PM -0700, Zach Brown wrote:
> > On Fri, Mar 21, 2014 at 03:54:37PM -0700, Darrick J. Wong wrote:
> > > On Fri, Mar 21, 2014 at 05:44:10PM -0400, Benjamin LaHaise wrote:
> > >
> > > > I'm inclined to agree with Zach on this item.  Ultimately, we need an 
> > > > extensible data structure that can be grown without completely revising 
> > > > the ABI as new parameters are added.  We need something that is either 
> > > > TLV based, or an extensible array.
> > > 
> > > Ok.  Let's define IOCB_FLAG_EXTENSIONS as an iocb.aio_flags flag to indicate
> > > that this struct iocb has extensions attached to it.  Then, iocb.aio_reserved2
> > > becomes a pointer to an array of extension descriptors, and iocb.aio_reqprio
> > > becomes a u16 that tells us the array length.  The libaio.h equivalents are
> > > iocb.u.c.flags, iocb.u.c.__pad3, and iocb.aio_reqprio, respectively.
> > > 
> > > Next, let's define a conceptual structure for aio extensions:
> > > 
> > > struct iocb_extension {
> > > 	void *ie_buf;
> > > 	unsigned int ie_buflen;
> > > 	unsigned int ie_type;
> > > 	unsigned int ie_flags;
> > > };
> > > 
> > > The actual definitions can be defined in a similar fashion to the other aio
> > > structures so that the structures are padded to the same layout regardless of
> > > bitness.  As mentioned above, iocb.aio_reserved2 points to an array of these.
> > 
> > I'm firmly in the camp that doesn't want to go down this abstract road.
> > We had this conversation with Kent when he wanted to do something very
> > similar.
> 
> Could you point me to this discussion?  I'd like to read it.

Is it "[RFC, PATCH] Extensible AIO interface"?
http://lkml.iu.edu//hypermail/linux/kernel/1210.0/00651.html 

Regrettably that discussion happened right during that period where I was
pleasantly AWOL from work for a few months. :)

Will read ... tomorrow.

> > What happens if there are duplicate ie_types?  Is that universally
> > prohibited, validity left up to the types that are duplicated?
> 
> Yes.
> 
> > What if the len is not the right size?  Who checks that?
> 
> The extension driver, presumably.
> 
> >  What if the extension (they're arguments, but one thing at a time) is
> >  writable and the buf pointers overlap or is unaligned?  Is that cool, who
> >  checks it?
> 
> Each extension driver has to check the alignment.  I don't know what to do
> about buffer pointer overlap; if you want to shoot yourself in the foot that's
> fine with me.
> 
> > Who defines the acceptable set?

(This was an "I don't know", for anyone who cares.)

> 
> >  Can drivers make up their own weird types?
> 
> How do you mean?  As far as whatever's in the ie_buf, I think that depends on
> the extension.
> 
> >  How does strace print all this?  How does the security module universe
> >  declare policies that can forbid or allow these things?
> 
> I don't know.
> 
> > Personally, I think this level of dynamism is not worth the complexity.
> > 
> > Can we instead just have a nice easy struct with fixed members that only
> > grows?
> > 
> > struct some_more_args {
> > 	u64 has; /* = HAS_PI_VEC; */
> > 	u64 pi_vec_ptr;
> > 	u64 pi_vec_nr_segs;
> > };
> > 
> > struct some_more_args {
> > 	u64 has; /* = HAS_PI_VEC | HAS_MAGIC_THING */
> > 	u64 pi_vec_ptr;
> > 	u64 pi_vec_nr_segs;
> > 	u64 magic_thing;
> > };
> > 
> > If it only grows and has bits indicating presence then I think we're
> > good.   You only fetch the space for the bits that are indicated.  You
> > can return errors for bits you don't recognize.  You could perhaps offer
> > some way to announce the bits you recognize.
> 
> <shrug> I was gonna just -EINVAL for types we don't recognize, or which don't
> apply in this scenario.
> 
> > I'll admit, though, that I don't really like having to fetch the 'has'
> > bits first to find out how large the rest of the struct is.  Maybe
> > that's not worth worrying about.
> 
> I'm not worrying about having to pluck 'has' out of the structure, but needing
> a function to tell me how big of a buffer I need for a given pile of flags
> seems ... icky.  But maybe the ease of modifying strace and security auditors
> would make it worth it?

How about explicitly specifying the structure size in struct some_more_args,
and checking that against whatever we find in .has?  Hm.  I still think that's
too clever for my brain to keep together for long.

I'm also nervous that we could be creating this monster of a structure wherein
some user wants to tack the first and last hints ever created onto an IO, so
now we have to lug this huge structure around that has space for hints that
we're not going to use, and most of which is zeroes.

I think it would be easy to add one of these interfaces to the regular
{read,write}{,v} calls too.

--D
> 
> > Thoughts?  Am I out to lunch here?
> 
> I don't have a problem adopting your design, aside from the complications of
> figuring out how big struct some_more_args really is.
> 
> > > Question: Do we want to allow ie_buf to be struct iovec[]?  Can we leave that
> > > to the extension designer to decide if they want to support either a S-G list,
> > > one big (vaddr) buffer, or toggle flags?
> > 
> > No idea.  Either seems doable.  I'd aim for simpler to reduce the number
> > of weird cases to handle or forbid (iovecs with a byte per page!) unless
> > Martin thinks people want to vector the PI goo.
> 
> For now I'll leave it as a simple buffer until I hear otherwise.
> 
> > > I think so.  Let's see how much we can get done.
> > 
> > FWIW, I'm happy to chat about this in person at LSF next week.  I'll be
> > around.
> 
> Me too!
> 
> --D
> > 
> > - z
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
