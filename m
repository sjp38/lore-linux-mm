Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFF516B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 15:48:45 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j83so534016qkh.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:48:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f1si3905983qtk.199.2017.09.26.12.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 12:48:44 -0700 (PDT)
Date: Tue, 26 Sep 2017 12:48:30 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 1/7] xfs: always use DAX if mount option is used
Message-ID: <20170926194830.GI5020@magnolia>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-2-ross.zwisler@linux.intel.com>
 <20170925233812.GM10955@dastard>
 <20170926093548.GB13627@quack2.suse.cz>
 <20170926110957.GR10955@dastard>
 <20170926143743.GB18758@lst.de>
 <20170926173057.GB20159@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926173057.GB20159@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Dan Williams <dan.j.williams@intel.com>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 11:30:57AM -0600, Ross Zwisler wrote:
> On Tue, Sep 26, 2017 at 04:37:43PM +0200, Christoph Hellwig wrote:
> > On Tue, Sep 26, 2017 at 09:09:57PM +1000, Dave Chinner wrote:
> > > Well, quite frankly, I never wanted the mount option for XFS. It was
> > > supposed to be for initial testing only, then we'd /always/ use the
> > > the inode flags. For a filesystem to default to using DAX, we
> > > set the DAX flag on the root inode at mkfs time, and then everything
> > > inode flag based just works.
> > 
> > And I deeply fundamentally disagree.  The mount option is a nice
> > enough big hammer to try a mode without encoding nitty gritty details
> > into the application ABI.
> > 
> > The per-inode persistent flag is the biggest nightmare ever, as we see
> > in all these discussions about it.
> > 
> > What does it even mean?  Right now it forces direct addressing as long
> > as the underlying media supports that.  But what about media that
> > you directly access but you really don't want to because it's really slow?
> > Or media that is so god damn fast that you never want to buffer?  Or
> > media where you want to buffer for writes (or at least some of them)
> > but not for reads?
> > 
> > It encodes a very specific mechanism for an early direct access
> > implementation into the ABI.  What we really need is for applications
> > to declare an intent, not specify a particular mechanism.
> 
> I agree that Christoph's idea about having the system intelligently adjust to
> use DAX based on performance information it gathers about the underlying
> persistent memory (probably via the HMAT on x86_64 systems) is interesting,
> but I think we're still a ways away from that.
> 
> FWIW, as my patches suggest and Jan observed I think that we should allow
> users to turn on DAX by treating the inode flag and the mount flag as an 'or'
> operation.  i.e. you get DAX if either the mount option is specified or if the
> inode flag is set, and you can continue to manipulate the per-inode flag as
> you want regardless of the mount option.  I think this provides maximum
> flexibility of the mechanism to select DAX without enforcing policy.
> 
> In the end, though, I think what's really important is that we figure out what
> the various options mean, have the same story for both XFS and ext4, and
> document it as hch suggested in response to my patch 7 in this series.

Agreed.  We have a fundamental conflict between letting the sysadmin or
user decide how they want an inode to behave vs. letting the kernel make
all the decisions based on whatever information it gathers.

I'm pulled this patch out of -fixes and for-next because I feel strongly
discouraged about taking any more patches that change the user-control
parts of the DAX implementation until we reach a consensus on what to
do.

Given that DAX and pmem support in filesystems is still experimental,
I'm open to changing the interface as needed.  Where do we think we'll
be in a few years once ACPI or whatever reaches the point of being able
to tell the kernel about the general performance characteristics of the
pmem?  What choices about the interface do we need to make now so that
we can get there while minimizing the number of insufficient interfaces
to deprecate?

My personal guess is that most programs will not care enough to want to
make a syscall so we might as well give them the most performant option
available.

Roughly speaking, here are the use cases I can think of:

 * Regular buffered read/write: we can let the kernel decide if it wants
   to push the IO through the page cache, directly access the pmem, or
   some future combination of the two.

 * O_DIRECT read/write: Straight to pmem.

 * Regular mmap: This seems fairly agnostic to how we actually make the
   memory mapping work, right?

 * MAP_DIRECT/MAP_SYNC mmap: If userspace actually goes to the trouble
   of making sure the whole range is allocated and pre-written and uses
   these flags then they get direct access.

I've wondered off and on if an acceptable solution is to define a number
of things surrounding an inode for which XFS /could/ optimize, and let
the user tell us which one thing matters most to them: total manual
control over everything like we do now, sequential io, random io,
fastest mmap access possible, most direct access to storage, etc.
If you set a hint other than full manual control then XFS reserves the
right to change inode flags at any time to satisfy the hint.

For the most part I'm in favor of Christoph's suggestion to let the
kernel decide on its own, and I don't see the point in encoding details
of the storage medium access strategy on the disk, particularly since
filesystems are supposed to be fairly independent of storage.  But
frankly, so many people have asked me over the years if there's some way
to influence the decision-making that I won't quite let go of file hints
as a way to influence the decisions XFS makes around storage media.

> Does it make sense at this point to just start a "dax" man page that can
> contain info about the mount options, inode flags, kernel config options, how
> to get PMDs, etc?  Or does this documentation need to be sprinkled around more
> in existing man pages?

Personally it'd be a lot easier to tell internal groups to go look at a
single documentation page that discusses everything you'd want to know
about enabling dax -- how to control it, how to make large page table
entries work, etc.  Some of those things will get into fs internals,
however, which probably belong in the ext4/xfs manpages.  I suggest
laying out the general details in a single dax manpage and pointing
people at each fs's documentation for specific details.

--D

> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
