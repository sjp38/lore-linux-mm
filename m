Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 791026B02AF
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 23:37:04 -0500 (EST)
Received: by ggni2 with SMTP id i2so476418ggn.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 20:37:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1323829490.22361.395.camel@sli10-conroe>
References: <1323798271-1452-1-git-send-email-mikew@google.com> <1323829490.22361.395.camel@sli10-conroe>
From: Mike Waychison <mikew@google.com>
Date: Tue, 13 Dec 2011 20:36:43 -0800
Message-ID: <CAGTjWtDvmLnNqUoddUCmLVSDN0HcOjtsuFbAs+MFy24JFX-P3g@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix kswapd livelock on single core, no preempt kernel
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickens <hughd@google.com>, Greg Thelen <gthelen@google.com>

On Tue, Dec 13, 2011 at 6:24 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Wed, 2011-12-14 at 01:44 +0800, Mike Waychison wrote:
>> On a single core system with kernel preemption disabled, it is possible
>> for the memory system to be so taxed that kswapd cannot make any forward
>> progress. =A0This can happen when most of system memory is tied up as
>> anonymous memory without swap enabled, causing kswapd to consistently
>> fail to achieve its watermark goals. =A0In turn, sleeping_prematurely()
>> will consistently return true and kswapd_try_to_sleep() to never invoke
>> schedule(). =A0This causes the kswapd thread to stay on the CPU in
>> perpetuity and keeps other threads from processing oom-kills to reclaim
>> memory.
>>
>> The cond_resched() instance in balance_pgdat() is never called as the
>> loop that iterates from DEF_PRIORITY down to 0 will always set
>> all_zones_ok to true, and not set it to false once we've passed
>> DEF_PRIORITY as zones that are marked ->all_unreclaimable are not
>> considered in the "all_zones_ok" evaluation.
>>
>> This change modifies kswapd_try_to_sleep to ensure that we enter
>> scheduler at least once per invocation if needed. =A0This allows kswapd =
to
>> get off the CPU and allows other threads to die off from the OOM killer
>> (freeing memory that is otherwise unavailable in the process).
> your description suggests zones with all_unreclaimable set. but in this
> case sleeping_prematurely() will return false instead of true, kswapd
> will do sleep then. is there anything I missed?

Debugging this, I didn't get a dump from oom-kill as it never ran
(until I binary patched in a cond_resched() into live hung machines --
this reproduced in a VM).

I was however able to capture the following data while it was hung:


/cloud/vmm/host/backend/perfmetric/node0/zone0/active_anon : long long =3D =
773
/cloud/vmm/host/backend/perfmetric/node0/zone0/active_file : long long =3D =
6
/cloud/vmm/host/backend/perfmetric/node0/zone0/anon_pages : long long =3D 1=
,329
/cloud/vmm/host/backend/perfmetric/node0/zone0/bounce : long long =3D 0
/cloud/vmm/host/backend/perfmetric/node0/zone0/dirtied : long long =3D 4,42=
5
/cloud/vmm/host/backend/perfmetric/node0/zone0/file_dirty : long long =3D 0
/cloud/vmm/host/backend/perfmetric/node0/zone0/file_mapped : long long =3D =
5
/cloud/vmm/host/backend/perfmetric/node0/zone0/file_pages : long long =3D 3=
30
/cloud/vmm/host/backend/perfmetric/node0/zone0/free_pages : long long =3D 2=
,018
/cloud/vmm/host/backend/perfmetric/node0/zone0/inactive_anon : long long =
=3D 865
/cloud/vmm/host/backend/perfmetric/node0/zone0/inactive_file : long long =
=3D 13
/cloud/vmm/host/backend/perfmetric/node0/zone0/kernel_stack : long long =3D=
 10
/cloud/vmm/host/backend/perfmetric/node0/zone0/mlock : long long =3D 0
/cloud/vmm/host/backend/perfmetric/node0/zone0/pagetable : long long =3D 74
/cloud/vmm/host/backend/perfmetric/node0/zone0/shmem : long long =3D 0
/cloud/vmm/host/backend/perfmetric/node0/zone0/slab_reclaimable : long long=
 =3D 54
/cloud/vmm/host/backend/perfmetric/node0/zone0/slab_unreclaimable :
long long =3D 130
/cloud/vmm/host/backend/perfmetric/node0/zone0/unevictable : long long =3D =
0
/cloud/vmm/host/backend/perfmetric/node0/zone0/writeback : long long =3D 0
/cloud/vmm/host/backend/perfmetric/node0/zone0/written : long long =3D 47,1=
84

/cloud/vmm/host/backend/perfmetric/node0/zone1/active_anon : long long =3D =
359,251
/cloud/vmm/host/backend/perfmetric/node0/zone1/active_file : long long =3D =
67
/cloud/vmm/host/backend/perfmetric/node0/zone1/anon_pages : long long =3D 4=
41,180
/cloud/vmm/host/backend/perfmetric/node0/zone1/bounce : long long =3D 0
/cloud/vmm/host/backend/perfmetric/node0/zone1/dirtied : long long =3D 6,45=
7,125
/cloud/vmm/host/backend/perfmetric/node0/zone1/file_dirty : long long =3D 0
/cloud/vmm/host/backend/perfmetric/node0/zone1/file_mapped : long long =3D =
134
/cloud/vmm/host/backend/perfmetric/node0/zone1/file_pages : long long =3D 3=
8,090
/cloud/vmm/host/backend/perfmetric/node0/zone1/free_pages : long long =3D 1=
,630
/cloud/vmm/host/backend/perfmetric/node0/zone1/inactive_anon : long
long =3D 119,779
/cloud/vmm/host/backend/perfmetric/node0/zone1/inactive_file : long long =
=3D 81
/cloud/vmm/host/backend/perfmetric/node0/zone1/kernel_stack : long long =3D=
 173
/cloud/vmm/host/backend/perfmetric/node0/zone1/mlock : long long =3D 0
/cloud/vmm/host/backend/perfmetric/node0/zone1/pagetable : long long =3D 15=
,222
/cloud/vmm/host/backend/perfmetric/node0/zone1/shmem : long long =3D 1
/cloud/vmm/host/backend/perfmetric/node0/zone1/slab_reclaimable : long
long =3D 1,677
/cloud/vmm/host/backend/perfmetric/node0/zone1/slab_unreclaimable :
long long =3D 7,152
/cloud/vmm/host/backend/perfmetric/node0/zone1/unevictable : long long =3D =
0
/cloud/vmm/host/backend/perfmetric/node0/zone1/writeback : long long =3D 8
/cloud/vmm/host/backend/perfmetric/node0/zone1/written : long long =3D 16,6=
39,708

These value were static while the machine was hung up in kswapd.  I
unfortunately don't have the low/min/max or lowmem watermarks handy.

>From stepping through with gdb, I was able to determine that
ZONE_DMA32 would fail zone_watermark_ok_safe(), causing a scan   up to
end_zone =3D=3D 1.  If memory serves, it would not get the
->all_unreclaimable flag.  I didn't get the chance to root cause this
internal inconsistency though.

FYI, this was seen with a 2.6.39-based kernel with no-numa, no-memcg
and swap-enabled.

If I get the chance, I can reproduce and look at this closer to try
and root cause why zone_reclaimable() would return true, but I won't
be able to do that until after the holidays -- sometime in January.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
