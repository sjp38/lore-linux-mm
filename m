Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57FDC6B0253
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 12:13:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z77so1600369wmc.16
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 09:13:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p198si1302433wmg.181.2017.10.23.09.13.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 09:13:17 -0700 (PDT)
Date: Mon, 23 Oct 2017 18:13:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
Message-ID: <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 23-10-17 16:00:13, C.Wehrmeyer wrote:
[...]
> > And that is what we have THP for...
> 
> Then I might have been using it incorrectly? I've been digging through
> Documentation/vm/transhuge.txt after your initial pointing out, and verified
> that the kernel uses THPs pretty much always, without the usage of madvise:
> 
> # cat /sys/kernel/mm/transparent_hugepage/enabled
> [always] madvise never

OK

> And just to be very sure I've added:
> 
> if (madvise(buf1,ALLOC_SIZE_1,MADV_HUGEPAGE)) {
>         errno_tmp = errno;
>         fprintf(stderr,"madvise: %u\n",errno_tmp);
>         goto out;
> }
> 
> /*Make sure the mapping is actually used*/
> memset(buf1,'!',ALLOC_SIZE_1);

Is the buffer aligned to 2MB?
 
> /*Give me time for monitoring*/
> sleep(2000);
> 
> right after the mmap call. I've also made sure that nothing is being
> optimised away by the compiler. With a 2MiB mapping being requested this
> should be a good opportunity for the kernel, and yet when I try to figure
> out how many THPs my processes uses:
> 
> $ cat /proc/21986/smaps  | grep 'AnonHuge'
> 
> I just end up with lots of:
> 
> AnonHugePages:         0 kB
> 
> And cat /proc/meminfo | grep 'Huge' doesn't change significantly as well. Am
> I just doing something wrong here, or shouldn't I trust the THP mechanisms
> to actually allocate hugepages for me?

If the mapping is aligned properly then the rest is up to system and
availability of large physically contiguous memory blocks.

> > General purpose allocator playing with hugetlb
> > pages is rather tricky and I would be really cautious there. I would
> > rather play with THP to reduce the TLB footprint.
> 
> May one ask why you'd recommend to be cautious here? I understand that
> actual huge pages can slow down certain things - swapping comes to mind
> immediately, which is probably the reason why Linux (used to?) lock such
> pages in memory as well.

THP shouldn't cause any significant slowdown or other issues (these
days). The main reason for the static pre allocated huge pages pool
(hugetlb) was a guarantee of the huge pages availability. Such a
pool has not been reclaimable. This brings an obvious issues, e.g.
unreclaimable huge pages will reduce the amount of usable memory for the
rest of the system so you should really think how much to reserve to not
get into memory short situations. That makes a general purpose hugetlb
pages usage rather challenging.

THP on the other hand can come and go as the system is able to
create/keep them without userspace involvement. You can hint a range by
madvise and the system will try harder to give you THP.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
