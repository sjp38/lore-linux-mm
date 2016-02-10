Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 91D7D6B0254
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 17:10:13 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id l127so36623473iof.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 14:10:13 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id rt3si8064625igb.97.2016.02.10.14.10.12
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 14:10:13 -0800 (PST)
Date: Thu, 11 Feb 2016 09:09:53 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Another proposal for DAX fault locking
Message-ID: <20160210220953.GW19486@dastard>
References: <20160209172416.GB12245@quack.suse.cz>
 <CAPcyv4g1Z-2BzOfF7KAsSviMeNz+rFS1e1KR-VeE1SJxLYhNBg@mail.gmail.com>
 <20160210103249.GD12245@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160210103249.GD12245@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>

On Wed, Feb 10, 2016 at 11:32:49AM +0100, Jan Kara wrote:
> On Tue 09-02-16 10:18:53, Dan Williams wrote:
> > On Tue, Feb 9, 2016 at 9:24 AM, Jan Kara <jack@suse.cz> wrote:
> > > Hello,
> > >
> > > I was thinking about current issues with DAX fault locking [1] (data
> > > corruption due to racing faults allocating blocks) and also races which
> > > currently don't allow us to clear dirty tags in the radix tree due to races
> > > between faults and cache flushing [2]. Both of these exist because we don't
> > > have an equivalent of page lock available for DAX. While we have a
> > > reasonable solution available for problem [1], so far I'm not aware of a
> > > decent solution for [2]. After briefly discussing the issue with Mel he had
> > > a bright idea that we could used hashed locks to deal with [2] (and I think
> > > we can solve [1] with them as well). So my proposal looks as follows:
> > >
> > > DAX will have an array of mutexes (the array can be made per device but
> > > initially a global one should be OK). We will use mutexes in the array as a
> > > replacement for page lock - we will use hashfn(mapping, index) to get
> > > particular mutex protecting our offset in the mapping. On fault / page
> > > mkwrite, we'll grab the mutex similarly to page lock and release it once we
> > > are done updating page tables. This deals with races in [1]. When flushing
> > > caches we grab the mutex before clearing writeable bit in page tables
> > > and clearing dirty bit in the radix tree and drop it after we have flushed
> > > caches for the pfn. This deals with races in [2].
> > >
> > > Thoughts?
> > >
> > 
> > I like the fact that this makes the locking explicit and
> > straightforward rather than something more tricky.  Can we make the
> > hashfn pfn based?  I'm thinking we could later reuse this as part of
> > the solution for eliminating the need to allocate struct page, and we
> > don't have the 'mapping' available in all paths...
> 
> So Mel originally suggested to use pfn for hashing as well. My concern with
> using pfn is that e.g. if you want to fill a hole, you don't have a pfn to
> lock. What you really need to protect is a logical offset in the file to
> serialize allocation of underlying blocks, its mapping into page tables,
> and flushing the blocks out of caches. So using inode/mapping and offset
> for the hashing is easier (it isn't obvious to me we can fix hole filling
> races with pfn-based locking).

So how does that file+offset hash work when trying to lock different
ranges?  file+offset hashing to determine the lock to use only works
if we are dealing with fixed size ranges that the locks affect.
e.g. offset has 4k granularity for a single page faults, but we also
need to handle 2MB granularity for huge page faults, and IIRC 1GB
granularity for giant page faults...

What's the plan here?

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
