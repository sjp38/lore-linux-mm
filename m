Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E07A89000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:00:24 -0400 (EDT)
Date: Thu, 29 Sep 2011 10:00:21 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: [Xen-devel] Re: RFC -- new zone type
Message-ID: <20110929170021.GB7007@labbmf-linux.qualcomm.com>
References: <20110928180909.GA7007@labbmf-linux.qualcomm.comCAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com>
 <c2d9add1-0095-4319-8936-db1b156559bf@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2d9add1-0095-4319-8936-db1b156559bf@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Sameer Pramod Niphadkar <spniphadkar@gmail.com>, Larry Bassel <lbassel@codeaurora.org>, linux-mm@kvack.org, vgandhi@codeaurora.org, Xen-devel@lists.xensource.com

On 29 Sep 11 09:38, Dan Magenheimer wrote:
> > From: Sameer Pramod Niphadkar [mailto:spniphadkar@gmail.com]
> > Sent: Thursday, September 29, 2011 12:08 AM
> > To: Larry Bassel
> > Cc: linux-mm@kvack.org; vgandhi@codeaurora.org; Xen-devel@lists.xensource.com
> > Subject: [Xen-devel] Re: RFC -- new zone type
> > 
> > On Wed, Sep 28, 2011 at 11:39 PM, Larry Bassel <lbassel@codeaurora.org> wrote:
> > > We need to create a large (~100M) contiguous physical memory region
> > > which will only be needed occasionally. As this region will
> > > use up 10-20% of all of the available memory, we do not want
> > > to pre-reserve it at boot time. Instead, we want to create
> > > this memory region "on the fly" when asked to by userspace,
> > > and do it as quickly as possible, and return it to
> > > system use when not needed.
> > >
> > > AFAIK, this sort of operation is currently done using memory
> > > compaction (as CMA does for instance).
> > > Alternatively, this memory region (if it is in a fixed place)
> > > could be created using "logical memory hotremove" and returned
> > > to the system using "logical memory hotplug". In either case,
> > > the contiguous physical memory would be created via migrating
> > > pages from the "movable zone".
> > >
> > > The problem with this approach is that the copying of up to 25000
> > > pages may take considerable time (as well as finding destinations
> > > for all of the pages if free memory is scarce -- this may
> > > even fail, causing the memory region not to be created).
> > >
> > > It was suggested to me that a new zone type which would be similar
> > > to the "movable zone" but is only allowed to contain pages
> > > that can be discarded (such as text) could solve this problem,
> > > so that there is no copying or finding destination pages needed (thus
> > > considerably reducing latency).
> 
> If I read the above correctly, you are talking about indeed
> pre-reserving your ~100MB contiguous chunk of memory but using
> it for "discardable" pages only, then discarding all of those
> pages when you need the memory region, then going back to using
> the contiguous chunk for discardable pages, and so on.

Yes, that is exactly what we want to do.

> 
> You may be interested in the concept of "ephemeral pages"
> introduced by transcendent memory ("tmem") and the cleancache
> patchset which went upstream at 3.0.  If you write a driver
> (called a "backend" in tmem language) that accepts pages
> from cleancache, you would be able to use your 100MB contiguous
> chunk of memory for clean pagecache pages when it is not needed
> for your other purposes, easily discard all the pages when
> you do need the space, then start using it for clean pagecache
> pages again when you don't need it for your purposes anymore
> (and repeat this cycle as many times as necessary).
> 
> You maybe could call your driver "cleanzone".
> 
> Zcache (also upstream in drivers/staging) does something like
> this already, though you might not want/need to use compression
> in your driver.  In zcache, space reclaim is driven by the kernel
> "shrinker" code that runs when memory is low, but another trigger
> could easily be used.  Also there is likely a lot of code in
> zcache (e.g. tmem.c) that you could leverage.
> 
> For more info, see: 
> http://lwn.net/Articles/454795/
> http://oss.oracle.com/projects/tmem 

Thanks very much, I'll look into these.

> 
> I'd be happy to answer any questions if you are still interested
> after you have read the above documentation.
> 
> Thanks,
> Dan

Larry
> 

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
