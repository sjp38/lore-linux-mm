Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 526B76B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 10:14:12 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id t61so5136032wes.3
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 07:14:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si9782959wjq.135.2014.03.07.07.14.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 07:14:02 -0800 (PST)
Date: Fri, 7 Mar 2014 15:13:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -mm] mm,numa,mprotect: always continue after finding a
 stable thp page
Message-ID: <20140307151357.GC1931@suse.de>
References: <5318E4BC.50301@oracle.com>
 <20140306173137.6a23a0b2@cuia.bos.redhat.com>
 <5318FC3F.4080204@redhat.com>
 <20140307140650.GA1931@suse.de>
 <20140307150923.GB1931@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140307150923.GB1931@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com

On Fri, Mar 07, 2014 at 03:09:23PM +0000, Mel Gorman wrote:
> On Fri, Mar 07, 2014 at 02:06:50PM +0000, Mel Gorman wrote:
> > On Thu, Mar 06, 2014 at 05:52:47PM -0500, Rik van Riel wrote:
> > > On 03/06/2014 05:31 PM, Rik van Riel wrote:
> > > >On Thu, 06 Mar 2014 16:12:28 -0500
> > > >Sasha Levin <sasha.levin@oracle.com> wrote:
> > > >
> > > >>While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've hit the
> > > >>following spew. This seems to be introduced by your patch "mm,numa: reorganize change_pmd_range()".
> > > >
> > > >That patch should not introduce any functional changes, except for
> > > >the VM_BUG_ON that catches the fact that we fell through to the 4kB
> > > >pte handling code, despite having just handled a THP pmd...
> > > >
> > > >Does this patch fix the issue?
> > > >
> > > >Mel, am I overlooking anything obvious? :)
> > > >
> > > >---8<---
> > > >
> > > >Subject: mm,numa,mprotect: always continue after finding a stable thp page
> > > >
> > > >When turning a thp pmds into a NUMA one, change_huge_pmd will
> > > >return 0 when the pmd already is a NUMA pmd.
> > > 
> > > I did miss something obvious.  In this case, the code returns 1.
> > > 
> > > >However, change_pmd_range would fall through to the code that
> > > >handles 4kB pages, instead of continuing on to the next pmd.
> > > 
> > > Maybe the case that I missed is when khugepaged is in the
> > > process of collapsing pages into a transparent huge page?
> > > 
> > > If the virtual CPU gets de-scheduled by the host for long
> > > enough, it would be possible for khugepaged to run on
> > > another virtual CPU, and turn the pmd into a THP pmd,
> > > before that VM_BUG_ON test.
> > > 
> > > I see that khugepaged takes the mmap_sem for writing in the
> > > collapse code, and it looks like task_numa_work takes the
> > > mmap_sem for reading, so I guess that may not be possible?
> > > 
> > 
> > mmap_sem will prevent a parallel collapse but what prevents something
> > like the following?
> > 
> > 							do_huge_pmd_wp_page
> > change_pmd_range
> > if (!pmd_trans_huge(*pmd) && pmd_none_or_clear_bad(pmd))
> > 	continue;
> > 							pmdp_clear_flush(vma, haddr, pmd);
> > if (pmd_trans_huge(*pmd)) {
> > 	.... path not taken ....
> > }
> > 							page_add_new_anon_rmap(new_page, vma, haddr);
> > 							set_pmd_at(mm, haddr, pmd, entry);
> > VM_BUG_ON(pmd_trans_huge(*pmd));
> > 
> > We do not hold the page table lock during the pmd_trans_huge check and we
> > do not recheck it under PTF lock in change_pte_range()
> > 
> 
> This is a completely untested prototype. It rechecks pmd_trans_huge
> under the lock and falls through if it hit a parallel split. It's not
> perfect because it could decide to fall through just because there was
> no prot_numa work to do but it's for illustration purposes.

Nope, if there was no prot_numa work to do, it returns 1 so the check is
ok. It's only if 0 is returned we need to fall through and really handle
ptes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
