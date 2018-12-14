Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9724F8E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 00:21:39 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id k76so2049243oih.13
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 21:21:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f3sor2057723oia.156.2018.12.13.21.21.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Dec 2018 21:21:38 -0800 (PST)
MIME-Version: 1.0
References: <20181205014441.GA3045@redhat.com> <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com> <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com> <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz> <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard> <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard> <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
In-Reply-To: <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 13 Dec 2018 21:21:26 -0800
Message-ID: <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: david <david@fromorbit.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Dec 13, 2018 at 7:53 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 12/12/18 4:51 PM, Dave Chinner wrote:
> > On Wed, Dec 12, 2018 at 04:59:31PM -0500, Jerome Glisse wrote:
> >> On Thu, Dec 13, 2018 at 08:46:41AM +1100, Dave Chinner wrote:
> >>> On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> >>>> On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> >>>>> On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> >>>>> So this approach doesn't look like a win to me over using counter in struct
> >>>>> page and I'd rather try looking into squeezing HMM public page usage of
> >>>>> struct page so that we can fit that gup counter there as well. I know that
> >>>>> it may be easier said than done...
> >>>>
>
> Agreed. After all the discussion this week, I'm thinking that the original idea
> of a per-struct-page counter is better. Fortunately, we can do the moral equivalent
> of that, unless I'm overlooking something: Jerome had another proposal that he
> described, off-list, for doing that counting, and his idea avoids the problem of
> finding space in struct page. (And in fact, when I responded yesterday, I initially
> thought that's where he was going with this.)
>
> So how about this hybrid solution:
>
> 1. Stay with the basic RFC approach of using a per-page counter, but actually
> store the counter(s) in the mappings instead of the struct page. We can use
> !PageAnon and page_mapping to look up all the mappings, stash the dma_pinned_count
> there. So the total pinned count is scattered across mappings. Probably still need
> a PageDmaPinned bit.

How do you safely look at page->mapping from the get_user_pages_fast()
path? You'll be racing invalidation disconnecting the page from the
mapping.
