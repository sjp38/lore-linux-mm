Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF416B006E
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 12:22:29 -0400 (EDT)
Received: by wixw10 with SMTP id w10so78380945wix.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:22:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si23505582wik.1.2015.03.25.09.22.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 09:22:27 -0700 (PDT)
Message-ID: <5512E0C0.6060406@suse.cz>
Date: Wed, 25 Mar 2015 17:22:24 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>	<550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com>
In-Reply-To: <550E6D9D.1060507@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>, Aliaksey Kandratsenka <alkondratenko@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

On 03/22/2015 08:22 AM, Daniel Micay wrote:
> BTW, THP currently interacts very poorly with the jemalloc/tcmalloc
> madvise purging. The part where khugepaged assigns huge pages to dense
> spans of pages is*great*. The part where the kernel hands out a huge
> page on for a fault in a 2M span can be awful. It causes the model
> inside the allocator of uncommitted vs. committed pages to break down.
>
> For example, the allocator might use 1M of a huge page and then start
> purging. The purging will split it into 4k pages, so there will be 1M of
> zeroed 4k pages that are considered purged by the allocator. Over time,
> this can cripple purging. Search for "jemalloc huge pages" and you'll
> find lots of horror stories about this.

I'm not sure I get your description right. The problem I know about is 
where "purging" means madvise(MADV_DONTNEED) and khugepaged later 
collapses a new hugepage that will repopulate the purged parts, 
increasing the memory usage. One can limit this via 
/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none . That 
setting doesn't affect the page fault THP allocations, which however 
happen only in newly accessed hugepage-sized areas and not partially 
purged ones, though.

> I think a THP implementation playing that played well with purging would
> need to drop the page fault heuristic and rely on a significantly better
> khugepaged.

See here http://lwn.net/Articles/636162/ (the "Compaction" part)

The objection is that some short-lived workloads like gcc have to map 
hugepages immediately if they are to benefit from them. I still plan to 
improve khugepaged and allow admins to say that they don't want THP page 
faults (and rely solely on khugepaged which has more information to 
judge additional memory usage), but I'm not sure if it would be an 
acceptable default behavior.
One workaround in the current state for jemalloc and friends could be to 
use madvise(MADV_NOHUGEPAGE) on hugepage-sized/aligned areas where it 
wants to purge parts of them via madvise(MADV_DONTNEED). It could mean 
overhead of another syscall and tracking of where this was applied and 
when it makes sense to undo this and allow THP to be collapsed again, 
though, and it would also split vma's.

> This would mean faulting in a span of memory would no longer
> be faster. Having a flag to populate a range with madvise would help a

If it's a newly mapped memory, there's mmap(MAP_POPULATE). There is also 
a madvise(MADV_WILLNEED), which sounds like what you want, but I don't 
know what the implementation does exactly - it was apparently added for 
paging in ahead, and maybe it ignores unpopulated anonymous areas, but 
it would probably be well in spirit of the flag to make it prepopulate 
those.

> lot though, since the allocator knows exactly how much it's going to
> clobber with the memcpy. There will still be a threshold where mremap
> gets significantly faster, but it would move it higher.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
