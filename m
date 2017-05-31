Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 647CD6B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 08:08:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i77so2180216wmh.10
        for <linux-mm@kvack.org>; Wed, 31 May 2017 05:08:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j67si30234936wmg.92.2017.05.31.05.08.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 05:08:27 -0700 (PDT)
Date: Wed, 31 May 2017 14:08:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170531120822.GL27783@dhcp22.suse.cz>
References: <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530154326.GB8412@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530154326.GB8412@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 30-05-17 17:43:26, Andrea Arcangeli wrote:
> On Tue, May 30, 2017 at 04:39:41PM +0200, Michal Hocko wrote:
> > I sysctl for the mapcount can be increased, right? I also assume that
> > those vmas will get merged after the post copy is done.
> 
> Assuming you enlarge the sysctl to the worst possible case, with 64bit
> address space you can have billions of VMAs if you're migrating 4T of
> RAM and you're unlucky and the address space gets fragmented. The
> unswappable kernel memory overhead would be relatively large
> (i.e. dozen gigabytes of RAM in vm_area_struct slab), and each
> find_vma operation would need to walk ~40 steps across that large vma
> rbtree. There's a reason the sysctl exist. Not to tell all those
> unnecessary vma mangling operations would be protected by the mmap_sem
> for writing.
> 
> Not creating a ton of vmas and enabling vma-less pte mangling with a
> single large vma and only using mmap_sem for reading during all the
> pte mangling, is one of the primary design motivations for
> userfaultfd.

Yes, I am aware of fallouts of too many vmas. I was asking merely to
learn whether this will really happen under the the specific usecase
Mike is after.

> > I understand that part but it sounds awfully one purpose thing to me.
> > Are we going to add other MADVISE_RESET_$FOO to clear other flags just
> > because we can race in this specific use case?
> 
> Those already exists, see for example MADV_NORMAL, clearing
> ~VM_RAND_READ & ~VM_SEQ_READ after calling MADV_SEQUENTIAL or
> MADV_RANDOM.

I would argue that MADV_NORMAL is everything but a clear madvise
command. Why doesn't it clear all the sticky MADV* flags?

> Or MADV_DOFORK after MADV_DONTFORK. MADV_DONTDUMP after MADV_DODUMP. Etc..
>
> > But we already have MADV_HUGEPAGE, MADV_NOHUGEPAGE and prctl to
> > enable/disable thp. Doesn't that sound little bit too much for a single
> > feature to you?
> 
> MADV_NOHUGEPAGE doesn't mean clearing the flag set with
> MADV_HUGEPAGE. MADV_NOHUGEPAGE disables THP on the region if the
> global sysfs "enabled" tune is set to "always". MADV_HUGEPAGE enables
> THP if the global "enabled" sysfs tune is set to "madvise". The two
> MADV_NOHUGEPAGE and MADV_HUGEPAGE are needed to leverage the three-way
> setting of "never" "madvise" "always" of the global tune.
> 
> The "madvise" global tune exists if you want to save RAM and you don't
> care much about performance but still allowing apps like QEMU where no
> memory is lost by enabling THP, to use THP.
> 
> There's no way to clear either of those two flags and bring back the
> default behavior of the global sysfs tune, so it's not redundant at
> the very least.

Yes I am not a huge fan of the current MADV*HUGEPAGE semantic but I
would really like to see a strong usecase for adding another command on
top. From what Mike said a global disable THP for the whole process
while the post-copy is in progress is a better solution anyway.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
