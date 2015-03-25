Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 45B6C6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 01:02:35 -0400 (EDT)
Received: by ykfc206 with SMTP id c206so7434355ykf.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 22:02:35 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b6si634822ykf.163.2015.03.24.22.02.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 22:02:33 -0700 (PDT)
Date: Tue, 24 Mar 2015 22:02:13 -0700
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
Message-ID: <20150325050213.GA343154@devbig257.prn2.facebook.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
 <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
 <550A5FF8.90504@gmail.com>
 <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
 <20150323051731.GA2616341@devbig257.prn2.facebook.com>
 <CADpJO7zk8J3q7Bw9NibV9CzLarO+YkfeshyFTTq=XeS5qziBiA@mail.gmail.com>
 <55117724.6030102@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <55117724.6030102@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Aliaksey Kandratsenka <alkondratenko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

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
> 
> I get ~20k requests/s with jemalloc on the ebizzy benchmark with this
> dual core ivy bridge laptop. It jumps to ~60k requests/s with MADV_FREE
> IIRC, but disabling purging via MALLOC_CONF=lg_dirty_mult:-1 leads to
> 3.5 *million* requests/s. It has a similar impact with TCMalloc.

MADV_FREE has side effect (exactly like if you use mlock), which causes
more memory are used. It's lazy memory free, so if there is no memory
pressure, you can think MADV_FREE is a nop. It's undoubt you will see
improvement in such case. But if there is memory pressure, it is
completely different story.
 
> >> I'm kind of confused why we talk about THP, mlock here. When application
> >> uses allocator, it doesn't need to be forced to use THP or mlock. Can we
> >> forcus on normal case?
> > 
> > See my note on mlock above.
> > 
> > THP it is actually "normal". I know for certain, that many production
> > workloads are run on boxes with THP enabled. Red Hat famously ships
> > it's distros with THP set to "always". And I also know that some other
> > many production workloads are run on boxes with THP disabled. Also, as
> > seen above, "teleporting" pages is more efficient with THP due to much
> > smaller overhead of moving those pages. So I felt it was important not
> > to omit THP in my runs.
> 
> Yeah, it's quite normal for it to be enabled. Allocators might as well
> give up on fine-grained purging when it is though :P. I think it only
> really makes sense to purge at 2M boundaries in multiples of 2M if it's
> going to end up breaking any other purging over the long-term.
> 
> I was originally only testing with THP since Arch uses "always" but I
> realized it had an enormous impact and started testing without it too.

Hmm, I didn't intend to ignore THP, but just can't understand why it's
matter. There is extra overhead when purge or mremap THP pages (if range
isn't 2M aligned in multiple of 2M), but other than that, there is no
other difference to me, but your test result doesn't suggest this. Guess
we should understand why THP makes so big difference.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
