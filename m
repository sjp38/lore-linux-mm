Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 709C48D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:33:29 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2TKS0dk022231
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:28:00 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p2TKXMWk106984
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:33:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2TKXI2w013240
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:33:21 -0600
Subject: Re: [PATCH 3/3] mm: Extend memory hotplug API to allow memory
 hotplug in virtual machines
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110329121541.d9a27c2e.akpm@linux-foundation.org>
References: <20110328092507.GD13826@router-fw-old.local.net-space.pl>
	 <20110328153735.d797c5b3.akpm@linux-foundation.org>
	 <20110329185913.GF30387@router-fw-old.local.net-space.pl>
	 <20110329121541.d9a27c2e.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 29 Mar 2011 13:33:14 -0700
Message-ID: <1301430794.21454.638.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-03-29 at 12:15 -0700, Andrew Morton wrote:
> On Tue, 29 Mar 2011 20:59:13 +0200
> Daniel Kiper <dkiper@net-space.pl> wrote:

> > OK. I am looking for simple generic mechanism which allow runtime
> > registration/unregistration of generic or module specific (in that
> > case Xen) page onlining function. Dave Hansen sugested compile time
> > solution (https://lkml.org/lkml/2011/2/8/235), however, it does not
> > fit well in my new project on which I am working on (I am going post
> > details at the end of April).
> 
> Well, without a complete description of what you're trying to do and
> without any indication of what "does not fit well" means, I'm at a bit
> of a loss to suggest anything.

We need (the arch-independent) online_page() to act differently when
we're hotplugging a Xen ballooned page versus a normal memory hotplug
operation.  We've basically run out of pages to take out of the balloon
and we need some more with which to fill it up (thus the hotplug).  But,
pages _in_ the balloon are not currently in use.  We want to hot-add
pages to the system, but keep them unused.

online_page(page)
{
	// add page to counters and max_pfn 
	...
	
	if (xen_doing_hotplug(page))
		put_page_in_balloon(page);
	else
		free_page(page);
}

Daniel also seems to want to avoid incrementing the counters and then
immediately decrementing them in the Xen code.  I'm not sure it matters.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
