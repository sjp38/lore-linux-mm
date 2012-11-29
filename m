Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 758AB6B0078
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 17:57:40 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id o19so955228qap.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 14:57:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA25o9R0XrEuQPTUHy8NYLeg74tDmBjuQ-jVu1Vcct34-tkTDg@mail.gmail.com>
References: <CAA25o9S5zpH_No+xgYuFSAKSRkQ=19Vf_aLgO1UWiajQxtjrpg@mail.gmail.com>
 <CAA25o9TnmSqBe48EN+9E6E8EiSzKf275AUaAijdk3wxg6QV2kQ@mail.gmail.com>
 <CAA25o9RiNfwtoeMBk=PLg-X_2wPSHuYLztONw1KToeOx9pUHGw@mail.gmail.com>
 <CAPz6YkUGO9DayCNbJBbzR0Lx8-zX5=+QTKWoueV8_TXAy1HZPQ@mail.gmail.com> <CAA25o9R0XrEuQPTUHy8NYLeg74tDmBjuQ-jVu1Vcct34-tkTDg@mail.gmail.com>
From: Sonny Rao <sonnyrao@google.com>
Date: Thu, 29 Nov 2012 14:57:19 -0800
Message-ID: <CAPz6YkVfRKs1nBURYu=cXeP6Kx_VYC0QKdEf_wVR_KHx+0Yt_w@mail.gmail.com>
Subject: Re: zram, OOM, and speed of allocation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>

On Thu, Nov 29, 2012 at 1:33 PM, Luigi Semenzato <semenzato@google.com> wrote:
> On Thu, Nov 29, 2012 at 12:55 PM, Sonny Rao <sonnyrao@google.com> wrote:
>> On Thu, Nov 29, 2012 at 11:31 AM, Luigi Semenzato <semenzato@google.com> wrote:
>>> Oh well, I found the problem, it's laptop_mode.  We keep it on by
>>> default.  When I turn it off, I can allocate as fast as I can, and no
>>> OOMs happen until swap is exhausted.
>>>
>>> I don't think this is a desirable behavior even for laptop_mode, so if
>>> anybody wants to help me debug it (or wants my help in debugging it)
>>> do let me know.
>>>
>>
>> Luigi, I thought we disabled Laptop mode a few weeks ago -- due to
>> undesirable behavior with respect to too many writes happening.
>> Are you sure it's on?
>
> Yes.  The change happened a month ago, but I hadn't updated my testing
> image since then.
>
> So I suppose we aren't really too interested in fixing the laptop_mode
> behavior, but I'll be happy to test fixes if anybody would like me to.
>

Yeah, the big problem that led us to disable laptop_mode is some
pathological behavior with disk writes.

Laptop mode sets a timer after each write, presumably to see if any
data got dirtied, and checks for dirty data after the timer expires
and then writes it out *and* sets the timer again.  So we saw a
pattern where things were being dirtied often enough and there is
almost always new dirty data when the timer expires and the we'd keep
the disk up and burning power for a very long time, which is clearly
not what laptop mode is trying to do.

Maybe we should work on trying to fix laptop_mode at some point.  If
it just did a single flush of dirty data when we woke up the disk and
didn't try to wait for more dirty data, it would work better.

Your case here is a different example of bad interactions with
laptop_mode seems to come from code in balance_pgdat:

loop_again:
        total_scanned = 0;
        sc.nr_reclaimed = 0;
        sc.may_writepage = !laptop_mode; <-----------
        count_vm_event(PAGEOUTRUN);


this code is assuming that swap is on a disk which is subject to
laptop mode, but in the case of zram (and NFS), this is an incorrect
assumption


>>
>>> Thanks!
>>> Luigi
>>>
>>> On Thu, Nov 29, 2012 at 10:46 AM, Luigi Semenzato <semenzato@google.com> wrote:
>>>> Minchan:
>>>>
>>>> I tried your suggestion to move the call to wake_all_kswapd from after
>>>> "restart:" to after "rebalance:".  The behavior is still similar, but
>>>> slightly improved.  Here's what I see.
>>>>
>>>> Allocating as fast as I can: 1.5 GB of the 3 GB of zram swap are used,
>>>> then OOM kills happen, and the system ends up with 1 GB swap used, 2
>>>> unused.
>>>>
>>>> Allocating 10 MB/s: some kills happen when only 1 to 1.5 GB are used,
>>>> and continue happening while swap fills up.  Eventually swap fills up
>>>> completely.  This is better than before (could not go past about 1 GB
>>>> of swap used), but there are too many kills too early.  I would like
>>>> to see no OOM kills until swap is full or almost full.
>>>>
>>>> Allocating 20 MB/s: almost as good as with 10 MB/s, but more kills
>>>> happen earlier, and not all swap space is used (400 MB free at the
>>>> end).
>>>>
>>>> This is with 200 processes using 20 MB each, and 2:1 compression ratio.
>>>>
>>>> So it looks like kswapd is still not aggressive enough in pushing
>>>> pages out.  What's the best way of changing that?  Play around with
>>>> the watermarks?
>>>>
>>>> Incidentally, I also tried removing the min_filelist_kbytes hacky
>>>> patch, but, as usual, the system thrashes so badly that it's
>>>> impossible to complete any experiment.  I set it to a lower minimum
>>>> amount of free file pages, 10 MB instead of the 50 MB which we use
>>>> normally, and I could run with some thrashing, but I got the same
>>>> results.
>>>>
>>>> Thanks!
>>>> Luigi
>>>>
>>>>
>>>> On Wed, Nov 28, 2012 at 4:31 PM, Luigi Semenzato <semenzato@google.com> wrote:
>>>>> I am beginning to understand why zram appears to work fine on our x86
>>>>> systems but not on our ARM systems.  The bottom line is that swapping
>>>>> doesn't work as I would expect when allocation is "too fast".
>>>>>
>>>>> In one of my tests, opening 50 tabs simultaneously in a Chrome browser
>>>>> on devices with 2 GB of RAM and a zram-disk of 3 GB (uncompressed), I
>>>>> was observing that on the x86 device all of the zram swap space was
>>>>> used before OOM kills happened, but on the ARM device I would see OOM
>>>>> kills when only about 1 GB (out of 3) was swapped out.
>>>>>
>>>>> I wrote a simple program to understand this behavior.  The program
>>>>> (called "hog") allocates memory and fills it with a mix of
>>>>> incompressible data (from /dev/urandom) and highly compressible data
>>>>> (1's, just to avoid zero pages) in a given ratio.  The memory is never
>>>>> touched again.
>>>>>
>>>>> It turns out that if I don't limit the allocation speed, I see
>>>>> premature OOM kills also on the x86 device.  If I limit the allocation
>>>>> to 10 MB/s, the premature OOM kills stop happening on the x86 device,
>>>>> but still happen on the ARM device.  If I further limit the allocation
>>>>> speed to 5 Mb/s, the premature OOM kills disappear also from the ARM
>>>>> device.
>>>>>
>>>>> I have noticed a few time constants in the MM whose value is not well
>>>>> explained, and I am wondering if the code is tuned for some ideal
>>>>> system that doesn't behave like ours (considering, for instance, that
>>>>> zram is much faster than swapping to a disk device, but it also uses
>>>>> more CPU).  If this is plausible, I am wondering if anybody has
>>>>> suggestions for changes that I could try out to obtain a better
>>>>> behavior with a higher allocation speed.
>>>>>
>>>>> Thanks!
>>>>> Luigi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
