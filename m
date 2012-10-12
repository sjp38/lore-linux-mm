Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 002D06B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 19:31:00 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so3162285qcq.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 16:31:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9SwO209DD6CUx-LzhMt9XU6niGJ-fBPmgwfcrUvf0BPWA@mail.gmail.com>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
	<CACJDEmphUupZK7y5EMqpsi91hzSexUCvxh8k2LwG0pLeCzCVKg@mail.gmail.com>
	<CAA25o9SwO209DD6CUx-LzhMt9XU6niGJ-fBPmgwfcrUvf0BPWA@mail.gmail.com>
Date: Fri, 12 Oct 2012 16:30:59 -0700
Message-ID: <CAA25o9RByqSC_TaxUbx6+XqUA8bb4GuM31XS8bBnuu8K9fza=A@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@kernel.org>, linux-mm@kvack.org

I fixed the "hang with compressed swap" problem but I cannot claim I
understand the code very well, before or after the fix.  However, the
fix seems to make sense, unless I am misinterpreting something.

In vm_swap.c there are a few places where the amount of reclaimable
memory is computed, in the presence or absence of swap.  For instance
here:

unsigned long zone_reclaimable_pages(struct zone *zone)
{
        int nr;

        nr = zone_page_state(zone, NR_ACTIVE_FILE) +
                zone_page_state(zone, NR_INACTIVE_FILE);

        if (nr_swap_pages > 0)
                nr += zone_page_state(zone, NR_ACTIVE_ANON) +
                        zone_page_state(zone, NR_INACTIVE_ANON);

        return nr;
}

But this code seems to assume that if there is any swap space left,
then there is infinite swap space left.  If there is only a little
swap space left, only that many ANON pages may be swapped out.  So I
replaced part of the above with

anon = zone_page_state(zone, NR_ACTIVE_ANON) +
           zone_page_state(zone, NR_INACTIVE_ANON);

if (total_swap_pages > 0)
        nr += min(anon, nr_swap_spaces)

and, as I mentioned, did something equivalent in a couple of other
places.  This fixes the hangs.  I think the hangs happened because the
page allocator thought that there was reclaimable memory and kept
trying to reclaim it unsuccessfully.

But it's still hard to believe that the original code could be *that*
wrong, so what am I missing?

Or is it possible that there isn't enough interest in improving
low-memory and out-of-memory behavior?  This is rather important on
consumer devices, such as Chromebooks.

Of course the zram module is not your standard swap device (it
allocates memory to free more memory).

My colleague Mandeep Baines submitted a patch a year or two ago that
prevents thrashing in the absence of swap.  The system can still
thrash because it evicts executable pages, which are file-backed.  His
patch is just a few lines.  It stops the mm from evicting the last X
megabytes of FILE memory, where X = 50 works well for us.  Thrashing
is nasty, and his patch fixes it, yet it is not included in ToT.

Thank you for any elucidation!




On Wed, Oct 3, 2012 at 8:33 AM, Luigi Semenzato <semenzato@google.com> wrote:
> On Wed, Oct 3, 2012 at 6:30 AM, Konrad Rzeszutek Wilk <konrad@kernel.org> wrote:
>> On Fri, Sep 28, 2012 at 1:32 PM, Luigi Semenzato <semenzato@google.com> wrote:
>>> Greetings,
>>>
>>> We are experimenting with zram in Chrome OS.  It works quite well
>>> until the system runs out of memory, at which point it seems to hang,
>>> but we suspect it is thrashing.
>>
>> Or spinning in some sad loop. Does the kernel have the CONFIG_DETECT_*
>> options to figure out what is happening?
>
> Don't think so, but will check and enable it.
>
> Can you invoke the Alt-SysRQ
>> when it is hung?
>
> I don't think we have that enabled, but I will check.
>
>>>
>>> Before the (apparent) hang, the OOM killer gets rid of a few
>>> processes, but then the other processes gradually stop responding,
>>> until the entire system becomes unresponsive.
>>
>> Does the OOM give you an idea what the memory state is?
>> Can you
>> actually provide the dmesg?
>
> I may be able to do that, through the serial line.
>
> Thanks, I will reply-all when I have more info.  Didn't want to spam
> the list for now.
>
>>
>>>
>>> I am wondering if anybody has run into this.  Thanks!
>>>
>>> Luigi
>>>
>>> P.S.  For those who wish to know more:
>>>
>>> 1. We use the min_filelist_kbytes patch
>>> (http://lwn.net/Articles/412313/)  (I am not sure if it made it into
>>> the standard kernel) and set min_filelist_kbytes to 50Mb.  (This may
>>> not matter, as it's unlikely to make things worse.)
>>>
>>> 2. We swap only to compressed ram.  The setup is very simple:
>>>
>>>  echo ${ZRAM_SIZE_KB}000 >/sys/block/zram0/disksize ||
>>>       logger -t "$UPSTART_JOB" "failed to set zram size"
>>>   mkswap /dev/zram0 || logger -t "$UPSTART_JOB" "mkswap /dev/zram0 failed"
>>>   swapon /dev/zram0 || logger -t "$UPSTART_JOB" "swapon /dev/zram0 failed"
>>>
>>> For ZRAM_SIZE_KB, we typically use 1.5 the size of RAM (which is 2 or
>>> 4 Gb).  The compression factor is about 3:1.  The hangs happen for
>>> quite a wide range of zram sizes.
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
