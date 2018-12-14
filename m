Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C269D8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 14:48:50 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id y88so5227325pfi.9
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 11:48:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l24si4676386pgj.171.2018.12.14.11.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Dec 2018 11:48:49 -0800 (PST)
Date: Fri, 14 Dec 2018 11:48:43 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181214194843.GG10600@bombadil.infradead.org>
References: <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard>
 <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
 <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
 <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
 <CAPcyv4hrbA9H20bi+QMpKNi7r=egstt61MdQSD5Fb293W1btaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hrbA9H20bi+QMpKNi7r=egstt61MdQSD5Fb293W1btaw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, david <david@fromorbit.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, Dec 14, 2018 at 11:38:59AM -0800, Dan Williams wrote:
> On Thu, Dec 13, 2018 at 10:11 PM John Hubbard <jhubbard@nvidia.com> wrote:
> > I don't have an answer for that, so maybe the page->mapping idea is dead already.
> >
> > So in that case, there is still one more way to do all of this, which is to
> > combine ZONE_DEVICE, HMM, and gup/dma information in a per-page struct, and get
> > there via basically page->private, more or less like this:
> 
> If we're going to allocate something new out-of-line then maybe we
> should go even further to allow for a page "proxy" object to front a
> real struct page. This idea arose from Dave Hansen as I explained to
> him the dax-reflink problem, and dovetails with Dave Chinner's
> suggestion earlier in this thread for dax-reflink.
> 
> Have get_user_pages() allocate a proxy object that gets passed around
> to drivers. Something like a struct page pointer with bit 0 set. This
> would add a conditional branch and pointer chase to many page
> operations, like page_to_pfn(), I thought something like it would be
> unacceptable a few years ago, but then HMM went and added similar
> overhead to put_page() and nobody balked.
> 
> This has the additional benefit of catching cases that might be doing
> a get_page() on a get_user_pages() result and should instead switch to
> a "ref_user_page()" (opposite of put_user_page()) as the API to take
> additional references on a get_user_pages() result.
> 
> page->index and page->mapping could be overridden by similar
> attributes in the proxy, and allow an N:1 relationship of proxy
> instances to actual pages. Filesystems could generate dynamic proxies
> as well.
> 
> The auxiliary information (dev_pagemap, hmm_data, etc...) moves to the
> proxy and stops polluting the base struct page which remains the
> canonical location for dirty-tracking and dma operations.
> 
> The difficulties are reconciling the source of the proxies as both
> get_user_pages() and filesystem may want to be the source of the
> allocation. In the get_user_pages_fast() path we may not be able to
> ask the filesystem for the proxy, at least not without destroying the
> performance expectations of get_user_pages_fast().

I think we can do better than a proxy object with bit 0 set.  I'd go
for allocating something like this:

struct dynamic_page {
	struct page;
	unsigned long vaddr;
	unsigned long pfn;
	...
};

and use a bit in struct page to indicate that this is a dynamic page.
