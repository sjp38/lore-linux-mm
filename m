Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E7B648D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:40:26 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2UEJ1AA004551
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:19:01 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E09146E803F
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:39:42 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2UEdJ392728156
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:39:19 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2UEdIT8031822
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:39:19 -0400
Subject: Re: [PATCH] xen/balloon: Memory hotplug support for Xen balloon
 driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110329181852.GD30387@router-fw-old.local.net-space.pl>
References: <20110328094757.GJ13826@router-fw-old.local.net-space.pl>
	 <1301327727.31700.8354.camel@nimitz>
	 <20110329181852.GD30387@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 30 Mar 2011 07:39:14 -0700
Message-ID: <1301495954.21454.3788.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-03-29 at 20:18 +0200, Daniel Kiper wrote:
> On Mon, Mar 28, 2011 at 08:55:27AM -0700, Dave Hansen wrote:
> > On Mon, 2011-03-28 at 11:47 +0200, Daniel Kiper wrote:
> > >
> > > +static enum bp_state reserve_additional_memory(long credit)
> > > +{
> > > +       int nid, rc;
> > > +       u64 start;
> > > +       unsigned long balloon_hotplug = credit;
> > > +
> > > +       start = PFN_PHYS(SECTION_ALIGN_UP(max_pfn));
> > > +       balloon_hotplug = (balloon_hotplug & PAGE_SECTION_MASK) + PAGES_PER_SECTION;
> > > +       nid = memory_add_physaddr_to_nid(start);
> >
> > Is the 'balloon_hotplug' calculation correct?  I _think_ you're trying
> > to round up to the SECTION_SIZE_PAGES.  But, if 'credit' was already
> > section-aligned I think you'll unnecessarily round up to the next
> > SECTION_SIZE_PAGES boundary.  Should it just be:
> >
> > 	balloon_hotplug = ALIGN(balloon_hotplug, PAGES_PER_SECTION);
> 
> Yes, you are right. I am wrong. I will correct that. However, as I said
> ealier I do not like ALIGN() in size context. For me ALIGN() is operation
> on an address which aligns this address to specified boundary. That is
> why I prefer use here open coded version (I agree that it is the same
> to ALIGN()). I think that ROUND() macro would be better in size context.
> However, I am not native english speaker and if I missed something correct
> me, please.

The only problem with open-coding it is that it's more likely to have
bugs.  But, sure, ROUND() sounds OK, as long as it does what you intend.
I'm still not quite sure what your intent here is, or in which direction
you're trying to round and why.

> > You might also want to consider some nicer units for those suckers.
> 
> What do you mind ??? I think that in that context PAGES_PER_SECTION
> is quite good.

Memory management code is tricky.  We keep addresses in many forms:
virtual addresses, physical addresses, pfns, 'struct page', etc...  I've
found it very useful in the past to ensure that I'm explicit about what
I'm dealing with among those.  

In this case, PAGES_PER_SECTION says that "balloon_hotplug" is intended
to be either a physical address or a page count.  But, that only says
what you're filling the variable with, not what you _intend_ it to
contain.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
