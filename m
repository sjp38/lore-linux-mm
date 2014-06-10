Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBE36B00F5
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 06:09:41 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so2761032wiw.4
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 03:09:37 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id k17si15948472wiv.42.2014.06.10.03.09.36
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 03:09:37 -0700 (PDT)
Date: Tue, 10 Jun 2014 13:09:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: NULL ptr deref in remove_migration_pte
Message-ID: <20140610100911.GA1718@node.dhcp.inet.fi>
References: <534E9ACA.2090008@oracle.com>
 <5367B365.1070709@oracle.com>
 <537FE9F3.40508@oracle.com>
 <alpine.LSU.2.11.1405261255530.3649@eggly.anvils>
 <538498A1.7010305@oracle.com>
 <alpine.LSU.2.11.1406092104330.12382@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1406092104330.12382@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Bob Liu <bob.liu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Mon, Jun 09, 2014 at 09:20:33PM -0700, Hugh Dickins wrote:
> [PATCH] mm: let mm_find_pmd fix buggy race with THP fault
> 
> Trinity has reported:
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> IP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
> CPU: 6 PID: 16173 Comm: trinity-c364 Tainted: G        W
>                         3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
> lock_acquire (arch/x86/include/asm/current.h:14
>               kernel/locking/lockdep.c:3602)
> _raw_spin_lock (include/linux/spinlock_api_smp.h:143
>                 kernel/locking/spinlock.c:151)
> remove_migration_pte (mm/migrate.c:137)
> rmap_walk (mm/rmap.c:1628 mm/rmap.c:1699)
> remove_migration_ptes (mm/migrate.c:224)
> migrate_pages (mm/migrate.c:922 mm/migrate.c:960 mm/migrate.c:1126)
> migrate_misplaced_page (mm/migrate.c:1733)
> __handle_mm_fault (mm/memory.c:3762 mm/memory.c:3812 mm/memory.c:3925)
> handle_mm_fault (mm/memory.c:3948)
> __get_user_pages (mm/memory.c:1851)
> __mlock_vma_pages_range (mm/mlock.c:255)
> __mm_populate (mm/mlock.c:711)
> SyS_mlockall (include/linux/mm.h:1799 mm/mlock.c:817 mm/mlock.c:791)
> 
> I believe this comes about because, whereas collapsing and splitting
> THP functions take anon_vma lock in write mode (which excludes
> concurrent rmap walks), faulting THP functions (write protection and
> misplaced NUMA) do not - and mostly they do not need to.
> 
> But they do use a pmdp_clear_flush(), set_pmd_at() sequence which,
> for an instant (indeed, for a long instant, given the inter-CPU
> TLB flush in there), leaves *pmd neither present not trans_huge.
> 
> Which can confuse a concurrent rmap walk, as when removing migration
> ptes, seen in the dumped trace.  Although that rmap walk has a 4k
> page to insert, anon_vmas containing THPs are in no way segregated
> from 4k-page anon_vmas, so the 4k-intent mm_find_pmd() does need to
> cope with that instant when a trans_huge pmd is temporarily absent.
> 
> I don't think we need strengthen the locking at the THP end: it's
> easily handled with an ACCESS_ONCE() before testing both conditions.
> 
> And since mm_find_pmd() had only one caller who wanted a THP rather
> than a pmd, let's slightly repurpose it to fail when it hits a THP
> or non-present pmd, and open code split_huge_page_address() again.
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
