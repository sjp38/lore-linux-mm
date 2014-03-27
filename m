Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id D39AF6B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 14:10:36 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so3851850pbc.10
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:10:36 -0700 (PDT)
Received: from tama50.ecl.ntt.co.jp (tama50.ecl.ntt.co.jp. [129.60.39.147])
        by mx.google.com with ESMTP id iu9si2057038pac.166.2014.03.27.11.10.35
        for <linux-mm@kvack.org>;
        Thu, 27 Mar 2014 11:10:35 -0700 (PDT)
Message-ID: <53346987.5060008@lab.ntt.co.jp>
Date: Fri, 28 Mar 2014 03:10:15 +0900
From: Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
MIME-Version: 1.0
Subject: Re: [Lsf] Postgresql performance problems with IO latency, especially
 during fsync()
References: <20140326191113.GF9066@alap3.anarazel.de>	<CALCETrUc1YvNc3EKb4ex579rCqBfF=84_h5bvbq49o62k2KpmA@mail.gmail.com>	<20140326215518.GH9066@alap3.anarazel.de> <20140327155002.GF18118@quack.suse.cz>
In-Reply-To: <20140327155002.GF18118@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Andres Freund <andres@2ndquadrant.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, lsf@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, rhaas@anarazel.de, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

(2014/03/28 0:50), Jan Kara wrote:
> On Wed 26-03-14 22:55:18, Andres Freund wrote:
>> On 2014-03-26 14:41:31 -0700, Andy Lutomirski wrote:
>>> On Wed, Mar 26, 2014 at 12:11 PM, Andres Freund <andres@anarazel.de> wrote:
>>>> Hi,
>>>>
>>>> At LSF/MM there was a slot about postgres' problems with the kernel. Our
>>>> top#1 concern is frequent slow read()s that happen while another process
>>>> calls fsync(), even though we'd be perfectly fine if that fsync() took
>>>> ages.
>>>> The "conclusion" of that part was that it'd be very useful to have a
>>>> demonstration of the problem without needing a full blown postgres
>>>> setup. I've quickly hacked something together, that seems to show the
>>>> problem nicely.
>>>>
>>>> For a bit of context: lwn.net/SubscriberLink/591723/940134eb57fcc0b8/
>>>> and the "IO Scheduling" bit in
>>>> http://archives.postgresql.org/message-id/20140310101537.GC10663%40suse.de
>>>>
>>> For your amusement: running this program in KVM on a 2GB disk image
>>> failed, but it caused the *host* to go out to lunch for several
>>> seconds while failing.  In fact, it seems to have caused the host to
>>> fall over so badly that the guest decided that the disk controller was
>>> timing out.  The host is btrfs, and I think that btrfs is *really* bad
>>> at this kind of workload.
>> Also, unless you changed the parameters, it's a) using a 48GB disk file,
>> and writes really rather fast ;)
>>
>>> Even using ext4 is no good.  I think that dm-crypt is dying under the
>>> load.  So I won't test your program for real :/
>> Try to reduce data_size to RAM * 2, NUM_RANDOM_READERS to something
>> smaller. If it still doesn't work consider increasing the two nsleep()s...
>>
>> I didn't have a good idea how to scale those to the current machine in a
>> halfway automatic fashion.
>    That's not necessary. If we have a guidance like above, we can figure it
> out ourselves (I hope ;).
>
>>>> Possible solutions:
>>>> * Add a fadvise(UNDIRTY), that doesn't stall on a full IO queue like
>>>>    sync_file_range() does.
>>>> * Make IO triggered by writeback regard IO priorities and add it to
>>>>    schedulers other than CFQ
>>>> * Add a tunable that allows limiting the amount of dirty memory before
>>>>    writeback on a per process basis.
>>>> * ...?
>>> I thought the problem wasn't so much that priorities weren't respected
>>> but that the fsync call fills up the queue, so everything starts
>>> contending for the right to enqueue a new request.
>> I think it's both actually. If I understand correctly there's not even a
>> correct association to the originator anymore during a fsync triggered
>> flush?
>    There is. The association is lost for background writeback (and sync(2)
> for that matter) but IO from fsync(2) is submitted in the context of the
> process doing fsync.
>
> What I think happens is the problem with 'dependent sync IO' vs
> 'independent sync IO'. Reads are an example of dependent sync IO where you
> submit a read, need it to complete and then you submit another read. OTOH
> fsync is an example of independent sync IO where you fire of tons of IO to
> the drive and they wait for everything. Since we treat both these types of
> IO in the same way, it can easily happen that independent sync IO starves
> out the dependent one (you execute say 100 IO requests for fsync and 1 IO
> request for read). We've seen problems like this in the past.
>
> I'll have a look into your test program and if my feeling is indeed
> correct, I'll have a look into what we could do in the block layer to fix
> this (and poke block layer guys - they had some preliminary patches that
> tried to address this but it didn't went anywhere).

We have been using PostgreSQL in production for years so I am pretty 
familiar
with the symptoms described by the PostgreSQL guys.

In almost all cases the problem was the "'dependent sync IO' vs 'independent
sync IO'" issue pointed out by Jan. However, as I mentioned during the 
LSF&MM
session, the culprit was not the kernel but the firmware of NCQ/TCQ capable
storage that would keep read requests queued forever, leaving tasks doing
reads (dependent sync IO) waiting for an interrupt that would not come. 
For the
record, latencies of up to 120 seconds in suposedly enterprise storage 
(I will not
name names) are relatively common. This can be fixed by modifying drivers
and/or the block layer to dynamically adjust the queue depth when dumb 
scheduling
by the firmware is observed. If you do not want to make changes to the 
kernel you
can always try to change the default queue depth. With this mechanism in 
place it is
relatively easy to make ionice work, since, as Jan mentioned, both reads 
and fsync
writes are done in process context.

- Fernando

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
