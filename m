Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9336B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:25:37 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so73087122wib.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:25:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jj2si11713231wid.42.2015.03.26.10.25.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 10:25:35 -0700 (PDT)
Message-ID: <5514410C.7090408@suse.cz>
Date: Thu, 26 Mar 2015 18:25:32 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com> <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org> <550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com> <5512E0C0.6060406@suse.cz> <55131F70.7020503@gmail.com> <alpine.DEB.2.10.1503251710400.31453@chino.kir.corp.google.com> <551351CA.3090803@gmail.com> <alpine.DEB.2.10.1503251914260.16714@chino.kir.corp.google.com> <55137C06.9020608@gmail.com>
In-Reply-To: <55137C06.9020608@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>, David Rientjes <rientjes@google.com>
Cc: Aliaksey Kandratsenka <alkondratenko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

On 03/26/2015 04:24 AM, Daniel Micay wrote:
> It's all well and good to say that you shouldn't do that, but it's the
> basis of the design in jemalloc and other zone-based arena allocators.
>
> There's a chosen chunk size and chunks are naturally aligned. An
> allocation is either a span of chunks (chunk-aligned) or has metadata
> stored in the chunk header. This also means chunks can be assigned to
> arenas for a high level of concurrency. Thread caching is then only
> necessary for batching operations to amortize the cost of locking rather
> than to reduce contention. Per-CPU arenas can be implemented quite well
> by using sched_getcpu() to move threads around whenever it detects that
> another thread allocated from the arena.
>
> With >= 2M chunks, madvise purging works very well at the chunk level
> but there's also fine-grained purging within chunks and it completely
> breaks down from THP page faults.

Are you sure it's due to page faults and not khugepaged + high value 
(such as the default 511) of max_ptes_none? As reported here?

https://bugzilla.kernel.org/show_bug.cgi?id=93111

Once you have faulted in a THP, and then purged part of it and split it, 
I don't think page faults in the purged part can lead to a new THP 
collapse, only khugepaged can do that AFAIK.
And if you mmap smaller than 2M areas (i.e. your 256K chunks), that 
should prevent THP page faults on the first fault within the chunk as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
