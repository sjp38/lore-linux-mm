Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 52BA56B0037
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 18:14:13 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id q10so4847410pdj.10
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 15:14:12 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id qx4si12126476pbc.15.2014.01.31.15.14.11
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 15:14:11 -0800 (PST)
Message-ID: <1391210041.2172.52.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [LSF/MM TOPIC] Fixing large block devices on 32 bit
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 31 Jan 2014 15:14:01 -0800
In-Reply-To: <52EC13A0.2080806@fb.com>
References: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com>
	 <52EC13A0.2080806@fb.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: linux-scsi <linux-scsi@vger.kernel.org>, linux-ide <linux-ide@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Fri, 2014-01-31 at 16:20 -0500, Chris Mason wrote:
> On 01/31/2014 02:02 PM, James Bottomley wrote:
> > It has been reported:
> >
> > http://marc.info/?t=139111447200006
> >
> > That large block devices (specifically devices > 16TB) crash when
> > mounted on 32 bit systems.  The problem specifically is that although
> > CONFIG_LBDAF extends the size of sector_t within the block and storage
> > layers to 64 bits, the buffer cache isn't big enough.  Specifically,
> > buffers are mapped through a single page cache mapping on the backing
> > device inode.  The size of the allowed offset in the page cache radix
> > tree is pgoff_t which is 32 bits, so once the size of device goes beyond
> > 16TB, this offset wraps and all hell breaks loose.
> >
> > The problem is that although the current single drive limit is about
> > 4TB, it will only be a couple of years before 16TB devices are
> > available.  By then, I bet that most arm (and other exotic CPU) Linux
> > based personal file servers are still going to be 32 bit, so they're not
> > going to be able to take this generation (or beyond) of drives.  The
> > thing I'd like to discuss is how to fix this.  There are several options
> > I see, but there might be others.
> >
> >       1. Try to pretend that CONFIG_LBDAF is supposed to cap out at 16TB
> >          and there's nothing we can do about it ... this won't be at all
> >          popular with arm based file server manufacturers.
> >       2. Slyly make sure that the buffer cache won't go over 16TB by
> >          keeping filesystem metadata below that limit ... the horse has
> >          probably already bolted on this one.
> >       3. Increase pgoff_t and the radix tree indexes to u64 for
> >          CONFIG_LBDAF.  This will blow out the size of struct page on 32
> >          bits by 4 bytes and may have other knock on effects, but at
> >          least it will be transparent.
> >       4. add an additional radix tree lookup within the buffer cache, so
> >          instead of a single inode for the buffer cache, we have a radix
> >          tree of them which are added and removed at the granularity of
> >          16TB offsets as entries are requested.
> >
> 
> I started typing up that #3 is going to cause problems with RCU radix, 
> but it looks ok.  I think we'll find a really scarey number of places 
> that interchange pgoff_t with unsigned long though.

Yes, beyond the performance issues of doing 64 bits in the radix tree,
it does look reasonably safe.

> I prefer #4, but it means each FS needs to add code too.  We assume 
> page_offset(page) maps to the disk in more than a few places.

Hmm, yes, that's just a few cases of the readahead code, though, isn't
it?  The necessary fixes look fairly small per filesystem.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
