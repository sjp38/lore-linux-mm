Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 63F556B010F
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 12:38:55 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1176397Ab1FEQiG (ORCPT <rfc822;linux-mm@kvack.org>);
	Sun, 5 Jun 2011 18:38:06 +0200
Date: Sun, 5 Jun 2011 18:38:06 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH V4] mm: Extend memory hotplug API to allow memory hotplug in virtual machines
Message-ID: <20110605163806.GA12527@router-fw-old.local.net-space.pl>
References: <20110524222733.GA29133@router-fw-old.local.net-space.pl> <20110602122607.3122e23b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602122607.3122e23b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 02, 2011 at 12:26:07PM -0700, Andrew Morton wrote:
> On Wed, 25 May 2011 00:27:33 +0200
> Daniel Kiper <dkiper@net-space.pl> wrote:
>
> > This patch applies to Linus' git tree, git commit 98b98d316349e9a028e632629fe813d07fa5afdd
> > (Merge branch 'drm-core-next' of git://git.kernel.org/pub/scm/linux/kernel/git/airlied/drm-2.6)
> > with a few prerequisite patches available at https://lkml.org/lkml/2011/5/2/296
> > and https://lkml.org/lkml/2011/5/17/408 (all prerequisite patches were included in -mm tree).
> >
> > This patch contains online_page_callback and apropriate functions for
> > registering/unregistering online page callbacks. It allows to do some
> > machine specific tasks during online page stage which is required
> > to implement memory hotplug in virtual machines. Currently this patch
> > is required by latest memory hotplug support for Xen balloon driver
> > patch which will be posted soon.
> >
> > Additionally, originial online_page() function was splited into
> > following functions doing "atomic" operations:
> >   - __online_page_set_limits() - set new limits for memory management code,
> >   - __online_page_increment_counters() - increment totalram_pages and totalhigh_pages,
> >   - __online_page_free() - free page to allocator.
> >
> > It was done to:
> >   - not duplicate existing code,
> >   - ease hotplug code devolpment by usage of well defined interface,
> >   - avoid stupid bugs which are unavoidable when the same code
> >     (by design) is developed in many places.
>
> I grabbed this and the xen patch.  I assume that all prerequisites
> are now in mainline?

Thank you. Yes, they are.

> Please give some thought to making this extra code Kconfigurable, and
> selected by Xen?  See if we can avoid a bit of bloat for other kernel
> users.

If you think about Xen part it is Kconfigurable.

> What is missing from the patchset is an explanation of why we should
> merge it ;) Why is this feature desirable?  What value does it provide
> to our users?  Why should we bother?  Answering these questions in a
> form which can be pasted into the changelog would be convenient,
> thanks.

Balloon driver for virtualized guest systems allows easy memory
allocation/deallocation from a hypervisor. It is utilized to improve
memory usage by memory deallocation from guests which have a lot of it
unused and allocation to systems under memory pressure. However, it is
not possible by design to allocate more memory for given guest machine
than it was allocated for it at startup. To obey that limitation memory
hotplug shuld be used. This patch contains memory hotplug implementation
for Xen balloon driver. It utilizes current memory hotplug infrastructure
with small modifications. This solution allows increasing guest machine
memory size without restart regardless of memory size set at startup.
It is very useful on critical systems which require long run
without rebooting.

Additionally, could you add

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

to both patches. Here https://lkml.org/lkml/2011/5/31/416
is original e-mail asking for it.

> Is there any propsect that the other virtualisation schemes will use
> this facility?  If not, why not?

I think about that. Even I put a project proposal for GSoC 2011 (you
could find more details here
http://www.google-melange.com/gsoc/proposal/review/google/gsoc2011/dkiper/1),
however, it was not accepted. Currently, I am working on kexec/kdump for
Xen (it was my second project proposal for GSoC 2011) and my PhD thesis.
That is why I could not devote my time to that project. However, I am going
to return to work on generic balloon implementation and memory hotplug
for other virtualisation schemes ASAP.

> > @@ -388,7 +450,7 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> >  	if (PageReserved(pfn_to_page(start_pfn)))
> >  		for (i = 0; i < nr_pages; i++) {
> >  			page = pfn_to_page(start_pfn + i);
> > -			online_page(page);
> > +			online_page_callback(page);
>
> nit.  I'll change this to
>
> 			(*online_page_callback)(page);
>
> because that syntax communicates some useful information to the reader.

OK.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
