Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3CFC6B57CF
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 12:12:33 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o18-v6so14480078qtm.11
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 09:12:33 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i50-v6si203574qte.298.2018.08.31.09.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 09:12:32 -0700 (PDT)
Date: Fri, 31 Aug 2018 12:12:30 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 5/7] mm/hmm: use a structure for update callback
 parameters
Message-ID: <20180831161230.GA4111@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-6-jglisse@redhat.com>
 <20180830231148.GC28695@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180830231148.GC28695@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Fri, Aug 31, 2018 at 09:11:48AM +1000, Balbir Singh wrote:
> On Fri, Aug 24, 2018 at 03:25:47PM -0400, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > Use a structure to gather all the parameters for the update callback.
> > This make it easier when adding new parameters by avoiding having to
> > update all callback function signature.
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  include/linux/hmm.h | 25 +++++++++++++++++--------
> >  mm/hmm.c            | 27 ++++++++++++++-------------
> >  2 files changed, 31 insertions(+), 21 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 1ff4bae7ada7..a7f7600b6bb0 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -274,13 +274,26 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
> >  struct hmm_mirror;
> >  
> >  /*
> > - * enum hmm_update_type - type of update
> > + * enum hmm_update_event - type of update
> >   * @HMM_UPDATE_INVALIDATE: invalidate range (no indication as to why)
> >   */
> > -enum hmm_update_type {
> > +enum hmm_update_event {
> >  	HMM_UPDATE_INVALIDATE,
> >  };
> >  
> > +/*
> > + * struct hmm_update - HMM update informations for callback
> > + *
> > + * @start: virtual start address of the range to update
> > + * @end: virtual end address of the range to update
> > + * @event: event triggering the update (what is happening)
> > + */
> > +struct hmm_update {
> > +	unsigned long start;
> > +	unsigned long end;
> > +	enum hmm_update_event event;
> > +};
> > +
> 
> I wonder if you want to add further information about the range,
> like page_size, I guess the other side does not care about the
> size. Do we care about sending multiple discontig ranges in
> hmm_update? Should it be an array?
> 
> Balbir Singh

This is a range of virtual address if a huge page is fully unmapped
then the range will cover the full huge page. It mirror mmu notifier
range callback because 99% of the time it is just use to pass down
mmu notifier invalidation. So we don't care about multi range at
least not yet.

Nor do we care about page size as it might vary in the range (range
can have a mix of THP and regular page) moreover the device driver
usualy ignore the page size.


Cheers,
Jerome
