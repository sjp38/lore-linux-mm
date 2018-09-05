Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFC06B74F3
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 16:18:39 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m13-v6so8618619ioq.9
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 13:18:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q15-v6sor1464691jam.107.2018.09.05.13.18.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 13:18:36 -0700 (PDT)
MIME-Version: 1.0
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183345.4416.76515.stgit@localhost.localdomain> <20180905062428.GV14951@dhcp22.suse.cz>
In-Reply-To: <20180905062428.GV14951@dhcp22.suse.cz>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 5 Sep 2018 13:18:24 -0700
Message-ID: <CAKgT0UeT1dL0VNMo1RSDkjABYBGLKjMsz5LsE_ML-EV+w2OURg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Create non-atomic version of SetPageReserved for
 init use
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, pavel.tatashin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 4, 2018 at 11:24 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 04-09-18 11:33:45, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> >
> > It doesn't make much sense to use the atomic SetPageReserved at init time
> > when we are using memset to clear the memory and manipulating the page
> > flags via simple "&=" and "|=" operations in __init_single_page.
> >
> > This patch adds a non-atomic version __SetPageReserved that can be used
> > during page init and shows about a 10% improvement in initialization times
> > on the systems I have available for testing.
>
> I agree with Dave about a comment is due. I am also quite surprised that
> this leads to such a large improvement. Could you be more specific about
> your test and machines you were testing on?

So my test case has been just initializing 4 3TB blocks of persistent
memory with a few trace_printk values added to track total time in
move_pfn_range_to_zone.

What I have been seeing is that the time needed for the call drops on
average from 35-36 seconds down to around 31-32.

> Other than that the patch makes sense to me.
>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>
> With the above addressed, feel free to add
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> Thanks!

As far as adding a comment are we just talking about why it is
reserved, or do we need a description of the __SetPageReserved versus
SetPageReserved. For now I was looking at adding a comment like:
@@ -5517,8 +5517,13 @@ void __meminit memmap_init_zone(unsigned long
size, int nid, unsigned long zone,
 not_early:
                page = pfn_to_page(pfn);
                __init_single_page(page, pfn, zone, nid);
+
+               /*
+                * Mark page reserved as it will need to wait for onlining
+                * phase for it to be fully associated with a zone.
+                */
                if (context == MEMMAP_HOTPLUG)
-                       SetPageReserved(page);
+                       __SetPageReserved(page);

                /*
                 * Mark the block movable so that blocks are reserved for

Any thoughts on this?

Thanks.

- Alex
