Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30EAC6B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 14:11:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v13so12826924pgq.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 11:11:00 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTPS id z13si4641426pfe.416.2017.10.03.11.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 11:10:59 -0700 (PDT)
Subject: Re: [PATCH 0/3 v8] oom: capture unreclaimable slab info in oom
 message
References: <1507053977-116952-1-git-send-email-yang.s@alibaba-inc.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <5b652442-d737-656d-2f54-ce69664a946b@alibaba-inc.com>
Date: Wed, 04 Oct 2017 02:10:38 +0800
MIME-Version: 1.0
In-Reply-To: <1507053977-116952-1-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This round should be v9. Sorry for the typo.

Yang


On 10/3/17 11:06 AM, Yang Shi wrote:
> 
> Recently we ran into a oom issue, kernel panic due to no killable process.
> The dmesg shows huge unreclaimable slabs used almost 100% memory, but kdump doesn't capture vmcore due to some reason.
> 
> So, it may sound better to capture unreclaimable slab info in oom message when kernel panic to aid trouble shooting and cover the corner case.
> Since kernel already panic, so capturing more information sounds worthy and doesn't bother normal oom killer.
> 
> With the patchset, tools/vm/slabinfo has a new option, "-U", to show unreclaimable slab only.
> 
> And, oom will print all non zero (num_objs * size != 0) unreclaimable slabs in oom killer message.
> 
> For details, please see the commit log for each commit.
> 
> Changelog v8 a??> 9:
> * Adopted Tetsuoa??s suggestion to protect global slab list traverse with mutex_trylock() to prevent from sleeping. Without the mutex acquired unreclaimable slbas will not be dumped.
> * Adopted the suggestion from Christoph to dump CONFIG_SLABINFO since it is pointless to keep it.
> * Rebased to 4.13-rc3
> 
> Changelog v7 a??> v8:
> * Adopted Michala??s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
> 
> Changelog v6 -> v7:
> * Added unreclaim_slabs_oom_ratio proc knob, unreclaimable slabs info will be dumped when unreclaimable slabs amount : all user memory > the ratio
> 
> Changelog v5 a??> v6:
> * Fixed a checkpatch.pl warning for patch #2
> 
> Changelog v4 a??> v5:
> * Solved the comments from David
> * Build test SLABINFO = n
> 
> Changelog v3 a??> v4:
> * Solved the comments from David
> * Added Davida??s Acked-by in patch 1
> 
> Changelog v2 a??> v3:
> * Show used size and total size of each kmem cache per Davida??s comment
> 
> Changelog v1 a??> v2:
> * Removed the original patch 1 (a??mm: slab: output reclaimable flag in /proc/slabinfoa??) since Christoph suggested it might break the compatibility and /proc/slabinfo is legacy
> * Added Christopha??s Acked-by
> * Removed acquiring slab_mutex per Tetsuoa??s comment
> 
> 
> Yang Shi (3):
>        tools: slabinfo: add "-U" option to show unreclaimable slabs only
>        mm: slabinfo: dump CONFIG_SLABINFO
>        mm: oom: show unreclaimable slab info when unreclaimable slabs > user memory
> 
>   init/Kconfig        |  6 ------
>   mm/memcontrol.c     |  2 --
>   mm/oom_kill.c       | 22 ++++++++++++++++++++++
>   mm/slab.c           |  2 --
>   mm/slab.h           |  2 ++
>   mm/slab_common.c    | 35 ++++++++++++++++++++++++++++++++---
>   mm/slub.c           |  2 --
>   tools/vm/slabinfo.c | 11 ++++++++++-
>   8 files changed, 66 insertions(+), 16 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
