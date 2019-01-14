Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65A0B8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 09:54:51 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so9084983edm.20
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 06:54:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b6si4204230edc.315.2019.01.14.06.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 06:54:49 -0800 (PST)
Date: Mon, 14 Jan 2019 15:54:47 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190114145447.GJ13316@quack2.suse.cz>
References: <20190103015533.GA15619@redhat.com>
 <20190103092654.GA31370@quack2.suse.cz>
 <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri 11-01-19 19:06:08, John Hubbard wrote:
> On 1/11/19 6:46 PM, Jerome Glisse wrote:
> > On Fri, Jan 11, 2019 at 06:38:44PM -0800, John Hubbard wrote:
> > [...]
> > 
> >>>> The other idea that you and Dan (and maybe others) pointed out was a debug
> >>>> option, which we'll certainly need in order to safely convert all the call
> >>>> sites. (Mirror the mappings at a different kernel offset, so that put_page()
> >>>> and put_user_page() can verify that the right call was made.)  That will be
> >>>> a separate patchset, as you recommended.
> >>>>
> >>>> I'll even go as far as recommending the page lock itself. I realize that this 
> >>>> adds overhead to gup(), but we *must* hold off page_mkclean(), and I believe
> >>>> that this (below) has similar overhead to the notes above--but is *much* easier
> >>>> to verify correct. (If the page lock is unacceptable due to being so widely used,
> >>>> then I'd recommend using another page bit to do the same thing.)
> >>>
> >>> Please page lock is pointless and it will not work for GUP fast. The above
> >>> scheme do work and is fine. I spend the day again thinking about all memory
> >>> ordering and i do not see any issues.
> >>>
> >>
> >> Why is it that page lock cannot be used for gup fast, btw?
> > 
> > Well it can not happen within the preempt disable section. But after
> > as a post pass before GUP_fast return and after reenabling preempt then
> > it is fine like it would be for regular GUP. But locking page for GUP
> > is also likely to slow down some workload (with direct-IO).
> > 
> 
> Right, and so to crux of the matter: taking an uncontended page lock
> involves pretty much the same set of operations that your approach does.
> (If gup ends up contended with the page lock for other reasons than these
> paths, that seems surprising.) I'd expect very similar performance.
> 
> But the page lock approach leads to really dramatically simpler code (and
> code reviews, let's not forget). Any objection to my going that
> direction, and keeping this idea as a Plan B? I think the next step will
> be, once again, to gather some performance metrics, so maybe that will
> help us decide.

FWIW I agree that using page lock for protecting page pinning (and thus
avoid races with page_mkclean()) looks simpler to me as well and I'm not
convinced there will be measurable difference to the more complex scheme
with barriers Jerome suggests unless that page lock contended. Jerome is
right that you cannot just do lock_page() in gup_fast() path. There you
have to do trylock_page() and if that fails just bail out to the slow gup
path.

Regarding places other than page_mkclean() that need to check pinned state:
Definitely page migration will want to check whether the page is pinned or
not so that it can deal differently with short-term page references vs
longer-term pins.

Also there is one more idea I had how to record number of pins in the page:

#define PAGE_PIN_BIAS	1024

get_page_pin()
	atomic_add(&page->_refcount, PAGE_PIN_BIAS);

put_page_pin();
	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);

page_pinned(page)
	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS

This is pretty trivial scheme. It still gives us 22-bits for page pins
which should be plenty (but we should check for that and bail with error if
it would overflow). Also there will be no false negatives and false
positives only if there are more than 1024 non-page-table references to the
page which I expect to be rare (we might want to also subtract
hpage_nr_pages() for radix tree references to avoid excessive false
positives for huge pages although at this point I don't think they would
matter). Thoughts?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
