Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1DB8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 14:39:14 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id r24so2860554otk.7
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 11:39:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k22sor4035309otn.183.2018.12.14.11.39.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 11:39:12 -0800 (PST)
MIME-Version: 1.0
References: <20181205014441.GA3045@redhat.com> <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com> <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com> <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz> <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard> <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard> <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
 <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com> <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
In-Reply-To: <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Dec 2018 11:38:59 -0800
Message-ID: <CAPcyv4hrbA9H20bi+QMpKNi7r=egstt61MdQSD5Fb293W1btaw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: david <david@fromorbit.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Dec 13, 2018 at 10:11 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 12/13/18 9:21 PM, Dan Williams wrote:
> > On Thu, Dec 13, 2018 at 7:53 PM John Hubbard <jhubbard@nvidia.com> wrote:
> >>
> >> On 12/12/18 4:51 PM, Dave Chinner wrote:
> >>> On Wed, Dec 12, 2018 at 04:59:31PM -0500, Jerome Glisse wrote:
> >>>> On Thu, Dec 13, 2018 at 08:46:41AM +1100, Dave Chinner wrote:
> >>>>> On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> >>>>>> On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> >>>>>>> On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> >>>>>>> So this approach doesn't look like a win to me over using counter in struct
> >>>>>>> page and I'd rather try looking into squeezing HMM public page usage of
> >>>>>>> struct page so that we can fit that gup counter there as well. I know that
> >>>>>>> it may be easier said than done...
> >>>>>>
> >>
> >> Agreed. After all the discussion this week, I'm thinking that the original idea
> >> of a per-struct-page counter is better. Fortunately, we can do the moral equivalent
> >> of that, unless I'm overlooking something: Jerome had another proposal that he
> >> described, off-list, for doing that counting, and his idea avoids the problem of
> >> finding space in struct page. (And in fact, when I responded yesterday, I initially
> >> thought that's where he was going with this.)
> >>
> >> So how about this hybrid solution:
> >>
> >> 1. Stay with the basic RFC approach of using a per-page counter, but actually
> >> store the counter(s) in the mappings instead of the struct page. We can use
> >> !PageAnon and page_mapping to look up all the mappings, stash the dma_pinned_count
> >> there. So the total pinned count is scattered across mappings. Probably still need
> >> a PageDmaPinned bit.
> >
> > How do you safely look at page->mapping from the get_user_pages_fast()
> > path? You'll be racing invalidation disconnecting the page from the
> > mapping.
> >
>
> I don't have an answer for that, so maybe the page->mapping idea is dead already.
>
> So in that case, there is still one more way to do all of this, which is to
> combine ZONE_DEVICE, HMM, and gup/dma information in a per-page struct, and get
> there via basically page->private, more or less like this:

If we're going to allocate something new out-of-line then maybe we
should go even further to allow for a page "proxy" object to front a
real struct page. This idea arose from Dave Hansen as I explained to
him the dax-reflink problem, and dovetails with Dave Chinner's
suggestion earlier in this thread for dax-reflink.

Have get_user_pages() allocate a proxy object that gets passed around
to drivers. Something like a struct page pointer with bit 0 set. This
would add a conditional branch and pointer chase to many page
operations, like page_to_pfn(), I thought something like it would be
unacceptable a few years ago, but then HMM went and added similar
overhead to put_page() and nobody balked.

This has the additional benefit of catching cases that might be doing
a get_page() on a get_user_pages() result and should instead switch to
a "ref_user_page()" (opposite of put_user_page()) as the API to take
additional references on a get_user_pages() result.

page->index and page->mapping could be overridden by similar
attributes in the proxy, and allow an N:1 relationship of proxy
instances to actual pages. Filesystems could generate dynamic proxies
as well.

The auxiliary information (dev_pagemap, hmm_data, etc...) moves to the
proxy and stops polluting the base struct page which remains the
canonical location for dirty-tracking and dma operations.

The difficulties are reconciling the source of the proxies as both
get_user_pages() and filesystem may want to be the source of the
allocation. In the get_user_pages_fast() path we may not be able to
ask the filesystem for the proxy, at least not without destroying the
performance expectations of get_user_pages_fast().

>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 5ed8f6292a53..13f651bb5cc1 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -67,6 +67,13 @@ struct hmm;
>  #define _struct_page_alignment
>  #endif
>
> +struct page_aux {
> +       struct dev_pagemap *pgmap;
> +       unsigned long hmm_data;
> +       unsigned long private;
> +       atomic_t dma_pinned_count;
> +};
> +
>  struct page {
>         unsigned long flags;            /* Atomic flags, some possibly
>                                          * updated asynchronously */
> @@ -149,11 +156,13 @@ struct page {
>                         spinlock_t ptl;
>  #endif
>                 };
> -               struct {        /* ZONE_DEVICE pages */
> +               struct {        /* ZONE_DEVICE, HMM or get_user_pages() pages */
>                         /** @pgmap: Points to the hosting device page map. */
> -                       struct dev_pagemap *pgmap;
> -                       unsigned long hmm_data;
> -                       unsigned long _zd_pad_1;        /* uses mapping */
> +                       unsigned long _zd_pad_1;        /* LRU */
> +                       unsigned long _zd_pad_2;        /* LRU */
> +                       unsigned long _zd_pad_3;        /* mapping */
> +                       unsigned long _zd_pad_4;        /* index */
> +                       struct page_aux *aux;           /* private */
>                 };
>
>                 /** @rcu_head: You can use this to free a page by RCU. */
>
> ...is there any appetite for that approach?
>
> --
> thanks,
> John Hubbard
> NVIDIA
