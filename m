Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 700046B13F4
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 19:33:48 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so105669pbc.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 16:33:47 -0800 (PST)
Date: Tue, 7 Feb 2012 16:33:18 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix UP THP spin_is_locked BUGs
In-Reply-To: <20120207161209.52d065e1.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1202071616390.16273@eggly.anvils>
References: <alpine.LSU.2.00.1202071556460.7549@eggly.anvils> <20120207161209.52d065e1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 7 Feb 2012, Andrew Morton wrote:
> On Tue, 7 Feb 2012 16:00:46 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > +++ linux/mm/huge_memory.c	2012-02-07 15:37:18.581666053 -0800
> > @@ -2083,7 +2083,7 @@ static void collect_mm_slot(struct mm_sl
> >  {
> >  	struct mm_struct *mm = mm_slot->mm;
> >  
> > -	VM_BUG_ON(!spin_is_locked(&khugepaged_mm_lock));
> > +	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
> 
> We do have assert_spin_locked(), but I couldn't see any way of using it
> while observing these laziness constraints ;)

;) I didn't know about assert_spin_locked().  Hmm, fs/dcache.c seems
to be using that successfully.  We could forget about the VM_ part of
it and respin the patch with assert_spin_locked().  I don't really
mind either way: but happy to let laziness win the day - I'm back
on an SMP kernel by now anyway.

> 
> Should we patch -stable too?

People seem to have survived very well without it so far, I think
it's an unusual config combination, and quickly obvious if anyone
hits it.  But I've no objection if you think it deserves -stable.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
