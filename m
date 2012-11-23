Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id ED2B46B004D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 12:56:44 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so8205634qcq.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 09:56:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <31ca2ed0-d039-4154-bc3d-669d29673706@default>
References: <CAA25o9Q4gMPeLf3uYJzMNR1EU4D3OPeje24X4PNsUVHGoqyY5g@mail.gmail.com>
	<20121123055144.GC13626@bbox>
	<31ca2ed0-d039-4154-bc3d-669d29673706@default>
Date: Fri, 23 Nov 2012 09:56:43 -0800
Message-ID: <CAA25o9T+UYEBt0nwPXxtfsmk-NHUXusjeqTVm+OgbDh5H2ty0Q@mail.gmail.com>
Subject: Re: behavior of zram stats, and zram allocation limit
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org

The ability to set a maximum RAM available to zram would be a stopgap
solution for a larger problem, which is how to balance compressed vs.
uncompressed RAM.

Experimentally, we allocate a 3 GB zram swap device.  With a 3:1
compression ratio, we end up with 1 GB available for the "working
set", and 1 GB for swap---but that assumes the compression ratio is
always the same.  In addition, different loads could take advantage of
a different allocation.  For instance, someone's working set may be
larger than 1 GB, and someone else may be happy with 1/2 GB.  Thus,
the ideal zram would be more tightly integrated with the memory
manager.

On the other hand, on a system like ours, where a single program
(Chrome) is responsible for pretty much all allocation, we can get
around this problem by allocating an even larger zram device, and then
monitoring paging activity to decide when to "discard" processes
(essentially we do our own version of OOM-killing).

So maybe this feature is not so important for us.  We always worry,
though, about what happens when our OOM-discards don't work as well as
they should (there is a lot of guessing).

Thanks!

On Fri, Nov 23, 2012 at 8:45 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> From: Minchan Kim [mailto:minchan@kernel.org]
>> Sent: Thursday, November 22, 2012 10:52 PM
>> To: Luigi Semenzato
>> Cc: linux-mm@kvack.org; Dan Magenheimer
>> Subject: Re: behavior of zram stats, and zram allocation limit
>>
>> On Wed, Nov 21, 2012 at 02:58:48PM -0800, Luigi Semenzato wrote:
>> > Hi,
>> >
>> > Two questions for zram developers/users.  (Please let me know if it is
>> > NOT acceptable to use this list for these questions.)
>> >
>> > 1. When I run a synthetic load using zram from kernel 3.4.0,
>> > compr_data_size from /sys/block/zram0 seems to decrease even though
>> > orig_data_size stays constant (see below).  Is this a bug that was
>> > fixed in a later release?  (The synthetic load is a bunch of processes
>> > that allocate memory, fill half of it with data from /dev/urandom, and
>> > touch the memory randomly.)  I looked at the code and it looks right.
>> > :-P
>> >
>> > 2. Is there a way of setting the max amount of RAM that zram is
>> > allowed to allocate?  Right now I can set the size of the
>> > *uncompressed* swap device, but how much memory gets allocated depends
>> > on the compression ratio, which could vary.
>>
>> There is no method to limit the RAM size but I think we can implement
>> it easily. The only thing we need is just a "voice of customer".
>> Why do you need it?
>
> Hi Minchan --
>
> I am not an expert on zram, but I do recall a conversation
> with hughd in 2010 along this line and, after some thought,
> he concluded it was far harder than it sounds.  Since
> zram appears as a block device, it is not easy to reject
> writes.  Zcache circumvents the block I/O system entirely
> so "writes" can be managed much more dynamically.
>
> Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
