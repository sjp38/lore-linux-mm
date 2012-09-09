Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 7FECF6B0044
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 23:46:12 -0400 (EDT)
Received: by iagk10 with SMTP id k10so1016884iag.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 20:46:11 -0700 (PDT)
Message-ID: <504C1100.2050300@vflare.org>
Date: Sat, 08 Sep 2012 20:46:08 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com> <e33a2c0e-3b51-4d89-a2b2-c1ed9c8f862c@default> <20120907143751.GB4670@phenom.dumpdata.com>
In-Reply-To: <20120907143751.GB4670@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 09/07/2012 07:37 AM, Konrad Rzeszutek Wilk wrote:
>> significant design challenges exist, many of which are already resolved in
>> the new codebase ("zcache2").  These design issues include:
> .. snip..
>> Before other key mm maintainers read and comment on zcache, I think
>> it would be most wise to move to a codebase which resolves the known design
>> problems or, at least to thoroughly discuss and debunk the design issues
>> described above.  OR... it may be possible to identify and pursue some
>> compromise plan.  In any case, I believe the promotion proposal is premature.
>
> Thank you for the feedback!
>
> I took your comments and pasted them in this patch.
>
> Seth, Robert, Minchan, Nitin, can you guys provide some comments pls,
> so we can put them as a TODO pls or modify the patch below.
>
> Oh, I think I forgot Andrew's comment which was:
>
>   - Explain which workloads this benefits and provide some benchmark data.
>     This should help in narrowing down in which case we know zcache works
>     well and in which it does not.
>
> My TODO's were:
>
>   - Figure out (this could be - and perhaps should be in frontswap) a
>     determination whether this swap is quite fast and the CPU is slow
>     (or taxed quite heavily now), so as to not slow the currently executing
>     workloads.
>   - Work out automatic benchmarks in three categories: database (I am going to use
>     swing for that), compile (that one is easy), and firefox tab browsers
>     overloading.
>
>
>  From bd85d5fa0cc231f2779f3209ee62b755caf3aa9b Mon Sep 17 00:00:00 2001
> From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Date: Fri, 7 Sep 2012 10:21:01 -0400
> Subject: [PATCH] zsmalloc/zcache: TODO list.
>
> Adding in comments by Dan.
>
> Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>   drivers/staging/zcache/TODO   |   21 +++++++++++++++++++++
>   drivers/staging/zsmalloc/TODO |   17 +++++++++++++++++
>   2 files changed, 38 insertions(+), 0 deletions(-)
>   create mode 100644 drivers/staging/zcache/TODO
>   create mode 100644 drivers/staging/zsmalloc/TODO
>
> diff --git a/drivers/staging/zcache/TODO b/drivers/staging/zcache/TODO
> new file mode 100644
> index 0000000..bf19a01
> --- /dev/null
> +++ b/drivers/staging/zcache/TODO
> @@ -0,0 +1,21 @@
> +
> +A) Andrea Arcangeli pointed out and, after some deep thinking, I came
> +   to agree that zcache _must_ have some "backdoor exit" for frontswap
> +   pages [2], else bad things will eventually happen in many workloads.
> +   This requires some kind of reaper of frontswap'ed zpages[1] which "evicts"
> +   the data to the actual swap disk.  This reaper must ensure it can reclaim
> +   _full_ pageframes (not just zpages) or it has little value.  Further the
> +   reaper should determine which pageframes to reap based on an LRU-ish
> +   (not random) approach.
> +
> +B) Zcache uses zbud(v1) for cleancache pages and includes a shrinker which
> +   reclaims pairs of zpages to release whole pageframes, but there is
> +   no attempt to shrink/reclaim cleanache pageframes in LRU order.
> +   It would also be nice if single-cleancache-pageframe reclaim could
> +   be implemented.
> +
> +C) Offer a mechanism to select whether zbud or zsmalloc should be used.
> +   This should be for either cleancache or frontswap pages. Meaning there
> +   are four choices: cleancache and frontswap using zbud; cleancache and
> +   frontswap using zsmalloc; cleancache using zsmalloc, frontswap using zbud;
> +   cleacache using zbud, and frontswap using zsmalloc.
> diff --git a/drivers/staging/zsmalloc/TODO b/drivers/staging/zsmalloc/TODO
> new file mode 100644
> index 0000000..b1debad
> --- /dev/null
> +++ b/drivers/staging/zsmalloc/TODO
> @@ -0,0 +1,17 @@
> +
> +A) Zsmalloc has potentially far superior density vs zbud because zsmalloc can
> +   pack more zpages into each pageframe and allows for zpages that cross pageframe
> +   boundaries.  But, (i) this is very data dependent... the average compression
> +   for LZO is about 2x.  The frontswap'ed pages in the kernel compile benchmark
> +   compress to about 4x, which is impressive but probably not representative of
> +   a wide range of zpages and workloads.  And (ii) there are many historical
> +   discussions going back to Knuth and mainframes about tight packing of data...
> +   high density has some advantages but also brings many disadvantages related to
> +   fragmentation and compaction.  Zbud is much less aggressive (max two zpages
> +   per pageframe) but has a similar density on average data, without the
> +   disadvantages of high density.
> +
> +   So zsmalloc may blow zbud away on a kernel compile benchmark but, if both were
> +   runners, zsmalloc is a sprinter and zbud is a marathoner.  Perhaps the best
> +   solution is to offer both?
> +
>

The problem is that zbud performs well only when a (compressed) page is 
either PAGE_SIZE/2 - e or PAGE_SIZE - e, where e is small. So, even if 
the average compression ratio is 2x (which is hard to believe), a 
majority of sizes can actually end up in PAGE_SIZE/2 + e bucket and zbud 
will still give bad performance.  For instance, consider these histograms:

# Created tar of /usr/lib (2GB) on a fairly loaded Linux system and 
compressed page-by-page using LZO:

# first two fields: bin start, end.  Third field: compressed size
32 286 7644
286 540 4226
540 794 11868
794 1048 20356
1048 1302 43443
1302 1556 39374
1556 1810 32903
1810 2064 37631
2064 2318 42400
2318 2572 51921
2572 2826 56255
2826 3080 59346
3080 3334 36545
3334 3588 12872
3588 3842 6513
3842 4096 3482

The only (approx) sweetspots for zbud are 1810-2064 and 3842-4096 which 
covers only a small fraction of pages.

# same page-by-page compression for 220MB ISO from project Gutenberg:
32 286 70
286 540 68
540 794 43
794 1048 36
1048 1302 46
1302 1556 78
1556 1810 142
1810 2064 244
2064 2318 561
2318 2572 1272
2572 2826 3889
2826 3080 17826
3080 3334 3896
3334 3588 358
3588 3842 465
3842 4096 804

Again very few pages in zbud favoring bins.

So, we really need zsmalloc style allocator which handles sizes all over 
the spectrum. But yes, compaction remains far easier to implement on zbud.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
