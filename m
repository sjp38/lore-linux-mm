Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9FD6B0007
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 08:20:54 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k22-v6so7100862wre.10
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 05:20:54 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id x195-v6si18648831wme.21.2018.11.01.05.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 05:20:52 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <154097891543.4007.9898414288875202246@skylake-alporthouse-com>
References: <20181031081945.207709-1-vovoy@chromium.org>
 <154097891543.4007.9898414288875202246@skylake-alporthouse-com>
Message-ID: <154107481370.4007.2421593962367820741@skylake-alporthouse-com>
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Date: Thu, 01 Nov 2018 12:20:13 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>, intel-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

Quoting Chris Wilson (2018-10-31 09:41:55)
> Quoting Kuo-Hsin Yang (2018-10-31 08:19:45)
> > The i915 driver uses shmemfs to allocate backing storage for gem
> > objects. These shmemfs pages can be pinned (increased ref count) by
> > shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> > wastes a lot of time scanning these pinned pages. In some extreme case,
> > all pages in the inactive anon lru are pinned, and only the inactive
> > anon lru is scanned due to inactive_ratio, the system cannot swap and
> > invokes the oom-killer. Mark these pinned pages as unevictable to speed
> > up vmscan.
> > =

> > Add check_move_lru_page() to move page to appropriate lru list.
> > =

> > This patch was inspired by Chris Wilson's change [1].
> > =

> > [1]: https://patchwork.kernel.org/patch/9768741/
> > =

> > Cc: Chris Wilson <chris@chris-wilson.co.uk>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> > ---
> > The previous mapping_set_unevictable patch is worse on gem_syslatency
> > because it defers to vmscan to move these pages to the unevictable list
> > and the test measures latency to allocate 2MiB pages. This performance
> > impact can be solved by explicit moving pages to the unevictable list in
> > the i915 function.
> > =

> > Chris, can you help to run the "igt/benchmarks/gem_syslatency -t 120 -b=
 -m"
> > test with this patch on your testing machine? I tried to run the test on
> > a Celeron N4000, 4GB Ram machine. The mean value with this patch is
> > similar to that with the mlock patch.
> =

> Will do. As you are confident, I'll try a few different machines. :)

I had one anomalous result with Ivybridge, but 3/4 different machines
confirm this is effective. I normalized the latency results from each
such that 0 is the baseline median latency (no i915 activity) and 1 is
the median latency with i915 running drm-tip.

    N           Min           Max        Median           Avg        Stddev
ivb 120      0.701641       2.79209       1.24469     1.3333911    0.408718=
25
byt 120     -0.108194     0.0777012     0.0485302    0.01343581   0.0615247=
34
bxt 120     -0.262057       6.27002     0.0801667    0.15963388    0.635281=
21
kbl 120    -0.0891262       1.22326    -0.0245336   0.041492506    0.149296=
89

Just need to go back and check on ivb, perhaps running on a few older =

chipsets as well. But the evidence so far indicates that this eliminates
the impact of i915 activity on the performance of shrink_page_list,
reducing the amount of crippling stalls under mempressure and often
preventing them.
-Chris
