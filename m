Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id F41066B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 03:27:39 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id 142so1977730ykq.2
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 00:27:39 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id v1si14481651yhg.124.2014.01.23.00.27.37
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 00:27:38 -0800 (PST)
Date: Thu, 23 Jan 2014 19:27:34 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140123082734.GP13997@dastard>
References: <52DF353D.6050300@redhat.com>
 <20140122093435.GS4963@suse.de>
 <52DFD168.8080001@redhat.com>
 <20140122143452.GW4963@suse.de>
 <52DFDCA6.1050204@redhat.com>
 <20140122151913.GY4963@suse.de>
 <1390410233.1198.7.camel@ret.masoncoding.com>
 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Chris Mason <clm@fb.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

On Wed, Jan 22, 2014 at 10:13:59AM -0800, James Bottomley wrote:
> On Wed, 2014-01-22 at 18:02 +0000, Chris Mason wrote:
> > On Wed, 2014-01-22 at 09:21 -0800, James Bottomley wrote:
> > > On Wed, 2014-01-22 at 17:02 +0000, Chris Mason wrote:
> > 
> > [ I like big sectors and I cannot lie ]
> 
> I think I might be sceptical, but I don't think that's showing in my
> concerns ...
> 
> > > > I really think that if we want to make progress on this one, we need
> > > > code and someone that owns it.  Nick's work was impressive, but it was
> > > > mostly there for getting rid of buffer heads.  If we have a device that
> > > > needs it and someone working to enable that device, we'll go forward
> > > > much faster.
> > > 
> > > Do we even need to do that (eliminate buffer heads)?  We cope with 4k
> > > sector only devices just fine today because the bh mechanisms now
> > > operate on top of the page cache and can do the RMW necessary to update
> > > a bh in the page cache itself which allows us to do only 4k chunked
> > > writes, so we could keep the bh system and just alter the granularity of
> > > the page cache.
> > > 
> > 
> > We're likely to have people mixing 4K drives and <fill in some other
> > size here> on the same box.  We could just go with the biggest size and
> > use the existing bh code for the sub-pagesized blocks, but I really
> > hesitate to change VM fundamentals for this.
> 
> If the page cache had a variable granularity per device, that would cope
> with this.  It's the variable granularity that's the VM problem.
> 
> > From a pure code point of view, it may be less work to change it once in
> > the VM.  But from an overall system impact point of view, it's a big
> > change in how the system behaves just for filesystem metadata.
> 
> Agreed, but only if we don't do RMW in the buffer cache ... which may be
> a good reason to keep it.
> 
> > > The other question is if the drive does RMW between 4k and whatever its
> > > physical sector size, do we need to do anything to take advantage of
> > > it ... as in what would altering the granularity of the page cache buy
> > > us?
> > 
> > The real benefit is when and how the reads get scheduled.  We're able to
> > do a much better job pipelining the reads, controlling our caches and
> > reducing write latency by having the reads done up in the OS instead of
> > the drive.
> 
> I agree with all of that, but my question is still can we do this by
> propagating alignment and chunk size information (i.e. the physical
> sector size) like we do today.  If the FS knows the optimal I/O patterns
> and tries to follow them, the odd cockup won't impact performance
> dramatically.  The real question is can the FS make use of this layout
> information *without* changing the page cache granularity?  Only if you
> answer me "no" to this do I think we need to worry about changing page
> cache granularity.

We already do this today.

The problem is that we are limited by the page cache assumption that
the block device/filesystem never need to manage multiple pages as
an atomic unit of change. Hence we can't use the generic
infrastructure as it stands to handle block/sector sizes larger than
a page size...

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
