Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8FAEB6B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 02:22:14 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so2169239eek.9
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 23:22:13 -0700 (PDT)
Received: from mail-ee0-x22e.google.com (mail-ee0-x22e.google.com [2a00:1450:4013:c00::22e])
        by mx.google.com with ESMTPS id q2si43376660eep.282.2014.04.18.23.22.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 23:22:11 -0700 (PDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so2124761eei.19
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 23:22:10 -0700 (PDT)
Message-ID: <5352160E.3020208@gmail.com>
Date: Sat, 19 Apr 2014 08:22:06 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] ipc,shm: disable shmmax and shmall by default
References: <1397272942.2686.4.camel@buesod1.americas.hpqcorp.net>	 <CAHO5Pa3BOgJGCm7NvE4xbm3O1WbRLRBS0pgvErPudypP_iiZ3g@mail.gmail.com>	 <534FFFC2.6050601@colorfullife.com>	 <CAKgNAkjCenvWr9A69-=j-55nyW1EM1Fy+=rSDWSxXvq5qFtGTw@mail.gmail.com>	 <1397773919.2556.22.camel@buesod1.americas.hpqcorp.net>	 <CAKgNAkh5s+U4hYhpCwMcFpKmxen9ztd8aAPoyGQOWyadTMYfOw@mail.gmail.com> <1397838572.19331.1.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1397838572.19331.1.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: mtk.manpages@gmail.com, Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/18/2014 06:29 PM, Davidlohr Bueso wrote:
> On Fri, 2014-04-18 at 07:28 +0200, Michael Kerrisk (man-pages) wrote:
>> Hello Davidlohr,
>>
>> On Fri, Apr 18, 2014 at 12:31 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>> On Thu, 2014-04-17 at 22:23 +0200, Michael Kerrisk (man-pages) wrote:
>>>> Hi Manfred!
>>>>
>>>> On Thu, Apr 17, 2014 at 6:22 PM, Manfred Spraul
>>>> <manfred@colorfullife.com> wrote:
>>>>> Hi Michael,
>>>>>
>>>>>
>>>>> On 04/17/2014 12:53 PM, Michael Kerrisk wrote:
>>>>>>
>>>>>> On Sat, Apr 12, 2014 at 5:22 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>
>> [...]
>>
>>>>>> Of the two proposed approaches (the other being
>>>>>> marc.info/?l=linux-kernel&m=139730332306185), this looks preferable to
>>>>>> me, since it allows strange users to maintain historical behavior
>>>>>> (i.e., the ability to set a limit) if they really want it, so:
>>>>>>
>>>>>> Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>
>>>>>>
>>>>>> One or two comments below, that you might consider for your v3 patch.
>>>>>
>>>>> I don't understand what you mean.
>>>>
>>>> As noted in the other mail, you don't understand, because I was being
>>>> dense (and misled a little by the commit message).
>>>>
>>>>> After a
>>>>>     # echo 33554432 > /proc/sys/kernel/shmmax
>>>>>     # echo 2097152 > /proc/sys/kernel/shmmax
>>>>>
>>>>> both patches behave exactly identical.
>>>>
>>>> Yes.
>>>>
>>>>> There are only two differences:
>>>>> - Davidlohr's patch handles
>>>>>     # echo <really huge number that doesn't fit into 64-bit> >
>>>>> /proc/sys/kernel/shmmax
>>>>>    With my patch, shmmax would end up as 0 and all allocations fail.
>>>>>
>>>>> - My patch handles the case if some startup code/installer checks
>>>>>    shmmax and complains if it is below the requirement of the application.
>>>>
>>>> Thanks for that clarification. I withdraw my Ack.
>>>
>>> :(
>>>
>>>> In fact, maybe I
>>>> even like your approach a little more, because of that last point.
>>>
>>> And it is a fair point. However, this is my counter argument: if users
>>> are checking shmmax then they sure better be checking shmmin as well! So
>>> if my patch causes shmctl(,IPC_INFO,) to return shminfo.shmmax = 0 and a
>>> user only checks this value and breaks the application, then *he's*
>>> doing it wrong. Checking shmmin is just as important...  0 value is
>>> *bogus*,
>>
>> That counter-argument sounds bogus. On all systems that I know/knew
>> of, SHMIN always defaulted to 1. (Stevens APUE 1e documents this as
>> the typical default even as far back as 1992.) Furthermore, the limit
>> was always 1 on Linux, and as far as I know it has always been
>> immutable. I very much doubt any sysadmin ever changed SHMMIN (why
>> would they?), even on those systems where it was possible (and both
>> SHMMIN and SHMMAX seem to have been obsolete on Solaris for some time
>> now), or that any application ever checked the limit.
> 
> I'm not talking about *changing* SHMMIN, but checking for the value...
> anything less than 1 is of course complete crap. And that's not the
> kernel's fault.

Okay--I think I must be missing something. If shmmin is immutable, with the
value 1, why would anyone ever need to check its value? How can checking
it be just as important as checking shmmax?


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
