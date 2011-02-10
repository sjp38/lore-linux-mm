Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 356878D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 12:18:00 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1AGwKwR023090
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 11:58:24 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1A8D1728098
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 12:16:40 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1AHGdSY284766
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 12:16:39 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1AHGcOO032275
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 12:16:39 -0500
Subject: Re: [PATCH R3 7/7] xen/balloon: Memory hotplug support for Xen
 balloon driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110210170152.GE12087@dumpdata.com>
References: <20110203163033.GJ1364@router-fw-old.local.net-space.pl>
	 <1296756744.8299.1440.camel@nimitz>
	 <20110207141227.GA10852@router-fw-old.local.net-space.pl>
	 <1297185746.6737.12110.camel@nimitz>  <20110210170152.GE12087@dumpdata.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 10 Feb 2011 09:16:34 -0800
Message-ID: <1297358194.6737.14488.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2011-02-10 at 12:01 -0500, Konrad Rzeszutek Wilk wrote:
> On Tue, Feb 08, 2011 at 09:22:26AM -0800, Dave Hansen wrote:
> > On Mon, 2011-02-07 at 15:12 +0100, Daniel Kiper wrote:
> > > I agree. I discussed a bit about this problem with Jeremy, too. However,
> > > there are some problems to implement that solution now. First of all it is
> > > possible to online hotplugged memory using sysfs interface only in chunks
> > > called sections. It means that it is not possible online once again section
> > > which was onlined ealier partialy populated and now it contains new pages
> > > to online. In this situation sysfs interface emits Invalid argument error.
> > > In theory it should be possible to offline and then online whole section
> > > once again, however, if memory from this section was used is not possible
> > > to do that. It means that those properties does not allow hotplug memory
> > > in guest in finer granulity than section and sysfs interface is too inflexible
> > > to be used in that solution. That is why I decided to online hoplugged memory
> > > using API which does not have those limitations.
> > 
> > Sure, you have to _online_ the whole thing at once, but you don't have
> > to actually make the pages available.  You also don't need to hook in to
> > the memory resource code like you're doing.  It's sufficient to just try
> > and add the memory.  If you get -EEXIST, then you can't add it there, so
> > move up and try again.  
> > 
> > int xen_balloon_add_memory(u64 size)
> > {
> > 	unsigned long top_of_mem = max_pfn;
> > 	top_of_mem = section_align_up(top_of_mem);
> > 
> > 	while (1) {
> > 		int ret = add_memory(nid, top_of_mem, size);
> > 		if (ret == -EEXIST)
> > 			continue;
> > 		// error handling...
> > 		break;
> > 	}
> > 	return...;
> > }
> > 
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
> I somehow have a vague recollection that the __weak was frowned upon? The issues
> were that when you compile a pv-ops kernel it can run as baremetal so the..

There are a bunch of alternatives to using 'weak'.  Any of those would
probably be fine as well.  Anything that allows us to check whether the
page should go back in to the allocator or the balloon.

> > void online_page(struct page *page)
> > {
> >         unsigned long pfn = page_to_pfn(page);
> > ...
> > -       __free_page(page);
> > +	arch_free_hotplug_page(page);
> > }
> > 
> > Then, have Xen override it:
> > 
> > void arch_free_hotplug_page(struct page *page)
> > {
> > 	if (xen_need_to_inflate_balloon())
> > 		put_page_in_balloon(page);	
> > 	else
> > 		__free_page(page);
> 
>  call above would get called even on baremetal (and would require the header
> file arch/x86/include/memory_hotplug.h to pull in header file from the balloon
> driver). If we are going to persue this it might be prudent to follow what we did for MSI:
> 
> 1525bf0d8f059a38c6e79353583854e1981b2e67
> 294ee6f89cfd629e276f632a6003a0fad7785dce
> b5401a96b59475c1c878439caecb8c521bdfd4ad

That looks a bit complicated for what I'm trying to do here, but
whatever works.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
