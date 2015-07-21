Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 29D976B025E
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:39:18 -0400 (EDT)
Received: by iehx8 with SMTP id x8so73106016ieh.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:39:18 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id 24si21364583iok.157.2015.07.21.14.39.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 14:39:17 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so121130497igb.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:39:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cover.1437303956.git.vdavydov@parallels.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
Date: Tue, 21 Jul 2015 14:39:17 -0700
Message-ID: <CAJu=L5_RJkOhOgvNimi3Vj688w3WDza74_K+pg3oUx4eVK8Bjg@mail.gmail.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: multipart/alternative; boundary=089e013cbd50773fe9051b697caf
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

--089e013cbd50773fe9051b697caf
Content-Type: text/plain; charset=UTF-8

On Sun, Jul 19, 2015 at 5:31 AM, Vladimir Davydov <vdavydov@parallels.com>
wrote:

> Hi,
>
> This patch set introduces a new user API for tracking user memory pages
> that have not been used for a given period of time. The purpose of this
> is to provide the userspace with the means of tracking a workload's
> working set, i.e. the set of pages that are actively used by the
> workload. Knowing the working set size can be useful for partitioning
> the system more efficiently, e.g. by tuning memory cgroup limits
> appropriately, or for job placement within a compute cluster.
>
> It is based on top of v4.2-rc2-mmotm-2015-07-15-16-46
> It applies without conflicts to v4.2-rc2-mmotm-2015-07-17-16-04 as well
>
> ---- USE CASES ----
>
> The unified cgroup hierarchy has memory.low and memory.high knobs, which
> are defined as the low and high boundaries for the workload working set
> size. However, the working set size of a workload may be unknown or
> change in time. With this patch set, one can periodically estimate the
> amount of memory unused by each cgroup and tune their memory.low and
> memory.high parameters accordingly, therefore optimizing the overall
> memory utilization.
>
> Another use case is balancing workloads within a compute cluster.
> Knowing how much memory is not really used by a workload unit may help
> take a more optimal decision when considering migrating the unit to
> another node within the cluster.
>
> Also, as noted by Minchan, this would be useful for per-process reclaim
> (https://lwn.net/Articles/545668/). With idle tracking, we could reclaim
> idle
> pages only by smart user memory manager.
>
> ---- USER API ----
>
> The user API consists of two new proc files:
>
>  * /proc/kpageidle.  This file implements a bitmap where each bit
> corresponds
>    to a page, indexed by PFN. When the bit is set, the corresponding page
> is
>    idle. A page is considered idle if it has not been accessed since it was
>    marked idle. To mark a page idle one should set the bit corresponding
> to the
>    page by writing to the file. A value written to the file is OR-ed with
> the
>    current bitmap value. Only user memory pages can be marked idle, for
> other
>    page types input is silently ignored. Writing to this file beyond max
> PFN
>    results in the ENXIO error. Only available when
> CONFIG_IDLE_PAGE_TRACKING is
>    set.
>
>    This file can be used to estimate the amount of pages that are not
>    used by a particular workload as follows:
>
>    1. mark all pages of interest idle by setting corresponding bits in the
>       /proc/kpageidle bitmap
>    2. wait until the workload accesses its working set
>    3. read /proc/kpageidle and count the number of bits set
>
>  * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
>    memory cgroup each page is charged to, indexed by PFN. Only available
> when
>    CONFIG_MEMCG is set.
>
>    This file can be used to find all pages (including unmapped file
>    pages) accounted to a particular cgroup. Using /proc/kpageidle, one
>    can then estimate the cgroup working set size.
>
> For an example of using these files for estimating the amount of unused
> memory pages per each memory cgroup, please see the script attached
> below.
>
> ---- REASONING ----
>
> The reason to introduce the new user API instead of using
> /proc/PID/{clear_refs,smaps} is that the latter has two serious
> drawbacks:
>
>  - it does not count unmapped file pages
>  - it affects the reclaimer logic
>
> The new API attempts to overcome them both. For more details on how it
> is achieved, please see the comment to patch 6.
>
> ---- CHANGE LOG ----
>
> Changes in v9:
>
>  - add cond_resched to /proc/kpage* read/write loop (Andres)
>  - rebase on top of v4.2-rc2-mmotm-2015-07-15-16-46
>

And thanks for the perf report.

This series
Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>


> Changes in v8:
>
>  - clear referenced/accessed bit in secondary ptes while accessing
>    /proc/kpageidle; this is required to estimate wss of KVM VMs (Andres)
>  - check the young flag when collapsing a huge page
>  - copy idle/young flags on page migration
>
> Changes in v7:
>
> This iteration addresses Andres's comments to v6:
>
>  - do not reuse page_referenced for clearing idle flag, introduce a
>    separate function instead; this way we won't issue expensive tlb
>    flushes on /proc/kpageidle read/write
>  - propagate young/idle flags from head to tail pages on thp split
>  - skip compound tail pages while reading/writing /proc/kpageidle
>  - cleanup page_referenced_one
>
> Changes in v6:
>
>  - Split the patch introducing page_cgroup_ino helper to ease review.
>  - Rebase on top of v4.1-rc7-mmotm-2015-06-09-16-55
>
> Changes in v5:
>
>  - Fix possible race between kpageidle_clear_pte_refs() and
>    __page_set_anon_rmap() by checking that a page is on an LRU list
>    under zone->lru_lock (Minchan).
>  - Export idle flag via /proc/kpageflags (Minchan).
>  - Rebase on top of 4.1-rc3.
>
> Changes in v4:
>
> This iteration primarily addresses Minchan's comments to v3:
>
>  - Implement /proc/kpageidle as a bitmap instead of using u64 per each
> page,
>    because there does not seem to be any future uses for the other 63 bits.
>  - Do not double-increase pra->referenced in page_referenced_one() if the
> page
>    was young and referenced recently.
>  - Remove the pointless (page_count == 0) check from kpageidle_get_page().
>  - Rename kpageidle_clear_refs() to kpageidle_clear_pte_refs().
>  - Improve comments to kpageidle-related functions.
>  - Rebase on top of 4.1-rc2.
>
> Note it does not address Minchan's concern of possible
> __page_set_anon_rmap vs
> page_referenced race (see https://lkml.org/lkml/2015/5/3/220) since it is
> still
> unclear if this race can really happen (see
> https://lkml.org/lkml/2015/5/4/160)
>
> Changes in v3:
>
>  - Enable CONFIG_IDLE_PAGE_TRACKING for 32 bit. Since this feature
>    requires two extra page flags and there is no space for them on 32
>    bit, page ext is used (thanks to Minchan Kim).
>  - Minor code cleanups and comments improved.
>  - Rebase on top of 4.1-rc1.
>
> Changes in v2:
>
>  - The main difference from v1 is the API change. In v1 the user can
>    only set the idle flag for all pages at once, and for clearing the
>    Idle flag on pages accessed via page tables /proc/PID/clear_refs
>    should be used.
>    The main drawback of the v1 approach, as noted by Minchan, is that on
>    big machines setting the idle flag for each pages can result in CPU
>    bursts, which would be especially frustrating if the user only wanted
>    to estimate the amount of idle pages for a particular process or VMA.
>    With the new API a more fine-grained approach is possible: one can
>    read a process's /proc/PID/pagemap and set/check the Idle flag only
>    for those pages of the process's address space he or she is
>    interested in.
>    Another good point about the v2 API is that it is possible to limit
>    /proc/kpage* scanning rate when the user wants to estimate the total
>    number of idle pages, which is unachievable with the v1 approach.
>  - Make /proc/kpagecgroup return the ino of the closest online ancestor
>    in case the cgroup a page is charged to is offline.
>  - Fix /proc/PID/clear_refs not clearing Young page flag.
>  - Rebase on top of v4.0-rc6-mmotm-2015-04-01-14-54
>
> v8: https://lkml.org/lkml/2015/7/15/587
> v7: https://lkml.org/lkml/2015/7/11/119
> v6: https://lkml.org/lkml/2015/6/12/301
> v5: https://lkml.org/lkml/2015/5/12/449
> v4: https://lkml.org/lkml/2015/5/7/580
> v3: https://lkml.org/lkml/2015/4/28/224
> v2: https://lkml.org/lkml/2015/4/7/260
> v1: https://lkml.org/lkml/2015/3/18/794
>
> ---- PATCH SET STRUCTURE ----
>
> The patch set is organized as follows:
>
>  - patch 1 adds page_cgroup_ino() helper for the sake of
>    /proc/kpagecgroup and patches 2-3 do related cleanup
>  - patch 4 adds /proc/kpagecgroup, which reports cgroup ino each page is
>    charged to
>  - patch 5 introduces a new mmu notifier callback, clear_young, which is
>    a lightweight version of clear_flush_young; it is used in patch 6
>  - patch 6 implements the idle page tracking feature, including the
>    userspace API, /proc/kpageidle
>  - patch 7 exports idle flag via /proc/kpageflags
>
> ---- SIMILAR WORKS ----
>
> Originally, the patch for tracking idle memory was proposed back in 2011
> by Michel Lespinasse (see http://lwn.net/Articles/459269/). The main
> difference between Michel's patch and this one is that Michel
> implemented a kernel space daemon for estimating idle memory size per
> cgroup while this patch only provides the userspace with the minimal API
> for doing the job, leaving the rest up to the userspace. However, they
> both share the same idea of Idle/Young page flags to avoid affecting the
> reclaimer logic.
>
> ---- PERFORMANCE EVALUATION ----
>
> SPECjvm2008 (https://www.spec.org/jvm2008/) was used to evaluate the
> performance impact introduced by this patch set. Three runs were carried
> out:
>
>  - base: kernel without the patch
>  - patched: patched kernel, the feature is not used
>  - patched-active: patched kernel, 1 minute-period daemon is used for
>    tracking idle memory
>
> For tracking idle memory, idlememstat utility was used:
> https://github.com/locker/idlememstat
>
> testcase            base            patched        patched-active
>
> compiler       537.40 ( 0.00)%   532.26 (-0.96)%   538.31 ( 0.17)%
> compress       305.47 ( 0.00)%   301.08 (-1.44)%   300.71 (-1.56)%
> crypto         284.32 ( 0.00)%   282.21 (-0.74)%   284.87 ( 0.19)%
> derby          411.05 ( 0.00)%   413.44 ( 0.58)%   412.07 ( 0.25)%
> mpegaudio      189.96 ( 0.00)%   190.87 ( 0.48)%   189.42 (-0.28)%
> scimark.large   46.85 ( 0.00)%    46.41 (-0.94)%    47.83 ( 2.09)%
> scimark.small  412.91 ( 0.00)%   415.41 ( 0.61)%   421.17 ( 2.00)%
> serial         204.23 ( 0.00)%   213.46 ( 4.52)%   203.17 (-0.52)%
> startup         36.76 ( 0.00)%    35.49 (-3.45)%    35.64 (-3.05)%
> sunflow        115.34 ( 0.00)%   115.08 (-0.23)%   117.37 ( 1.76)%
> xml            620.55 ( 0.00)%   619.95 (-0.10)%   620.39 (-0.03)%
>
> composite      211.50 ( 0.00)%   211.15 (-0.17)%   211.67 ( 0.08)%
>
> time idlememstat:
>
> 17.20user 65.16system 2:15:23elapsed 1%CPU (0avgtext+0avgdata
> 8476maxresident)k
> 448inputs+40outputs (1major+36052minor)pagefaults 0swaps
>
> ---- SCRIPT FOR COUNTING IDLE PAGES PER CGROUP ----
> #! /usr/bin/python
> #
>
> import os
> import stat
> import errno
> import struct
>
> CGROUP_MOUNT = "/sys/fs/cgroup/memory"
> BUFSIZE = 8 * 1024  # must be multiple of 8
>
>
> def get_hugepage_size():
>     with open("/proc/meminfo", "r") as f:
>         for s in f:
>             k, v = s.split(":")
>             if k == "Hugepagesize":
>                 return int(v.split()[0]) * 1024
>
> PAGE_SIZE = os.sysconf("SC_PAGE_SIZE")
> HUGEPAGE_SIZE = get_hugepage_size()
>
>
> def set_idle():
>     f = open("/proc/kpageidle", "wb", BUFSIZE)
>     while True:
>         try:
>             f.write(struct.pack("Q", pow(2, 64) - 1))
>         except IOError as err:
>             if err.errno == errno.ENXIO:
>                 break
>             raise
>     f.close()
>
>
> def count_idle():
>     f_flags = open("/proc/kpageflags", "rb", BUFSIZE)
>     f_cgroup = open("/proc/kpagecgroup", "rb", BUFSIZE)
>
>     with open("/proc/kpageidle", "rb", BUFSIZE) as f:
>         while f.read(BUFSIZE): pass  # update idle flag
>
>     idlememsz = {}
>     while True:
>         s1, s2 = f_flags.read(8), f_cgroup.read(8)
>         if not s1 or not s2:
>             break
>
>         flags, = struct.unpack('Q', s1)
>         cgino, = struct.unpack('Q', s2)
>
>         unevictable = (flags >> 18) & 1
>         huge = (flags >> 22) & 1
>         idle = (flags >> 25) & 1
>
>         if idle and not unevictable:
>             idlememsz[cgino] = idlememsz.get(cgino, 0) + \
>                 (HUGEPAGE_SIZE if huge else PAGE_SIZE)
>
>     f_flags.close()
>     f_cgroup.close()
>     return idlememsz
>
>
> if __name__ == "__main__":
>     print "Setting the idle flag for each page..."
>     set_idle()
>
>     raw_input("Wait until the workload accesses its working set, "
>               "then press Enter")
>
>     print "Counting idle pages..."
>     idlememsz = count_idle()
>
>     for dir, subdirs, files in os.walk(CGROUP_MOUNT):
>         ino = os.stat(dir)[stat.ST_INO]
>         print dir + ": " + str(idlememsz.get(ino, 0) / 1024) + " kB"
> ---- END SCRIPT ----
>
> Comments are more than welcome.
>
> Thanks,
>
> Vladimir Davydov (8):
>   memcg: add page_cgroup_ino helper
>   hwpoison: use page_cgroup_ino for filtering by memcg
>   memcg: zap try_get_mem_cgroup_from_page
>   proc: add kpagecgroup file
>   mmu-notifier: add clear_young callback
>   proc: add kpageidle file
>   proc: export idle flag via kpageflags
>   proc: add cond_resched to /proc/kpage* read/write loop
>
>  Documentation/vm/pagemap.txt           |  22 ++-
>  fs/proc/page.c                         | 282
> +++++++++++++++++++++++++++++++++
>  fs/proc/task_mmu.c                     |   4 +-
>  include/linux/memcontrol.h             |  10 +-
>  include/linux/mm.h                     |  98 ++++++++++++
>  include/linux/mmu_notifier.h           |  44 +++++
>  include/linux/page-flags.h             |  11 ++
>  include/linux/page_ext.h               |   4 +
>  include/uapi/linux/kernel-page-flags.h |   1 +
>  mm/Kconfig                             |  12 ++
>  mm/debug.c                             |   4 +
>  mm/huge_memory.c                       |  11 +-
>  mm/hwpoison-inject.c                   |   5 +-
>  mm/memcontrol.c                        |  71 ++++-----
>  mm/memory-failure.c                    |  16 +-
>  mm/migrate.c                           |   5 +
>  mm/mmu_notifier.c                      |  17 ++
>  mm/page_ext.c                          |   3 +
>  mm/rmap.c                              |   5 +
>  mm/swap.c                              |   2 +
>  virt/kvm/kvm_main.c                    |  18 +++
>  21 files changed, 579 insertions(+), 66 deletions(-)
>
> --
> 2.1.4
>
>


-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--089e013cbd50773fe9051b697caf
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Sun, Jul 19, 2015 at 5:31 AM, Vladimir Davydov <span dir=3D"ltr">&lt=
;<a href=3D"mailto:vdavydov@parallels.com" target=3D"_blank">vdavydov@paral=
lels.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Hi,<br>
<br>
This patch set introduces a new user API for tracking user memory pages<br>
that have not been used for a given period of time. The purpose of this<br>
is to provide the userspace with the means of tracking a workload&#39;s<br>
working set, i.e. the set of pages that are actively used by the<br>
workload. Knowing the working set size can be useful for partitioning<br>
the system more efficiently, e.g. by tuning memory cgroup limits<br>
appropriately, or for job placement within a compute cluster.<br>
<br>
It is based on top of v4.2-rc2-mmotm-2015-07-15-16-46<br>
It applies without conflicts to v4.2-rc2-mmotm-2015-07-17-16-04 as well<br>
<br>
---- USE CASES ----<br>
<br>
The unified cgroup hierarchy has memory.low and memory.high knobs, which<br=
>
are defined as the low and high boundaries for the workload working set<br>
size. However, the working set size of a workload may be unknown or<br>
change in time. With this patch set, one can periodically estimate the<br>
amount of memory unused by each cgroup and tune their memory.low and<br>
memory.high parameters accordingly, therefore optimizing the overall<br>
memory utilization.<br>
<br>
Another use case is balancing workloads within a compute cluster.<br>
Knowing how much memory is not really used by a workload unit may help<br>
take a more optimal decision when considering migrating the unit to<br>
another node within the cluster.<br>
<br>
Also, as noted by Minchan, this would be useful for per-process reclaim<br>
(<a href=3D"https://lwn.net/Articles/545668/" rel=3D"noreferrer" target=3D"=
_blank">https://lwn.net/Articles/545668/</a>). With idle tracking, we could=
 reclaim idle<br>
pages only by smart user memory manager.<br>
<br>
---- USER API ----<br>
<br>
The user API consists of two new proc files:<br>
<br>
=C2=A0* /proc/kpageidle.=C2=A0 This file implements a bitmap where each bit=
 corresponds<br>
=C2=A0 =C2=A0to a page, indexed by PFN. When the bit is set, the correspond=
ing page is<br>
=C2=A0 =C2=A0idle. A page is considered idle if it has not been accessed si=
nce it was<br>
=C2=A0 =C2=A0marked idle. To mark a page idle one should set the bit corres=
ponding to the<br>
=C2=A0 =C2=A0page by writing to the file. A value written to the file is OR=
-ed with the<br>
=C2=A0 =C2=A0current bitmap value. Only user memory pages can be marked idl=
e, for other<br>
=C2=A0 =C2=A0page types input is silently ignored. Writing to this file bey=
ond max PFN<br>
=C2=A0 =C2=A0results in the ENXIO error. Only available when CONFIG_IDLE_PA=
GE_TRACKING is<br>
=C2=A0 =C2=A0set.<br>
<br>
=C2=A0 =C2=A0This file can be used to estimate the amount of pages that are=
 not<br>
=C2=A0 =C2=A0used by a particular workload as follows:<br>
<br>
=C2=A0 =C2=A01. mark all pages of interest idle by setting corresponding bi=
ts in the<br>
=C2=A0 =C2=A0 =C2=A0 /proc/kpageidle bitmap<br>
=C2=A0 =C2=A02. wait until the workload accesses its working set<br>
=C2=A0 =C2=A03. read /proc/kpageidle and count the number of bits set<br>
<br>
=C2=A0* /proc/kpagecgroup.=C2=A0 This file contains a 64-bit inode number o=
f the<br>
=C2=A0 =C2=A0memory cgroup each page is charged to, indexed by PFN. Only av=
ailable when<br>
=C2=A0 =C2=A0CONFIG_MEMCG is set.<br>
<br>
=C2=A0 =C2=A0This file can be used to find all pages (including unmapped fi=
le<br>
=C2=A0 =C2=A0pages) accounted to a particular cgroup. Using /proc/kpageidle=
, one<br>
=C2=A0 =C2=A0can then estimate the cgroup working set size.<br>
<br>
For an example of using these files for estimating the amount of unused<br>
memory pages per each memory cgroup, please see the script attached<br>
below.<br>
<br>
---- REASONING ----<br>
<br>
The reason to introduce the new user API instead of using<br>
/proc/PID/{clear_refs,smaps} is that the latter has two serious<br>
drawbacks:<br>
<br>
=C2=A0- it does not count unmapped file pages<br>
=C2=A0- it affects the reclaimer logic<br>
<br>
The new API attempts to overcome them both. For more details on how it<br>
is achieved, please see the comment to patch 6.<br>
<br>
---- CHANGE LOG ----<br>
<br>
Changes in v9:<br>
<br>
=C2=A0- add cond_resched to /proc/kpage* read/write loop (Andres)<br>
=C2=A0- rebase on top of v4.2-rc2-mmotm-2015-07-15-16-46<br></blockquote><d=
iv><br></div><div>And thanks for the perf report.</div><div><br></div><div>=
This series</div><div>Reviewed-by: Andres Lagar-Cavilla &lt;<a href=3D"mail=
to:andreslc@google.com">andreslc@google.com</a>&gt;</div><div><br></div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #=
ccc solid;padding-left:1ex">
<br>
Changes in v8:<br>
<br>
=C2=A0- clear referenced/accessed bit in secondary ptes while accessing<br>
=C2=A0 =C2=A0/proc/kpageidle; this is required to estimate wss of KVM VMs (=
Andres)<br>
=C2=A0- check the young flag when collapsing a huge page<br>
=C2=A0- copy idle/young flags on page migration<br>
<br>
Changes in v7:<br>
<br>
This iteration addresses Andres&#39;s comments to v6:<br>
<br>
=C2=A0- do not reuse page_referenced for clearing idle flag, introduce a<br=
>
=C2=A0 =C2=A0separate function instead; this way we won&#39;t issue expensi=
ve tlb<br>
=C2=A0 =C2=A0flushes on /proc/kpageidle read/write<br>
=C2=A0- propagate young/idle flags from head to tail pages on thp split<br>
=C2=A0- skip compound tail pages while reading/writing /proc/kpageidle<br>
=C2=A0- cleanup page_referenced_one<br>
<br>
Changes in v6:<br>
<br>
=C2=A0- Split the patch introducing page_cgroup_ino helper to ease review.<=
br>
=C2=A0- Rebase on top of v4.1-rc7-mmotm-2015-06-09-16-55<br>
<br>
Changes in v5:<br>
<br>
=C2=A0- Fix possible race between kpageidle_clear_pte_refs() and<br>
=C2=A0 =C2=A0__page_set_anon_rmap() by checking that a page is on an LRU li=
st<br>
=C2=A0 =C2=A0under zone-&gt;lru_lock (Minchan).<br>
=C2=A0- Export idle flag via /proc/kpageflags (Minchan).<br>
=C2=A0- Rebase on top of 4.1-rc3.<br>
<br>
Changes in v4:<br>
<br>
This iteration primarily addresses Minchan&#39;s comments to v3:<br>
<br>
=C2=A0- Implement /proc/kpageidle as a bitmap instead of using u64 per each=
 page,<br>
=C2=A0 =C2=A0because there does not seem to be any future uses for the othe=
r 63 bits.<br>
=C2=A0- Do not double-increase pra-&gt;referenced in page_referenced_one() =
if the page<br>
=C2=A0 =C2=A0was young and referenced recently.<br>
=C2=A0- Remove the pointless (page_count =3D=3D 0) check from kpageidle_get=
_page().<br>
=C2=A0- Rename kpageidle_clear_refs() to kpageidle_clear_pte_refs().<br>
=C2=A0- Improve comments to kpageidle-related functions.<br>
=C2=A0- Rebase on top of 4.1-rc2.<br>
<br>
Note it does not address Minchan&#39;s concern of possible __page_set_anon_=
rmap vs<br>
page_referenced race (see <a href=3D"https://lkml.org/lkml/2015/5/3/220" re=
l=3D"noreferrer" target=3D"_blank">https://lkml.org/lkml/2015/5/3/220</a>) =
since it is still<br>
unclear if this race can really happen (see <a href=3D"https://lkml.org/lkm=
l/2015/5/4/160" rel=3D"noreferrer" target=3D"_blank">https://lkml.org/lkml/=
2015/5/4/160</a>)<br>
<br>
Changes in v3:<br>
<br>
=C2=A0- Enable CONFIG_IDLE_PAGE_TRACKING for 32 bit. Since this feature<br>
=C2=A0 =C2=A0requires two extra page flags and there is no space for them o=
n 32<br>
=C2=A0 =C2=A0bit, page ext is used (thanks to Minchan Kim).<br>
=C2=A0- Minor code cleanups and comments improved.<br>
=C2=A0- Rebase on top of 4.1-rc1.<br>
<br>
Changes in v2:<br>
<br>
=C2=A0- The main difference from v1 is the API change. In v1 the user can<b=
r>
=C2=A0 =C2=A0only set the idle flag for all pages at once, and for clearing=
 the<br>
=C2=A0 =C2=A0Idle flag on pages accessed via page tables /proc/PID/clear_re=
fs<br>
=C2=A0 =C2=A0should be used.<br>
=C2=A0 =C2=A0The main drawback of the v1 approach, as noted by Minchan, is =
that on<br>
=C2=A0 =C2=A0big machines setting the idle flag for each pages can result i=
n CPU<br>
=C2=A0 =C2=A0bursts, which would be especially frustrating if the user only=
 wanted<br>
=C2=A0 =C2=A0to estimate the amount of idle pages for a particular process =
or VMA.<br>
=C2=A0 =C2=A0With the new API a more fine-grained approach is possible: one=
 can<br>
=C2=A0 =C2=A0read a process&#39;s /proc/PID/pagemap and set/check the Idle =
flag only<br>
=C2=A0 =C2=A0for those pages of the process&#39;s address space he or she i=
s<br>
=C2=A0 =C2=A0interested in.<br>
=C2=A0 =C2=A0Another good point about the v2 API is that it is possible to =
limit<br>
=C2=A0 =C2=A0/proc/kpage* scanning rate when the user wants to estimate the=
 total<br>
=C2=A0 =C2=A0number of idle pages, which is unachievable with the v1 approa=
ch.<br>
=C2=A0- Make /proc/kpagecgroup return the ino of the closest online ancesto=
r<br>
=C2=A0 =C2=A0in case the cgroup a page is charged to is offline.<br>
=C2=A0- Fix /proc/PID/clear_refs not clearing Young page flag.<br>
=C2=A0- Rebase on top of v4.0-rc6-mmotm-2015-04-01-14-54<br>
<br>
v8: <a href=3D"https://lkml.org/lkml/2015/7/15/587" rel=3D"noreferrer" targ=
et=3D"_blank">https://lkml.org/lkml/2015/7/15/587</a><br>
v7: <a href=3D"https://lkml.org/lkml/2015/7/11/119" rel=3D"noreferrer" targ=
et=3D"_blank">https://lkml.org/lkml/2015/7/11/119</a><br>
v6: <a href=3D"https://lkml.org/lkml/2015/6/12/301" rel=3D"noreferrer" targ=
et=3D"_blank">https://lkml.org/lkml/2015/6/12/301</a><br>
v5: <a href=3D"https://lkml.org/lkml/2015/5/12/449" rel=3D"noreferrer" targ=
et=3D"_blank">https://lkml.org/lkml/2015/5/12/449</a><br>
v4: <a href=3D"https://lkml.org/lkml/2015/5/7/580" rel=3D"noreferrer" targe=
t=3D"_blank">https://lkml.org/lkml/2015/5/7/580</a><br>
v3: <a href=3D"https://lkml.org/lkml/2015/4/28/224" rel=3D"noreferrer" targ=
et=3D"_blank">https://lkml.org/lkml/2015/4/28/224</a><br>
v2: <a href=3D"https://lkml.org/lkml/2015/4/7/260" rel=3D"noreferrer" targe=
t=3D"_blank">https://lkml.org/lkml/2015/4/7/260</a><br>
v1: <a href=3D"https://lkml.org/lkml/2015/3/18/794" rel=3D"noreferrer" targ=
et=3D"_blank">https://lkml.org/lkml/2015/3/18/794</a><br>
<br>
---- PATCH SET STRUCTURE ----<br>
<br>
The patch set is organized as follows:<br>
<br>
=C2=A0- patch 1 adds page_cgroup_ino() helper for the sake of<br>
=C2=A0 =C2=A0/proc/kpagecgroup and patches 2-3 do related cleanup<br>
=C2=A0- patch 4 adds /proc/kpagecgroup, which reports cgroup ino each page =
is<br>
=C2=A0 =C2=A0charged to<br>
=C2=A0- patch 5 introduces a new mmu notifier callback, clear_young, which =
is<br>
=C2=A0 =C2=A0a lightweight version of clear_flush_young; it is used in patc=
h 6<br>
=C2=A0- patch 6 implements the idle page tracking feature, including the<br=
>
=C2=A0 =C2=A0userspace API, /proc/kpageidle<br>
=C2=A0- patch 7 exports idle flag via /proc/kpageflags<br>
<br>
---- SIMILAR WORKS ----<br>
<br>
Originally, the patch for tracking idle memory was proposed back in 2011<br=
>
by Michel Lespinasse (see <a href=3D"http://lwn.net/Articles/459269/" rel=
=3D"noreferrer" target=3D"_blank">http://lwn.net/Articles/459269/</a>). The=
 main<br>
difference between Michel&#39;s patch and this one is that Michel<br>
implemented a kernel space daemon for estimating idle memory size per<br>
cgroup while this patch only provides the userspace with the minimal API<br=
>
for doing the job, leaving the rest up to the userspace. However, they<br>
both share the same idea of Idle/Young page flags to avoid affecting the<br=
>
reclaimer logic.<br>
<br>
---- PERFORMANCE EVALUATION ----<br>
<br>
SPECjvm2008 (<a href=3D"https://www.spec.org/jvm2008/" rel=3D"noreferrer" t=
arget=3D"_blank">https://www.spec.org/jvm2008/</a>) was used to evaluate th=
e<br>
performance impact introduced by this patch set. Three runs were carried<br=
>
out:<br>
<br>
=C2=A0- base: kernel without the patch<br>
=C2=A0- patched: patched kernel, the feature is not used<br>
=C2=A0- patched-active: patched kernel, 1 minute-period daemon is used for<=
br>
=C2=A0 =C2=A0tracking idle memory<br>
<br>
For tracking idle memory, idlememstat utility was used:<br>
<a href=3D"https://github.com/locker/idlememstat" rel=3D"noreferrer" target=
=3D"_blank">https://github.com/locker/idlememstat</a><br>
<br>
testcase=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 base=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 patched=C2=A0 =C2=A0 =C2=A0 =C2=A0 patched-active<br>
<br>
compiler=C2=A0 =C2=A0 =C2=A0 =C2=A0537.40 ( 0.00)%=C2=A0 =C2=A0532.26 (-0.9=
6)%=C2=A0 =C2=A0538.31 ( 0.17)%<br>
compress=C2=A0 =C2=A0 =C2=A0 =C2=A0305.47 ( 0.00)%=C2=A0 =C2=A0301.08 (-1.4=
4)%=C2=A0 =C2=A0300.71 (-1.56)%<br>
crypto=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0284.32 ( 0.00)%=C2=A0 =C2=A0282.21 =
(-0.74)%=C2=A0 =C2=A0284.87 ( 0.19)%<br>
derby=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 411.05 ( 0.00)%=C2=A0 =C2=A0413.44 =
( 0.58)%=C2=A0 =C2=A0412.07 ( 0.25)%<br>
mpegaudio=C2=A0 =C2=A0 =C2=A0 189.96 ( 0.00)%=C2=A0 =C2=A0190.87 ( 0.48)%=
=C2=A0 =C2=A0189.42 (-0.28)%<br>
scimark.large=C2=A0 =C2=A046.85 ( 0.00)%=C2=A0 =C2=A0 46.41 (-0.94)%=C2=A0 =
=C2=A0 47.83 ( 2.09)%<br>
scimark.small=C2=A0 412.91 ( 0.00)%=C2=A0 =C2=A0415.41 ( 0.61)%=C2=A0 =C2=
=A0421.17 ( 2.00)%<br>
serial=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0204.23 ( 0.00)%=C2=A0 =C2=A0213.46 =
( 4.52)%=C2=A0 =C2=A0203.17 (-0.52)%<br>
startup=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A036.76 ( 0.00)%=C2=A0 =C2=A0 35.49 =
(-3.45)%=C2=A0 =C2=A0 35.64 (-3.05)%<br>
sunflow=C2=A0 =C2=A0 =C2=A0 =C2=A0 115.34 ( 0.00)%=C2=A0 =C2=A0115.08 (-0.2=
3)%=C2=A0 =C2=A0117.37 ( 1.76)%<br>
xml=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 620.55 ( 0.00)%=C2=A0 =C2=A061=
9.95 (-0.10)%=C2=A0 =C2=A0620.39 (-0.03)%<br>
<br>
composite=C2=A0 =C2=A0 =C2=A0 211.50 ( 0.00)%=C2=A0 =C2=A0211.15 (-0.17)%=
=C2=A0 =C2=A0211.67 ( 0.08)%<br>
<br>
time idlememstat:<br>
<br>
17.20user 65.16system 2:15:23elapsed 1%CPU (0avgtext+0avgdata 8476maxreside=
nt)k<br>
448inputs+40outputs (1major+36052minor)pagefaults 0swaps<br>
<br>
---- SCRIPT FOR COUNTING IDLE PAGES PER CGROUP ----<br>
#! /usr/bin/python<br>
#<br>
<br>
import os<br>
import stat<br>
import errno<br>
import struct<br>
<br>
CGROUP_MOUNT =3D &quot;/sys/fs/cgroup/memory&quot;<br>
BUFSIZE =3D 8 * 1024=C2=A0 # must be multiple of 8<br>
<br>
<br>
def get_hugepage_size():<br>
=C2=A0 =C2=A0 with open(&quot;/proc/meminfo&quot;, &quot;r&quot;) as f:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for s in f:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 k, v =3D s.split(&quot;:&quot;)<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if k =3D=3D &quot;Hugepagesize&qu=
ot;:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return int(v.split(=
)[0]) * 1024<br>
<br>
PAGE_SIZE =3D os.sysconf(&quot;SC_PAGE_SIZE&quot;)<br>
HUGEPAGE_SIZE =3D get_hugepage_size()<br>
<br>
<br>
def set_idle():<br>
=C2=A0 =C2=A0 f =3D open(&quot;/proc/kpageidle&quot;, &quot;wb&quot;, BUFSI=
ZE)<br>
=C2=A0 =C2=A0 while True:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 try:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 f.write(struct.pack(&quot;Q&quot;=
, pow(2, 64) - 1))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 except IOError as err:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if err.errno =3D=3D errno.ENXIO:<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 raise<br>
=C2=A0 =C2=A0 f.close()<br>
<br>
<br>
def count_idle():<br>
=C2=A0 =C2=A0 f_flags =3D open(&quot;/proc/kpageflags&quot;, &quot;rb&quot;=
, BUFSIZE)<br>
=C2=A0 =C2=A0 f_cgroup =3D open(&quot;/proc/kpagecgroup&quot;, &quot;rb&quo=
t;, BUFSIZE)<br>
<br>
=C2=A0 =C2=A0 with open(&quot;/proc/kpageidle&quot;, &quot;rb&quot;, BUFSIZ=
E) as f:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 while f.read(BUFSIZE): pass=C2=A0 # update idle=
 flag<br>
<br>
=C2=A0 =C2=A0 idlememsz =3D {}<br>
=C2=A0 =C2=A0 while True:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 s1, s2 =3D f_flags.read(8), f_cgroup.read(8)<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if not s1 or not s2:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 flags, =3D struct.unpack(&#39;Q&#39;, s1)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 cgino, =3D struct.unpack(&#39;Q&#39;, s2)<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unevictable =3D (flags &gt;&gt; 18) &amp; 1<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 huge =3D (flags &gt;&gt; 22) &amp; 1<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 idle =3D (flags &gt;&gt; 25) &amp; 1<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if idle and not unevictable:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 idlememsz[cgino] =3D idlememsz.ge=
t(cgino, 0) + \<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (HUGEPAGE_SIZE if h=
uge else PAGE_SIZE)<br>
<br>
=C2=A0 =C2=A0 f_flags.close()<br>
=C2=A0 =C2=A0 f_cgroup.close()<br>
=C2=A0 =C2=A0 return idlememsz<br>
<br>
<br>
if __name__ =3D=3D &quot;__main__&quot;:<br>
=C2=A0 =C2=A0 print &quot;Setting the idle flag for each page...&quot;<br>
=C2=A0 =C2=A0 set_idle()<br>
<br>
=C2=A0 =C2=A0 raw_input(&quot;Wait until the workload accesses its working =
set, &quot;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;then press Enter&quo=
t;)<br>
<br>
=C2=A0 =C2=A0 print &quot;Counting idle pages...&quot;<br>
=C2=A0 =C2=A0 idlememsz =3D count_idle()<br>
<br>
=C2=A0 =C2=A0 for dir, subdirs, files in os.walk(CGROUP_MOUNT):<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ino =3D os.stat(dir)[stat.ST_INO]<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 print dir + &quot;: &quot; + str(idlememsz.get(=
ino, 0) / 1024) + &quot; kB&quot;<br>
---- END SCRIPT ----<br>
<br>
Comments are more than welcome.<br>
<br>
Thanks,<br>
<br>
Vladimir Davydov (8):<br>
=C2=A0 memcg: add page_cgroup_ino helper<br>
=C2=A0 hwpoison: use page_cgroup_ino for filtering by memcg<br>
=C2=A0 memcg: zap try_get_mem_cgroup_from_page<br>
=C2=A0 proc: add kpagecgroup file<br>
=C2=A0 mmu-notifier: add clear_young callback<br>
=C2=A0 proc: add kpageidle file<br>
=C2=A0 proc: export idle flag via kpageflags<br>
=C2=A0 proc: add cond_resched to /proc/kpage* read/write loop<br>
<br>
=C2=A0Documentation/vm/pagemap.txt=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
|=C2=A0 22 ++-<br>
=C2=A0fs/proc/page.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 282 +++++++++++++++++++++++++++++++++<=
br>
=C2=A0fs/proc/task_mmu.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A04 +-<br>
=C2=A0include/linux/memcontrol.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0|=C2=A0 10 +-<br>
=C2=A0include/linux/mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 98 ++++++++++++<br>
=C2=A0include/linux/mmu_notifier.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
|=C2=A0 44 +++++<br>
=C2=A0include/linux/page-flags.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0|=C2=A0 11 ++<br>
=C2=A0include/linux/page_ext.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A04 +<br>
=C2=A0include/uapi/linux/kernel-page-flags.h |=C2=A0 =C2=A01 +<br>
=C2=A0mm/Kconfig=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 12 ++<br>
=C2=A0mm/debug.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A04 +<br>
=C2=A0mm/huge_memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 11 +-<br>
=C2=A0mm/hwpoison-inject.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A05 +-<br>
=C2=A0mm/memcontrol.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 71 ++++-----<br>
=C2=A0mm/memory-failure.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 16 +-<br>
=C2=A0mm/migrate.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A05 +<br>
=C2=A0mm/mmu_notifier.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 17 ++<br>
=C2=A0mm/page_ext.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A03 +<br>
=C2=A0mm/rmap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A05 +<br>
=C2=A0mm/swap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A02 +<br>
=C2=A0virt/kvm/kvm_main.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 18 +++<br>
=C2=A021 files changed, 579 insertions(+), 66 deletions(-)<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
2.1.4<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div class=3D"gmail_signature"><div dir=3D"ltr"><span style=3D"color:rgb(=
85,85,85);font-family:sans-serif;font-size:small;line-height:19.5px;border-=
width:2px 0px 0px;border-style:solid;border-color:rgb(213,15,37);padding-to=
p:2px;margin-top:2px">Andres Lagar-Cavilla=C2=A0|</span><span style=3D"colo=
r:rgb(85,85,85);font-family:sans-serif;font-size:small;line-height:19.5px;b=
order-width:2px 0px 0px;border-style:solid;border-color:rgb(51,105,232);pad=
ding-top:2px;margin-top:2px">=C2=A0Google Kernel Team |</span><span style=
=3D"color:rgb(85,85,85);font-family:sans-serif;font-size:small;line-height:=
19.5px;border-width:2px 0px 0px;border-style:solid;border-color:rgb(0,153,5=
7);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"mailto:andreslc@google.=
com" target=3D"_blank">andreslc@google.com</a>=C2=A0</span><br></div></div>
</div></div>

--089e013cbd50773fe9051b697caf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
