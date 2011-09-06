Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C53D56B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 12:36:22 -0400 (EDT)
Date: Tue, 6 Sep 2011 12:35:53 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] Re: [Revert] Re: [PATCH] mm: sync vmalloc address
 space page tables in alloc_vm_area()
Message-ID: <20110906163553.GA28971@dumpdata.com>
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
 <20110901161134.GA8979@dumpdata.com>
 <4E5FED1A.1000300@goop.org>
 <20110901141754.76cef93b.akpm@linux-foundation.org>
 <4E60C067.4010600@citrix.com>
 <20110902153204.59a928c1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110902153204.59a928c1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Vrabel <david.vrabel@citrix.com>, Jeremy Fitzhardinge <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "namhyung@gmail.com" <namhyung@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "rientjes@google.com" <rientjes@google.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On Fri, Sep 02, 2011 at 03:32:04PM -0700, Andrew Morton wrote:
> On Fri, 2 Sep 2011 12:39:19 +0100
> David Vrabel <david.vrabel@citrix.com> wrote:
> 
> > Xen backend drivers (e.g., blkback and netback) would sometimes fail
> > to map grant pages into the vmalloc address space allocated with
> > alloc_vm_area().  The GNTTABOP_map_grant_ref would fail because Xen
> > could not find the page (in the L2 table) containing the PTEs it
> > needed to update.
> > 
> > (XEN) mm.c:3846:d0 Could not find L1 PTE for address fbb42000
> > 
> > netback and blkback were making the hypercall from a kernel thread
> > where task->active_mm != &init_mm and alloc_vm_area() was only
> > updating the page tables for init_mm.  The usual method of deferring
> > the update to the page tables of other processes (i.e., after taking a
> > fault) doesn't work as a fault cannot occur during the hypercall.
> > 
> > This would work on some systems depending on what else was using
> > vmalloc.
> > 
> > Fix this by reverting ef691947d8a3d479e67652312783aedcf629320a
> > (vmalloc: remove vmalloc_sync_all() from alloc_vm_area()) and add a
> > comment to explain why it's needed.
> 
> oookay, I queued this for 3.1 and tagged it for a 3.0.x backport.  I
> *think* that's the outcome of this discussion, for the short-term?

<nods> Yup. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
