Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l16Kqjfa026859
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 15:52:45 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l16Kqju8399380
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 13:52:45 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l16KqixF031768
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 13:52:45 -0700
Subject: Re: [RFC/PATCH] prepare_unmapped_area
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1170792754.2620.244.camel@localhost.localdomain>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net>
	 <1170736938.2620.213.camel@localhost.localdomain>
	 <20070206044516.GA16647@wotan.suse.de>
	 <1170738296.2620.220.camel@localhost.localdomain>
	 <1170777380.26117.28.camel@localhost.localdomain>
	 <1170792754.2620.244.camel@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 06 Feb 2007 14:52:43 -0600
Message-Id: <1170795164.26117.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>, hch@infradead.org, "David C. Hansen [imap]" <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-02-07 at 07:12 +1100, Benjamin Herrenschmidt wrote:
> On Tue, 2007-02-06 at 09:56 -0600, Adam Litke wrote:
> > On Tue, 2007-02-06 at 16:04 +1100, Benjamin Herrenschmidt wrote:
> > > Hi folks !
> > > 
> > > On Cell, I have, for performance reasons, a need to create special
> > > mappings of SPEs that use a different page size as the system base page
> > > size _and_ as the huge page size.
> > > 
> > > Due to the way the PowerPC memory management works, however, I can only
> > > have one page size per "segment" of 256MB (or 1T) and thus after such a
> > > mapping have been created in its own segment, I need to constraint
> > > -other- vma's to stay out of that area.
> > > 
> > > This currently cannot be done with the existing arch hooks (because of
> > > MAP_FIXED). However, the hugetlbfs code already has a hack in there to
> > > do the exact same thing for huge pages. Thus, this patch moves that hack
> > > into something that can be overriden by the architectures. This approach
> > > was choosen as the less ugly of the uglies after discussing with Nick
> > > Piggin. If somebody has a better idea, I'd love to hear it.
> > 
> > Hi Ben.  Would my patch from last Jan 31 entitled "[PATCH 5/6] Abstract
> > is_hugepage_only_range" (attached for your convienence) solve this
> > problem?
> 
> I don't see how your patch abstracts is_hugepage_only_range tho... you
> still call it at the same spot, you abstracted prepare_hugepage_range.

Yeah, you're right... Former revisions of the patch created a function
called is_special_range() which for the moment only called
is_hugepage_only_range().  The thought was that other types of "special
ranges" could be checked for in this function.  I guess that's basically
the same idea as validate_area() below.  That would work for me.

> I was talking to hch and arjan yesterday on irc and we though about
> having an mm hook validate_area() that could replace the
> is_hugepage_only_range() hack and deal with my issue as well. As for
> having prepare in the fops, do we need it at all if we call fops->g_u_a
> in the MAP_FIXED case ?

Nah, if we cleaned up g_u_a() so that it is always called, away goes the
need for f_ops->prepare_unmapped_area().

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
