Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 94B516B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 01:37:47 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so65580315pdn.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 22:37:47 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g11si799950pdk.12.2015.03.18.22.37.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 22:37:46 -0700 (PDT)
Date: Wed, 18 Mar 2015 22:08:26 -0700
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
Message-ID: <20150319050826.GA1591708@devbig257.prn2.facebook.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
 <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, danielmicay@gmail.com, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>

On Wed, Mar 18, 2015 at 03:31:00PM -0700, Andrew Morton wrote:
> On Tue, 17 Mar 2015 14:09:39 -0700 Shaohua Li <shli@fb.com> wrote:
> 
> > There was a similar patch posted before, but it doesn't get merged. I'd like
> > to try again if there are more discussions.
> > http://marc.info/?l=linux-mm&m=141230769431688&w=2
> > 
> > mremap can be used to accelerate realloc. The problem is mremap will
> > punch a hole in original VMA, which makes specific memory allocator
> > unable to utilize it. Jemalloc is an example. It manages memory in 4M
> > chunks. mremap a range of the chunk will punch a hole, which other
> > mmap() syscall can fill into. The 4M chunk is then fragmented, jemalloc
> > can't handle it.
> 
> Daniel's changelog had additional details regarding the userspace
> allocators' behaviour.  It would be best to incorporate that into your
> changelog.

I'll extract some from his changelog in next post
 
> Daniel also had microbenchmark testing results for glibc and jemalloc. 
> Can you please do this?

I run Daniel's microbenchmark too, and not surprise the result is
similar:
glibc: 32.82
jemalloc: 70.35
jemalloc+mremap: 33.01
tcmalloc: 68.81

but tcmalloc doesn't support mremap currently, so I cant test it.
 
> I'm not seeing any testing results for tcmalloc and I'm not seeing
> confirmation that this patch will be useful for tcmalloc.  Has anyone
> tried it, or sought input from tcmalloc developers?
> 
> > This patch adds a new flag for mremap. With it, mremap will not punch the
> > hole. page tables of original vma will be zapped in the same way, but
> > vma is still there. That is original vma will look like a vma without
> > pagefault. Behavior of new vma isn't changed.
> > 
> > For private vma, accessing original vma will cause
> > page fault and just like the address of the vma has never been accessed.
> > So for anonymous, new page/zero page will be fault in. For file mapping,
> > new page will be allocated with file reading for cow, or pagefault will
> > use existing page cache.
> > 
> > For shared vma, original and new vma will map to the same file. We can
> > optimize this without zaping original vma's page table in this case, but
> > this patch doesn't do it yet.
> > 
> > Since with MREMAP_NOHOLE, original vma still exists. pagefault handler
> > for special vma might not able to handle pagefault for mremap'd area.
> > The patch doesn't allow vmas with VM_PFNMAP|VM_MIXEDMAP flags do NOHOLE
> > mremap.
> 
> At some point (preferably an early point) we'd like a manpage update
> and a cc: to linux-man@vger.kernel.org please.

ok, will add in next post.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
