Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2606D6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 15:14:37 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so1302366pdb.37
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 12:14:36 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id ef1si5436439pbc.386.2014.04.25.12.14.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 12:14:36 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so3447937pdi.16
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 12:14:35 -0700 (PDT)
Date: Fri, 25 Apr 2014 12:13:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <CA+55aFz=fwpGegGXfyWh9bh_iVM7g4q=0ywugS+sR=L+Od7j5g@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1404251142110.5909@eggly.anvils>
References: <53558507.9050703@zytor.com> <20140422075459.GD11182@twins.programming.kicks-ass.net> <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com> <alpine.LSU.2.11.1404221847120.1759@eggly.anvils> <20140423184145.GH17824@quack.suse.cz>
 <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com> <20140424065133.GX26782@laptop.programming.kicks-ass.net> <alpine.LSU.2.11.1404241110160.2443@eggly.anvils> <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
 <alpine.LSU.2.11.1404241252520.3455@eggly.anvils> <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com> <1398389846.8437.6.camel@pasglop> <1398393700.8437.22.camel@pasglop> <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
 <5359CD7C.5020604@zytor.com> <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com> <alpine.LSU.2.11.1404250414590.5198@eggly.anvils> <CA+55aFz=fwpGegGXfyWh9bh_iVM7g4q=0ywugS+sR=L+Od7j5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Fri, 25 Apr 2014, Linus Torvalds wrote:
> On Fri, Apr 25, 2014 at 5:01 AM, Hugh Dickins <hughd@google.com> wrote:
> >
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
> Hmm. unmap_mapping_range() is just abotu the only thing that _does_
> take i_mmap_mutex. unmap_single_vma() does it for
> is_vm_hugetlb_page(), which is a bit confusing. And normally we only
> take it for the actual final vma link/unlink, not for the actual
> traversal. So we'd have to change that all quite radically (or we'd
> have to drop and re-take it).
> 
> So I'm not quite convinced. Your simple patch looks simple and should
> certainly fix DaveH's test-case, but then leaves munmap/exit as a
> separate thing to fix. And I don't see how to do that cleanly (it
> really looks like "we'll just have to take that semaphore again
> separately).

Yes, mine is quite nice for the MADV_DONTNEED case, but needs more
complication to handle munmap/exit.  I don't want to drop and retake,
I'm hoping we can decide what to do via the zap_details.

It would still be messy that sometimes we come in with the mutex
and sometimes we take it inside; but then it's already messy that
sometimes we have it and sometimes we don't.

I'll try extending the patch to munmap/exit in a little bit, and
send out the result for comparison later today. 

> 
> i_mmap_mutex is likely not contended, but we *do* take it for private
> mappings too (and for read-only ones), so this lock is actually much
> more common than the dirty shared mapping.

We only need to take it in the (presumed rare beyond shared memory)
VM_SHARED case.  I'm not very keen on adding a mutex into the exit
path, but at least this one used to be a spinlock, and there should
be nowhere that tries to allocate memory while holding it (I'm wary
of adding OOM-kill deadlocks) - aside from tlb_next_batch()'s
GFP_NOWAIT|__GFP_NOWARN attempts.

> 
> So I think I prefer my patch, even if that may be partly due to just
> it being mine ;)

Yes, fair enough, I'm not against it: I just felt rather ashamed of
going on about page_mkclean() protocol and ptlock, while forgetting
all about i_mmap_mutex.  Let's see how beautiful mine turns out ;)

And it may be worth admitting that here we avoid CONFIG_PREEMPT,
and have been bitten in the past by free_pages_and_swap_cache()
latencies, so drastically reduced MAX_GATHER_BATCH_COUNT: so we
wouldn't expect to see much hit from your more frequent TLB flushes.

I must answer Peter now...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
