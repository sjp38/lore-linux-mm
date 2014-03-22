Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 94C3D6B028C
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 20:29:12 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id i17so3712630qcy.28
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 17:29:12 -0700 (PDT)
Date: Fri, 21 Mar 2014 17:29:09 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [RFC PATCH 0/5] userspace PI passthrough via AIO/DIO
Message-ID: <20140322002909.GT10561@lenny.home.zabbo.net>
References: <20140321043041.8428.79003.stgit@birch.djwong.org>
 <20140321182332.GP10561@lenny.home.zabbo.net>
 <20140321214410.GE23173@kvack.org>
 <20140321225437.GB9074@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140321225437.GB9074@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>, axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 21, 2014 at 03:54:37PM -0700, Darrick J. Wong wrote:
> On Fri, Mar 21, 2014 at 05:44:10PM -0400, Benjamin LaHaise wrote:
>
> > I'm inclined to agree with Zach on this item.  Ultimately, we need an 
> > extensible data structure that can be grown without completely revising 
> > the ABI as new parameters are added.  We need something that is either 
> > TLV based, or an extensible array.
> 
> Ok.  Let's define IOCB_FLAG_EXTENSIONS as an iocb.aio_flags flag to indicate
> that this struct iocb has extensions attached to it.  Then, iocb.aio_reserved2
> becomes a pointer to an array of extension descriptors, and iocb.aio_reqprio
> becomes a u16 that tells us the array length.  The libaio.h equivalents are
> iocb.u.c.flags, iocb.u.c.__pad3, and iocb.aio_reqprio, respectively.
> 
> Next, let's define a conceptual structure for aio extensions:
> 
> struct iocb_extension {
> 	void *ie_buf;
> 	unsigned int ie_buflen;
> 	unsigned int ie_type;
> 	unsigned int ie_flags;
> };
> 
> The actual definitions can be defined in a similar fashion to the other aio
> structures so that the structures are padded to the same layout regardless of
> bitness.  As mentioned above, iocb.aio_reserved2 points to an array of these.

I'm firmly in the camp that doesn't want to go down this abstract road.
We had this conversation with Kent when he wanted to do something very
similar.

What happens if there are duplicate ie_types?  Is that universally
prohibited, validity left up to the types that are duplicated?  What if
the len is not the right size?  Who checks that?  What if the extension
(they're arguments, but one thing at a time) is writable and the buf
pointers overlap or is unaligned?  Is that cool, who checks it?

Who defines the acceptable set?  Can drivers make up their own weird
types?  How does strace print all this?  How does the security module
universe declare policies that can forbid or allow these things?

Personally, I think this level of dynamism is not worth the complexity.

Can we instead just have a nice easy struct with fixed members that only
grows?

struct some_more_args {
	u64 has; /* = HAS_PI_VEC; */
	u64 pi_vec_ptr;
	u64 pi_vec_nr_segs;
};

struct some_more_args {
	u64 has; /* = HAS_PI_VEC | HAS_MAGIC_THING */
	u64 pi_vec_ptr;
	u64 pi_vec_nr_segs;
	u64 magic_thing;
};

If it only grows and has bits indicating presence then I think we're
good.   You only fetch the space for the bits that are indicated.  You
can return errors for bits you don't recognize.  You could perhaps offer
some way to announce the bits you recognize.

I'll admit, though, that I don't really like having to fetch the 'has'
bits first to find out how large the rest of the struct is.  Maybe
that's not worth worrying about.

Thoughts?  Am I out to lunch here?

> Question: Do we want to allow ie_buf to be struct iovec[]?  Can we leave that
> to the extension designer to decide if they want to support either a S-G list,
> one big (vaddr) buffer, or toggle flags?

No idea.  Either seems doable.  I'd aim for simpler to reduce the number
of weird cases to handle or forbid (iovecs with a byte per page!) unless
Martin thinks people want to vector the PI goo.

> I think so.  Let's see how much we can get done.

FWIW, I'm happy to chat about this in person at LSF next week.  I'll be
around.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
