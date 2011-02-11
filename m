Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E4AE98D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 18:22:31 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1BN24DN032201
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 18:02:32 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 591A6728049
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 18:22:23 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1BNMNCx393760
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 18:22:23 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1BNMLeF008913
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 21:22:22 -0200
Subject: Re: [PATCH R3 7/7] xen/balloon: Memory hotplug support for Xen
 balloon driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110211231312.GA9646@router-fw-old.local.net-space.pl>
References: <20110203163033.GJ1364@router-fw-old.local.net-space.pl>
	 <1296756744.8299.1440.camel@nimitz>
	 <20110207141227.GA10852@router-fw-old.local.net-space.pl>
	 <1297185746.6737.12110.camel@nimitz>
	 <20110211231312.GA9646@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 11 Feb 2011 15:22:18 -0800
Message-ID: <1297466538.6737.18521.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2011-02-12 at 00:13 +0100, Daniel Kiper wrote:
> On Tue, Feb 08, 2011 at 09:22:26AM -0800, Dave Hansen wrote:
> > You spoke about page alignment up there.  Why is this section-aligned?
> > Should we make an "align to section" function in generic sparsemem code?
> 
> It is done because all pages in relevant section starting from max_pfn
> to the end of that section do not have PG_reserved bit set. It was tested
> on Linux Kernel Ver. 2.6.32.x, however, I am going to do some tests on
> current Linus tree. Currently, I do not expect that "align to section"
> function is required by others.

It doesn't matter if it gets used by anybody else.  It's a generic
function that fits in well with the other sparsemem code.  It should go
there.

...
> > As for telling the hypervisor where you've mapped things, that should be
> > done in arch_add_memory().
> >
> > When it comes down to online_page(), you don't want your pages freed
> > back in to the buddy allocator, you want them put in to the balloon.
> > So, take the __free_page() in online_page(), and put a Xen hook in
> > there.
> >
> > +void __attribute__((weak)) arch_free_hotplug_page(struct page *page)
> > +{
> > +	__free_page(page);
> > +}
> 
> I think that this function should be registered dynamically at init
> stage by specific balloon driver (in this case Xen balloon driver).

That sounds fine to me.  I guess we could use some of the subarch stuff
or the pv_ops structure to do it as well.  This isn't exactly a hot
path, either, so I'm not worried about it being some kind of
conditional.

Really, anything that allows us to divert pages over to the Xen balloon
driver rather than the buddy allocator is probably just fine.  

> > > Additionally, IIRC, add_memory() requires
> > > that underlying memory is available before its call.
> >
> > No, that's not correct.  s390's memory isn't available until after it
> > calls vmem_add_mapping().  See arch/s390/mm/init.c
> 
> I was right to some extent. First versions of memory hotplug code were
> written on the base of Linux Kernel Ver. 2.6.32.x. Tests done on that
> versions showed that add_memory() required that underlying memory should
> be available before its call. However, after short investigation it came
> out that there are some issues with some Xen calls. Those issues does
> not exists in current Linus tree.

Sounds good, I'm looking forward to your next patch.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
