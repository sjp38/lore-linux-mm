Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE7F6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:09:36 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so68728090pdn.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:09:36 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v5si9147699pdo.216.2015.03.26.10.09.34
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 10:09:35 -0700 (PDT)
Date: Thu, 26 Mar 2015 13:09:18 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Should implementations of ->direct_access be allowed to sleep?
Message-ID: <20150326170918.GO4003@linux.intel.com>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com>
 <20150324185046.GA4994@whiteoak.sf.office.twttr.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150324185046.GA4994@whiteoak.sf.office.twttr.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, msharbiani@twopensource.com

On Tue, Mar 24, 2015 at 11:50:47AM -0700, Matt Mullins wrote:
> We're also developing a user of direct_access, and we ended up with some
> questions about the sleeping guarantees of the direct_access API.

That's a great question.  Since DAX can always sleep when it's calling
into bdev_direct_access(), I hadn't thought about it (DAX is basically
called to handle page faults and do I/O; both of which are expected
to sleep).

> Since brd is currently the only (x86) implementation of DAX in Linus's tree,
> I've been testing against that.  We noticed that the brd implementation of DAX
> can call into alloc_page() with __GFP_WAIT if we call direct_access() on a page
> that has not yet been allocated.  This is compounded by the fact that brd does
> not support size > PAGE_SIZE (and thus I call bdev_direct_access() on each use),
> though the limitation makes sense -- I shouldn't expect the brd driver to be
> able to allocate a gigabyte of contiguous memory.
> 
> The potential sleeping behavior was somewhat surprising to me, as I would expect
> the NV-DIMM device implementation to simply offset the pfn at which the device
> is located rather than perform a memory allocation.  What are the guaranteed
> and/or expected contexts from which direct_access() can be safely called?

Yes, for 'real' NV-DIMM devices, as you can see by the ones in tree,
as well as the pmem driver that Ross has been posting, it's a simple
piece of arithmetic.  The question is whether we should make all users
of ->direct_access accommodate brd, or whether we should change brd so
that it doesn't sleep.

I'm leaning towards the latter.  But I'm not sure what GFP flags to
recommend that brd use ... GFP_NOWAIT | __GFP_ZERO, perhaps?

> If it would make more sense for us to test against (for example) the pmem or an
> mtd-block driver instead, as you've discussed with Mathieu Desnoyers, then I'd
> be happy to work with those in our environment as well.

I use Ross's pmem driver for my testing mostly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
