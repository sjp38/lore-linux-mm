Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51A396B0008
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 04:15:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k21-v6so9067768ede.12
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 01:15:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d14si13336702edx.427.2018.10.18.01.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 01:15:58 -0700 (PDT)
Date: Thu, 18 Oct 2018 10:15:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] drm/i915: Mark pinned shmemfs pages as unevictable
Message-ID: <20181018081552.GZ18839@dhcp22.suse.cz>
References: <20181016174300.197906-1-vovoy@chromium.org>
 <20181016174300.197906-3-vovoy@chromium.org>
 <20181016182155.GW18839@dhcp22.suse.cz>
 <153971466599.22931.16793398326492316920@skylake-alporthouse-com>
 <153984580501.19935.11456945882099910977@skylake-alporthouse-com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153984580501.19935.11456945882099910977@skylake-alporthouse-com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Kuo-Hsin Yang <vovoy@chromium.org>, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, akpm@linux-foundation.org, peterz@infradead.org, dave.hansen@intel.com, corbet@lwn.net, hughd@google.com, joonas.lahtinen@linux.intel.com, marcheu@chromium.org, hoegsberg@chromium.org

On Thu 18-10-18 07:56:45, Chris Wilson wrote:
> Quoting Chris Wilson (2018-10-16 19:31:06)
> > Fwiw, the shmem_unlock_mapping() call feels quite expensive, almost
> > nullifying the advantage gained from not walking the lists in reclaim.
> > I'll have better numbers in a couple of days.
> 
> Using a test ("igt/benchmarks/gem_syslatency -t 120 -b -m" on kbl)
> consisting of cycletest with a background load of trying to allocate +
> populate 2MiB (to hit thp) while catting all files to /dev/null, the
> result of using mapping_set_unevictable is mixed.

I haven't really read through your report completely yet but I wanted to
point out that the above test scenario is unlikely show the real effect of
the LRU scanning overhead because shmem pages do live on the anonymous
LRU list. With a plenty of file page cache available we do not even scan
anonymous LRU lists. You would have to generate a swapout workload to
test this properly.

On the other hand if mapping_set_unevictable has really a measurably bad
performance impact then this is probably not worth much because most
workloads are swap modest.
-- 
Michal Hocko
SUSE Labs
