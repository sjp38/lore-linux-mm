Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 92E6F6B0070
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 05:19:24 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id o19so2158725qap.14
        for <linux-mm@kvack.org>; Wed, 05 Dec 2012 02:19:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50bec4af.0aad2a0a.2fc9.6fe5SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1347798342-2830-1-git-send-email-linkinjeon@gmail.com>
	<20120920084422.GA5697@localhost>
	<20120925013658.GC23520@dastard>
	<CAKYAXd975U_n2SSFXz0VfEs6GrVCoc2S=3kQbfw_2uOtGXbGxA@mail.gmail.com>
	<CAKYAXd-BXOrXJDMo5_ANACn2qo3J5oM3vMJD-LXnEacegxHgTA@mail.gmail.com>
	<20121022012555.GB2739@dastard>
	<CAKYAXd-BzgVvhbGE=OcSeXSMFe+5NdTt3L1A6Synds4vZ9vc2A@mail.gmail.com>
	<50bec4af.0aad2a0a.2fc9.6fe5SMTPIN_ADDED_BROKEN@mx.google.com>
Date: Wed, 5 Dec 2012 19:19:23 +0900
Message-ID: <CAKYAXd_qj0-R7M6ZDUTjW+QLHZz0MEr9CXdQqcNxS7F9OZsY5w@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] writeback: add dirty_background_centisecs per bdi variable
From: Namjae Jeon <linkinjeon@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

2012/12/5, Wanpeng Li <liwanp@linux.vnet.ibm.com>:
> Hi Namjae,
>
> How about set bdi->dirty_background_bytes according to bdi_thresh? I found
> an issue during background flush process when review codes, if over
> background
> flush threshold, wb_check_background_flush will kick a work to current
> per-bdi
> flusher, but maybe it is other heavy dirties written in other bdis who
> heavily
> dirty pages instead of current bdi, the worst case is current bdi has many
> frequently used data and flush lead to cache thresh. How about add a check
> in wb_check_background_flush if it is not current bdi who contributes large
>
> number of dirty pages to background flush threshold(over
> bdi->dirty_background_bytes),
> then don't bother it.

Hi Wanpeng.

First, Thanks for your suggestion!
Yes, I think that it looks reasonable.
I will start checking it.

Thanks.
>
> Regards,
> Wanpeng Li
>
> On Tue, Nov 20, 2012 at 08:18:59AM +0900, Namjae Jeon wrote:
>>2012/10/22, Dave Chinner <david@fromorbit.com>:
>>> On Fri, Oct 19, 2012 at 04:51:05PM +0900, Namjae Jeon wrote:
>>>> Hi Dave.
>>>>
>>>> Test Procedure:
>>>>
>>>> 1) Local USB disk WRITE speed on NFS server is ~25 MB/s
>>>>
>>>> 2) Run WRITE test(create 1 GB file) on NFS Client with default
>>>> writeback settings on NFS Server. By default
>>>> bdi->dirty_background_bytes = 0, that means no change in default
>>>> writeback behaviour
>>>>
>>>> 3) Next we change bdi->dirty_background_bytes = 25 MB (almost equal to
>>>> local USB disk write speed on NFS Server)
>>>> *** only on NFS Server - not on NFS Client ***
>>>
>>> Ok, so the results look good, but it's not really addressing what I
>>> was asking, though.  A typical desktop PC has a disk that can do
>>> 100MB/s and GbE, so I was expecting a test that showed throughput
>>> close to GbE maximums at least (ie. around that 100MB/s). I have 3
>>> year old, low end, low power hardware (atom) that hanles twice the
>>> throughput you are testing here, and most current consumer NAS
>>> devices are more powerful than this. IOWs, I think the rates you are
>>> testing at are probably too low even for the consumer NAS market to
>>> consider relevant...
>>>
>>>> ----------------------------------------------------------------------------------
>>>> Multiple NFS Client test:
>>>> -----------------------------------------------------------------------------------
>>>> Sorry - We could not arrange multiple PCs to verify this.
>>>> So, we tried 1 NFS Server + 2 NFS Clients using 3 target boards:
>>>> ARM Target + 512 MB RAM + ethernet - 100 Mbits/s, create 1 GB File
>>>
>>> But this really doesn't tells us anything - it's still only 100Mb/s,
>>> which we'd expect is already getting very close to line rate even
>>> with low powered client hardware.
>>>
>>> What I'm concerned about the NFS server "sweet spot" - a $10k server
>>> that exports 20TB of storage and can sustain close to a GB/s of NFS
>>> traffic over a single 10GbE link with tens to hundreds of clients.
>>> 100MB/s and 10 clients is about the minimum needed to be able to
>>> extrapolate a litle and make an informed guess of how it will scale
>>> up....
>>>
>>>> > 1. what's the comparison in performance to typical NFS
>>>> > server writeback parameter tuning? i.e. dirty_background_ratio=5,
>>>> > dirty_ratio=10, dirty_expire_centiseconds=1000,
>>>> > dirty_writeback_centisecs=1? i.e. does this give change give any
>>>> > benefit over the current common practice for configuring NFS
>>>> > servers?
>>>>
>>>> Agreed, that above improvement in write speed can be achieved by
>>>> tuning above write-back parameters.
>>>> But if we change these settings, it will change write-back behavior
>>>> system wide.
>>>> On the other hand, if we change proposed per bdi setting,
>>>> bdi->dirty_background_bytes it will change write-back behavior for the
>>>> block device exported on NFS server.
>>>
>>> I already know what the difference between global vs per-bdi tuning
>>> means.  What I want to know is how your results compare
>>> *numerically* to just having a tweaked global setting on a vanilla
>>> kernel.  i.e. is there really any performance benefit to per-bdi
>>> configuration that cannot be gained by existing methods?
>>>
>>>> > 2. what happens when you have 10 clients all writing to the server
>>>> > at once? Or a 100? NFS servers rarely have a single writer to a
>>>> > single file at a time, so what impact does this change have on
>>>> > multiple concurrent file write performance from multiple clients
>>>>
>>>> Sorry, we could not arrange more than 2 PCs for verifying this.
>>>
>>> Really? Well, perhaps there's some tools that might be useful for
>>> you here:
>>>
>>> http://oss.sgi.com/projects/nfs/testtools/
>>>
>>> "Weber
>>>
>>> Test load generator for NFS. Uses multiple threads, multiple
>>> sockets and multiple IP addresses to simulate loads from many
>>> machines, thus enabling testing of NFS server setups with larger
>>> client counts than can be tested with physical infrastructure (or
>>> Virtual Machine clients). Has been useful in automated NFS testing
>>> and as a pinpoint NFS load generator tool for performance
>>> development."
>>>
>>
>>Hi Dave,
>>We ran "weber" test on below setup:
>>1) SATA HDD - Local WRITE speed ~120 MB/s, NFS WRITE speed ~90 MB/s
>>2) Used 10GbE - network interface to mount NFS
>>
>>We ran "weber" test with  NFS clients ranging from 1 to 100,
>>below is the % GAIN in NFS WRITE speed with
>>bdi->dirty_background_bytes = 100 MB at NFS server
>>
>>-------------------------------------------------
>>| Number of NFS Clients |% GAIN in WRITE Speed  |
>>|-----------------------------------------------|
>>|         1             |     19.83 %           |
>>|-----------------------------------------------|
>>|         2             |      2.97 %           |
>>|-----------------------------------------------|
>>|         3             |      2.01 %           |
>>|-----------------------------------------------|
>>|        10             |      0.25 %           |
>>|-----------------------------------------------|
>>|        20             |      0.23 %           |
>>|-----------------------------------------------|
>>|        30             |      0.13 %           |
>>|-----------------------------------------------|
>>|       100             |    - 0.60 %           |
>>-------------------------------------------------
>>
>>with bdi->dirty_background_bytes setting at NFS server, we observed
>>that NFS WRITE speed improvement is maximum with single NFS client.
>>But WRITE speed improvement drops when Number of NFS clients increase
>>from 1 to 100.
>>
>>So, bdi->dirty_background_bytes setting might be useful where we have
>>only one NFS client(scenario like ours).
>>But this is not useful for big NFS Servers which host hundreads of NFS
>> clients.
>>
>>Let me know your opinion.
>>
>>Thanks.
>>
>>>> > 3. Following on from the multiple client test, what difference does
>>>> > it
>>>> > make to file fragmentation rates? Writing more frequently means
>>>> > smaller allocations and writes, and that tends to lead to higher
>>>> > fragmentation rates, especially when multiple files are being
>>>> > written concurrently. Higher fragmentation also means lower
>>>> > performance over time as fragmentation accelerates filesystem aging
>>>> > effects on performance.  IOWs, it may be faster when new, but it
>>>> > will be slower 3 months down the track and that's a bad tradeoff to
>>>> > make.
>>>>
>>>> We agree that there could be bit more framentation. But as you know,
>>>> we are not changing writeback settings at NFS clients.
>>>> So, write-back behavior on NFS client will not change - IO requests
>>>> will be buffered at NFS client as per existing write-back behavior.
>>>
>>> I think you misunderstand - writeback settings on the server greatly
>>> impact the way the server writes data and therefore the way files
>>> are fragmented. It has nothing to do with client side tuning.
>>>
>>> Effectively, what you are presenting is best case numbers - empty
>>> filesystem, single client, streaming write, no fragmentation, no
>>> allocation contention, no competing IO load that causes write
>>> latency occurring.  Testing with lots of clients introduces all of
>>> these things, and that will greatly impact server behaviour.
>>> Aggregation in memory isolates a lot of this variation from
>>> writeback and hence smooths out a lot of the variability that leads
>>> to fragmentation, seeks, latency spikes and preamture filesystem
>>> aging.
>>>
>>> That is, if you set a 100MB dirty_bytes limit on a bdi it will give
>>> really good buffering for a single client doing a streaming write.
>>> If you've got 10 clients, then assuming fair distribution of server
>>> resources, then that is 10MB per client per writeback trigger.
>>> That's line ball as to whether it will cause fragmentation severe
>>> enough to impact server throughput. If you've got 100 clients,then
>>> that's only 1MB per client per writeback trigger, and that's
>>> definitely too low to maintain decent writeback behaviour.  i.e.
>>> you're now writing 100 files 1MB at a time, and that tends towards
>>> random IO patterns rather than sequential IO patterns. Seek time
>>> dertermines throughput, not IO bandwidth limits.
>>>
>>> IOWs, as the client count goes up, the writeback patterns will tends
>>> more towards random IO than sequential IO unless the amount of
>>> buffering allowed before writeback triggers also grows. That's
>>> important, because random IO is much slower than sequential IO.
>>> What I'd like to have is some insight into whether this patch
>>> changes that inflection point, for better or for worse. The only way
>>> to find that is to run multi-client testing....
>>>
>>>> > 5. Are the improvements consistent across different filesystem
>>>> > types?  We've had writeback changes in the past cause improvements
>>>> > on one filesystem but significant regressions on others.  I'd
>>>> > suggest that you need to present results for ext4, XFS and btrfs so
>>>> > that we have a decent idea of what we can expect from the change to
>>>> > the generic code.
>>>>
>>>> As mentioned in the above Table 1 & 2, performance gain in WRITE speed
>>>> is different on different file systems i.e. different on NFS client
>>>> over XFS & EXT4.
>>>> We also tried BTRFS over NFS, but we could not see any WRITE speed
>>>> performance gain/degrade on BTRFS over NFS, so we are not posting
>>>> BTRFS results here.
>>>
>>> You should post btrfs numbers even if they show no change. It wasn't
>>> until I got this far that I even realised that you'd even tested
>>> BTRFS. I don't know what to make of this, because I don't know what
>>> the throughput rates compared to XFS and EXT4 are....
>>>
>>> Cheers,
>>>
>>> Dave.
>>> --
>>> Dave Chinner
>>> david@fromorbit.com
>>>
>>--
>>To unsubscribe from this list: send the line "unsubscribe linux-fsdevel"
>> in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
