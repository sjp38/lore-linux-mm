Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 246F46B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 01:28:11 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 78so515556qky.17
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 22:28:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 53sor79043qtr.9.2018.02.20.22.28.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 22:28:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180220153857.dee8f7d5c904cd7219529312@linux-foundation.org>
References: <20180213014220.2464-1-ying.huang@intel.com> <20180213154123.9f4ef9e406ea8365ca46d9c5@linux-foundation.org>
 <87fu64jthz.fsf@yhuang-dev.intel.com> <20180216153823.ad74f1d2c157adc67ed2c970@linux-foundation.org>
 <CAC=cRTMuDtuwCqTK+0UfaTrKcVHzuN4YkHLnH3Yn7FkxknKXtw@mail.gmail.com> <20180220153857.dee8f7d5c904cd7219529312@linux-foundation.org>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Wed, 21 Feb 2018 14:28:08 +0800
Message-ID: <CAC=cRTP1=PLbiL+VCy3xa4DkQj4j5=M_+eNEGqCRtW0hcbekQw@mail.gmail.com>
Subject: Re: [PATCH -mm -v5 RESEND] mm, swap: Fix race between swapoff and
 some swap operations
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, jglisse@redhat.com, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Wed, Feb 21, 2018 at 7:38 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 18 Feb 2018 09:06:47 +0800 huang ying <huang.ying.caritas@gmail.com> wrote:
>
>> >> >> +struct swap_info_struct *get_swap_device(swp_entry_t entry)
>> >> >> +{
>> >> >> +  struct swap_info_struct *si;
>> >> >> +  unsigned long type, offset;
>> >> >> +
>> >> >> +  if (!entry.val)
>> >> >> +          goto out;
>> >> >> +  type = swp_type(entry);
>> >> >> +  if (type >= nr_swapfiles)
>> >> >> +          goto bad_nofile;
>> >> >> +  si = swap_info[type];
>> >> >> +
>> >> >> +  preempt_disable();
>> >> >
>> >> > This preempt_disable() is later than I'd expect.  If a well-timed race
>> >> > occurs, `si' could now be pointing at a defunct entry.  If that
>> >> > well-timed race include a swapoff AND a swapon, `si' could be pointing
>> >> > at the info for a new device?
>> >>
>> >> struct swap_info_struct pointed to by swap_info[] will never be freed.
>> >> During swapoff, we only free the memory pointed to by the fields of
>> >> struct swap_info_struct.  And when swapon, we will always reuse
>> >> swap_info[type] if it's not NULL.  So it should be safe to dereference
>> >> swap_info[type] with preemption enabled.
>> >
>> > That's my point.  If there's a race window during which there is a
>> > parallel swapoff+swapon, this swap_info_struct may now be in use for a
>> > different device?
>>
>> Yes.  It's possible.  And the caller of get_swap_device() can live
>> with it if the swap_info_struct has been fully initialized.  For
>> example, for the race in the patch description,
>>
>> do_swap_page
>>   swapin_readahead
>>     __read_swap_cache_async
>>       swapcache_prepare
>>         __swap_duplicate
>>
>> in __swap_duplicate(), it's possible that the swap device returned by
>> get_swap_device() is different from the swap device when
>> __swap_duplicate() call get_swap_device().  But the struct_info_struct
>> has been fully initialized, so __swap_duplicate() can reference
>> si->swap_map[] safely.  And we will check si->swap_map[] before any
>> further operation.  Even if the swap entry is swapped out again for
>> the new swap device, we will check the page table again in
>> do_swap_page().  So there is no functionality problem.
>
> That's rather revolting.  Can we tighten this up?  Or at least very
> loudly document it?

TBH, I think my original fix patch which uses a reference count in
swap_info_struct is easier to be understood.  But I understand it has
its own drawbacks too.  Anyway, unless there are some better ideas to
resolve this, I will send out a new version with more document.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
