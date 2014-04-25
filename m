Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 778BB6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 15:43:05 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so3514744pab.12
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 12:43:05 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id iw1si5466425pbb.497.2014.04.25.12.43.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 12:43:04 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so3486815pde.31
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 12:43:03 -0700 (PDT)
Date: Fri, 25 Apr 2014 12:41:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <20140425135101.GE11096@twins.programming.kicks-ass.net>
Message-ID: <alpine.LSU.2.11.1404251215280.5909@eggly.anvils>
References: <alpine.LSU.2.11.1404241110160.2443@eggly.anvils> <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com> <alpine.LSU.2.11.1404241252520.3455@eggly.anvils> <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
 <1398389846.8437.6.camel@pasglop> <1398393700.8437.22.camel@pasglop> <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com> <5359CD7C.5020604@zytor.com> <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
 <alpine.LSU.2.11.1404250414590.5198@eggly.anvils> <20140425135101.GE11096@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Fri, 25 Apr 2014, Peter Zijlstra wrote:
> On Fri, Apr 25, 2014 at 05:01:23AM -0700, Hugh Dickins wrote:
> > One, regarding dirty shared mappings: you're thinking above of
> > mmap()'ing proper filesystem files, but this case also includes
> > shared memory - I expect there are uses of giant amounts of shared
> > memory, for which we really would prefer not to slow the teardown.
> > 
> > And confusingly, those are not subject to the special page_mkclean()
> > constraints, but still need to be handled in a correct manner: your
> > patch is fine, but might be overkill for them - I'm not yet sure.
> 
> I think we could look at mapping_cap_account_dirty(page->mapping) while
> holding the ptelock, the mapping can't go away while we hold that lock.
> 
> And afaict that's the exact differentiator between these two cases.

Yes, that's easily done, but I wasn't sure whether it was correct to
skip on shmem or not - just because shmem doesn't participate in the
page_mkclean() protocol, doesn't imply it's free from similar bugs.

I haven't seen a precise description of the bug we're anxious to fix:
Dave's MADV_DONTNEED should be easily fixable, that's not a concern;
Linus's first patch wrote of writing racing with cleaning, but didn't
give a concrete example.

How about this: a process with one thread repeatedly (but not very often)
writing timestamp into a shared file mapping, but another thread munmaps
it at some point; and another process repeatedly (but not very often)
reads the timestamp file (or peeks at it through mmap); with memory
pressure forcing page reclaim.

In the page_mkclean() shared file case, the second process might see
the timestamp move backwards: because a write from the timestamping
thread went into the pagecache after it had been written, but the
page not re-marked dirty; so when reclaimed and later read back
from disk, the older timestamp is seen.

But I think you can remove "page_mkclean() " from that paragraph:
the same can happen with shmem written out to swap.

It could not happen with ramfs, but I don't think we're desperate
to special case ramfs these days.

Hugh

> 
> > Two, Ben said earlier that he's more worried about users of
> > unmap_mapping_range() than concurrent munmap(); and you said
> > earlier that you would almost prefer to have some special lock
> > to serialize with page_mkclean().
> > 
> > Er, i_mmap_mutex.
> > 
> > That's what unmap_mapping_range(), and page_mkclean()'s rmap_walk,
> > take to iterate over the file vmas.  So perhaps there's no race at all
> > in the unmap_mapping_range() case.  And easy (I imagine) to fix the
> > race in Dave's racewrite.c use of MADV_DONTNEED: untested patch below.
> 
> Ooh shiney.. yes that might work! 
> 
> > But exit and munmap() don't take i_mmap_mutex: perhaps they should
> > when encountering a VM_SHARED vma 
> 
> Well, they will of course take it in order to detach the vma from the
> rmap address_space::i_mmap tree.
> 
> > (I believe VM_SHARED should be
> > peculiar to having vm_file seta, but test both below because I don't
> > want to oops in some odd corner where a special vma is set up).
> 
> I think you might be on to something there...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
