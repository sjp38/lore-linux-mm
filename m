Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id F04226B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 07:18:15 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id h10so2271182eak.22
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 04:18:15 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id i43si16047807eev.112.2014.03.07.04.18.14
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 04:18:14 -0800 (PST)
Date: Fri, 7 Mar 2014 14:18:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:2785!
Message-ID: <20140307121810.GA6740@node.dhcp.inet.fi>
References: <530F3F0A.5040304@oracle.com>
 <20140227150313.3BA27E0098@blue.fi.intel.com>
 <CAA_GA1c02iSmkmCLHFkrK4b4W+JppZ4CSMUJ-Wn1rCs-c=dV6g@mail.gmail.com>
 <53169FC5.4080006@oracle.com>
 <531921C0.3030904@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <531921C0.3030904@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Bob Liu <lliubbo@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 06, 2014 at 08:32:48PM -0500, Sasha Levin wrote:
> On 03/04/2014 10:53 PM, Sasha Levin wrote:
> >On 03/04/2014 10:16 PM, Bob Liu wrote:
> >>On Thu, Feb 27, 2014 at 11:03 PM, Kirill A. Shutemov
> >><kirill.shutemov@linux.intel.com> wrote:
> >>>Sasha Levin wrote:
> >>>>Hi all,
> >>>>
> >>>>While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on the
> >>>>following spew:
> >>>>
> >>>>[ 1428.146261] kernel BUG at mm/huge_memory.c:2785!
> >>>
> >>>Hm, interesting.
> >>>
> >>>It seems we either failed to split huge page on vma split or it
> >>>materialized from under us. I don't see how it can happen:
> >>>
> >>>   - it seems we do the right thing with vma_adjust_trans_huge() in
> >>>     __split_vma();
> >>>   - we hold ->mmap_sem all the way from vm_munmap(). At least I don't see
> >>>     a place where we could drop it;
> >>>
> >>
> >>Enable CONFIG_DEBUG_VM may show some useful information, at least we
> >>can confirm weather rwsem_is_locked(&tlb->mm->mmap_sem) before
> >>split_huge_page_pmd().
> >
> >I have CONFIG_DEBUG_VM enabled and that code you're talking is not triggering, so mmap_sem
> >is locked.
> 
> Guess what. I've just hit it.

I think this particular traceback is not a real problem: by time of
exit_mm() we shouldn't race with anybody for the mm_struct.

We probably could drop ->mmap_sem later in mmput() rather then in
exit_mm() to fix this false positive.

> It's worth keeping in mind that this is the first time I see it.

Hm. That's strange exit_mmap() is called without holding ->mmap_sem.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
