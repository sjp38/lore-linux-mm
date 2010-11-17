Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3291D8D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:00:40 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAHMh69A015608
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 17:43:06 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAHN0XlQ420772
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:00:35 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAHN0W8Q014100
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 16:00:33 -0700
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1011171434320.22190@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com>
	 <20101117021000.916235444@intel.com> <1290019807.9173.3789.camel@nimitz>
	 <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com>
	 <1290030945.9173.4211.camel@nimitz>
	 <alpine.DEB.2.00.1011171434320.22190@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Wed, 17 Nov 2010 15:00:30 -0800
Message-ID: <1290034830.9173.4363.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: shaohui.zheng@intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>, Aaron Durbin <adurbin@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 14:44 -0800, David Rientjes wrote:
> > That would work, in theory.  But, in practice, we allocate the mem_map[]
> > at probe time.  So, we've already effectively picked a node at probe.
> > That was done because the probe is equivalent to the hardware "add"
> > event.  Once the hardware where in the address space the memory is, it
> > always also knows the node.
> > 
> > But, I guess it also wouldn't be horrible if we just hot-removed and
> > hot-added an offline section if someone did write to a node file like
> > you're suggesting.  It might actually exercise some interesting code
> > paths.
> 
> Since the pages are offline you should be able to modify the memmap when 
> the 'node' file is written and use populate_memnodemap() since that file 
> is only writeable in an offline state.

It's not just the mem_map[], though.  When a section is sitting
"offline", it's pretty much all ready to go, except that its pages
aren't in the allocators.  But, all of the other mm structures have
already been modified to make room for the pages.  Zones have been added
or modified, pgdats resized, 'struct page's initialized.

Changing the node implies changing _all_ of those, which requires
unrolling most of what happened when the "echo $foo > probe" operation
happened in the first place.

This is all _doable_, but it's not trivial.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
