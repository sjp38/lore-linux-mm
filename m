Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7BA6B0008
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 04:42:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g36-v6so4786637edb.3
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:42:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1-v6si2963726ejr.283.2018.10.11.01.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 01:42:24 -0700 (PDT)
Date: Thu, 11 Oct 2018 10:42:22 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20181011084222.GA8418@quack2.suse.cz>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
 <5198a797-fa34-c859-ff9d-568834a85a83@nvidia.com>
 <20181010085936.GC11507@quack2.suse.cz>
 <f5fb98a8-a1dc-6f1d-bc9e-210be14e91b4@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f5fb98a8-a1dc-6f1d-bc9e-210be14e91b4@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Wed 10-10-18 16:23:35, John Hubbard wrote:
> On 10/10/18 1:59 AM, Jan Kara wrote:
> > On Tue 09-10-18 17:42:09, John Hubbard wrote:
> >> On 10/8/18 5:14 PM, Andrew Morton wrote:
> >>> Also, maintainability.  What happens if someone now uses put_page() by
> >>> mistake?  Kernel fails in some mysterious fashion?  How can we prevent
> >>> this from occurring as code evolves?  Is there a cheap way of detecting
> >>> this bug at runtime?
> >>>
> >>
> >> It might be possible to do a few run-time checks, such as "does page that came 
> >> back to put_user_page() have the correct flags?", but it's harder (without 
> >> having a dedicated page flag) to detect the other direction: "did someone page 
> >> in a get_user_pages page, to put_page?"
> >>
> >> As Jan said in his reply, converting get_user_pages (and put_user_page) to 
> >> work with a new data type that wraps struct pages, would solve it, but that's
> >> an awfully large change. Still...given how much of a mess this can turn into 
> >> if it's wrong, I wonder if it's worth it--maybe? 
> > 
> > I'm certainly not opposed to looking into it. But after looking into this
> > for a while it is not clear to me how to convert e.g. fs/direct-io.c or
> > fs/iomap.c. They pass the reference from gup() via
> > bio->bi_io_vec[]->bv_page and then release it after IO completion.
> > Propagating the new type to ->bv_page is not good as lower layer do not
> > really care how the page is pinned in memory. But we do need to somehow
> > pass the information to the IO completion functions in a robust manner.
> > 
> 
> You know, that problem has to be solved in either case: even if we do not
> use a new data type for get_user_pages, we still need to clearly, accurately
> match up the get/put pairs. And for the complicated systems (block IO, and
> GPU DRM layer, especially) one of the things that has caused me concern is 
> the way the pages all end up in a large, complicated pool, and put_page is
> used to free all of them, indiscriminately.

Agreed.

> > Hmm, what about the following:
> > 
> > 1) Make gup() return new type - struct user_page *? In practice that would
> > be just a struct page pointer with 0 bit set so that people are forced to
> > use proper helpers and not just force types (and the setting of bit 0 and
> > masking back would be hidden behind CONFIG_DEBUG_USER_PAGE_REFERENCES for
> > performance reasons). Also the transition would have to be gradual so we'd
> > have to name the function differently and use it from converted code.
> 
> Yes. That seems perfect: it just fades away if you're not debugging, but we
> can catch lots of problems when CONFIG_DEBUG_USER_PAGE_REFERENCES is set. 

Yeah, and when you suspect issues with page pinning, you can try to run
with CONFIG_DEBUG_USER_PAGE_REFERENCES enabled. It's not like the overhead
is going to be huge. But it could be measurable for some workloads...

> > 2) Provide helper bio_add_user_page() that will take user_page, convert it
> > to struct page, add it to the bio, and flag the bio as having pages with
> > user references. That code would also make sure the bio is consistent in
> > having only user-referenced pages in that case. IO completion (like
> > bio_check_pages_dirty(), bio_release_pages() etc.) will check the flag and
> > use approprite release function.
> 
> I'm very new to bio, so I have to ask: can we be sure that the same types of 
> pages are always used, within each bio? Because otherwise, we'll have to plumb 
> it all the way down to bio_vec's--or so it appears, based on my reading of 
> bio_release_pages() and surrounding code.

No, we cannot be sure (the zero page usage within DIO code is one example
when it currently is not true) although usually it is the case that same
type of pages is used for one bio. But bio_add_page() (and thus similarly
bio_add_user_page()) is fine to refuse adding a page to the bio and the
caller then has to submit the current bio and start a new one. So we can
just reuse this mechanism when we detect that currently passed page is of a
different type than other pages in the bio.

> > 3) I have noticed fs/direct-io.c may submit zero page for IO when it needs
> > to clear stuff so we'll probably need a helper function to acquire 'user pin'
> > reference given a page pointer so that that code can be kept reasonably
> > simple and pass user_page references all around.
> >
> 
> This only works if we don't set page flags, because if we do set page flags 
> on the single, global zero page, that will break the world. So I'm not sure
> that the zero page usage in fs/directio.c is going to survive the conversion
> to this new approach. :)

Hum, we can always allocate single page filled with zeros for the use by
DIO code itself. But at this point I'm actually not sure why "user pinning"
of zero page would be an issue. After all if you have private anonymous
read-only mapping, it is going to be backed by zero pages and
get_user_pages() and put_user_pages() have to propely detect pin attempts
for these pages and handle them consistently... So DIO code does not seem
to be doing anything that special.

> > So this way we could maintain reasonable confidence that refcounts didn't
> > get mixed up. Thoughts?
> > 
> 
> After thinking some more about the complicated situations in bio and DRM,
> and looking into the future (bug reports...), I am leaning toward your 
> struct user_page approach. 
> 
> I'm looking forward to hearing other opinions on whether it's worth it to go
> and do this fairly intrusive change, in return for, probably, fewer bugs along
> the way.

Yeah, at this point I think it is worth it as it's probably going to save
us quite some hair-tearing when debugging stuff.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
