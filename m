Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 298AC6B02DF
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:42:36 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id h67-v6so13641908wmh.0
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:42:36 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id e1-v6si1115675wrt.130.2018.10.31.02.42.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 02:42:34 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20181031081945.207709-1-vovoy@chromium.org>
References: <20181031081945.207709-1-vovoy@chromium.org>
Message-ID: <154097891543.4007.9898414288875202246@skylake-alporthouse-com>
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Date: Wed, 31 Oct 2018 09:41:55 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>, intel-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

Quoting Kuo-Hsin Yang (2018-10-31 08:19:45)
> The i915 driver uses shmemfs to allocate backing storage for gem
> objects. These shmemfs pages can be pinned (increased ref count) by
> shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> wastes a lot of time scanning these pinned pages. In some extreme case,
> all pages in the inactive anon lru are pinned, and only the inactive
> anon lru is scanned due to inactive_ratio, the system cannot swap and
> invokes the oom-killer. Mark these pinned pages as unevictable to speed
> up vmscan.
> =

> Add check_move_lru_page() to move page to appropriate lru list.
> =

> This patch was inspired by Chris Wilson's change [1].
> =

> [1]: https://patchwork.kernel.org/patch/9768741/
> =

> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> ---
> The previous mapping_set_unevictable patch is worse on gem_syslatency
> because it defers to vmscan to move these pages to the unevictable list
> and the test measures latency to allocate 2MiB pages. This performance
> impact can be solved by explicit moving pages to the unevictable list in
> the i915 function.
> =

> Chris, can you help to run the "igt/benchmarks/gem_syslatency -t 120 -b -=
m"
> test with this patch on your testing machine? I tried to run the test on
> a Celeron N4000, 4GB Ram machine. The mean value with this patch is
> similar to that with the mlock patch.

Will do. As you are confident, I'll try a few different machines. :)
-Chris
