Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 953806B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 10:48:04 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id t10so316894eei.7
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 07:48:03 -0800 (PST)
Received: from e06smtp18.uk.ibm.com (e06smtp18.uk.ibm.com. [195.75.94.114])
        by mx.google.com with ESMTPS id h9si28542097eev.63.2014.01.28.07.48.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 07:48:03 -0800 (PST)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Tue, 28 Jan 2014 15:48:02 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4A6C317D8062
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:48:19 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0SFllWU48627932
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:47:48 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0SFlxFu004379
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 08:47:59 -0700
Message-ID: <52E7D12E.4070703@linux.vnet.ibm.com>
Date: Tue, 28 Jan 2014 16:47:58 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Resend] Puzzling behaviour with multiple swap targets
References: <52D9248F.6030901@linux.vnet.ibm.com> <20140120010533.GA24605@kernel.org> <52DCE44D.9020501@linux.vnet.ibm.com>
In-Reply-To: <52DCE44D.9020501@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Eberhard Pasch <epasch@de.ibm.com>

On 20/01/14 09:54, Christian Ehrhardt wrote:
> On 20/01/14 02:05, Shaohua Li wrote:
>> On Fri, Jan 17, 2014 at 01:39:43PM +0100, Christian Ehrhardt wrote:
[...]
>>
>> Is the swap disk a SSD? If not, there is no point to partition the
>> disk. Do you
>> see any changes in iostat in the bad/good case, for example, request
>> size,
>> iodepth?
>
> Hi,
> I use normal disks and SSDs or even the special s390 ramdisks - I agree
> that partitioning makes no sense in a real case, but it doesn't matter
> atm. I just partition to better show the effect that "more swap targets
> -> less throughput" - and partitioning makes it easy for me to guarantee
> that the HW ressources serving that I/O stay the same.
>
> IOstat and such things don't report very significant changes regarding
> I/O depth. Sizes are more interesting with the bad case having slightly
> more (16%) read I/Os and dropping average request size from 14.62 to
> 11.89. Along with that goes a drop in read request merges of 28%.
>
> But I don't see how a workload that is random in memory would create
> significantly better/worse chances for request merging depending on the
> case if the disk is partitioned more or less often.
> On the read path swap doesn't care about iterating disks, it just goes
> by associated swap extends -> offsets to the disk.
> And I thought in a random load that should be purely random and hit each
> partition in e.g. the 4 partition case just by 25%.
> I checked some blocktraces I had and can confirm as expected each got an
> equal share.
>
>> There is one patch can avoid swapin reads more than swapout for random
>> case,
>> but still not in upstream yet. You can try it here:
>> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/mm/swap_state.c?id=5d19b04a2dae73382fb607f16e2acfb594d1c63f
>>
>
> Great suggestion - it sounds very interesting to me, I'll give it a try
> in a few days since I'm out Tue/Wed.

I had already a patch prepared and successfully tested that allows to 
configure page cluster for read/write separately from userspace. That 
worked well but would require an admin to configure the "right" value 
for his system.
Since that fails with so much kernel tunables and would also not be 
adaptive if the behaviour changes over time I very much prefer your 
solution to it.
That is why I tried to verify your patch in my environment with at least 
some of the cases I used recently for swap analysis and improvement.

The environment has 10G of real memory and drives a working set of 12.5Gb.
So just a slight 1.25:1 overcommit (While s390 often runs in higher 
overcommits for most of the linux Swap issues so far 1.25:1 was enough 
to trigger and produced more reliable results).
To swap I use 8x16G xpram devices which one can imagine as SSDs at main 
memory speed (good to make forecasts how ssds might behave in a few years).

I compared a 3.10 kernel (I know a bit old already, but I knew that my 
env works fine with it) with and without the patch for swap readahead 
scaling.

All memory is initially completely faulted in (memset) and thne warmed 
up with two full sweeps of the entire working set following the current 
workload configuration.
The unit reported is MB/s the workload can achieve in its 
(overcommitted) memory being an average of 2 runs for 5 minutes each (+ 
the init and warmup as described).
(Noise is usually ~+/-5%, maybe a bit more in non exclusive runs like 
this when other things are on the machine)

Memory Access is done via memcpy in either direction (R/W) with 
alternating sizes of:
5% 65536 bytes
5%  8192 bytes
90% 4096 bytes

Further abbreviations
PC = the currently configured page cluster size (0,3,5)
M - Multi threaded (=32)
S - Single threaded
Seq/Rnd - Sequential/Random

                       No Swap RA   With Swap RA     Diff
PC0-M-Rnd        ~=     10732.97        9891.87   -7.84%
PC0-M-Seq        ~=     10780.56       10587.76   -1.79%
PC0-S-Rnd        ~=      2010.47        2067.51    2.84%
PC0-S-Seq        ~=      1783.74        1834.28    2.83%
PC3-M-Rnd        ~=     10745.19       10990.90    2.29%
PC3-M-Seq        ~=     11792.67       11107.79   -5.81%
PC3-S-Rnd        ~=      1301.28        2017.61   55.05%
PC3-S-Seq        ~=      1664.40        1637.72   -1.60%
PC5-M-Rnd        ~=      7568.56       10733.60   41.82%
PC5-M-Seq        ~=          n/a       11208.40      n/a
PC5-S-Rnd        ~=       608.48        2052.17  237.26%
PC5-S-Seq        ~=      1604.97        1685.65    5.03%
(for and PC5-M-Seq I ran out of time, but the remaining results are 
interesting enough already)

I like what I see, there is nothing significantly out of the noise range 
which shouldn't be.
The Page Cluster 0 cases didn't show an effect as expected.
For page cluster 3 the multithreaded cases have hidden the impact to TP 
due to the fact that then just another thread can continue.
But I checked sar data and see that PC3-M-Rnd has avoided about 50% of 
swapins while staying at equal throughput (1000k vs 500k pswpin/s).
Other than that Random loads had the biggest improvements matching what 
I had with splitting up read/write page-cluster size.
Eventually with page cluster 5 even the multi threaded cases start to 
show benefits of the readahead scaling code.
In all that time sequential cases didn't change a lot.

So I think that test worked fine. I see there were some discussion son 
the form of the implementation, but in terms of results I really like it 
as far as I had time to check it out.



*** Context switch ***

Now back to my original question about why swapping to multiple targets 
makes things slower.
Your patch helps there a but as the Workload with the biggest issue was 
a random workload and I knew that with pagecluster set to zero the loss 
of efficiency with those multiple swap targets is stopped.
But I consider that only a fix of the symptom and would love if one 
comes up with an idea actually *why* things get worse with more swap 
targets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
