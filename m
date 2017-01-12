Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12B046B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:56:21 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u143so36970283oif.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:56:21 -0800 (PST)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id t204si3699378oig.145.2017.01.12.05.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 05:56:20 -0800 (PST)
Received: by mail-oi0-x243.google.com with SMTP id j15so2928165oih.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:56:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170106162827.GA31816@esperanza>
References: <bug-190841-27@https.bugzilla.kernel.org/> <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
 <20170106162827.GA31816@esperanza>
From: Vladyslav Frolov <frolvlad@gmail.com>
Date: Thu, 12 Jan 2017 15:55:59 +0200
Message-ID: <CAJABK0M6NYgQRzJnTv0w4qHiyY+zQUHs_5f0_zTNYodDXNi=mQ@mail.gmail.com>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

Indeed, `cgroup.memory=nokmem` works around the high load average on
all the kernels!

4.10rc2 kernel without `cgroup.memory=nokmem` behaves much better than
4.7-4.9 kernels, yet it still reaches LA ~6 using my reproduction
script, while LA <=1.0 is expected. 4.10rc2 feels like 4.6, which I
described as "seminormal".

Running the reproduction script 3000 times gives the following results:

* 4.4 kernel takes 13 seconds to complete and LA <= 1.0
* 4.6-4.10rc2 kernels with `cgroup.memory=nokmem'` also takes 13
seconds to complete and LA <= 1.0
* 4.6 kernel takes 25 seconds to complete and LA ~= 5
* 4.7-4.9 kernels take 6-9 minutes (yes, 25-40 times slower than with
`nokmem`) to complete and LA > 20
* 4.10rc2 kernel takes 60 seconds (4 times slower than with `nokmem`)
to complete and LA ~= 6


On 6 January 2017 at 18:28, Vladimir Davydov <vdavydov@tarantool.org> wrote:
> Hello,
>
> The issue does look like kmemcg related - see below.
>
> On Wed, Jan 04, 2017 at 05:30:37PM -0800, Andrew Morton wrote:
>
>> > * Ubuntu 4.4.0-57 kernel works fine
>> > * Mainline 4.4.39 and below seem to work just fine -
>> > https://youtu.be/tGD6sfwa-3c
>
> kmemcg is disabled
>
>> > * Mainline 4.6.7 kernel behaves seminormal, load average is higher than on 4.4,
>> > but not as bad as on 4.7+ - https://youtu.be/-CyhmkkPbKE
>
> 4.6+
>
> b313aeee25098 mm: memcontrol: enable kmem accounting for all cgroups in the legacy hierarchy
>
> kmemcg is enabled by default for all cgroups, which introduces extra
> overhead to memcg destruction path
>
>> > * Mainline 4.7.0-rc1 kernel is the first kernel after 4.6.7 that is available
>> > in binaries, so I chose to test it and it doesn't play nicely -
>> > https://youtu.be/C_J5es74Ars
>
> 4.7+
>
> 81ae6d03952c1 mm/slub.c: replace kick_all_cpus_sync() with synchronize_sched() in kmem_cache_shrink()
>
> kick_all_cpus_sync(), which was used for synchronizing slub cache
> destruction before this commit, turns out to be too disruptive on big
> SMP machines as it generates a lot of IPIs, so it is replaced with more
> lightweight synchronize_sched(). The latter, however, blocks cgroup
> rmdir under the slab_mutex for relatively long, resulting in higher load
> average as well as stalling other processes trying to create or destroy
> a kmem cache.
>
>> > * Mainline 4.9.0 kernel still doesn't play nicely -
>> > https://youtu.be/_o17U5x3bmY
>
> The above-mentioned issue is still unfixed.
>
>> >
>> > OTHER NOTES:
>> > 1. Using VirtualBox I have noticed that this bug only reproducible when I have
>> > 2+ CPU cores!
>
> synchronize_sched() is a no-op on UP machines, which explains why on a
> UP machine the problems goes away.
>
> If I'm correct, the issue must have been fixed in 4.10, which is yet to
> be released:
>
> 89e364db71fb5 slub: move synchronize_sched out of slab_mutex on shrink
>
> You can workaround it on older kernels by turning kmem accounting off.
> To do that, append 'cgroup.memory=nokmem' to the kernel command line.
> Alternatively, you can try to recompile the kernel choosing SLAB as the
> slab allocator, because only SLUB is affected IIRC.
>
> FWIW I tried the script you provided in a 4 CPU VM running 4.10-rc2 and
> didn't notice any significant stalls or latency spikes. Could you please
> check if this kernel fixes your problem? If it does it might be worth
> submitting the patch to stable..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
