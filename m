Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8C96B026C
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:28:38 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id i135so14695657lfe.1
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:28:37 -0800 (PST)
Received: from smtp21.mail.ru (smtp21.mail.ru. [94.100.179.250])
        by mx.google.com with ESMTPS id 29si28772601lfx.390.2017.01.06.08.28.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 08:28:36 -0800 (PST)
Date: Fri, 6 Jan 2017 19:28:27 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Message-ID: <20170106162827.GA31816@esperanza>
References: <bug-190841-27@https.bugzilla.kernel.org/>
 <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: frolvlad@gmail.com
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

Hello,

The issue does look like kmemcg related - see below.

On Wed, Jan 04, 2017 at 05:30:37PM -0800, Andrew Morton wrote:

> > * Ubuntu 4.4.0-57 kernel works fine
> > * Mainline 4.4.39 and below seem to work just fine -
> > https://youtu.be/tGD6sfwa-3c

kmemcg is disabled

> > * Mainline 4.6.7 kernel behaves seminormal, load average is higher than on 4.4,
> > but not as bad as on 4.7+ - https://youtu.be/-CyhmkkPbKE

4.6+

b313aeee25098 mm: memcontrol: enable kmem accounting for all cgroups in the legacy hierarchy

kmemcg is enabled by default for all cgroups, which introduces extra
overhead to memcg destruction path

> > * Mainline 4.7.0-rc1 kernel is the first kernel after 4.6.7 that is available
> > in binaries, so I chose to test it and it doesn't play nicely -
> > https://youtu.be/C_J5es74Ars

4.7+

81ae6d03952c1 mm/slub.c: replace kick_all_cpus_sync() with synchronize_sched() in kmem_cache_shrink()

kick_all_cpus_sync(), which was used for synchronizing slub cache
destruction before this commit, turns out to be too disruptive on big
SMP machines as it generates a lot of IPIs, so it is replaced with more
lightweight synchronize_sched(). The latter, however, blocks cgroup
rmdir under the slab_mutex for relatively long, resulting in higher load
average as well as stalling other processes trying to create or destroy
a kmem cache.

> > * Mainline 4.9.0 kernel still doesn't play nicely -
> > https://youtu.be/_o17U5x3bmY

The above-mentioned issue is still unfixed.

> > 
> > OTHER NOTES:
> > 1. Using VirtualBox I have noticed that this bug only reproducible when I have
> > 2+ CPU cores!

synchronize_sched() is a no-op on UP machines, which explains why on a
UP machine the problems goes away.

If I'm correct, the issue must have been fixed in 4.10, which is yet to
be released:

89e364db71fb5 slub: move synchronize_sched out of slab_mutex on shrink

You can workaround it on older kernels by turning kmem accounting off.
To do that, append 'cgroup.memory=nokmem' to the kernel command line.
Alternatively, you can try to recompile the kernel choosing SLAB as the
slab allocator, because only SLUB is affected IIRC.

FWIW I tried the script you provided in a 4 CPU VM running 4.10-rc2 and
didn't notice any significant stalls or latency spikes. Could you please
check if this kernel fixes your problem? If it does it might be worth
submitting the patch to stable..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
