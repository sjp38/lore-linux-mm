Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 98EA46B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 16:45:05 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1582142Ab1ECUol (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 3 May 2011 22:44:41 +0200
Date: Tue, 3 May 2011 22:44:41 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH V2] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110503204441.GC15775@router-fw-old.local.net-space.pl>
References: <20110502220148.GI4623@router-fw-old.local.net-space.pl> <1304440353.30823.73.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1304440353.30823.73.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 03, 2011 at 09:32:33AM -0700, Dave Hansen wrote:
> On Tue, 2011-05-03 at 00:01 +0200, Daniel Kiper wrote:
> > @@ -448,6 +575,14 @@ static int __init balloon_init(void)
> >         balloon_stats.retry_count = 1;
> >         balloon_stats.max_retry_count = RETRY_UNLIMITED;
> >
> > +#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> > +       balloon_stats.hotplug_pages = 0;
> > +       balloon_stats.balloon_hotplug = 0;
> > +
> > +       register_online_page_callback(&xen_online_page);
> > +       register_memory_notifier(&xen_memory_nb);
> > +#endif 
>
> This is 100% static, apparently.  XEN_BALLOON can't be a module, so I
> still don't see the point of having the un/register stuff.  

You are right to some extent. However, xen_online_page() is registered
as page onlining function only on Xen hypervisor. On bare metal
generic_online_page() is only valid page onlining function.

Additionally, I think this callback mechanism enable other balloon
implementations (KVM, VMware, ...) to easily integrate with memory
hotplug. If it comes true (I am going to propose relevant solution
maybe with more generic balloon driver for Linux Kernel somewhen;
I have some ideas, however, I must focus on more important issues
for me now) proper page onlining function (for Xen, KVM, ...) should
be registered at boot time or module load/unload (after hypervisor
detection). That is why I am insisting on run time solution.
It is an investment into the future.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
