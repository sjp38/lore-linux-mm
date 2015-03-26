Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A09686B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:50:22 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so45302829pdb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:50:22 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id r1si5873025pdp.197.2015.03.25.17.50.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 17:50:21 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so45912797pac.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:50:21 -0700 (PDT)
Date: Thu, 26 Mar 2015 09:50:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
Message-ID: <20150326005009.GA7658@blaptop>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
 <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
 <550A5FF8.90504@gmail.com>
 <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
 <20150323051731.GA2616341@devbig257.prn2.facebook.com>
 <CADpJO7zk8J3q7Bw9NibV9CzLarO+YkfeshyFTTq=XeS5qziBiA@mail.gmail.com>
 <55117724.6030102@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55117724.6030102@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Aliaksey Kandratsenka <alkondratenko@gmail.com>, Shaohua Li <shli@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

Hello Daniel,

On Tue, Mar 24, 2015 at 10:39:32AM -0400, Daniel Micay wrote:
> On 24/03/15 01:25 AM, Aliaksey Kandratsenka wrote:
> > 
> > Well, I don't have any workloads. I'm just maintaining a library that
> > others run various workloads on. Part of the problem is lack of good
> > and varied malloc benchmarks which could allow us that prevent
> > regression. So this makes me a bit more cautious on performance
> > matters.
> > 
> > But I see your point. Indeed I have no evidence at all that exclusive
> > locking might cause observable performance difference.
> 
> I'm sure it matters but I expect you'd need *many* cores running many
> threads before it started to outweigh the benefit of copying pages
> instead of data.
> 
> Thinking about it a bit more, it would probably make sense for mremap to
> start with the optimistic assumption that the reader lock is enough here
> when using MREMAP_NOHOLE|MREMAP_FIXED. It only needs the writer lock if
> the destination mapping is incomplete or doesn't match, which is an edge
> case as holes would mean thread unsafety.
> 
> An ideal allocator will toggle on PROT_NONE when overcommit is disabled
> so this assumption would be wrong. The heuristic could just be adjusted
> to assume the dest VMA will match with MREMAP_NOHOLE|MREMAP_FIXED when
> full memory accounting isn't enabled. The fallback would never ended up
> being needed in existing use cases that I'm aware of, and would just add
> the overhead of a quick lock, O(log n) check and unlock with the reader
> lock held anyway. Another flag isn't really necessary.
> 
> >>> Another notable thing is how mlock effectively disables MADV_DONTNEED for
> >>> jemalloc{1,2} and tcmalloc, lowers page faults count and thus improves
> >>> runtime. It can be seen that tcmalloc+mlock on thp-less configuration is
> >>> slightly better on runtime to glibc. The later spends a ton of time in
> >>> kernel,
> >>> probably handling minor page faults, and the former burns cpu in user space
> >>> doing memcpy-s. So "tons of memcpys" seems to be competitive to what glibc
> >>> is
> >>> doing in this benchmark.
> >>
> >> mlock disables MADV_DONTNEED, so this is an unfair comparsion. With it,
> >> allocator will use more memory than expected.
> > 
> > Do not agree with unfair. I'm actually hoping MADV_FREE to provide
> > most if not all of benefits of mlock in this benchmark. I believe it's
> > not too unreasonable expectation.
> 
> MADV_FREE will still result in as many page faults, just no zeroing.

I didn't follow this thread. However, as you mentioned MADV_FREE will
make many page fault, I jump into here.
One of the benefit with MADV_FREE in current implementation is to
avoid page fault as well as no zeroing.
Why did you see many page fault?


> 
> I get ~20k requests/s with jemalloc on the ebizzy benchmark with this
> dual core ivy bridge laptop. It jumps to ~60k requests/s with MADV_FREE
> IIRC, but disabling purging via MALLOC_CONF=lg_dirty_mult:-1 leads to
> 3.5 *million* requests/s. It has a similar impact with TCMalloc.

When I tested MADV_FREE with ebizzy, I saw similar result two or three
times fater than MADV_DONTNEED. But It's no free cost. It incurs MADV_FREE
cost itself*(ie, enumerating all of page table in the range and clear
dirty bit and tlb flush). Of course, it has mmap_sem with read-side lock.
If you see great improve when you disable purging, I guess mainly it's
caused by no lock of mmap_sem so some threads can allocate while other
threads can do page fault. The reason I think so is I saw similar result
when I implemented vrange syscall which hold mmap_sem read-side lock
during very short time(ie, marking the volatile into vma, ie O(1) while
MADV_FREE holds a lock during enumerating all of pages in the range, ie O(N))

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
