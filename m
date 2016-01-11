Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4079F828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 01:31:37 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id cy9so316513269pac.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 22:31:37 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [125.16.236.2])
        by mx.google.com with ESMTPS id t74si3478524pfa.106.2016.01.10.22.31.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 22:31:36 -0800 (PST)
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Jan 2016 12:01:33 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 41D0CE0054
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:02:48 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0B6VUi311141538
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:01:30 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0B6VRO1020346
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:01:29 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_SWP_SOFT_DIRTY breaking swapoff
In-Reply-To: <alpine.LSU.2.11.1601102149300.1634@eggly.anvils>
References: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils> <87mvscu0ve.fsf@linux.vnet.ibm.com> <alpine.LSU.2.11.1601102149300.1634@eggly.anvils>
Date: Mon, 11 Jan 2016 12:01:19 +0530
Message-ID: <87h9iktyo8.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Cyrill Gorcunov <gorcunov@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> On Mon, 11 Jan 2016, Aneesh Kumar K.V wrote:
>> Hugh Dickins <hughd@google.com> writes:
>> 
>> > Swapoff after swapping hangs on the G5, when CONFIG_CHECKPOINT_RESTORE=y
>> > but CONFIG_MEM_SOFT_DIRTY is not set.  That's because the non-zero
>> > _PAGE_SWP_SOFT_DIRTY bit, added by CONFIG_HAVE_ARCH_SOFT_DIRTY=y, is not
>> > discounted when CONFIG_MEM_SOFT_DIRTY is not set: so swap ptes cannot be
>> > recognized.
>> >
>> > (I suspect that the peculiar dependence of HAVE_ARCH_SOFT_DIRTY on
>> > CHECKPOINT_RESTORE in arch/powerpc/Kconfig comes from an incomplete
>> > attempt to solve this problem.)
>> >
>> > It's true that the relationship between CONFIG_HAVE_ARCH_SOFT_DIRTY and
>> > and CONFIG_MEM_SOFT_DIRTY is too confusing, and it's true that swapoff
>> > should be made more robust; but nevertheless, fix up the powerpc ifdefs
>> > as x86_64 and s390 (which met the same problem) have them, defining the
>> > bits as 0 if CONFIG_MEM_SOFT_DIRTY is not set.
>> 
>> Do we need this patch, if we make the maybe_same_pte() more robust. The
>> #ifdef with pte bits is always a confusing one and IMHO, we should avoid
>> that if we can ?
>
> If maybe_same_pte() were more robust (as in the pte_same_as_swp() patch),
> this patch here becomes an optimization rather than a correctness patch:
> without this patch here, pte_same_as_swp() will perform an unnecessary 
> transformation (masking out _PAGE_SWP_SOFT_DIRTY) from every one of the
> millions of ptes it has to examine, on configs where it couldn't be set.
> Or perhaps the processor gets that all nicely lined up without any actual
> delay, I don't know.

But we have
#ifndef CONFIG_HAVE_ARCH_SOFT_DIRTY
static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
{
	return pte;
}
#endif 

If we fix the CONFIG_HAVE_ARCH_SOFT_DIRTY correctly, we can do the same
optmization without the #ifdef of pte bits right ?

>
> I've already agreed that the way SOFT_DIRTY is currently config'ed is
> too confusing; but until that's improved, I strongly recommend that you
> follow the same way of handling this as x86_64 and s390 are doing - going
> off and doing it differently is liable to lead to error, as we have seen.
>
> So I recommend using the patch below too, whether or not you care for
> the optimization.
>
> Hugh


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
