Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DA7CA5F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 03:32:18 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Date: Mon, 6 Apr 2009 17:32:39 +1000
References: <20090327150905.819861420@de.ibm.com> <49D6532C.6010804@goop.org> <20090406092111.3b432edd@skybase>
In-Reply-To: <20090406092111.3b432edd@skybase>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904061732.39885.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Rik van Riel <riel@redhat.com>, akpm@osdl.org, frankeh@watson.ibm.com, virtualization@lists.osdl.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, hugh@veritas.com, Xen-devel <xen-devel@lists.xensource.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 April 2009 17:21:11 Martin Schwidefsky wrote:
> On Fri, 03 Apr 2009 11:19:24 -0700

> > Yes.  But it still depends on the guest.  A very helpful guest could 
> > deliberately preswap pages so that it can mark them as volatile, whereas 
> > a less helpful one may keep them persistent and defer preswapping them 
> > until there's a good reason to do so.  Host swapping and page hinting 
> > won't put any apparent memory pressure on the guest, so it has no reason 
> > to start preswapping even if the overall system is under pressure.  
> > Ballooning will expose each guest to its share of the overall system 
> > memory pressure, so they can respond appropriately (one hopes).
> 
> Why should the guest want to do preswapping? It is as expensive for
> the host to swap a page and get it back as it is for the guest (= one
> write + one read). It is a waste of cpu time to call into the guest. You
> need something we call PFAULT though: if a guest process hits a page
> that is missing in the host page table you don't want to stop the
> virtual cpu until the page is back. You notify the guest that the host
> page is missing. The process that caused the fault is put to sleep
> until the host retrieved the page again. You will find the pfault code
> for s390 in arch/s390/mm/fault.c
> 
> So to me preswap doesn't make sense. The only thing you can gain by
> putting memory pressure on the guest is to free some of the memory that
> is used by the kernel for dentries, inodes, etc. 

The guest kernel can have more context about usage patterns, or user
hints set on some pages or ranges. And as you say, there are
non-pagecache things to free that can be taking significant or most of
the freeable memory, and there can be policy knobs set in the guest
(swappiness or vfs_cache_pressure etc).

I guess that counters or performance monitoring events in the guest
should also look more like a normal Linux kernel (although I haven't
remembered what you do in that department in your patches).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
