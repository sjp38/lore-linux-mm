Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 00DD56B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 19:58:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s8so4594728pgf.16
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 16:58:54 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id d23si1539569pgn.683.2018.03.09.16.58.52
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 16:58:53 -0800 (PST)
Date: Sat, 10 Mar 2018 11:58:50 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: fallocate on XFS for swap
Message-ID: <20180310005850.GW18129@dastard>
References: <8C28C1CB-47F1-48D1-85C9-5373D29EA13E@amazon.com>
 <20180309234422.GA4860@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180309234422.GA4860@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: "Besogonov, Aleksei" <cyberax@amazon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xfs <linux-xfs@vger.kernel.org>

On Fri, Mar 09, 2018 at 03:44:22PM -0800, Darrick J. Wong wrote:
> [you really ought to cc the xfs list]
> 
> On Fri, Mar 09, 2018 at 10:05:24PM +0000, Besogonov, Aleksei wrote:
> > Hi!
> > 
> > Wea??re working at Amazon on making XFS our default root filesystem for
> > the upcoming Amazon Linux 2 (now in prod preview). One of the problems
> > that wea??ve encountered is inability to use fallocated files for swap
> > on XFS. This is really important for us, since wea??re shipping our
> > current Amazon Linux with hibernation support .
> 
> <shudder>
> 
> > Ia??ve traced the problem to bmap(), used in generic_swapfile_activate
> > call, which returns 0 for blocks inside holes created by fallocate and
> > Dave Chinner confirmed it in a private email. Ia??m thinking about ways
> > to fix it, so far I see the following possibilities:
> > 
> > 1. Change bmap() to not return zeroes for blocks inside holes. But
> > this is an ABI change and it likely will break some obscure userspace
> > utility somewhere.
> 
> bmap is a horrible interface, let's leave it to wither and eventually go
> away.
> 
> > 2. Change generic_swap_activate to use a more modern interface, by
> > adding fiemap-like operation to address_space_operations with fallback
> > on bmap().
> 
> Probably the best idea, but see fs/iomap.c since we're basically leasing
> a chunk of file space to the kernel.  Leasing space to a user that wants
> direct access is becoming rather common (rdma, map_sync, etc.)

thing is, we don't want in-kernel users of fiemap. We've got other
block mapping interfaces that can be used, such as iomap...

> > 3. Add an XFS-specific implementation of swapfile_activate.
> 
> Ugh no.

What we want is an iomap-based re-implementation of
generic_swap_activate(). One of the ways to plumb that in is to
use ->swapfile_activate() like so:

iomap_swapfile_activate()
{
	return iomap_apply(... iomap_swapfile_add_extent, ...)
}

xfs_vm_swapfile_activate()
{
	return iomap_swapfile_activate(xfs_iomap_ops);
}

	.swapfile_activate = xfs_vm_swapfile_activate()

And massage the swapfile_activate callout be friendly to fragmented
files. i.e. change the nfs caller to run a
"add_single_swap_extent()" caller rather than have to do it in the
generic code on return....

IOWs, I think the choices we have are to either re-implement
generic_swapfile_activate() and then be stuck with using get_block
style interfaces forever in XFS, or we use the filesystem specific
callout to implement more advanced generic support using the
filesystem supplied get_block/iomap interfaces for block mapping
like we do for everything else that the VM needs the filesystem to
do....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
