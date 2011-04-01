Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E98598D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:03:26 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p31DpOmC007636
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 07:51:24 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31E3KOJ119224
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 08:03:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31E3Jj0031592
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 08:03:20 -0600
Subject: Re: [PATCH 04/12] mm: alloc_contig_freed_pages() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.vs8cf5xd3l0zgt@mnazarewicz-glaptop>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
	 <1301577368-16095-5-git-send-email-m.szyprowski@samsung.com>
	 <1301587083.31087.1032.camel@nimitz>
	 <op.vs77qfx03l0zgt@mnazarewicz-glaptop>
	 <1301606078.31087.1275.camel@nimitz>
	 <op.vs8awkrx3l0zgt@mnazarewicz-glaptop> <1301610411.30870.29.camel@nimitz>
	 <op.vs8cf5xd3l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 01 Apr 2011 07:03:16 -0700
Message-ID: <1301666596.30870.176.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Fri, 2011-04-01 at 00:51 +0200, Michal Nazarewicz wrote:
> On Fri, 01 Apr 2011 00:26:51 +0200, Dave Hansen <dave@linux.vnet.ibm.com>  
> wrote:
> >> Bug in the above place does not mean that we could not allocate  
> >> memory.  It means caller is broken.
> >
> > Could you explain that a bit?
> >
> > Is this a case where a device is mapped to a very *specific* range of
> > physical memory and no where else?  What are the reasons for not marking
> > it off limits at boot?  I also saw some bits of isolation and migration
> > in those patches.  Can't the migration fail?
> 
> The function is called from alloc_contig_range() (see patch 05/12) which
> makes sure that the PFN is valid.  Situation where there is not enough
> space is caught earlier in alloc_contig_range().
> 
> alloc_contig_freed_pages() must be given a valid PFN range such that all
> the pages in that range are free (as in are within the region tracked by
> page allocator) and of MIGRATETYPE_ISOLATE so that page allocator won't
> touch them.

OK, so it really is a low-level function only.  How about a comment that
explicitly says this?  "Only called from $FOO with the area already
isolated."  It probably also deserves an __ prefix.

> That's why invalid PFN is a bug in the caller and not an exception that
> has to be handled.
> 
> Also, the function is not called during boot time.  It is called while
> system is already running.

What kind of success have you had running this in practice?  I'd be
worried that some silly task or a sticky dentry would end up in the
range that you want to allocate in.  


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
