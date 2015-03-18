Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E7BFC6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 18:31:02 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so55870308pdb.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 15:31:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k6si5698881pdp.70.2015.03.18.15.31.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 15:31:01 -0700 (PDT)
Date: Wed, 18 Mar 2015 15:31:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
Message-Id: <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
In-Reply-To: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, danielmicay@gmail.com, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>

On Tue, 17 Mar 2015 14:09:39 -0700 Shaohua Li <shli@fb.com> wrote:

> There was a similar patch posted before, but it doesn't get merged. I'd like
> to try again if there are more discussions.
> http://marc.info/?l=linux-mm&m=141230769431688&w=2
> 
> mremap can be used to accelerate realloc. The problem is mremap will
> punch a hole in original VMA, which makes specific memory allocator
> unable to utilize it. Jemalloc is an example. It manages memory in 4M
> chunks. mremap a range of the chunk will punch a hole, which other
> mmap() syscall can fill into. The 4M chunk is then fragmented, jemalloc
> can't handle it.

Daniel's changelog had additional details regarding the userspace
allocators' behaviour.  It would be best to incorporate that into your
changelog.

Daniel also had microbenchmark testing results for glibc and jemalloc. 
Can you please do this?

I'm not seeing any testing results for tcmalloc and I'm not seeing
confirmation that this patch will be useful for tcmalloc.  Has anyone
tried it, or sought input from tcmalloc developers?

> This patch adds a new flag for mremap. With it, mremap will not punch the
> hole. page tables of original vma will be zapped in the same way, but
> vma is still there. That is original vma will look like a vma without
> pagefault. Behavior of new vma isn't changed.
> 
> For private vma, accessing original vma will cause
> page fault and just like the address of the vma has never been accessed.
> So for anonymous, new page/zero page will be fault in. For file mapping,
> new page will be allocated with file reading for cow, or pagefault will
> use existing page cache.
> 
> For shared vma, original and new vma will map to the same file. We can
> optimize this without zaping original vma's page table in this case, but
> this patch doesn't do it yet.
> 
> Since with MREMAP_NOHOLE, original vma still exists. pagefault handler
> for special vma might not able to handle pagefault for mremap'd area.
> The patch doesn't allow vmas with VM_PFNMAP|VM_MIXEDMAP flags do NOHOLE
> mremap.

At some point (preferably an early point) we'd like a manpage update
and a cc: to linux-man@vger.kernel.org please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
