Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id 737996B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 18:26:40 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id cz12so3063547veb.7
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 15:26:40 -0700 (PDT)
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
        by mx.google.com with ESMTPS id dr8si12392vcb.13.2014.03.26.15.26.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 15:26:39 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id ld13so3232933vcb.33
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 15:26:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140326215518.GH9066@alap3.anarazel.de>
References: <20140326191113.GF9066@alap3.anarazel.de> <CALCETrUc1YvNc3EKb4ex579rCqBfF=84_h5bvbq49o62k2KpmA@mail.gmail.com>
 <20140326215518.GH9066@alap3.anarazel.de>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 26 Mar 2014 15:26:19 -0700
Message-ID: <CALCETrVEjpFpKhY6=CEG-9Prm=uBDLS936imb=+hyWN4fXPjtg@mail.gmail.com>
Subject: Re: [Lsf] Postgresql performance problems with IO latency, especially
 during fsync()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@2ndquadrant.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>, rhaas@anarazel.de

On Wed, Mar 26, 2014 at 2:55 PM, Andres Freund <andres@2ndquadrant.com> wrote:
> On 2014-03-26 14:41:31 -0700, Andy Lutomirski wrote:
>> On Wed, Mar 26, 2014 at 12:11 PM, Andres Freund <andres@anarazel.de> wrote:
>> > Hi,
>> >
>> > At LSF/MM there was a slot about postgres' problems with the kernel. Our
>> > top#1 concern is frequent slow read()s that happen while another process
>> > calls fsync(), even though we'd be perfectly fine if that fsync() took
>> > ages.
>> > The "conclusion" of that part was that it'd be very useful to have a
>> > demonstration of the problem without needing a full blown postgres
>> > setup. I've quickly hacked something together, that seems to show the
>> > problem nicely.
>> >
>> > For a bit of context: lwn.net/SubscriberLink/591723/940134eb57fcc0b8/
>> > and the "IO Scheduling" bit in
>> > http://archives.postgresql.org/message-id/20140310101537.GC10663%40suse.de
>> >
>>
>> For your amusement: running this program in KVM on a 2GB disk image
>> failed, but it caused the *host* to go out to lunch for several
>> seconds while failing.  In fact, it seems to have caused the host to
>> fall over so badly that the guest decided that the disk controller was
>> timing out.  The host is btrfs, and I think that btrfs is *really* bad
>> at this kind of workload.
>
> Also, unless you changed the parameters, it's a) using a 48GB disk file,
> and writes really rather fast ;)
>
>> Even using ext4 is no good.  I think that dm-crypt is dying under the
>> load.  So I won't test your program for real :/
>
> Try to reduce data_size to RAM * 2, NUM_RANDOM_READERS to something
> smaller. If it still doesn't work consider increasing the two nsleep()s...
>
> I didn't have a good idea how to scale those to the current machine in a
> halfway automatic fashion.

OK, I think I'm getting reasonable bad behavior with these qemu options:

-smp 2 -cpu host -m 600 -drive file=/var/lutotmp/test.img,cache=none

and a 2GB test partition.

>
>> > Possible solutions:
>> > * Add a fadvise(UNDIRTY), that doesn't stall on a full IO queue like
>> >   sync_file_range() does.
>> > * Make IO triggered by writeback regard IO priorities and add it to
>> >   schedulers other than CFQ
>> > * Add a tunable that allows limiting the amount of dirty memory before
>> >   writeback on a per process basis.
>> > * ...?
>>
>> I thought the problem wasn't so much that priorities weren't respected
>> but that the fsync call fills up the queue, so everything starts
>> contending for the right to enqueue a new request.
>
> I think it's both actually. If I understand correctly there's not even a
> correct association to the originator anymore during a fsync triggered
> flush?
>
>> Since fsync blocks until all of its IO finishes anyway, what if it
>> could just limit itself to a much smaller number of outstanding
>> requests?
>
> Yea, that could already help. If you remove the fsync()s, the problem
> will periodically appear anyway, because writeback is triggered with
> vengeance. That'd need to be fixed in a similar way.
>
>> I'm not sure I understand the request queue stuff, but here's an idea.
>>  The block core contains this little bit of code:
>
> I haven't read enough of the code yet, to comment intelligently ;)

My little patch doesn't seem to help.  I'm either changing the wrong
piece of code entirely or I'm penalizing readers and writers too much.

Hopefully some real block layer people can comment as to whether a
refinement of this idea could work.  The behavior I want is for
writeback to be limited to using a smallish fraction of the total
request queue size -- I think that writeback should be able to enqueue
enough requests to get decent sorting performance but not enough
requests to prevent the io scheduler from doing a good job on
non-writeback I/O.

As an even more radical idea, what if there was a way to submit truly
enormous numbers of lightweight requests, such that the queue will
give the requester some kind of callback when the request is nearly
ready for submission so the requester can finish filling in the
request?  This would allow things like dm-crypt to get the benefit of
sorting without needing to encrypt hundreds of MB of data in advance
of having that data actually be to the backing device.  It might also
allow writeback to submit multiple gigabytes of writes, in arbitrarily
large pieces, but not to need to pin pages or do whatever expensive
things are needed until the IO actually happens.

For reference, here's my patch that doesn't work well:

diff --git a/block/blk-core.c b/block/blk-core.c
index 4cd5ffc..c0dedc3 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -941,11 +941,11 @@ static struct request *__get_request(struct request_list *
        }

        /*
-        * Only allow batching queuers to allocate up to 50% over the defined
-        * limit of requests, otherwise we could have thousands of requests
-        * allocated with any setting of ->nr_requests
+        * Only allow batching queuers to allocate up to 50% of the
+        * defined limit of requests, so that non-batching queuers can
+        * get into the queue and thus be scheduled properly.
         */
-       if (rl->count[is_sync] >= (3 * q->nr_requests / 2))
+       if (rl->count[is_sync] >= (q->nr_requests + 3) / 4)
                return NULL;

        q->nr_rqs[is_sync]++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
