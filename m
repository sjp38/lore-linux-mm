Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0A69182F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 18:36:49 -0500 (EST)
Received: by pasz6 with SMTP id z6so128318450pas.2
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 15:36:48 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id sb1si6701608pbb.154.2015.11.01.15.36.47
        for <linux-mm@kvack.org>;
        Sun, 01 Nov 2015 15:36:48 -0800 (PST)
Date: Mon, 2 Nov 2015 10:36:32 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 00/11] DAX fsynx/msync support
Message-ID: <20151101233632.GG10656@dastard>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4haGNytokPfgL3m-qOEw=BO4QF5dO3woLSYZDCRmL-YWg@mail.gmail.com>
 <20151030194300.GA22670@linux.intel.com>
 <CAPcyv4jnEF2g+tUs+ZZxzmdgacWhU=KepKQvXLfFVHri=Pj+Jg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jnEF2g+tUs+ZZxzmdgacWhU=KepKQvXLfFVHri=Pj+Jg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Fri, Oct 30, 2015 at 12:51:40PM -0700, Dan Williams wrote:
> On Fri, Oct 30, 2015 at 12:43 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > On Fri, Oct 30, 2015 at 11:34:07AM -0700, Dan Williams wrote:
> >> This is great to have when the flush-the-world solution ends up
> >> killing performance.  However, there are a couple mitigating options
> >> for workloads that dirty small amounts and flush often that we need to
> >> collect data on:
> >>
> >> 1/ Using cache management and pcommit from userspace to skip calls to
> >> msync / fsync.  Although, this does not eliminate all calls to
> >> blkdev_issue_flush as the fs may invoke it for other reasons.  I
> >> suspect turning on REQ_FUA support eliminates a number of those
> >> invocations, and pmem already satisfies REQ_FUA semantics by default.
> >
> > Sure, I'll turn on REQ_FUA in addition to REQ_FLUSH - I agree that PMEM
> > already handles the requirements of REQ_FUA, but I didn't realize that it
> > might reduce the number of REQ_FLUSH bios we receive.
> 
> I'll let Dave chime in, but a lot of the flush requirements come from
> guaranteeing the state of the metadata, if metadata updates can be
> done with REQ_FUA then there is no subsequent need to flush.

No need for cache flushes in this case, but we still need the IO
scheduler to order such operations correctly.

> >> 2/ Turn off DAX and use the page cache.  As Dave mentions [1] we
> >> should enable this control on a per-inode basis.  I'm folding in this
> >> capability as a blkdev_ioctl for the next version of the raw block DAX
> >> support patch.
> >
> > Umm...I think you just said "the way to avoid this delay is to just not use
> > DAX".  :)  I don't think this is where we want to go - we are trying to make
> > DAX better, not abandon it.
> 
> That's a bit of an exaggeration.  Avoiding DAX where it is not
> necessary is not "abandoning DAX", it's using the right tool for the
> job.  Page cache is fine for many cases.

Think btrfs - any file that uses COW can't use DAX for write.
Everything has to be buffered, unless the nodatacow flag is set, and
then DAX can be used. Indeed, on ext4 if you are using file
encryption you can't use DAX.

IOWs, we already know that we have to support mixed DAX/non-DAX
access within the same filesystem, so I'm with Dan here...

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
