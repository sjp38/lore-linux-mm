Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 889356B0253
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 11:01:23 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id bc4so102816402lbc.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 08:01:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x69si18847003lfd.16.2016.02.09.08.01.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 08:01:22 -0800 (PST)
Date: Tue, 9 Feb 2016 17:01:34 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] dax: move writeback calls into the filesystems
Message-ID: <20160209160134.GA12245@quack.suse.cz>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
 <1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4jT=yAb2_yLfMGqV1SdbQwoWQj7joroeJGAJAcjsMY_oQ@mail.gmail.com>
 <20160207215047.GJ31407@dastard>
 <CAPcyv4jNmdm-ATTBaLLLzBT+RXJ0YrxxXLYZ=T7xUgEJ8PaSKw@mail.gmail.com>
 <20160208201808.GK27429@dastard>
 <CAPcyv4iHi17pv_VC=WgEP4_GgN9OvSr8xbw1bvbEFMiQ83GbWw@mail.gmail.com>
 <20160209094353.GF9451@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
In-Reply-To: <20160209094353.GF9451@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>, jmoyer <jmoyer@redhat.com>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 09-02-16 10:43:53, Jan Kara wrote:
> On Mon 08-02-16 12:55:24, Dan Williams wrote:
> > On Mon, Feb 8, 2016 at 12:18 PM, Dave Chinner <david@fromorbit.com> wrote:
> > [..]
> > >> Setting aside the current block zeroing problem you seem to assuming
> > >> that DAX will always be faster and that may not be true at a media
> > >> level.  Waiting years for some applications to determine if DAX makes
> > >> sense for their use case seems completely reasonable.  In the meantime
> > >> the apps that are already making these changes want to know that a DAX
> > >> mapping request has not silently dropped backed to page cache.  They
> > >> also want to know if they successfully jumped through all the hoops to
> > >> get a larger than pte mapping.
> > >>
> > >> I agree it is useful to be able to force DAX on an unmodified
> > >> application to see what happens, and it follows that if those
> > >> applications want to run in that mode they will need functional
> > >> fsync()...
> > >>
> > >> I would feel better if we were talking about specific applications and
> > >> performance numbers to know if forcing DAX on application is a debug
> > >> facility or a production level capability.  You seem to have already
> > >> made that determination and I'm curious what I'm missing.
> > >
> > > I'm not setting any policy here at all.  This whole argument is
> > > based around the DAX mount option doing "global fs enable or
> > > silently turning it off" and the application not knowing about that.
> > >
> > > The whole point of having a persistent per-inode DAX flags is that
> > > it is a policy mechanism, not a policy.  The application can, if it
> > > is DAX aware, directly control whether DAX is used on a file or not.
> > > The application can even query and clear that persistent inode flag
> > > if it is configured not to (or cannot) use DAX.
> > >
> > > If the filesystem cannot support DAX, then we can error out attempts
> > > to set the DAX flag and then the app knows DAX is not available.
> > > i.e. the attempt to set policy failed. If the flag is set, then the
> > > inode will *always* use DAX - there is no "fall back to page cache"
> > > when DAX is enabled.
> > >
> > > If the applicaiton is not DAX aware, then the admin can control the
> > > DAX policy by manipulating these flags themselves, and hence control
> > > whether DAX is used by the application or not.
> > >
> > > If you think I'm dictating policy for DAX users and application,
> > > then you haven't understood anything I've previously said about why
> > > the DAX mount option needs to die before any of this is considered
> > > production ready. DAX is not an opaque "all or nothing" option. XFS
> > > will provide apps and admins with fine-grained, persistent,
> > > discoverable policy flags to allow admins and applications to set
> > > DAX policies however they see fit. This simply cannot be done if the
> > > only knob you have is a mount option that may or may not stick.
> > 
> > I agree the mount option needs to die, and I fully grok the reasoning.
> >   What I'm concerned with is that a system using fully-DAX-aware
> > applications is forced to incur the overhead of maintaining *sync
> > semantics, periodic sync(2) in particular,  even if it is not relying
> > on those semantics.
> 
> Let me somewhat correct this: IMO hard requirement is maintaining sync(2)
> semantics. Periodic writeback does not have any hard durability guarantees
> and we are free to ignore such requests in ->writepages() (that function
> has enough information in the writeback_control structure to differentiate
> between periodic writeback and data integrity sync) if we decide it is
> useful. Actually, we could do that even for 4.5.

Attached is a version of Ross' patch that will work for sync(2) and
fsync(2) and we won't flush caches during periodic writeback. The patch is
only compile-tested. Ross?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--LQksG6bCIzRHxTLp
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-dax-move-writeback-calls-into-the-filesystems.patch"


--LQksG6bCIzRHxTLp--
