Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86AC66B0373
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:18:28 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 187so17415745itk.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:18:28 -0700 (PDT)
Received: from mail-it0-x22c.google.com (mail-it0-x22c.google.com. [2607:f8b0:4001:c0b::22c])
        by mx.google.com with ESMTPS id p19si17840959iod.95.2017.03.21.10.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 10:18:27 -0700 (PDT)
Received: by mail-it0-x22c.google.com with SMTP id y18so12507747itc.1
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:18:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170320055930.GA30167@bbox>
References: <20170317231636.142311-1-timmurray@google.com> <20170320055930.GA30167@bbox>
From: Tim Murray <timmurray@google.com>
Date: Tue, 21 Mar 2017 10:18:26 -0700
Message-ID: <CAEe=SxnYXGg+s15imF4D93DVzvhVT+yo5fvAvDtKrQKdXz2kyA@mail.gmail.com>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Suren Baghdasaryan <surenb@google.com>, Patrik Torstensson <totte@google.com>, Android Kernel Team <kernel-team@android.com>, vinmenon@codeaurora.org

On Sun, Mar 19, 2017 at 10:59 PM, Minchan Kim <minchan@kernel.org> wrote:
> However, I'm not sure your approach is good. It seems your approach just
> reclaims pages from groups (DEF_PRIORITY - memcg->priority) >=3D sc->prio=
rity.
> IOW, it is based on *temporal* memory pressure fluctuation sc->priority.
>
> Rather than it, I guess pages to be reclaimed should be distributed by
> memcg->priority. Namely, if global memory pressure happens and VM want to
> reclaim 100 pages, VM should reclaim 90 pages from memcg-A(priority-10)
> and 10 pages from memcg-B(prioirty-90).

This is what I debated most while writing this patch. If I'm
understanding your concern correctly, I think I'm doing more than
skipping high-priority cgroups:

- If the scan isn't high priority yet, then skip high-priority cgroups.
- When the scan is high priority, scan fewer pages from
higher-priority cgroups (using the priority to modify the shift in
get_scan_count).

This is tightly coupled with the question of what to do with
vmpressure. The right thing to do on an Android device under memory
pressure is probably something like this:

1. Reclaim aggressively from low-priority background processes. The
goal here is to reduce the pages used by background processes to the
size of their heaps (or smaller with ZRAM) but zero file pages.
They're already likely to be killed by userspace and we're keeping
them around opportunistically, so a performance hit if they run and
have to do IO to restore some of that working set is okay.
2. Reclaim a small amount from persistent processes. These often have
a performance-critical subset of pages that we absolutely don't want
paged out, but some reclaim of these processes is fine. They're large,
some of them only run sporadically and don't impact performance, it's
okay to touch these sometimes.
3. If there still aren't enough free pages, notify userspace to kill
any processes it can. If I put my "Android performance engineer
working on userspace" hat on, what I'd want to know from userspace is
that kswapd/direct reclaim probably has to scan foreground processes
in order to reclaim enough free pages to satisfy watermarks. That's a
signal I could directly act on from userspace.
4. If that still isn't enough, reclaim from foreground processes,
since those processes are performance-critical.

As a result, I like not being fair about which cgroups are scanned
initially. Some cgroups are strictly more important than others. (With
that said, I'm not tied to enforcing unfairness in scanning. Android
would probably use different priority levels for each app level for
fair scanning vs unfair scanning, but my guess is that the actual
reclaiming behavior would look similar in both schemes.)

Mem cgroup priority suggests a useful signal for vmpressure. If
scanning is starting to touch cgroups at a higher priority than
persistent processes, then the userspace lowmemorykiller could kill
one or more background processes (which would be in low-priority
cgroups that have already been scanned aggressively). The current lmk
hand-tuned watermarks would be gone, and tuning the /proc/sys/vm knobs
would be all that's required to make an Android device do the right
thing in terms of memory.

On Sun, Mar 19, 2017 at 10:59 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hello,
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
>
> AFAIK, many platforms as well as android have done it. IOW, they know wha=
t
> processes are important while others are not critical for user-response.
>
>> This patch adds a new tunable to mem cgroups, memory.priority. A mem cgr=
oup with a non-zero priority will not be eligible for scanning until the sc=
an_control's priority is greater than zero. Once the mem cgroup is eligible=
 for scanning, the priority acts as a bias to reduce the number of pages th=
at should be scanned.
>
> First of all, the concept makes sense to me. The problem with cgroup-per-=
app
> model is that it's really hard to predict how many of memory a group need=
s to
> make system smooth although we know what processes are important.
> Because of it, it's hard to tune memcg low/high/max proactively.
>
> So, it would be great if admin can give more priority some groups like
> graphic mamager, laucher and killer applications like TV manager, Dial
> manager and so (ie, when memory pressure happens, please reclaim more pag=
es
> from low priority groups).
>
> However, I'm not sure your approach is good. It seems your approach just
> reclaims pages from groups (DEF_PRIORITY - memcg->priority) >=3D sc->prio=
rity.
> IOW, it is based on *temporal* memory pressure fluctuation sc->priority.
>
> Rather than it, I guess pages to be reclaimed should be distributed by
> memcg->priority. Namely, if global memory pressure happens and VM want to
> reclaim 100 pages, VM should reclaim 90 pages from memcg-A(priority-10)
> and 10 pages from memcg-B(prioirty-90).
>
> Anyway, it's really desireble approach so memcg maintainers, Please, have=
 a
> look.
>
> Thanks.
>
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
