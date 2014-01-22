Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 02DB26B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 16:05:28 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e53so31357eek.13
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:05:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si19843968eem.187.2014.01.22.13.05.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 13:05:27 -0800 (PST)
Date: Wed, 22 Jan 2014 22:05:24 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140122210524.GA27916@quack.suse.cz>
References: <20131220093022.GV11295@suse.de>
 <52DF353D.6050300@redhat.com>
 <20140122093435.GS4963@suse.de>
 <1390403770.1198.4.camel@ret.masoncoding.com>
 <1390406584.2372.7.camel@dabdike.int.hansenpartnership.com>
 <52DFF5A8.1090002@redhat.com>
 <1390410033.2372.28.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390410033.2372.28.camel@dabdike.int.hansenpartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Ric Wheeler <rwheeler@redhat.com>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Chris Mason <clm@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mgorman@suse.de" <mgorman@suse.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Wed 22-01-14 09:00:33, James Bottomley wrote:
> On Wed, 2014-01-22 at 11:45 -0500, Ric Wheeler wrote:
> > On 01/22/2014 11:03 AM, James Bottomley wrote:
> > > On Wed, 2014-01-22 at 15:14 +0000, Chris Mason wrote:
> > >> On Wed, 2014-01-22 at 09:34 +0000, Mel Gorman wrote:
> > >>> On Tue, Jan 21, 2014 at 10:04:29PM -0500, Ric Wheeler wrote:
> > >>>> One topic that has been lurking forever at the edges is the current
> > >>>> 4k limitation for file system block sizes. Some devices in
> > >>>> production today and others coming soon have larger sectors and it
> > >>>> would be interesting to see if it is time to poke at this topic
> > >>>> again.
> > >>>>
> > >>> Large block support was proposed years ago by Christoph Lameter
> > >>> (http://lwn.net/Articles/232757/). I think I was just getting started
> > >>> in the community at the time so I do not recall any of the details. I do
> > >>> believe it motivated an alternative by Nick Piggin called fsblock though
> > >>> (http://lwn.net/Articles/321390/). At the very least it would be nice to
> > >>> know why neither were never merged for those of us that were not around
> > >>> at the time and who may not have the chance to dive through mailing list
> > >>> archives between now and March.
> > >>>
> > >>> FWIW, I would expect that a show-stopper for any proposal is requiring
> > >>> high-order allocations to succeed for the system to behave correctly.
> > >>>
> > >> My memory is that Nick's work just didn't have the momentum to get
> > >> pushed in.  It all seemed very reasonable though, I think our hatred of
> > >> buffered heads just wasn't yet bigger than the fear of moving away.
> > >>
> > >> But, the bigger question is how big are the blocks going to be?  At some
> > >> point (64K?) we might as well just make a log structured dm target and
> > >> have a single setup for both shingled and large sector drives.
> > > There is no real point.  Even with 4k drives today using 4k sectors in
> > > the filesystem, we still get 512 byte writes because of journalling and
> > > the buffer cache.
> > 
> > I think that you are wrong here James. Even with 512 byte drives, the IO's we 
> > send down tend to be 4k or larger. Do you have traces that show this and details?
> 
> It's mostly an ext3 journalling issue ... and it's only metadata and
> mostly the ioschedulers can elevate it into 4k chunks, so yes, most of
> our writes are 4k+, so this is a red herring, yes.
  ext3 (similarly as ext4) does block level journalling meaning that it
journals *only* full blocks. So an ext3/4 filesystem with 4 KB blocksize
will never journal anything else than full 4 KB blocks. So I'm not sure
where this 512-byte writes idea came from..

> > Also keep in mind that larger block sizes allow us to track larger
> > files with 
> > smaller amounts of metadata which is a second win.
> 
> Larger file block sizes are completely independent from larger device
> block sizes (we can have 16k file block sizes on 4k or even 512b
> devices).  The questions on larger block size devices are twofold:
> 
>      1. If manufacturers tell us that they'll only support I/O on the
>         physical sector size, do we believe them, given that they said
>         this before on 4k and then backed down.  All the logical vs
>         physical sector stuff is now in T10 standards, why would they
>         try to go all physical again, especially as they've now all
>         written firmware that does the necessary RMW?
>      2. If we agree they'll do RMW in Firmware again, what do we have to
>         do to take advantage of larger sector sizes beyond what we
>         currently do in alignment and chunking?  There may still be
>         issues in FS journal and data layouts.
  I also believe drives will support smaller-than-blocksize writes. But
supporting larger fs blocksize can sometimes be beneficial for other
reasons (think performance with specialized workloads because amount of
metadata is smaller, fragmentation is smaller, ...). Currently ocfs2, ext4,
and possibly others go through the hoops to support allocating file data in
chunks larger than fs blocksize - at the first sight that should be
straightforward but if you look at the code you find out there are nasty
corner cases which make it pretty ugly. And each fs doing these large data
allocations currently invents its own way to deal with the problems. So
providing some common infrastructure for dealing with blocks larger than
page size would definitely relieve some pain.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
