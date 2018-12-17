Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2605F8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 03:56:57 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w2so8077180edc.13
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 00:56:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p32si3769206edd.191.2018.12.17.00.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 00:56:55 -0800 (PST)
Date: Mon, 17 Dec 2018 09:56:53 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181217085653.GB28270@quack2.suse.cz>
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
Cc: John Hubbard <jhubbard@nvidia.com>, david <david@fromorbit.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Fri 14-12-18 11:38:59, Dan Williams wrote:
> On Thu, Dec 13, 2018 at 10:11 PM John Hubbard <jhubbard@nvidia.com> wrote:
> >
> > On 12/13/18 9:21 PM, Dan Williams wrote:
> > > On Thu, Dec 13, 2018 at 7:53 PM John Hubbard <jhubbard@nvidia.com> wrote:
> > >>
> > >> On 12/12/18 4:51 PM, Dave Chinner wrote:
> > >>> On Wed, Dec 12, 2018 at 04:59:31PM -0500, Jerome Glisse wrote:
> > >>>> On Thu, Dec 13, 2018 at 08:46:41AM +1100, Dave Chinner wrote:
> > >>>>> On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> > >>>>>> On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > >>>>>>> On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > >>>>>>> So this approach doesn't look like a win to me over using counter in struct
> > >>>>>>> page and I'd rather try looking into squeezing HMM public page usage of
> > >>>>>>> struct page so that we can fit that gup counter there as well. I know that
> > >>>>>>> it may be easier said than done...
> > >>>>>>
> > >>
> > >> Agreed. After all the discussion this week, I'm thinking that the original idea
> > >> of a per-struct-page counter is better. Fortunately, we can do the moral equivalent
> > >> of that, unless I'm overlooking something: Jerome had another proposal that he
> > >> described, off-list, for doing that counting, and his idea avoids the problem of
> > >> finding space in struct page. (And in fact, when I responded yesterday, I initially
> > >> thought that's where he was going with this.)
> > >>
> > >> So how about this hybrid solution:
> > >>
> > >> 1. Stay with the basic RFC approach of using a per-page counter, but actually
> > >> store the counter(s) in the mappings instead of the struct page. We can use
> > >> !PageAnon and page_mapping to look up all the mappings, stash the dma_pinned_count
> > >> there. So the total pinned count is scattered across mappings. Probably still need
> > >> a PageDmaPinned bit.
> > >
> > > How do you safely look at page->mapping from the get_user_pages_fast()
> > > path? You'll be racing invalidation disconnecting the page from the
> > > mapping.
> > >
> >
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

What you describe here sounds almost like page_ext mechanism we already
have? Or do you really aim at per-pin allocated structure?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
