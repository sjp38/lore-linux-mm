Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E01E6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:27:56 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so315961041pfb.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:27:56 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y2si65438724pfk.286.2016.11.30.10.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 10:27:55 -0800 (PST)
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
References: <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
 <20161130174713.lhvqgophhiupzwrm@merlins.org>
 <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
From: Jens Axboe <axboe@fb.com>
Message-ID: <0c7df460-90a3-b71e-3965-abda00336ac9@fb.com>
Date: Wed, 30 Nov 2016 11:27:43 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Marc MERLIN <marc@merlins.org>, Kent Overstreet <kent.overstreet@gmail.com>, Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo
 Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 11/30/2016 11:14 AM, Linus Torvalds wrote:
> On Wed, Nov 30, 2016 at 9:47 AM, Marc MERLIN <marc@merlins.org> wrote:
>>
>> I gave it a thought again, I think it is exactly the nasty situation you
>> described.
>> bcache takes I/O quickly while sending to SSD cache. SSD fills up, now
>> bcache can't handle IO as quickly and has to hang until the SSD has been
>> flushed to spinning rust drives.
>> This actually is exactly the same as filling up the cache on a USB key
>> and now you're waiting for slow writes to flash, is it not?
> 
> It does sound like you might hit exactly the same kind of situation, yes.
> 
> And the fact that you have dmcrypt running too just makes things pile
> up more. All those IO's end up slowed down by the scheduling too.
> 
> Anyway, none of this seems new per se. I'm adding Kent and Jens to the
> cc (Tejun already was), in the hope that maybe they have some idea how
> to control the nasty worst-case behavior wrt workqueue lockup (it's
> not really a "lockup", it looks like it's just hundreds of workqueues
> all waiting for IO to complete and much too deep IO queues).

Honestly, the easiest would be to wire it up to the blk-wbt stuff that
is queued up for 4.10, which attempts to limit the queue depths to
something reasonable instead of letting them run amok. This is largely
(exclusively, almost) a problem with buffered writeback.

On devices utilizing the stacked interface, they never get any depth
throttling. Obviously it's worse if each IO ends up queueing work, but
it's a big problem even if they do not.

> I think it's the traditional "throughput is much easier to measure and
> improve" situation, where making queues big help some throughput
> situation, but ends up causing chaos when things go south.

Yes, and the longer queues never buy you anything, but they end up
causing tons of problems at the other end of the spectrum.

Still makes sense to limit dirty memory for highmem, though.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
