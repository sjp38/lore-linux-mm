Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE9E6B006C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 04:45:41 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id hv19so7146574lab.0
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 01:45:40 -0800 (PST)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id qz8si14069160lbc.116.2015.01.14.01.45.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 01:45:40 -0800 (PST)
Received: by mail-lb0-f181.google.com with SMTP id l4so6989234lbv.12
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 01:45:39 -0800 (PST)
Date: Wed, 14 Jan 2015 12:45:38 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
Message-ID: <20150114094538.GD2253@moon>
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20150113214355.GC2253@moon>
 <54B592D6.4090406@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54B592D6.4090406@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Tue, Jan 13, 2015 at 01:49:10PM -0800, Dave Hansen wrote:
> On 01/13/2015 01:43 PM, Cyrill Gorcunov wrote:
> > On Tue, Jan 13, 2015 at 09:14:15PM +0200, Kirill A. Shutemov wrote:
> >> We're going to account pmd page tables too. Let's rename mm->nr_pgtables
> >> to something more generic.
> >>
> >> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >> --- a/fs/proc/task_mmu.c
> >> +++ b/fs/proc/task_mmu.c
> >> @@ -64,7 +64,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
> >>  		data << (PAGE_SHIFT-10),
> >>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
> >>  		(PTRS_PER_PTE * sizeof(pte_t) *
> >> -		 atomic_long_read(&mm->nr_ptes)) >> 10,
> >> +		 atomic_long_read(&mm->nr_pgtables)) >> 10,
> > 
> > This implies that (PTRS_PER_PTE * sizeof(pte_t)) = (PTRS_PER_PMD * sizeof(pmd_t))
> > which might be true for all archs, right?
> 
> I wonder if powerpc is OK on this front today.  This diagram:
> 
> 	http://linux-mm.org/PageTableStructure
> 
> says that they use a 128-byte "pte" table when mapping 16M pages.  I
> wonder if they bump mm->nr_ptes for these.

It looks like this doesn't matter. The statistics here prints the size
of summary memory occupied for pte_t entries, here PTRS_PER_PTE * sizeof(pte_t)
is only valid for, once we start accounting pmd into same counter it implies
that PTRS_PER_PTE == PTRS_PER_PMD, which is not true for all archs
(if I understand the idea of accounting here right).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
