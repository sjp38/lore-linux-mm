Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 521546B000A
	for <linux-mm@kvack.org>; Mon, 28 May 2018 04:29:12 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id a21-v6so10322656qtp.19
        for <linux-mm@kvack.org>; Mon, 28 May 2018 01:29:12 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z60-v6si7284779qvz.49.2018.05.28.01.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 01:29:11 -0700 (PDT)
Date: Mon, 28 May 2018 16:28:46 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180528082846.GA7884@dhcp-128-65.nay.redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524085610.GA5467@dhcp-128-65.nay.redhat.com>
 <e70de03e-6965-749a-6c3c-ecf6dcb60c71@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e70de03e-6965-749a-6c3c-ecf6dcb60c71@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On 05/24/18 at 11:14am, David Hildenbrand wrote:
> On 24.05.2018 10:56, Dave Young wrote:
> > Hi,
> > 
> > [snip]
> >>>
> >>>> For kdump and onlining/offlining code, we
> >>>> have to mark pages as offline before a new segment is visible to the system
> >>>> (e.g. as these pages might not be backed by real memory in the hypervisor).
> >>>
> >>> Please expand on the kdump part. That is really confusing because
> >>> hotplug should simply not depend on kdump at all. Moreover why don't you
> >>> simply mark those pages reserved and pull them out from the page
> >>> allocator?
> >>
> >> 1. "hotplug should simply not depend on kdump at all"
> >>
> >> In theory yes. In the current state we already have to trigger kdump to
> >> reload whenever we add/remove a memory block.
> >>
> >>
> >> 2. kdump part
> >>
> >> Whenever we offline a page and tell the hypervisor about it ("unplug"),
> >> we should not assume that we can read that page again. Now, if dumping
> >> tools assume they can read all memory that is offline, we are in trouble.
> >>
> >> It is the same thing as we already have with Pg_hwpoison. Just a
> >> different meaning - "don't touch this page, it is offline" compared to
> >> "don't touch this page, hw is broken".
> > 
> > Does that means in case an offline no kdump reload as mentioned in 1)?
> > 
> > If we have the offline event and reload kdump, I assume the memory state
> > is refreshed so kdump will not read the memory offlined, am I missing
> > something?
> 
> If a whole section is offline: yes. (ACPI hotplug)
> 
> If pages are online but broken ("logically offline" - hwpoison): no
> 
> If single pages are logically offline: no. (Balloon inflation - let's
> call it unplug as that's what some people refer to)
> 
> If only subsections (4MB chunks) are offline: no.
> 
> Exporting memory ranges in a smaller granularity to kdump than section
> size would a) be heavily complicated b) introduce a lot of overhead for
> this tracking data c) make us retrigger kdump way too often.
> 
> So simply marking pages offline in the struct pages and telling kdump
> about it is the straight forward thing to do. And it is fairly easy to
> add and implement as we have the exact same thing in place for hwpoison.

Ok, it is clear enough.   If case fine grained page offline is is like
a hwpoison page so a userspace patch for makedumpfile is needes to
exclude them when copying vmcore.

> 
> > 
> >>
> >> Balloon drivers solve this problem by always allowing to read unplugged
> >> memory. In virtio-mem, this cannot and should even not be guaranteed.
> >>
> > 
> > Hmm, that sounds a bug..
> 
> I can give you a simple example why reading such unplugged (or balloon
> inflated) memory is problematic: Huge page backed guests.
> 
> There is no zero page for huge pages. So if we allow the guest to read
> that memory any time, we cannot guarantee that we actually consume less
> memory in the hypervisor. This is absolutely to be avoided.
> 
> Existing balloon drivers don't support huge page backed guests. (well
> you can inflate, but the hypervisor cannot madvise() 4k on a huge page,
> resulting in no action being performed). This scenario is to be
> supported with virtio-mem.
> 
> 
> So yes, this is actually a bug in e.g. virtio-balloon implementations:
> 
> With "VIRTIO_BALLOON_F_MUST_TELL_HOST" we have to tell the hypervisor
> before we access a page again. kdump cannot do this and does not care,
> so this page is silently accessed and dumped. One of the main problems
> why extending virtio-balloon hypervisor implementations to support
> host-enforced R/W protection is impossible.

I'm not sure I got all virt related background, but still thank you
for the detailed explanation.  This is the first time I heard about
this, nobody complained before :(

> 
> > 
> >> And what we have to do to make this work is actually pretty simple: Just
> >> like Pg_hwpoison, track per page if it is online and provide this
> >> information to kdump.
> >>
> >>
> > 
> > Thanks
> > Dave
> > 
> 
> 
> -- 
> 
> Thanks,
> 
> David / dhildenb

Thanks
Dave
