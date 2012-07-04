Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 11F366B006C
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:08:20 -0400 (EDT)
Received: by yenr5 with SMTP id r5so8080381yen.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 08:08:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4OdDhn5C_vfMhu3ejzzcXmCCt6r0h=nXUqKJaNYZxg8Bw@mail.gmail.com>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	<1340390729-2821-1-git-send-email-js1304@gmail.com>
	<CAOJsxLHSboF0rQdGv8bdgGtinBz5dTo+omQbUnj9on_ewzgNAQ@mail.gmail.com>
	<CAAmzW4OdDhn5C_vfMhu3ejzzcXmCCt6r0h=nXUqKJaNYZxg8Bw@mail.gmail.com>
Date: Wed, 4 Jul 2012 18:08:18 +0300
Message-ID: <CAOJsxLGBxeu2sE-wDT+YNyVipmXiPj7Gvmmdo-0zGmJObp2zxg@mail.gmail.com>
Subject: Re: [PATCH 1/3 v2] slub: prefetch next freelist pointer in __slab_alloc()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, David Rientjes <rientjes@google.com>

> 2012/7/4 Pekka Enberg <penberg@kernel.org>:
>> Well, can you show improvement in any benchmark or workload?
>> Prefetching is not always an obvious win and the reason we merged
>> Eric's patch was that he was able to show an improvement in hackbench.

On Wed, Jul 4, 2012 at 5:30 PM, JoonSoo Kim <js1304@gmail.com> wrote:
> I thinks that this patch is perfectly same effect as Eric's patch, so
> doesn't include benchmark result.
> Eric's patch which add "prefetch instruction" in fastpath works for
> second ~ last object of cpu slab.
> This patch which add "prefetch instrunction" in slowpath works for
> first object of cpu slab.

Prefetching can also have negative effect on overall performance:

http://lwn.net/Articles/444336/

> But, I do test "./perf stat -r 20 ./hackbench 50 process 4000 >
> /dev/null" and gain following outputs.
>
> ***** vanilla *****
>
>  Performance counter stats for './hackbench 50 process 4000' (20 runs):
>
>      114189.571311 task-clock                #    7.924 CPUs utilized
>           ( +-  0.29% )
>          2,978,515 context-switches          #    0.026 M/sec
>           ( +-  3.45% )
>            102,635 CPU-migrations            #    0.899 K/sec
>           ( +-  5.63% )
>            123,948 page-faults               #    0.001 M/sec
>           ( +-  0.16% )
>    422,477,120,134 cycles                    #    3.700 GHz
>           ( +-  0.29% )
>    <not supported> stalled-cycles-frontend
>    <not supported> stalled-cycles-backend
>    251,943,851,074 instructions              #    0.60  insns per
> cycle          ( +-  0.14% )
>     46,214,207,979 branches                  #  404.715 M/sec
>           ( +-  0.15% )
>        215,342,095 branch-misses             #    0.47% of all
> branches          ( +-  0.53% )
>
>       14.409990448 seconds time elapsed
>           ( +-  0.30% )
>
>  Performance counter stats for './hackbench 50 process 4000' (20 runs):
>
>      114576.053284 task-clock                #    7.921 CPUs utilized
>           ( +-  0.35% )
>          2,810,138 context-switches          #    0.025 M/sec
>           ( +-  3.21% )
>             85,641 CPU-migrations            #    0.747 K/sec
>           ( +-  5.05% )
>            124,299 page-faults               #    0.001 M/sec
>           ( +-  0.18% )
>    423,906,539,517 cycles                    #    3.700 GHz
>           ( +-  0.35% )
>    <not supported> stalled-cycles-frontend
>    <not supported> stalled-cycles-backend
>    251,354,351,283 instructions              #    0.59  insns per
> cycle          ( +-  0.13% )
>     46,098,601,012 branches                  #  402.341 M/sec
>           ( +-  0.13% )
>        213,448,657 branch-misses             #    0.46% of all
> branches          ( +-  0.50% )
>
>       14.464325969 seconds time elapsed
>           ( +-  0.34% )
>
>
> ***** patch applied *****
>
>  Performance counter stats for './hackbench 50 process 4000' (20 runs):
>
>      112935.199731 task-clock                #    7.926 CPUs utilized
>           ( +-  0.29% )
>          2,810,157 context-switches          #    0.025 M/sec
>           ( +-  2.95% )
>            104,278 CPU-migrations            #    0.923 K/sec
>           ( +-  6.83% )
>            123,999 page-faults               #    0.001 M/sec
>           ( +-  0.17% )
>    417,834,406,420 cycles                    #    3.700 GHz
>           ( +-  0.29% )
>    <not supported> stalled-cycles-frontend
>    <not supported> stalled-cycles-backend
>    251,291,523,926 instructions              #    0.60  insns per
> cycle          ( +-  0.11% )
>     46,083,091,476 branches                  #  408.049 M/sec
>           ( +-  0.12% )
>        213,714,228 branch-misses             #    0.46% of all
> branches          ( +-  0.43% )
>
>       14.248980376 seconds time elapsed
>           ( +-  0.29% )
>
>  Performance counter stats for './hackbench 50 process 4000' (20 runs):
>
>      113640.944855 task-clock                #    7.926 CPUs utilized
>           ( +-  0.28% )
>          2,776,983 context-switches          #    0.024 M/sec
>           ( +-  5.66% )
>             95,962 CPU-migrations            #    0.844 K/sec
>           ( +- 10.69% )
>            123,849 page-faults               #    0.001 M/sec
>           ( +-  0.15% )
>    420,446,572,595 cycles                    #    3.700 GHz
>           ( +-  0.28% )
>    <not supported> stalled-cycles-frontend
>    <not supported> stalled-cycles-backend
>    251,174,259,429 instructions              #    0.60  insns per
> cycle          ( +-  0.21% )
>     46,060,683,039 branches                  #  405.318 M/sec
>           ( +-  0.23% )
>        213,480,999 branch-misses             #    0.46% of all
> branches          ( +-  0.75% )
>
>       14.336843534 seconds time elapsed
>           ( +-  0.28% )

That doesn't seem like that obvious win to me... Eric, Christoph?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
