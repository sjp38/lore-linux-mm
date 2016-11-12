Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 409DD280282
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 20:37:12 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id bi5so36662831pad.0
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 17:37:12 -0800 (PST)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id t67si13011995pfk.141.2016.11.11.17.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 17:37:11 -0800 (PST)
Received: by mail-pg0-x22f.google.com with SMTP id 3so19551055pgd.0
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 17:37:11 -0800 (PST)
Date: Fri, 11 Nov 2016 17:37:03 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] mm: THP page cache support for ppc64
In-Reply-To: <20161111162909.GG19382@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1611111702170.10776@eggly.anvils>
References: <20161107083441.21901-1-aneesh.kumar@linux.vnet.ibm.com> <20161107083441.21901-2-aneesh.kumar@linux.vnet.ibm.com> <20161111101439.GB19382@node.shutemov.name> <8737iy1ahw.fsf@linux.vnet.ibm.com> <20161111162909.GG19382@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Fri, 11 Nov 2016, Kirill A. Shutemov wrote:
> On Fri, Nov 11, 2016 at 05:42:11PM +0530, Aneesh Kumar K.V wrote:
> > 
> > doing this in do_set_pmd keeps this closer to where we set the pmd. Any
> > reason you thing we should move it higher up the stack. We already do
> > pte_alloc() at the same level for a non transhuge case in
> > alloc_set_pte().
> 
> I vaguely remember Hugh mentioned deadlock of allocation under page-lock vs.
> OOM-killer (or something else?).

You remember well.  It was indeed the OOM killer, but in particular due
to the way it used to wait for a current victim to exit, and that exit
could be delayed forever by the way munlock_vma_pages_all() goes to lock
each page in a VM_LOCKED area - a pity if one of them is the page we
hold locked while servicing a fault and need to allocate a pagetable.

> 
> If the deadlock is still there it would be matter of making preallocation
> unconditional to fix the issue.

I think enough has changed at the OOM killer end that the deadlock is
no longer there.  I haven't kept up with all the changes made recently,
but I think we no longer wait for a unique victim to exit before trying
another (reaped mms set MMF_OOM_SKIP); and the OOM reaper skips over
VM_LOCKED areas to avoid just such a deadlock.

It's still silly that munlock_vma_pages_all() should require page lock
on each of those pages; but neither Michal nor I have had time to
revisit our attempts to relieve that requirement - mlock.c is not easy.

> 
> But what you propose about doesn't make situation any worse. I'm fine with
> that.

Yes, I think that's right: if there is a problem, then it would already
be problem since alloc_set_pte() was created; but we've seen no reports.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
