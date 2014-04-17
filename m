Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 79D346B003B
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 16:23:55 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so737160pbb.36
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 13:23:55 -0700 (PDT)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id ov9si13864520pbc.41.2014.04.17.13.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Apr 2014 13:23:54 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so750750pbb.1
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 13:23:54 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <534FFFC2.6050601@colorfullife.com>
References: <1397272942.2686.4.camel@buesod1.americas.hpqcorp.net>
 <CAHO5Pa3BOgJGCm7NvE4xbm3O1WbRLRBS0pgvErPudypP_iiZ3g@mail.gmail.com> <534FFFC2.6050601@colorfullife.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 17 Apr 2014 22:23:32 +0200
Message-ID: <CAKgNAkjCenvWr9A69-=j-55nyW1EM1Fy+=rSDWSxXvq5qFtGTw@mail.gmail.com>
Subject: Re: [PATCH v2] ipc,shm: disable shmmax and shmall by default
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Manfred!

On Thu, Apr 17, 2014 at 6:22 PM, Manfred Spraul
<manfred@colorfullife.com> wrote:
> Hi Michael,
>
>
> On 04/17/2014 12:53 PM, Michael Kerrisk wrote:
>>
>> On Sat, Apr 12, 2014 at 5:22 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>>
>>> From: Davidlohr Bueso <davidlohr@hp.com>
>>>
>>> The default size for shmmax is, and always has been, 32Mb.
>>> Today, in the XXI century, it seems that this value is rather small,
>>> making users have to increase it via sysctl, which can cause
>>> unnecessary work and userspace application workarounds[1].
>>>
>>> Instead of choosing yet another arbitrary value, larger than 32Mb,
>>> this patch disables the use of both shmmax and shmall by default,
>>> allowing users to create segments of unlimited sizes. Users and
>>> applications that already explicitly set these values through sysctl
>>> are left untouched, and thus does not change any of the behavior.
>>>
>>> So a value of 0 bytes or pages, for shmmax and shmall, respectively,
>>> implies unlimited memory, as opposed to disabling sysv shared memory.
>>> This is safe as 0 cannot possibly be used previously as SHMMIN is
>>> hardcoded to 1 and cannot be modified.
>>>
>>> This change allows Linux to treat shm just as regular anonymous memory.
>>> One important difference between them, though, is handling out-of-memory
>>> conditions: as opposed to regular anon memory, the OOM killer will not
>>> free the memory as it is shm, allowing users to potentially abuse this.
>>> To overcome this situation, the shm_rmid_forced option must be enabled.
>>>
>>> [1]: http://rhaas.blogspot.com/2012/06/absurd-shared-memory-limits.html
>>>
>>> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
>>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> Of the two proposed approaches (the other being
>> marc.info/?l=linux-kernel&m=139730332306185), this looks preferable to
>> me, since it allows strange users to maintain historical behavior
>> (i.e., the ability to set a limit) if they really want it, so:
>>
>> Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>
>>
>> One or two comments below, that you might consider for your v3 patch.
>
> I don't understand what you mean.

As noted in the other mail, you don't understand, because I was being
dense (and misled a little by the commit message).

> After a
>     # echo 33554432 > /proc/sys/kernel/shmmax
>     # echo 2097152 > /proc/sys/kernel/shmmax
>
> both patches behave exactly identical.

Yes.

> There are only two differences:
> - Davidlohr's patch handles
>     # echo <really huge number that doesn't fit into 64-bit> >
> /proc/sys/kernel/shmmax
>    With my patch, shmmax would end up as 0 and all allocations fail.
>
> - My patch handles the case if some startup code/installer checks
>    shmmax and complains if it is below the requirement of the application.

Thanks for that clarification. I withdraw my Ack. In fact, maybe I
even like your approach a little more, because of that last point. Did
one of you not yet manage to persuade the other to his point of view
yet?

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
