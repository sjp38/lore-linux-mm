Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3A30F6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 22:31:16 -0400 (EDT)
Received: by igcxg11 with SMTP id xg11so42799015igc.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 19:31:16 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id ey4si3839183icb.9.2015.03.25.19.31.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 19:31:15 -0700 (PDT)
Received: by igbqf9 with SMTP id qf9so42357349igb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 19:31:15 -0700 (PDT)
Date: Wed, 25 Mar 2015 19:31:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
In-Reply-To: <551351CA.3090803@gmail.com>
Message-ID: <alpine.DEB.2.10.1503251914260.16714@chino.kir.corp.google.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com> <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org> <550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com>
 <5512E0C0.6060406@suse.cz> <55131F70.7020503@gmail.com> <alpine.DEB.2.10.1503251710400.31453@chino.kir.corp.google.com> <551351CA.3090803@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aliaksey Kandratsenka <alkondratenko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

On Wed, 25 Mar 2015, Daniel Micay wrote:

> > With tcmalloc, it's simple to always expand the heap by mmaping 2MB ranges 
> > for size classes <= 2MB, allocate its own metadata from an arena that is 
> > also expanded in 2MB range, and always do madvise(MADV_DONTNEED) for the 
> > longest span on the freelist when it does periodic memory freeing back to 
> > the kernel, and even better if the freed memory splits at most one 
> > hugepage.  When memory is pulled from the freelist of memory that has 
> > already been returned to the kernel, you can return a span that will make 
> > it eligible to be collapsed into a hugepage based on your setting of 
> > max_ptes_none, trying to consolidate the memory as much as possible.  If 
> > your malloc is implemented in a way to understand the benefit of 
> > hugepages, and how much memory you're willing to sacrifice (max_ptes_none) 
> > for it, then you should _never_ be increasing memory usage by 50%.
> 
> If khugepaged was the only source of huge pages, sure. The primary
> source of huge pages is the heuristic handing out an entire 2M page on
> the first page fault in a 2M range.
> 

The behavior is a property of what you brk() or mmap() to expand your 
heap, you can intentionally require it to fault hugepages or not fault 
hugepages without any special madvise().

With the example above, the implementation I wrote specifically tries to 
sbrk() in 2MB regions and hands out allocator metadata via a memory arena 
doing the same thing.  Memory is treated as being on a normal freelist so 
that it is considered resident, i.e. the same as faulting 4KB, freeing it, 
before tcmalloc does madvise(MADV_DONTNEED), and we naturally prefer to 
hand that out before going to the returned freelist or mmap() as fallback.  
There will always be fragmentation in your normal freelist spans, so 
there's always wasted memory (with or without thp).  There should never be 
a case where you're always mapping 2MB aligned regions and then only 
touching a small portion of it, for >2MB size classes you could easily map 
only the size required and you would never get an excess of memory due to 
thp at fault.

I think this may be tangential to the thread, though, since this has 
nothing to do with mremap() or any new mremap() flag.

If the thp faulting behavior is going to be changed, then it would need to 
be something that is opted into and not by any system tunable or madvise() 
flag.  It would probably need to be a prctl() like PR_SET_THP_DISABLE is 
that would control only fault behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
