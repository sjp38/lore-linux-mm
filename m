Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9701A6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 15:56:46 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so733603pdi.4
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 12:56:46 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id td3si33631295pab.128.2014.07.03.12.56.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 12:56:45 -0700 (PDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so722172pde.26
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 12:56:44 -0700 (PDT)
Date: Thu, 3 Jul 2014 12:54:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: memcontrol: rewrite uncharge API: problems
In-Reply-To: <alpine.LSU.2.11.1407021518120.8299@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1407031219500.1370@eggly.anvils>
References: <alpine.LSU.2.11.1406301558090.4572@eggly.anvils> <20140701174612.GC1369@cmpxchg.org> <20140702212004.GF1369@cmpxchg.org> <alpine.LSU.2.11.1407021518120.8299@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Jul 2014, Hugh Dickins wrote:
> On Wed, 2 Jul 2014, Johannes Weiner wrote:
> > 
> > Could you give the following patch a spin?  I put it in the mmots
> > stack on top of mm-memcontrol-rewrite-charge-api-fix-shmem_unuse-fix.
> 
> I'm just with the laptop until this evening.  I slapped it on top of
> my 3.16-rc2-mm1 plus fixes (but obviously minus my memcg_batch one
> - which incidentally continues to run without crashing on the G5),
> and it quickly gave me this lockdep splat, which doesn't look very
> different from the one before.
> 
> I see there's now an -rc3-mm1, I'll try it out on that in half an
> hour... but unless I send word otherwise, assume that's the same.

Yes, I get that lockdep report each time on -rc3-mm1 + your patch.

I also twice got a flurry of res_counter.c:28 underflow warnings.
Hmm, 62 of them each time (I was checking for a number near 512,
which would suggest a THP/4k confusion, but no).  The majority
of them coming from mem_cgroup_reparent_charges.

But the laptop stayed up fine (for two hours before I had to stop
it), and the G5 has run fine with that load for 16 hours now, no
problems with release_pages, and not even a res_counter.c:28 (but
I don't use lockdep on it).

The x86 workstation ran fine for 4.5 hours, then hit some deadlock
which I doubt had any connection to your changes: looked more like
a jbd2 transaction was failing to complete (which, with me trying
ext4 on loop on tmpfs, might be more my problem than anyone else's).

Oh, but nearly forgot, I did an earlier run on the laptop last night,
which crashed within minutes on

VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM))
mm/memcontrol.c:6680!
page had count 1 mapcount 0 mapping anon index 0x196
flags locked uptodate reclaim swapbacked, pcflags 1, memcg not root
mem_cgroup_migrate < move_to_new_page < migrate_pages < compact_zone <
compact_zone_order < try_to_compact_pages < __alloc_pages_direct_compact <
__alloc_pages_nodemask < alloc_pages_vma < do_huge_pmd_anonymous_page <
handle_mm_fault < __do_page_fault

I was expecting to reproduce that quite easily on the laptop or
workstation, and investigate more closely then; but in fact have
not seen it since.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
