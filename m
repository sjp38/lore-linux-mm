Received: by wr-out-0506.google.com with SMTP id i11so282639wra
        for <linux-mm@kvack.org>; Tue, 27 Jun 2006 11:51:28 -0700 (PDT)
Message-ID: <29495f1d0606271151w164202e8uce762b155a93ff1f@mail.gmail.com>
Date: Tue, 27 Jun 2006 11:51:25 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: slow hugetlb from 2.6.15
In-Reply-To: <20060627182325.GE6380@blackhole.websupport.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060627182325.GE6380@blackhole.websupport.sk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "stanojr@blackhole.websupport.sk" <stanojr@blackhole.websupport.sk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/27/06, stanojr@blackhole.websupport.sk
<stanojr@blackhole.websupport.sk> wrote:
> hello
>
> look at this benchmark
> http://www-unix.mcs.anl.gov/~kazutomo/hugepage/note.html
> i try benchmark it on latest 2.6.17.1 (x86 and x86_64) and it slow like 2.6.16 on
> that web
> (in comparing to standard 4kb page)
> its feature or bug ?
> i am just interested where can be hugepages used, but if they are slower than
> normal pages its pointless to use it :)

I believe your benchmark is measuring the time in such a way to make
current kernels look worse than older ones.

Basically, newer kernels (the ones that have the performance issue
you're seeing) use demand faulting of hugepages.

Thus, timing only the bench() call, as is done now, causes the newer
kernels to appear to take longer, as the pages must be zero'd, and the
page tables must be set up, as part of the bench() invocation (first
use).

In contrast, the older kernels would have done that up front, and thus
that time was not being accounted for in the bench() run.

There are a few ways to make sure this is the case:

1) Time the mmap, bench and unmap calls all together.

2) Add memset(addr, 1, LENGTH) and memset(addr, 0, LENGTH) calls
*before* bench(), to fault in the hugepages before running bench().

If the numbers return to normal after this, then the analysis above
should be accurate. If not, we do have a problem.

Thanks to Andy Whitcroft and Mel Gorman for insight into the potential problem.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
