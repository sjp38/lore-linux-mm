Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 13ECC828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 02:33:11 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so40778358pfn.3
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 23:33:11 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id ho3si18770172pac.224.2016.01.10.23.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 23:33:10 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id 65so40795316pff.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 23:33:10 -0800 (PST)
Date: Sun, 10 Jan 2016 23:33:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_SWP_SOFT_DIRTY breaking
 swapoff
In-Reply-To: <87h9iktyo8.fsf@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1601102325490.2517@eggly.anvils>
References: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils> <87mvscu0ve.fsf@linux.vnet.ibm.com> <alpine.LSU.2.11.1601102149300.1634@eggly.anvils> <87h9iktyo8.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Cyrill Gorcunov <gorcunov@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 11 Jan 2016, Aneesh Kumar K.V wrote:
> Hugh Dickins <hughd@google.com> writes:
> > On Mon, 11 Jan 2016, Aneesh Kumar K.V wrote:
> >> Hugh Dickins <hughd@google.com> writes:
> >> 
> >> > Swapoff after swapping hangs on the G5, when CONFIG_CHECKPOINT_RESTORE=y
> >> > but CONFIG_MEM_SOFT_DIRTY is not set.  That's because the non-zero
> >> > _PAGE_SWP_SOFT_DIRTY bit, added by CONFIG_HAVE_ARCH_SOFT_DIRTY=y, is not
> >> > discounted when CONFIG_MEM_SOFT_DIRTY is not set: so swap ptes cannot be
> >> > recognized.
> >> >
> >> > (I suspect that the peculiar dependence of HAVE_ARCH_SOFT_DIRTY on
> >> > CHECKPOINT_RESTORE in arch/powerpc/Kconfig comes from an incomplete
> >> > attempt to solve this problem.)
> >> >
> >> > It's true that the relationship between CONFIG_HAVE_ARCH_SOFT_DIRTY and
> >> > and CONFIG_MEM_SOFT_DIRTY is too confusing, and it's true that swapoff
> >> > should be made more robust; but nevertheless, fix up the powerpc ifdefs
> >> > as x86_64 and s390 (which met the same problem) have them, defining the
> >> > bits as 0 if CONFIG_MEM_SOFT_DIRTY is not set.
> >> 
> >> Do we need this patch, if we make the maybe_same_pte() more robust. The
> >> #ifdef with pte bits is always a confusing one and IMHO, we should avoid
> >> that if we can ?
> >
> > If maybe_same_pte() were more robust (as in the pte_same_as_swp() patch),
> > this patch here becomes an optimization rather than a correctness patch:
> > without this patch here, pte_same_as_swp() will perform an unnecessary 
> > transformation (masking out _PAGE_SWP_SOFT_DIRTY) from every one of the
> > millions of ptes it has to examine, on configs where it couldn't be set.
> > Or perhaps the processor gets that all nicely lined up without any actual
> > delay, I don't know.
> 
> But we have
> #ifndef CONFIG_HAVE_ARCH_SOFT_DIRTY
> static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
> {
> 	return pte;
> }
> #endif 
> 
> If we fix the CONFIG_HAVE_ARCH_SOFT_DIRTY correctly, we can do the same
> optmization without the #ifdef of pte bits right ?

I'm not sure that I understand you (I'll have to look at your patch),
but suspect you're not optimizing the CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MEM_SOFT_DIRTY not set case.

Which would not be the end of the world, but...
 
> >
> > I've already agreed that the way SOFT_DIRTY is currently config'ed is
> > too confusing; but until that's improved, I strongly recommend that you
> > follow the same way of handling this as x86_64 and s390 are doing - going
> > off and doing it differently is liable to lead to error, as we have seen.

... as before, I don't think that doing it differently is a good idea.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
