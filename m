Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0C46B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 15:32:42 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so72008492pdb.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:32:41 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id ms3si9571717pbb.228.2015.03.26.12.32.39
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 12:32:40 -0700 (PDT)
Date: Fri, 27 Mar 2015 06:32:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Should implementations of ->direct_access be allowed to sleep?
Message-ID: <20150326193224.GA28129@dastard>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com>
 <20150324185046.GA4994@whiteoak.sf.office.twttr.net>
 <20150326170918.GO4003@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326170918.GO4003@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, msharbiani@twopensource.com

On Thu, Mar 26, 2015 at 01:09:18PM -0400, Matthew Wilcox wrote:
> On Tue, Mar 24, 2015 at 11:50:47AM -0700, Matt Mullins wrote:
> > We're also developing a user of direct_access, and we ended up with some
> > questions about the sleeping guarantees of the direct_access API.
> 
> That's a great question.  Since DAX can always sleep when it's calling
> into bdev_direct_access(), I hadn't thought about it (DAX is basically
> called to handle page faults and do I/O; both of which are expected
> to sleep).
> 
> > Since brd is currently the only (x86) implementation of DAX in Linus's tree,
> > I've been testing against that.  We noticed that the brd implementation of DAX
> > can call into alloc_page() with __GFP_WAIT if we call direct_access() on a page
> > that has not yet been allocated.  This is compounded by the fact that brd does
> > not support size > PAGE_SIZE (and thus I call bdev_direct_access() on each use),
> > though the limitation makes sense -- I shouldn't expect the brd driver to be
> > able to allocate a gigabyte of contiguous memory.
> > 
> > The potential sleeping behavior was somewhat surprising to me, as I would expect
> > the NV-DIMM device implementation to simply offset the pfn at which the device
> > is located rather than perform a memory allocation.  What are the guaranteed
> > and/or expected contexts from which direct_access() can be safely called?
> 
> Yes, for 'real' NV-DIMM devices, as you can see by the ones in tree,
> as well as the pmem driver that Ross has been posting, it's a simple
> piece of arithmetic.  The question is whether we should make all users
> of ->direct_access accommodate brd, or whether we should change brd so
> that it doesn't sleep.
> 
> I'm leaning towards the latter.  But I'm not sure what GFP flags to
> recommend that brd use ... GFP_NOWAIT | __GFP_ZERO, perhaps?

What, so we get random IO failures under memory pressure?

I really think we should allow .direct_access to sleep. It means we
can use existing drivers and it also allows future implementations
that might require, say, RDMA to be performed to update a page
before access is granted. i.e. .direct_access is the first hook into
the persistent device at page fault time....

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
