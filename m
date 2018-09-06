Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE5536B7718
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 01:41:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c25-v6so3150167edb.12
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 22:41:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w37-v6si3390749edb.15.2018.09.05.22.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 22:41:58 -0700 (PDT)
Date: Thu, 6 Sep 2018 07:41:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Create non-atomic version of SetPageReserved for
 init use
Message-ID: <20180906054157.GI14951@dhcp22.suse.cz>
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183345.4416.76515.stgit@localhost.localdomain>
 <20180905062428.GV14951@dhcp22.suse.cz>
 <CAKgT0UeT1dL0VNMo1RSDkjABYBGLKjMsz5LsE_ML-EV+w2OURg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UeT1dL0VNMo1RSDkjABYBGLKjMsz5LsE_ML-EV+w2OURg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, pavel.tatashin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 05-09-18 13:18:24, Alexander Duyck wrote:
> On Tue, Sep 4, 2018 at 11:24 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 04-09-18 11:33:45, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > >
> > > It doesn't make much sense to use the atomic SetPageReserved at init time
> > > when we are using memset to clear the memory and manipulating the page
> > > flags via simple "&=" and "|=" operations in __init_single_page.
> > >
> > > This patch adds a non-atomic version __SetPageReserved that can be used
> > > during page init and shows about a 10% improvement in initialization times
> > > on the systems I have available for testing.
> >
> > I agree with Dave about a comment is due. I am also quite surprised that
> > this leads to such a large improvement. Could you be more specific about
> > your test and machines you were testing on?
> 
> So my test case has been just initializing 4 3TB blocks of persistent
> memory with a few trace_printk values added to track total time in
> move_pfn_range_to_zone.
> 
> What I have been seeing is that the time needed for the call drops on
> average from 35-36 seconds down to around 31-32.

This information belongs to the changelog.

> 
> > Other than that the patch makes sense to me.
> >
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> >
> > With the above addressed, feel free to add
> > Acked-by: Michal Hocko <mhocko@suse.com>
> >
> > Thanks!
> 
> As far as adding a comment are we just talking about why it is
> reserved, or do we need a description of the __SetPageReserved versus
> SetPageReserved. For now I was looking at adding a comment like:

the later. The reason why we make it reserved should be quite clear. A
comment wouldn't hurt of course and what you have is a good start. But
it is usually atomic vs. non-atomic SetPage$Foo which needs some
clarification.

> @@ -5517,8 +5517,13 @@ void __meminit memmap_init_zone(unsigned long
> size, int nid, unsigned long zone,
>  not_early:
>                 page = pfn_to_page(pfn);
>                 __init_single_page(page, pfn, zone, nid);
> +
> +               /*
> +                * Mark page reserved as it will need to wait for onlining
> +                * phase for it to be fully associated with a zone.
> +                */
>                 if (context == MEMMAP_HOTPLUG)
> -                       SetPageReserved(page);
> +                       __SetPageReserved(page);
> 
>                 /*
>                  * Mark the block movable so that blocks are reserved for
> 
> Any thoughts on this?
> 
> Thanks.
> 
> - Alex

-- 
Michal Hocko
SUSE Labs
