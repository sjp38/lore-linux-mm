Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 418836B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 19:13:16 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id yy13so19733349pab.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 16:13:16 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fd9si8290621pad.134.2016.02.10.16.13.15
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 16:13:15 -0800 (PST)
Date: Wed, 10 Feb 2016 17:13:00 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: Another proposal for DAX fault locking
Message-ID: <20160211001300.GB19534@linux.intel.com>
References: <20160209172416.GB12245@quack.suse.cz>
 <20160210234406.GD30938@linux.intel.com>
 <CALXu0UfnUzDFyS1DNHoimpWXRiCHKeM7ysP2v5evrtVVgj=s2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALXu0UfnUzDFyS1DNHoimpWXRiCHKeM7ysP2v5evrtVVgj=s2Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>

On Thu, Feb 11, 2016 at 12:51:05AM +0100, Cedric Blancher wrote:
> There is another "twist" in this game: If there is a huge page with
> 1GB with a small 4k page as "overlay" (e.g. mmap() MAP_FIXED somewhere
> in the middle of a 1GB huge page), hows that handled?

Ugh - I'm pretty sure we haven't touched overlays with DAX at all.

The man page says this:

  If the memory region specified by addr and len overlaps pages of any
  existing mapping(s), then the overlapped part of the existing mapping(s)
  will be discarded.

I wonder if this would translate into a hole punch for our DAX mapping,
whatever size it may be, plus an insert?

If so, it seems like we just need to handle each of those operations correctly
on their own (hole punch, insert), and things will take care of themselves?

That being said, I know for a fact that PMD hole punch is currently broken.

> On 11 February 2016 at 00:44, Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> > On Tue, Feb 09, 2016 at 06:24:16PM +0100, Jan Kara wrote:
> >> Hello,
> >>
> >> I was thinking about current issues with DAX fault locking [1] (data
> >> corruption due to racing faults allocating blocks) and also races which
> >> currently don't allow us to clear dirty tags in the radix tree due to races
> >> between faults and cache flushing [2]. Both of these exist because we don't
> >> have an equivalent of page lock available for DAX. While we have a
> >> reasonable solution available for problem [1], so far I'm not aware of a
> >> decent solution for [2]. After briefly discussing the issue with Mel he had
> >> a bright idea that we could used hashed locks to deal with [2] (and I think
> >> we can solve [1] with them as well). So my proposal looks as follows:
> >>
> >> DAX will have an array of mutexes (the array can be made per device but
> >> initially a global one should be OK). We will use mutexes in the array as a
> >> replacement for page lock - we will use hashfn(mapping, index) to get
> >> particular mutex protecting our offset in the mapping. On fault / page
> >> mkwrite, we'll grab the mutex similarly to page lock and release it once we
> >> are done updating page tables. This deals with races in [1]. When flushing
> >> caches we grab the mutex before clearing writeable bit in page tables
> >> and clearing dirty bit in the radix tree and drop it after we have flushed
> >> caches for the pfn. This deals with races in [2].
> >>
> >> Thoughts?
> >>
> >>                                                               Honza
> >>
> >> [1] http://oss.sgi.com/archives/xfs/2016-01/msg00575.html
> >> [2] https://lists.01.org/pipermail/linux-nvdimm/2016-January/004057.html
> >
> > Overall I think this sounds promising.  I think a potential tie-in with the
> > radix tree would maybe take us in a good direction.
> >
> > I had another idea of how to solve race #2 that involved sticking a seqlock
> > around the DAX radix tree + pte_mkwrite() sequence, and on the flushing side
> > if you noticed that you've raced against a page fault, just leaving the dirty
> > page tree entry intact.
> >
> > I *think* this could work - I'd want to bang on it more - but if we have a
> > general way of handling DAX locking that we can use instead of solving these
> > issues one-by-one as they come up, that seems like a much better route.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
> -- 
> Cedric Blancher <cedric.blancher@gmail.com>
> Institute Pasteur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
