Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 123316B01A7
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 18:32:15 -0400 (EDT)
Date: Fri, 2 Sep 2011 15:32:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Revert] Re: [PATCH] mm: sync vmalloc address space page tables
 in alloc_vm_area()
Message-Id: <20110902153204.59a928c1.akpm@linux-foundation.org>
In-Reply-To: <4E60C067.4010600@citrix.com>
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
	<20110901161134.GA8979@dumpdata.com>
	<4E5FED1A.1000300@goop.org>
	<20110901141754.76cef93b.akpm@linux-foundation.org>
	<4E60C067.4010600@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "namhyung@gmail.com" <namhyung@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On Fri, 2 Sep 2011 12:39:19 +0100
David Vrabel <david.vrabel@citrix.com> wrote:

> Xen backend drivers (e.g., blkback and netback) would sometimes fail
> to map grant pages into the vmalloc address space allocated with
> alloc_vm_area().  The GNTTABOP_map_grant_ref would fail because Xen
> could not find the page (in the L2 table) containing the PTEs it
> needed to update.
> 
> (XEN) mm.c:3846:d0 Could not find L1 PTE for address fbb42000
> 
> netback and blkback were making the hypercall from a kernel thread
> where task->active_mm != &init_mm and alloc_vm_area() was only
> updating the page tables for init_mm.  The usual method of deferring
> the update to the page tables of other processes (i.e., after taking a
> fault) doesn't work as a fault cannot occur during the hypercall.
> 
> This would work on some systems depending on what else was using
> vmalloc.
> 
> Fix this by reverting ef691947d8a3d479e67652312783aedcf629320a
> (vmalloc: remove vmalloc_sync_all() from alloc_vm_area()) and add a
> comment to explain why it's needed.

oookay, I queued this for 3.1 and tagged it for a 3.0.x backport.  I
*think* that's the outcome of this discussion, for the short-term?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
