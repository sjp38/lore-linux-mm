Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9D56B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:34:10 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id w62so9069456wes.13
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:34:09 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ev8si26557428wib.27.2015.01.14.06.34.08
        for <linux-mm@kvack.org>;
        Wed, 14 Jan 2015 06:34:09 -0800 (PST)
Date: Wed, 14 Jan 2015 16:33:58 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
Message-ID: <20150114143358.GA9820@node.dhcp.inet.fi>
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20150113214355.GC2253@moon>
 <54B592D6.4090406@linux.intel.com>
 <20150114094538.GD2253@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150114094538.GD2253@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Wed, Jan 14, 2015 at 12:45:38PM +0300, Cyrill Gorcunov wrote:
> On Tue, Jan 13, 2015 at 01:49:10PM -0800, Dave Hansen wrote:
> > On 01/13/2015 01:43 PM, Cyrill Gorcunov wrote:
> > > On Tue, Jan 13, 2015 at 09:14:15PM +0200, Kirill A. Shutemov wrote:
> > >> We're going to account pmd page tables too. Let's rename mm->nr_pgtables
> > >> to something more generic.
> > >>
> > >> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > >> --- a/fs/proc/task_mmu.c
> > >> +++ b/fs/proc/task_mmu.c
> > >> @@ -64,7 +64,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
> > >>  		data << (PAGE_SHIFT-10),
> > >>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
> > >>  		(PTRS_PER_PTE * sizeof(pte_t) *
> > >> -		 atomic_long_read(&mm->nr_ptes)) >> 10,
> > >> +		 atomic_long_read(&mm->nr_pgtables)) >> 10,
> > > 
> > > This implies that (PTRS_PER_PTE * sizeof(pte_t)) = (PTRS_PER_PMD * sizeof(pmd_t))
> > > which might be true for all archs, right?

I doubt it. And even if it's true now, nobody can guarantee that this will
be true for all future configurations.

> > I wonder if powerpc is OK on this front today.  This diagram:
> > 
> > 	http://linux-mm.org/PageTableStructure
> > 
> > says that they use a 128-byte "pte" table when mapping 16M pages.  I
> > wonder if they bump mm->nr_ptes for these.
> 
> It looks like this doesn't matter. The statistics here prints the size
> of summary memory occupied for pte_t entries, here PTRS_PER_PTE * sizeof(pte_t)
> is only valid for, once we start accounting pmd into same counter it implies
> that PTRS_PER_PTE == PTRS_PER_PMD, which is not true for all archs
> (if I understand the idea of accounting here right).

Yeah. good catch. Thank you.

I'll respin with separate counter for pmd tables. It seems the best
option.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
