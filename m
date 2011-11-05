Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9994E6B002D
	for <linux-mm@kvack.org>; Sat,  5 Nov 2011 09:39:08 -0400 (EDT)
Date: Sat, 5 Nov 2011 09:38:46 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] Re: [Revert] Re: [PATCH] mm: sync vmalloc address
 space page tables in alloc_vm_area()
Message-ID: <20111105133846.GA4415@phenom.dumpdata.com>
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
 <20110901161134.GA8979@dumpdata.com>
 <4E5FED1A.1000300@goop.org>
 <20110901141754.76cef93b.akpm@linux-foundation.org>
 <4E60C067.4010600@citrix.com>
 <20110902153204.59a928c1.akpm@linux-foundation.org>
 <20110906163553.GA28971@dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110906163553.GA28971@dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Vrabel <david.vrabel@citrix.com>, Jeremy Fitzhardinge <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "namhyung@gmail.com" <namhyung@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "rientjes@google.com" <rientjes@google.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On Tue, Sep 06, 2011 at 12:35:53PM -0400, Konrad Rzeszutek Wilk wrote:
> On Fri, Sep 02, 2011 at 03:32:04PM -0700, Andrew Morton wrote:
> > On Fri, 2 Sep 2011 12:39:19 +0100
> > David Vrabel <david.vrabel@citrix.com> wrote:
> > 
> > > Xen backend drivers (e.g., blkback and netback) would sometimes fail
> > > to map grant pages into the vmalloc address space allocated with
> > > alloc_vm_area().  The GNTTABOP_map_grant_ref would fail because Xen
> > > could not find the page (in the L2 table) containing the PTEs it
> > > needed to update.
> > > 
> > > (XEN) mm.c:3846:d0 Could not find L1 PTE for address fbb42000
> > > 
> > > netback and blkback were making the hypercall from a kernel thread
> > > where task->active_mm != &init_mm and alloc_vm_area() was only
> > > updating the page tables for init_mm.  The usual method of deferring
> > > the update to the page tables of other processes (i.e., after taking a
> > > fault) doesn't work as a fault cannot occur during the hypercall.
> > > 
> > > This would work on some systems depending on what else was using
> > > vmalloc.
> > > 
> > > Fix this by reverting ef691947d8a3d479e67652312783aedcf629320a
> > > (vmalloc: remove vmalloc_sync_all() from alloc_vm_area()) and add a
> > > comment to explain why it's needed.
> > 
> > oookay, I queued this for 3.1 and tagged it for a 3.0.x backport.  I
> > *think* that's the outcome of this discussion, for the short-term?
> 
> <nods> Yup. Thanks!

Hey Andrew,

The long term outcome is the patchset that David worked on. I've sent
a GIT PULL to Linus to pick up the Xen related patches that switch over
the users of the right API:

 (xen) stable/vmalloc-3.2 for Linux 3.2-rc0

(https://lkml.org/lkml/2011/10/29/82)

And then on top of that use this patch:
[Note, I am still waiting for Linus to pull that patchset above.. so not
sure on the outcome. perhaps a better way would be for you to pull
all patches in your tree?]

Also, not sure what you thought of this patch below?
