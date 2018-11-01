Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3556B0005
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 07:28:59 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id m2-v6so14549844oic.16
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 04:28:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t91sor4356033ota.152.2018.11.01.04.28.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Nov 2018 04:28:58 -0700 (PDT)
MIME-Version: 1.0
References: <20181031081945.207709-1-vovoy@chromium.org> <20181031142458.GP32673@dhcp22.suse.cz>
 <cc44aa53-8705-02ea-6c59-f311427d93af@intel.com> <20181031164231.GQ32673@dhcp22.suse.cz>
In-Reply-To: <20181031164231.GQ32673@dhcp22.suse.cz>
From: Vovo Yang <vovoy@chromium.org>
Date: Thu, 1 Nov 2018 19:28:46 +0800
Message-ID: <CAEHM+4pSkv_fD3Yb2KX1xFrOmRHU1e=+wCBrCyLAAMBG3zP75w@mail.gmail.com>
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: dave.hansen@intel.com, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, peterz@infradead.org, akpm@linux-foundation.org

On Thu, Nov 1, 2018 at 12:42 AM Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 31-10-18 07:40:14, Dave Hansen wrote:
> > Didn't we create the unevictable lists in the first place because
> > scanning alone was observed to be so expensive in some scenarios?
>
> Yes, that is the case. I might just misunderstood the code I thought
> those pages were already on the LRU when unevictable flag was set and
> we would only move these pages to the unevictable list lazy during the
> reclaim. If the flag is set at the time when the page is added to the
> LRU then it should get to the proper LRU list right away. But then I do
> not understand the test results from previous run at all.

"gem_syslatency -t 120 -b -m" allocates a lot of anon pages, it consists of
these looping threads:
  * ncpu threads to alloc i915 shmem buffers, these buffers are freed by i915
shrinker.
  * ncpu threads to mmap, write, munmap an 2 MiB mapping.
  * 1 thread to cat all files to /dev/null

Without the unevictable patch, after rebooting and running
"gem_syslatency -t 120 -b -m", I got these custom vmstat:
  pgsteal_kswapd_anon 29261
  pgsteal_kswapd_file 1153696
  pgsteal_direct_anon 255
  pgsteal_direct_file 13050
  pgscan_kswapd_anon 14524536
  pgscan_kswapd_file 1488683
  pgscan_direct_anon 1702448
  pgscan_direct_file 25849

And meminfo shows large anon lru size during test.
  # cat /proc/meminfo | grep -i "active("
  Active(anon):     377760 kB
  Inactive(anon):  3195392 kB
  Active(file):      19216 kB
  Inactive(file):    16044 kB

With this patch, the custom vmstat after test:
  pgsteal_kswapd_anon 74962
  pgsteal_kswapd_file 903588
  pgsteal_direct_anon 4434
  pgsteal_direct_file 14969
  pgscan_kswapd_anon 2814791
  pgscan_kswapd_file 1113676
  pgscan_direct_anon 526766
  pgscan_direct_file 32432

The anon pgscan count is reduced.
