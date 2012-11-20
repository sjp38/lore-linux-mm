Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 9FCF86B0088
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 08:20:32 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4599935pbc.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 05:20:31 -0800 (PST)
Message-ID: <50AB8396.4040504@gmail.com>
Date: Tue, 20 Nov 2012 21:20:22 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: fadvise interferes with readahead
References: <CAGTBQpaDR4+V5b1AwAVyuVLu5rkU=Wc1WeUdLu5ag=WOk5oJzQ@mail.gmail.com> <20121120080427.GA11019@localhost>
In-Reply-To: <20121120080427.GA11019@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Claudio Freire <klaussfreire@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On 11/20/2012 04:04 PM, Fengguang Wu wrote:
> Hi Claudio,
>
> Thanks for the detailed problem description!
>
> On Fri, Nov 09, 2012 at 04:30:32PM -0300, Claudio Freire wrote:
>> Hi. First of all, I'm not subscribed to this list, so I'd suggest all
>> replies copy me personally.
>>
>> I have been trying to implement some I/O pipelining in Postgres (ie:
>> read the next data page asynchronously while working on the current
>> page), and stumbled upon some puzzling behavior involving the
>> interaction between fadvise and readahead.
>>
>> I'm running kernel 3.0.0 (debian testing), on a single-disk system
>> which, though unsuitable for database workloads, is slow enough to let
>> me experiment with these read-ahead issues.
>>
>> Typical random I/O performance is on the order of between 150 r/s to
>> 200 r/s (ballpark 7200rpm I'd say), with thoughput around 1.5MB/s.
>> Sequential I/O can go up to 60MB/s, though it tends to be around 50.
>>
>> Now onto the problem. In order to parallelize I/O with computation,
>> I've made postgres fadvise(willneed) the pages it will read next. How
>> far ahead is configurable, and I've tested with a number of
>> configurations.
>>
>> The prefetching logic is aware of the OS and pg-specific cache, so it
>> will only fadvise a block once. fadvise calls will stay 1 (or a
>> configurable N) real I/O ahead of read calls, and there's no fadvising
>> of pages that won't be read eventually, in the same order. I checked
>> with strace.
>>
>> However, performance when fadvising drops considerably for a specific
>> yet common access pattern:
>>
>> When a nested loop with two index scans happens, access is random
>> locally, but eventually whole ranges of a file get read (in this
>> random order). Think block "1 6 8 100 34 299 3 7 68 24" followed by "2
>> 4 5 101 298 301". Though random, there are ranges there that can be
>> merged in one read-request.
>>
>> The kernel seems to do the merge by applying some form of readahead,
>> not sure if it's context, ondemand or adaptive readahead on the 3.0.0
>> kernel. Anyway, it seems to do readahead, as iostat says:
>>
>> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s
>> avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
>> sda               0.00     4.40  224.20    2.00     4.16     0.03
>> 37.86     1.91    8.43    8.00   56.80   4.40  99.44
>>
>> (notice the avgrq-sz of 37.8)
>>
>> With fadvise calls, the thing looks a lot different:
>>
>> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s
>> avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
>> sda               0.00    18.00  226.80    1.00     1.80     0.07
>> 16.81     4.00   17.52   17.23   82.40   4.39  99.92
> FYI, there is a readahead tracing/stats patchset that can provide far
> more accurate numbers about what's going on with readahead, which will
> help eliminate lots of the guess works here.
>
> https://lwn.net/Articles/472798/
>
>> Notice the avgrq-sz of 16.8. Assuming it's 512-byte sectors, that's
>> spot-on with a postgres page (8k). So, fadvise seems to carry out the
>> requests verbatim, while read manages to merge at least two of them.
>>
>> The random nature of reads makes me think the scheduler is failing to
>> merge the requests in both cases (rrqm/s = 0), because it only looks
>> at successive requests (I'm only guessing here though).
> I guess it's not a merging problem, but that the kernel readahead code
> manages to submit larger IO requests in the first place.
>
>> Looking into the kernel code, it seems the problem could be related to
>> how fadvise works in conjunction with readahead. fadvise seems to call
>> the function in readahead.c that schedules the asynchornous I/O[0]. It
>> doesn't seem subject to readahead logic itself[1], which in on itself
>> doesn't seem bad. But it does, I assume (not knowing the code that
>> well), prevent readahead logic[2] to eventually see the pattern. It
>> effectively disables readahead altogether.
> You are right. If user space does fadvise() and the fadvised pages
> cover all read() pages, the kernel readahead code will not run at all.
>
> So the title is actually a bit misleading. The kernel readahead won't
> interfere with user space prefetching at all. ;)
>
>> This, I theorize, may be because after the fadvise call starts an
>> async I/O on the page, further reads won't hit readahead code because
>> of the page cache[3] (!PageUptodate I imagine). Whether this is
>> desirable or not is not really obvious. In this particular case, doing
>> fadvise calls in what would seem an optimum way, results in terribly
>> worse performance. So I'd suggest it's not really that advisable.
> Yes. The kernel readahead code by design will outperform simple
> fadvise in the case of clustered random reads. Imagine the access
> pattern 1, 3, 2, 6, 4, 9. fadvise will trigger 6 IOs literally. While

You mean it will trigger 6 IOs in the POSIX_FADV_RANDOM case or 
POSIX_FADV_WILLNEED case?

> kernel readahead will likely trigger 3 IOs for 1, 3, 2-9. Because on
> the page miss for 2, it will detect the existence of history page 1
> and do readahead properly. For hard disks, it's mainly the number of

If the first IO read 1, it will call page_cache_sync_read() since cache 
miss,
if (offset - (ra->prev_pos) >> PAGE_CACHE_SHIFT) <= 1UL)
     goto initial_readahead;
If the initial_readahead will be called? Because offset is equal to 1 
and ra->prev_pos is equal to 0. If my assume is true, 2 also will be 
readahead.

> IOs that matters. So even if kernel readahead loses some opportunities
> to do async IO and possibly loads some extra pages that will never be
> used, it still manges to perform much better.
>
>> The fix would lay in fadvise, I think. It should update readahead
>> tracking structures. Alternatively, one could try to do it in
>> do_generic_file_read, updating readahead on !PageUptodate or even on
>> page cache hits. I really don't have the expertise or time to go
>> modifying, building and testing the supposedly quite simple patch that
>> would fix this. It's mostly about the testing, in fact. So if someone
>> can comment or try by themselves, I guess it would really benefit
>> those relying on fadvise to fix this behavior.
> One possible solution is to try the context readahead at fadvise time
> to check the existence of history pages and do readahead accordingly.
>
> However it will introduce *real interferences* between kernel
> readahead and user prefetching. The original scheme is, once user
> space starts its own informed prefetching, kernel readahead will
> automatically stand out of the way.
>
> Thanks,
> Fengguang
>
>> Additionally, I would welcome any suggestions for ways to mitigate
>> this problem on current kernels, as the patch I'm working I'd like to
>> deploy with older kernels. Even if the latest kernel had this behavior
>> fixed, I'd still welcome some workarounds.
>>
>> More details on the benchmarks I've run can be found in the postgresql
>> dev ML archive[4].
>>
>> [0] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=blob;f=mm/fadvise.c#l95
>> [1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=blob;f=mm/readahead.c#l211
>> [2] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=blob;f=mm/readahead.c#l398
>> [3] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=blob;f=mm/filemap.c#l1081
>> [4] http://archives.postgresql.org/pgsql-hackers/2012-10/msg01139.php
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
