Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id D24106B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 11:25:02 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id k14so27737759wgh.10
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:25:02 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id km10si21639541wjc.32.2015.01.30.08.25.00
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 08:25:01 -0800 (PST)
Date: Fri, 30 Jan 2015 18:24:40 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 03/19] arm: expose number of page table levels on Kconfig
 level
Message-ID: <20150130162440.GA29551@node.dhcp.inet.fi>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1422629008-13689-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20150130160212.GP26493@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130160212.GP26493@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>

On Fri, Jan 30, 2015 at 04:02:13PM +0000, Russell King - ARM Linux wrote:
> It'd be nice to see the cover for this series so that people know the
> reason behind this change is.  Maybe it'd be a good idea to add a
> pointer or some description below the "---" to such patches which
> are otherwise totally meaningless to the people you add to the Cc
> line?

Okay, some background:

I've implemented accounting for pmd page tables as we have for pte (see
mm->nr_ptes). It's requires a new counter in mm_struct: mm->nr_pmds.

But the feature doesn't make any sense if an architecture has PMD level
folded and it would be nice get rid of the counter in this case.

The problem is that we cannot use __PAGETABLE_PMD_FOLDED in
<linux/mm_types.h> due to circular dependencies:

<linux/mm_types> -> <asm/pgtable.h> -> <linux/mm_types.h>

In most cases <asm/pgtable.h> wants <linux/mm_types.h> to get definition
of struct page and struct vm_area_struct. I've tried to split mm_struct
into separate header file to be able to user <asm/pgtable.h> there.

But it doesn't fly on some architectures, including ARM: it wants
mm_struct <asm/pgtable.h> to implement tlb flushing. I don't see how to
fix it without massive de-inlining or coverting a lot for inline functions
to macros.

This is other approach: expose number of page tables in use via Kconfig
and use it in <linux/mm_types.h> instead of __PAGETABLE_PMD_FOLDED from
<asm/pgtable.h>.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
