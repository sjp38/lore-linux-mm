Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 81A156B2544
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:52:28 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v74-v6so1665696lje.6
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:52:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6-v6sor23990128ljh.37.2018.11.21.00.52.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 00:52:26 -0800 (PST)
Date: Wed, 21 Nov 2018 11:52:23 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: Re: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181121085223.dylxncsobzoyok4w@esperanza>
References: <bug-201699-27@https.bugzilla.kernel.org/>
 <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
 <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dong <bauers@126.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Nov 19, 2018 at 07:56:53PM +0800, dong wrote:
> Sorry, there's a leak indeed. The memory was leaking all the time and
> I tried to run command `echo 3 > /proc/sys/vm/drop_caches`, it didn't
> help.
> 
> But when I delete the log files which was created by the failed
> systemd service, the leak(cached) memory was released.  I suspect the
> leak is relevant to the inode objects.

What kind of filesystem is used for storing logs?

Also, I assume you use SLAB. It would be nice if you could try to
reproduce the issue with SLUB, because the latter exports information
about per memcg caches under /sys/kernel/slab/<cache-name>/cgroup. It
could shed the light on what kinds of objects are not freed after cgroup
destruction.

In case of SLAB you can try to monitor /proc/slabinfo to see which
caches are growing. Anyway, you'll probably have to turn off kmem cache
merging - see slab_nomerge boot options.
