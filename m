Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEA878E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:20:45 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w18so5350877qts.8
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 07:20:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l6si2882154qve.146.2018.12.14.07.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 07:20:44 -0800 (PST)
Date: Fri, 14 Dec 2018 10:20:38 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181214152038.GB3645@redhat.com>
References: <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard>
 <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
 <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
 <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>, david <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Dec 13, 2018 at 10:11:09PM -0800, John Hubbard wrote:
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

The page mapcount idea does work to get a pin count. So i believe
that this is what should be pursue, if no one wants to try it i
will do patches. Anything else is too invasive and requires too
much changes. Note that in all the discussion that happened in the
mapcount having a separate pin count would not have help one bit
nor would it solve the page_mkwrite issue.

So we need to audit put_user_page call place and see if they can
sleep and call mkwrite without issue. I believe the answer will be
yes for many ... maybe all.

Cheers,
J�r�me
