Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0E00D6B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 15:25:56 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so1734340eek.20
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 12:25:56 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id r9si12020537eeo.212.2014.01.10.12.25.55
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 12:25:56 -0800 (PST)
Date: Fri, 10 Jan 2014 22:23:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
Message-ID: <20140110202310.GB1421@node.dhcp.inet.fi>
References: <1389383718-46031-1-git-send-email-athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389383718-46031-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Fri, Jan 10, 2014 at 01:55:18PM -0600, Alex Thorlton wrote:
> This patch adds an mm flag (MMF_THP_DISABLE) to disable transparent
> hugepages using prctl.  It is based on my original patch to add a
> per-task_struct flag to disable THP:
> 
> v1 - https://lkml.org/lkml/2013/8/2/671
> v2 - https://lkml.org/lkml/2013/8/2/703
> 
> After looking at alternate methods of modifying how THPs are handed out,
> it sounds like people might be more in favor of this type of approach,
> so I'm re-introducing the patch.
> 
> It seemed that everyone was in favor of moving this control over to the
> mm_struct, if it is to be implemented.  That's the only major change
> here, aside from the added ability to both set and clear the flag from
> prctl.
> 
> The main motivation behind this patch is to provide a way to disable THP
> for jobs where the code cannot be modified and using a malloc hook with
> madvise is not an option (i.e. statically allocated data).  This patch
> allows us to do just that, without affecting other jobs running on the
> system.
> 
> Here are some results showing the improvement that my test case gets
> when the MMF_THP_DISABLE flag is clear vs. set:
> 
> MMF_THP_DISABLE clear:
> 
> # perf stat -a -r 3 ./prctl_wrapper_mm 0 ./thp_pthread -C 0 -m 0 -c 512 -b 256g
> 
>  Performance counter stats for './prctl_wrapper_mm 0 ./thp_pthread -C 0 -m 0 -c 512 -b 256g' (3 runs):
> 
>   267694862.049279 task-clock                #  641.100 CPUs utilized            ( +-  0.23% ) [100.00%]
>            908,846 context-switches          #    0.000 M/sec                    ( +-  0.23% ) [100.00%]
>                874 CPU-migrations            #    0.000 M/sec                    ( +-  4.01% ) [100.00%]
>            131,966 page-faults               #    0.000 M/sec                    ( +-  2.75% )
> 351,127,909,744,906 cycles                    #    1.312 GHz                      ( +-  0.27% ) [100.00%]
> 523,537,415,562,692 stalled-cycles-frontend   #  149.10% frontend cycles idle     ( +-  0.26% ) [100.00%]
> 392,400,753,609,156 stalled-cycles-backend    #  111.75% backend  cycles idle     ( +-  0.29% ) [100.00%]
> 147,467,956,557,895 instructions              #    0.42  insns per cycle
>                                              #    3.55  stalled cycles per insn  ( +-  0.09% ) [100.00%]
> 26,922,737,309,021 branches                  #  100.572 M/sec                    ( +-  0.24% ) [100.00%]
>      1,308,714,545 branch-misses             #    0.00% of all branches          ( +-  0.18% )
> 
>      417.555688399 seconds time elapsed                                          ( +-  0.23% )
> 
> 
> MMF_THP_DISABLE set:
> 
> # perf stat -a -r 3 ./prctl_wrapper_mm 1 ./thp_pthread -C 0 -m 0 -c 512 -b 256g
> 
>  Performance counter stats for './prctl_wrapper_mm 1 ./thp_pthread -C 0 -m 0 -c 512 -b 256g' (3 runs):
> 
>   141674994.160138 task-clock                #  642.107 CPUs utilized            ( +-  0.23% ) [100.00%]
>          1,190,415 context-switches          #    0.000 M/sec                    ( +- 42.87% ) [100.00%]
>                688 CPU-migrations            #    0.000 M/sec                    ( +-  2.47% ) [100.00%]
>         62,394,646 page-faults               #    0.000 M/sec                    ( +-  0.00% )
> 156,748,225,096,919 cycles                    #    1.106 GHz                      ( +-  0.20% ) [100.00%]
> 211,440,354,290,433 stalled-cycles-frontend   #  134.89% frontend cycles idle     ( +-  0.40% ) [100.00%]
> 114,304,536,881,102 stalled-cycles-backend    #   72.92% backend  cycles idle     ( +-  0.88% ) [100.00%]
> 179,939,084,230,732 instructions              #    1.15  insns per cycle
>                                              #    1.18  stalled cycles per insn  ( +-  0.26% ) [100.00%]
> 26,659,099,949,509 branches                  #  188.171 M/sec                    ( +-  0.72% ) [100.00%]
>        762,772,361 branch-misses             #    0.00% of all branches          ( +-  0.97% )
> 
>      220.640905073 seconds time elapsed                                          ( +-  0.23% )
> 
> As you can see, this particular test gets about a 2x performance boost
> when THP is turned off. 

Do you know what cause the difference? I prefer to fix THP instead of
adding new knob to disable it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
