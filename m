Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B099B6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 14:11:03 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nA3J3xkt028889
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:03:59 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nA3JAZ9I146458
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:10:36 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nA3JAY1Z012056
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:10:34 -0700
Subject: Re: RFC: Transparent Hugepage support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20091103111829.GJ11981@random.random>
References: <20091026185130.GC4868@random.random>
	 <1257024567.7907.17.camel@pasglop>  <20091103111829.GJ11981@random.random>
Content-Type: text/plain
Date: Tue, 03 Nov 2009 11:10:32 -0800
Message-Id: <1257275432.31972.2712.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-03 at 12:18 +0100, Andrea Arcangeli wrote:
> On Sun, Nov 01, 2009 at 08:29:27AM +1100, Benjamin Herrenschmidt wrote:
> > This isn't possible on all architectures. Some archs have "segment"
> > constraints which mean only one page size per such "segment". Server
> > ppc's for example (segment size being either 256M or 1T depending on the
> > CPU).
> 
> Hmm 256M is already too large for a transparent allocation. It will
> require reservation and hugetlbfs to me actually seems a perfect fit
> for this hardware limitation. The software limits of hugetlbfs matches
> the hardware limit perfectly and it already provides all necessary
> permission and reservation features needed to deal with extremely huge
> page sizes that probabilistically would never be found in the buddy
> (even if we were to extend it to make it not impossible).

POWER is pretty unusual in its mmu.  These 256MB (or 1TB) segments are
the granularity with which we must make the choice about page size, but
they *aren't* the page size itself.

We can fill that 256MB segment with any 16MB pages from all over the
physical address space, but we just can't *mix* 4k and 16MB mappings in
the same 256MB virtual area.

16*16MB pages are going to be hard to get, but they are much much easier
to get than 1 256MB page.  But, remember that most ppc64 systems have a
64k page, so the 16MB page is actually only an order-8 allocation.
x86-64's huge pages are order-9.  So, it sucks, but allocating the pages
themselves isn't that big of an issue.  It's getting a big enough
virtual bunch of them together without any small pages in the segment.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
