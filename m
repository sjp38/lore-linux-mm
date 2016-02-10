Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id ADDBA6B0254
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 05:32:35 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so20368615wme.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 02:32:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q10si3687404wjo.159.2016.02.10.02.32.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 02:32:34 -0800 (PST)
Date: Wed, 10 Feb 2016 11:32:49 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Another proposal for DAX fault locking
Message-ID: <20160210103249.GD12245@quack.suse.cz>
References: <20160209172416.GB12245@quack.suse.cz>
 <CAPcyv4g1Z-2BzOfF7KAsSviMeNz+rFS1e1KR-VeE1SJxLYhNBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g1Z-2BzOfF7KAsSviMeNz+rFS1e1KR-VeE1SJxLYhNBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>

On Tue 09-02-16 10:18:53, Dan Williams wrote:
> On Tue, Feb 9, 2016 at 9:24 AM, Jan Kara <jack@suse.cz> wrote:
> > Hello,
> >
> > I was thinking about current issues with DAX fault locking [1] (data
> > corruption due to racing faults allocating blocks) and also races which
> > currently don't allow us to clear dirty tags in the radix tree due to races
> > between faults and cache flushing [2]. Both of these exist because we don't
> > have an equivalent of page lock available for DAX. While we have a
> > reasonable solution available for problem [1], so far I'm not aware of a
> > decent solution for [2]. After briefly discussing the issue with Mel he had
> > a bright idea that we could used hashed locks to deal with [2] (and I think
> > we can solve [1] with them as well). So my proposal looks as follows:
> >
> > DAX will have an array of mutexes (the array can be made per device but
> > initially a global one should be OK). We will use mutexes in the array as a
> > replacement for page lock - we will use hashfn(mapping, index) to get
> > particular mutex protecting our offset in the mapping. On fault / page
> > mkwrite, we'll grab the mutex similarly to page lock and release it once we
> > are done updating page tables. This deals with races in [1]. When flushing
> > caches we grab the mutex before clearing writeable bit in page tables
> > and clearing dirty bit in the radix tree and drop it after we have flushed
> > caches for the pfn. This deals with races in [2].
> >
> > Thoughts?
> >
> 
> I like the fact that this makes the locking explicit and
> straightforward rather than something more tricky.  Can we make the
> hashfn pfn based?  I'm thinking we could later reuse this as part of
> the solution for eliminating the need to allocate struct page, and we
> don't have the 'mapping' available in all paths...

So Mel originally suggested to use pfn for hashing as well. My concern with
using pfn is that e.g. if you want to fill a hole, you don't have a pfn to
lock. What you really need to protect is a logical offset in the file to
serialize allocation of underlying blocks, its mapping into page tables,
and flushing the blocks out of caches. So using inode/mapping and offset
for the hashing is easier (it isn't obvious to me we can fix hole filling
races with pfn-based locking).

I'm not sure for which other purposes you'd like to use this lock and
whether propagating file+offset to those call sites would make sense or
not. struct page has the advantage that block mapping information is only
attached to it, so when filling a hole, we can just allocate some page,
attach it to the radix tree, use page lock for synchronization, and allocate
blocks only after that. With pfns we cannot do this...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
