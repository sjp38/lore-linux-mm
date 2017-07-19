Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33FBA6B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:58:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w63so10458105wrc.5
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 12:58:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si3796345wrb.310.2017.07.19.12.58.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 12:58:22 -0700 (PDT)
Date: Wed, 19 Jul 2017 20:58:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170719195820.drtfmweuhdc4eca6@suse.de>
References: <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Jul 19, 2017 at 12:41:01PM -0700, Nadav Amit wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Tue, Jul 18, 2017 at 02:28:27PM -0700, Nadav Amit wrote:
> >>> If there are separate address spaces using a shared mapping then the
> >>> same race does not occur.
> >> 
> >> I missed the fact you reverted the two operations since the previous version
> >> of the patch. This specific scenario should be solved with this patch.
> >> 
> >> But in general, I think there is a need for a simple locking scheme.
> > 
> > Such as?
> 
> Something like:
> 
> bool is_potentially_stale_pte(pte_t pte, pgprot_t prot, int lock_state);
> 
> which would get the current PTE, the protection bits that the user is
> interested in, and whether mmap_sem is taken read/write/none. 
> 

>From a PTE you cannot know the state of mmap_sem because you can rmap
back to multiple mm's for shared mappings. It's also fairly heavy handed.
Technically, you could lock on the basis of the VMA but that has other
consequences for scalability. The staleness is also a factor because
it's a case of "does the staleness matter". Sometimes it does, sometimes
it doesn't.  mmap_sem even if it could be used does not always tell us
the right information either because it can matter whether we are racing
against a userspace reference or a kernel operation.

It's possible your idea could be made work, but right now I'm not seeing a
solution that handles every corner case. I asked to hear what your ideas
were because anything I thought of that could batch TLB flushing in the
general case had flaws that did not improve over what is already there.

> [snip]
> 
> >> As a result, concurrent operation such as KSM???s write_protect_page() or
> > 
> > write_protect_page operates under the page lock and cannot race with reclaim.
> 
> I still do not understand this claim. IIUC, reclaim can unmap the page in
> some page table, decide not to reclaim the page and release the page-lock
> before flush.
> 

shrink_page_list is the caller of try_to_unmap in reclaim context. It
has this check

                if (!trylock_page(page))
                        goto keep;

For pages it cannot lock, they get put back on the LRU and recycled instead
of reclaimed. Hence, if KSM or anything else holds the page lock, reclaim
can't unmap it.

> >> page_mkclean_one() can consider the page write-protected while in fact it is
> >> still accessible - since the TLB flush was deferred.
> > 
> > As long as it's flushed before any IO occurs that would lose a data update,
> > it's not a data integrity issue.
> > 
> >> As a result, they may
> >> mishandle the PTE without flushing the page. In the case of
> >> page_mkclean_one(), I suspect it may even lead to memory corruption. I admit
> >> that in x86 there are some mitigating factors that would make such ???attack???
> >> complicated, but it still seems wrong to me, no?
> > 
> > I worry that you're beginning to see races everywhere. I admit that the
> > rules and protections here are varied and complex but it's worth keeping
> > in mind that data integrity is the key concern (no false reads to wrong
> > data, no lost writes) and the first race you identified found some problems
> > here. However, with or without batching, there is always a delay between
> > when a PTE is cleared and when the TLB entries are removed.
> 
> Sure, but usually the delay occurs while the page-table lock is taken so
> there is no race.
> 
> Now, it is not fair to call me a paranoid, considering that these races are
> real - I confirmed that at least two can happen in practice.

It's less an accusation of paranoia and more a caution that the fact that
pte_clear_flush is not atomic means that it can be difficult to find what
races matter and what ones don't.

> As for ???data integrity is the key concern??? - violating the memory management
> API can cause data integrity issues for programs.

The madvise one should be fixed too. It could also be "fixed" by
removing all batching but the performance cost will be sufficiently high
that there will be pressure to find an alternative.

> It may not cause the OS to
> crash, but it should not be acceptable either, and may potentially raise
> security concerns. If you think that the current behavior is ok, let the
> documentation and man pages clarify that mprotect may not protect, madvise
> may not advise and so on.
> 

The madvise one should be fixed, not because because it allows a case
whereby userspace thinks it has initialised a structure that is actually
in a page that is freed after a TLB is flushed resulting in a lost
write. It wouldn't cause any issues with shared or file-backed mappings
but it is a problem for anonymous.

> And although you would use it against me, I would say: Nobody knew that TLB
> flushing could be so complicated.
> 

There is no question that the area is complicated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
