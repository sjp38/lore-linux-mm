Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4438E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 22:14:09 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 80so11268279qkd.0
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 19:14:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 63si152013qth.271.2019.01.11.19.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 19:14:08 -0800 (PST)
Date: Fri, 11 Jan 2019 22:14:01 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190112031401.GC5059@redhat.com>
References: <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com>
 <20190103092654.GA31370@quack2.suse.cz>
 <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Jan 11, 2019 at 06:38:44PM -0800, John Hubbard wrote:
> On 1/11/19 6:02 PM, Jerome Glisse wrote:
> > On Fri, Jan 11, 2019 at 05:04:05PM -0800, John Hubbard wrote:
> >> On 1/11/19 8:51 AM, Jerome Glisse wrote:
> >>> On Thu, Jan 10, 2019 at 06:59:31PM -0800, John Hubbard wrote:
> >>>> On 1/3/19 6:44 AM, Jerome Glisse wrote:
> >>>>> On Thu, Jan 03, 2019 at 10:26:54AM +0100, Jan Kara wrote:
> >>>>>> On Wed 02-01-19 20:55:33, Jerome Glisse wrote:
> >>>>>>> On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
> >>>>>>>> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> >>>>>>>>> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> >>> [...]
> >>
> >> Hi Jerome,
> >>
> >> Looks good, in a conceptual sense. Let me do a brain dump of how I see it,
> >> in case anyone spots a disastrous conceptual error (such as the lock_page
> >> point), while I'm putting together the revised patchset.
> >>
> >> I've studied this carefully, and I agree that using mapcount in 
> >> this way is viable, *as long* as we use a lock (or a construct that looks just 
> >> like one: your "memory barrier, check, retry" is really just a lock) in
> >> order to hold off gup() while page_mkclean() is in progress. In other words,
> >> nothing that increments mapcount may proceed while page_mkclean() is running.
> > 
> > No, increment to page->_mapcount are fine while page_mkclean() is running.
> > The above solution do work no matter what happens thanks to the memory
> > barrier. By clearing the pin flag first and reading the page->_mapcount
> > after (and doing the reverse in GUP) we know that a racing GUP will either
> > have its pin page clear but the incremented mapcount taken into account by
> > page_mkclean() or page_mkclean() will miss the incremented mapcount but
> > it will also no clear the pin flag set concurrently by any GUP.
> > 
> > Here are all the possible time line:
> > [T1]:
> > GUP on CPU0                      | page_mkclean() on CPU1
> >                                  |
> > [G2] atomic_inc(&page->mapcount) |
> > [G3] smp_wmb();                  |
> > [G4] SetPagePin(page);           |
> >                                 ...
> >                                  | [C1] pined = TestClearPagePin(page);
> 
> It appears that you're using the "page pin is clear" to indicate that
> page_mkclean() is running. The problem is, that approach leads to toggling
> the PagePin flag, and so an observer (other than gup or page_mkclean) will
> see intervals during which the PagePin flag is clear, when conceptually it
> should be set.

Also forgot to stress that i am not using the pin flag to report page_mkclean
is running, i am clearing it first because clearing that bit is the thing
that is racy. If we clear it first and then read map and pin count and then
count number of real mapping we get a proper ordering and we will always
detect pined page and properly restore the pin flag at the end of page_mkclean.

In fact GUP or PUP never need to check if the flag is clear. The check in
GUP in my pseudo code is an optimization for the write back ordering (no
need to do any ordering if the pin flag was already set before the current
GUP).

Cheers,
Jérôme
