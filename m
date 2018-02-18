Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3C8B6B0006
	for <linux-mm@kvack.org>; Sun, 18 Feb 2018 09:02:55 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id l14so1016573lfl.20
        for <linux-mm@kvack.org>; Sun, 18 Feb 2018 06:02:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q37sor3504738lfi.12.2018.02.18.06.02.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Feb 2018 06:02:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180215214858.GQ7000@dastard>
References: <1517974845.4352.8.camel@gmail.com> <20180207065520.66f6gocvxlnxmkyv@destitution>
 <1518255240.31843.6.camel@gmail.com> <1518255352.31843.8.camel@gmail.com>
 <20180211225657.GA6778@dastard> <1518643669.6070.21.camel@gmail.com>
 <20180214215245.GI7000@dastard> <1518666178.6070.25.camel@gmail.com>
 <20180215054436.GN7000@dastard> <CABXGCsOpJU4WU2w5DYBA+Q1nquh14zN0oCW6OfCbhTOFYLwO5w@mail.gmail.com>
 <20180215214858.GQ7000@dastard>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Sun, 18 Feb 2018 19:02:37 +0500
Message-ID: <CABXGCsMK61J_+3c4JaXoi1e6aZzngvkQ29zRvQAj3nNcRpv5-Q@mail.gmail.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 16 February 2018 at 02:48, Dave Chinner <david@fromorbit.com> wrote:
> On Fri, Feb 16, 2018 at 12:02:28AM +0500, Mikhail Gavrilov wrote:
>> On 15 February 2018 at 10:44, Dave Chinner <david@fromorbit.com> wrote:
>> > I've already explained that we can't annotate these memory
>> > allocations to turn off the false positives because that will also
>> > turning off all detection of real deadlock conditions.  Lockdep has
>> > many, many limitations, and this happens to be one of them.
>> >
>> > FWIW, is there any specific reason you running lockdep on your
>> > desktop system?
>>
>> Because I wanna make open source better (help fixing all freezing)
>
> lockdep isn't a user tool - most developers don't even understand
> what it tries to tell them. Worse, it is likely contributing to your
> problems as it has a significant runtime CPU and memory overhead....

I don't know how else collect debug info about freezes which occurring
accidentally. Is there a better idea?

>> > I think I've already explained that, too. The graphics subsystem -
>> > which is responsible for updating the cursor - requires memory
>> > allocation. The machine is running low on memory, so it runs memory
>> > reclaim, which recurses back into the filesystem and blocks waiting
>> > for IO to be completed (either writing dirty data pages or flushing
>> > dirty metadata) so it can free memory.
>>
>> Which means machine is running low on memory?
>> How many memory needed?
>>
>> $ free -h
>>               total        used        free      shared  buff/cache   available
>> Mem:            30G         17G        2,1G        1,4G         10G         12G
>> Swap:           59G          0B         59G
>>
>> As can we see machine have 12G available memory. Is this means low memory?
>
> No, you only have 2.1G free memory. You have 10GB of *reclaimable
> memory* in the buffer/page cache, and that gives you 12GB of
> "available memory". Memory reclaim happens all the time in a normal
> system - it does not mean you are running low on memory, it just
> means your system is busy.
>
> And, FWIW, we know you have memory pressure because the lockdep
> reports you are pasting are a result of memory reclaim operating.
>

Anyway I believe that memory pressure should not lead to such lockdep
reports. Looks like something wrong but not on file system side, may
be on side memory management.
Last 24 hours I don't see lockdep reports, but short-term interface
freezing whatever occurs.

>> > IOWs, your problems all stem from long IO latencies caused by the
>> > overloaded storage subsystem - they are propagate to all
>> > aspects of the OS via direct memory reclaim blocking on IO....
>>
>> I'm surprised that no QOS analog for disk I/O.
>
> There is, but it's not like a network where overload situations are
> mitigated by dropping packets to reduce load. We cannot do that with
> IO (dropped IO == broken filesystem), so QoS doesn't help when you
> drive the storage subsystem in extreme, long term overload
> conditions as you seem to be doing.

I no suggest broke file system I suggest reserving I/O and memory for
proceses who need realtime work for example for GUI (gnome-shell). I
this way high I/O and memory pressure couldn't affect to user
experience.

>
>> This is reminiscent of the situation in past where a torrent client
>> clogs the entire channel on the cheap router and it causes problems
>> with opening web pages. In nowadays it never happens with modern
>> routers even with overloaded network channel are possible video calls
>
> Storage != network.
>
>> In 2018 my personaly expectation that user can run any set of
>> applications on computer and this never shoudn't harm system.
>
> There's no "harm" occurring on your system - it's just slow
> because the load you've put on it means no task can execute quickly.

slow != freeze
I have nothing against long time launching and long time working
applications, but system freezing hurts everybody.

--
Best Regards,
Mike Gavrilov.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
