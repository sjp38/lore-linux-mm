Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A49A46B7504
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 16:35:25 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h5-v6so8928469itb.3
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 13:35:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h198-v6sor1415892ioe.150.2018.09.05.13.35.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 13:35:24 -0700 (PDT)
MIME-Version: 1.0
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183345.4416.76515.stgit@localhost.localdomain> <20180905062428.GV14951@dhcp22.suse.cz>
 <CAKgT0UeT1dL0VNMo1RSDkjABYBGLKjMsz5LsE_ML-EV+w2OURg@mail.gmail.com> <ec060d9b-d313-417c-4389-2ac7b482f94c@microsoft.com>
In-Reply-To: <ec060d9b-d313-417c-4389-2ac7b482f94c@microsoft.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 5 Sep 2018 13:35:11 -0700
Message-ID: <CAKgT0UdtgaZv5sjAcSe8-UYsxoji4scbJTRvTECZDpt+TPM+FA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Create non-atomic version of SetPageReserved for
 init use
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel.Tatashin@microsoft.com
Cc: mhocko@kernel.org, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Sep 5, 2018 at 1:22 PM Pasha Tatashin
<Pavel.Tatashin@microsoft.com> wrote:
>
>
>
> On 9/5/18 4:18 PM, Alexander Duyck wrote:
> > On Tue, Sep 4, 2018 at 11:24 PM Michal Hocko <mhocko@kernel.org> wrote:
> >>
> >> On Tue 04-09-18 11:33:45, Alexander Duyck wrote:
> >>> From: Alexander Duyck <alexander.h.duyck@intel.com>
> >>>
> >>> It doesn't make much sense to use the atomic SetPageReserved at init time
> >>> when we are using memset to clear the memory and manipulating the page
> >>> flags via simple "&=" and "|=" operations in __init_single_page.
> >>>
> >>> This patch adds a non-atomic version __SetPageReserved that can be used
> >>> during page init and shows about a 10% improvement in initialization times
> >>> on the systems I have available for testing.
> >>
> >> I agree with Dave about a comment is due. I am also quite surprised that
> >> this leads to such a large improvement. Could you be more specific about
> >> your test and machines you were testing on?
> >
> > So my test case has been just initializing 4 3TB blocks of persistent
> > memory with a few trace_printk values added to track total time in
> > move_pfn_range_to_zone.
> >
> > What I have been seeing is that the time needed for the call drops on
> > average from 35-36 seconds down to around 31-32.
>
> Just curious why is there variance? During boot time is usually pretty
> consistent, as there is only one thread and system is in pretty much the
> same state.
>
> A dmesg output in the commit log would be helpful.
>
> Thank you,
> Pavel

The variance has to do with the fact that it is being added via
hot-plug. So in this case the system boots and then after 5 minutes it
then goes about hot-plugging the memory. The memmap_init_zone call
will make regular calls into cond_resched() and it seems like if there
are any other active threads that can end up impacting the timings and
provide a few hundred ms of variation between runs.

In addition there is also NUMA locality that plays a role. I have seen
values as low as 25.5s pre-patch, 23.2 after, and values as high as
39.17 pre-patch, 37.3 after. I am assuming that the lowest values just
happened to luck into being node local, and the highest values end up
being 2 nodes away on the 4 node system I am testing. I'm planning to
try and address the NUMA issues using an approach similar to what the
deferred_init is already doing by trying to start a kernel thread on
the correct node and then probably just waiting on that to complete
outside of the hotplug lock. The solution will end up being a hybrid
probably between the work Dan Williams had submitted a couple months
ago and the existing deferred_init code. But I will be targeting that
for 4.20 at the earliest.

- Alex
