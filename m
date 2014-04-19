Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2D65A6B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 03:10:34 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so2118565pbc.34
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 00:10:33 -0700 (PDT)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id fb8si6488417pab.213.2014.04.19.00.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 00:10:33 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so2113317pbb.17
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 00:10:32 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <1397890512.19331.21.camel@buesod1.americas.hpqcorp.net>
References: <1397812720-5629-1-git-send-email-manfred@colorfullife.com> <1397890512.19331.21.camel@buesod1.americas.hpqcorp.net>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Sat, 19 Apr 2014 09:10:12 +0200
Message-ID: <CAKgNAkgMrWhSky8Cys2gxiS_s0=ya=wi=R5ehuT0bdjEBpDgdg@mail.gmail.com>
Subject: Re: [PATCH] ipc/shm: Increase the defaults for SHMALL, SHMMAX to infinity
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Apr 19, 2014 at 8:55 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> On Fri, 2014-04-18 at 11:18 +0200, Manfred Spraul wrote:
>> System V shared memory
>>
>> a) can be abused to trigger out-of-memory conditions and the standard
>>    measures against out-of-memory do not work:
>>
>>     - it is not possible to use setrlimit to limit the size of shm segments.
>>
>>     - segments can exist without association with any processes, thus
>>       the oom-killer is unable to free that memory.
>>
>> b) is typically used for shared information - today often multiple GB.
>>    (e.g. database shared buffers)
>>
>> The current default is a maximum segment size of 32 MB and a maximum total
>> size of 8 GB. This is often too much for a) and not enough for b), which
>> means that lots of users must change the defaults.
>>
>> This patch increases the default limits to ULONG_MAX, which is perfect for
>> case b). The defaults are used after boot and as the initial value for
>> each new namespace.
>>
>> Admins/distros that need a protection against a) should reduce the limits
>> and/or enable shm_rmid_forced.
>>
>> Further notes:
>> - The patch only changes the boot time default, overrides behave as before:
>>       # sysctl kernel/shmall=33554432
>>   would recreate the previous limit for SHMMAX (for the current namespace).
>>
>> - Disabling sysv shm allocation is possible with:
>>       # sysctl kernel.shmall=0
>>   (not a new feature, also per-namespace)
>>
>> - ULONG_MAX is not really infinity, but 18 Exabyte segment size and
>>   75 Zettabyte total size. This should be enough for the next few weeks.
>>   (assuming a 64-bit system with 4k pages)
>>
>> Risks:
>> - The patch breaks installations that use "take current value and increase
>>   it a bit". [seems to exist, http://marc.info/?l=linux-mm&m=139638334330127]
>
> This really scares me. The probability of occurrence is now much higher,
> and not just theoretical. It would legitimately break userspace.

I'm missing something. Manfred's patch doesn't actually change the
behavior on this point does it? If the problem is more than
theoretical, then it _already_ affects users, right? (And they would
therefore already be working around the problem.)

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
