Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 87F9D8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:19:24 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1576541Ab1C2SSw (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 29 Mar 2011 20:18:52 +0200
Date: Tue, 29 Mar 2011 20:18:52 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110329181852.GD30387@router-fw-old.local.net-space.pl>
References: <20110328094757.GJ13826@router-fw-old.local.net-space.pl> <1301327727.31700.8354.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1301327727.31700.8354.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 08:55:27AM -0700, Dave Hansen wrote:
> On Mon, 2011-03-28 at 11:47 +0200, Daniel Kiper wrote:
> >
> > +static enum bp_state reserve_additional_memory(long credit)
> > +{
> > +       int nid, rc;
> > +       u64 start;
> > +       unsigned long balloon_hotplug = credit;
> > +
> > +       start = PFN_PHYS(SECTION_ALIGN_UP(max_pfn));
> > +       balloon_hotplug = (balloon_hotplug & PAGE_SECTION_MASK) + PAGES_PER_SECTION;
> > +       nid = memory_add_physaddr_to_nid(start);
>
> Is the 'balloon_hotplug' calculation correct?  I _think_ you're trying
> to round up to the SECTION_SIZE_PAGES.  But, if 'credit' was already
> section-aligned I think you'll unnecessarily round up to the next
> SECTION_SIZE_PAGES boundary.  Should it just be:
>
> 	balloon_hotplug = ALIGN(balloon_hotplug, PAGES_PER_SECTION);

Yes, you are right. I am wrong. I will correct that. However, as I said
ealier I do not like ALIGN() in size context. For me ALIGN() is operation
on an address which aligns this address to specified boundary. That is
why I prefer use here open coded version (I agree that it is the same
to ALIGN()). I think that ROUND() macro would be better in size context.
However, I am not native english speaker and if I missed something correct
me, please.

> You might also want to consider some nicer units for those suckers.

What do you mind ??? I think that in that context PAGES_PER_SECTION
is quite good.

> 'start_paddr' is _much_ easier to grok than 'start', for instance.

OK.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
