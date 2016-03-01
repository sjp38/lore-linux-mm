Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 330686B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 16:44:06 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id bj10so50267898pad.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 13:44:06 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id ny6si52865047pab.59.2016.03.01.13.44.05
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 13:44:05 -0800 (PST)
Date: Tue, 1 Mar 2016 16:44:03 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301214403.GJ3730@linux.intel.com>
References: <20160301070911.GD3730@linux.intel.com>
 <20160301102541.GD27666@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301102541.GD27666@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 01, 2016 at 11:25:41AM +0100, Jan Kara wrote:
> On Tue 01-03-16 02:09:11, Matthew Wilcox wrote:
> > There are a few issues around 1GB THP support that I've come up against
> > while working on DAX support that I think may be interesting to discuss
> > in person.
> > 
> >  - Do we want to add support for 1GB THP for anonymous pages?  DAX support
> >    is driving the initial 1GB THP support, but would anonymous VMAs also
> >    benefit from 1GB support?  I'm not volunteering to do this work, but
> >    it might make an interesting conversation if we can identify some users
> >    who think performance would be better if they had 1GB THP support.
> 
> Some time ago I was thinking about 1GB THP and I was wondering: What is the
> motivation for 1GB pages for persistent memory? Is it the savings in memory
> used for page tables? Or is it about the cost of fault?

I think it's both.  I heard from one customer who calculated that with
a 6TB server, mapping every page into a process would take ~24MB of
page tables.  Multiply that by the 50,000 processes they expect to run
on a server of that size consumes 1.2TB of DRAM.  Using 1GB pages reduces
that by a factor of 512, down to 2GB.

Another topic to consider then would be generalising the page table
sharing code that is currently specific to hugetlbfs.  I didn't bring
it up as I haven't researched it in any detail, and don't know how hard
it would be.

> For your multi-order entries I was wondering whether we shouldn't relax the
> requirement that all nodes have the same number of slots - e.g. we could
> have number of slots variable with node depth so that PMD and eventually PUD
> multi-order slots end up being a single entry at appropriate radix tree
> level.

I'm not a big fan of the sibling entries either :-)  One thing I do
wonder is whether anyone has done performance analysis recently of
whether 2^6 is the right size for radix tree nodes?  If it used 2^9,
this would be a perfect match to x86 page tables ;-)

Variable size is a bit painful because we've got two variable size arrays
in the node; the array of node pointers and the tag bitmasks.  And then
we lose the benefit of the slab allocator if the node size is variable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
