Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 947D16B03A0
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:10:49 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c72so25848018ita.13
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 00:10:49 -0700 (PDT)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id s206si9368681itd.97.2017.03.30.00.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 00:10:48 -0700 (PDT)
Received: by mail-it0-x235.google.com with SMTP id y18so167190628itc.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 00:10:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170330055908.GA6603@bbox>
References: <20170317231636.142311-1-timmurray@google.com> <20170330055908.GA6603@bbox>
From: Tim Murray <timmurray@google.com>
Date: Thu, 30 Mar 2017 00:10:46 -0700
Message-ID: <CAEe=Sx=rg=YLagFX4LBQ7Z7wRjwsQGHbc7dNo8P5qQk9P8oLAA@mail.gmail.com>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Suren Baghdasaryan <surenb@google.com>, Patrik Torstensson <totte@google.com>, Android Kernel Team <kernel-team@android.com>

Sorry for the delay on my end as well. I realized that given multiple
equivalent prioritization implementations, my favorite would be the
one that provides the clearest signal to vmpressure. I've been
experimenting with different approaches to using memcg priority in
vmpressure, and I'm cautiously optimistic about my latest attempt. I
like the data I get from vmscan, but I'm still wiring up userspace and
testing different thresholds so I don't yet know that it's a strong
enough signal. I hope to have a new RFC before the weekend.

On Wed, Mar 29, 2017 at 10:59 PM, Minchan Kim <minchan@kernel.org> wrote:
> To memcg maintainer,
>
> Could you comment about this topic?
>
> On Fri, Mar 17, 2017 at 04:16:35PM -0700, Tim Murray wrote:
>> Hi all,
>>
>> I've been working to improve Android's memory management and drop lowmem=
orykiller from the kernel, and I'd like to get some feedback on a small pat=
ch with a lot of side effects.
>>
>> Currently, when an Android device is under memory pressure, one of three=
 things will happen from kswapd:
>>
>> 1. Compress an anonymous page to ZRAM.
>> 2. Evict a file page.
>> 3. Kill a process via lowmemorykiller.
>>
>> The first two are cheap and per-page, the third is relatively cheap in t=
he short term, frees many pages, and may cause power and performance penalt=
ies later on when the process has to be started again. For lots of reasons,=
 I'd like a better balance between reclamation and killing on Android.
>>
>> One of the nice things about Android from an optimization POV is that th=
e execution model is more constrained than a generic Linux machine. There a=
re only a limited number of processes that need to execute quickly for the =
device to appear to have good performance, and a userspace daemon (called A=
ctivityManagerService) knows exactly what those processes are at any given =
time. We've made use of that in the past via cpusets and schedtune to limit=
 the CPU resources available to background processes, and I think we can ap=
ply the same concept to memory.
>>
>> This patch adds a new tunable to mem cgroups, memory.priority. A mem cgr=
oup with a non-zero priority will not be eligible for scanning until the sc=
an_control's priority is greater than zero. Once the mem cgroup is eligible=
 for scanning, the priority acts as a bias to reduce the number of pages th=
at should be scanned.
>>
>> We've seen cases on Android where the global LRU isn't sufficient. For e=
xample, notifications in Android are rendered as part of a separate process=
 that runs infrequently. However, when a notification appears and the user =
slides down the notification tray, we'll often see dropped frames due to pa=
ge faults if there has been severe memory pressure. There are similar issue=
s with other persistent processes.
>>
>> The goal on an Android device is to aggressively evict from very low-pri=
ority background tasks that are likely to be killed anyway, since this will=
 reduce the likelihood of lowmemorykiller running in the first place. It wi=
ll still evict some from foreground and persistent processes, but it should=
 help ensure that background processes are effectively reduced to the size =
of their heaps before evicting from more critical tasks. This should mean f=
ewer background processes end up killed, which should improve performance a=
nd power on Android across the board (since it costs significantly less to =
page things back in than to replay the entirety of application startup).
>>
>> The follow-on that I'm also experimenting with is how to improve vmpress=
ure such that userspace can have some idea when low-priority memory cgroups=
 are about as small as they can get. The correct time for Android to kill a=
 background process under memory pressure is when there is evidence that a =
process has to be killed in order to alleviate memory pressure. If the devi=
ce is below the low memory watermark and we know that there's probably no w=
ay to reclaim any more from background processes, then a userspace daemon s=
hould kill one or more background processes to fix that. Per-cgroup priorit=
y could be the first step toward that information.
>>
>> I've tested a version of this patch on a Pixel running 3.18 along with a=
n overhauled version of lmkd (the Android userspace lowmemorykiller daemon)=
, and it does seem to work fine. I've ported it forward but have not yet ri=
gorously tested it at TOT, since I don't have an Android test setup running=
 TOT. While I'm getting my tests ported over, I would like some feedback on=
 adding another tunable as well as what the tunable's interface should be--=
I really don't like the 0-10 priority scheme I have in the patch but I don'=
t have a better idea.
>>
>> Thanks,
>> Tim
>>
>> Tim Murray (1):
>>   mm, memcg: add prioritized reclaim
>>
>>  include/linux/memcontrol.h | 20 +++++++++++++++++++-
>>  mm/memcontrol.c            | 33 +++++++++++++++++++++++++++++++++
>>  mm/vmscan.c                |  3 ++-
>>  3 files changed, 54 insertions(+), 2 deletions(-)
>>
>> --
>> 2.12.0.367.g23dc2f6d3c-goog
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
