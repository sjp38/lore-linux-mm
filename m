Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2BBE86B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 00:28:26 -0500 (EST)
Received: by pdno5 with SMTP id o5so2289694pdn.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 21:28:25 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id f5si10205531pdh.174.2015.02.24.21.28.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 21:28:25 -0800 (PST)
Received: by pabkq14 with SMTP id kq14so2511649pab.3
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 21:28:24 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Wed, 25 Feb 2015 14:31:08 +0900 (KST)
Subject: Re: [RFC v2 0/5] introduce gcma
In-Reply-To: <20150224144804.GE15626@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1502251403390.23105@hxeon>
References: <1424721263-25314-1-git-send-email-sj38.park@gmail.com> <20150224144804.GE15626@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: SeongJae Park <sj38.park@gmail.com>, akpm@linux-foundation.org, lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Michal,

Thanks for your comment :)

On Tue, 24 Feb 2015, Michal Hocko wrote:

> On Tue 24-02-15 04:54:18, SeongJae Park wrote:
> [...]
>>  include/linux/cma.h  |    4 +
>>  include/linux/gcma.h |   64 +++
>>  mm/Kconfig           |   24 +
>>  mm/Makefile          |    1 +
>>  mm/cma.c             |  113 ++++-
>>  mm/gcma.c            | 1321 ++++++++++++++++++++++++++++++++++++++++++++++++++
>>  6 files changed, 1508 insertions(+), 19 deletions(-)
>>  create mode 100644 include/linux/gcma.h
>>  create mode 100644 mm/gcma.c
>
> Wow this is huge! And I do not see reason for it to be so big. Why
> cannot you simply define (per-cma area) 2-class users policy? Either via
> kernel command line or export areas to userspace and allow to set policy
> there.

For implementation of the idea, we should develop not only policy 
selection, but also backend for discardable memory. Most part of this 
patch were made for the backend.

Current implementation gives selection of policy per cma area to users. 
Only about 120 lines of code were changed for that though it's most ugly 
part of this patch. The part remains as ugly in this RFC because this is 
just prototype. The part will be changed in next version patchset.

>
> For starter something like the following policies should suffice AFAIU
> your description.
> 	- NONE - exclusive pool for CMA allocations only
> 	- DROPABLE - only allocations which might be dropped without any
> 	  additional actions - e.g. cleancache and frontswap with
> 	  write-through policy
> 	- RECLAIMABLE - only movable allocations which can be migrated
> 	  or dropped after writeback.
>
> Has such an approach been considered?

Similarly, but not in same way. In summary, GCMA gives DROPABLE and 
RECLAIMABLE policy selection per cma area and NONE policy to entire cma 
area declared using GCMA interface.

In detail, user could set policy of cma area as gcma way(DROPABLE) or cma 
way(RECLAIMABLE). Also, user could set gcma to utilize their cma area with 
Cleancache and/or Frontswap or not(NONE policy).

Your suggestion looks simple and better to understand. Next version of 
gcma will let users to be able to select policy as those per cma area.


Thanks,
SeongJae Park

> -- 
> Michal Hocko
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
