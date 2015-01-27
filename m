Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7355F6B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 11:24:42 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id a141so13154090oig.6
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 08:24:42 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id np10si884473oeb.27.2015.01.27.08.24.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 08:24:41 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YG8wS-003tPD-Uo
	for linux-mm@kvack.org; Tue, 27 Jan 2015 16:24:41 +0000
Date: Tue, 27 Jan 2015 08:24:28 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mmotm 2015-01-22-15-04: qemu failures due to 'mm: account pmd
 page tables to the process'
Message-ID: <20150127162428.GA21638@roeck-us.net>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050445.GA22751@roeck-us.net>
 <20150123111304.GA5975@node.dhcp.inet.fi>
 <54C263CC.1060904@roeck-us.net>
 <20150123135519.9f1061caf875f41f89298d59@linux-foundation.org>
 <20150124055207.GA8926@roeck-us.net>
 <20150126122944.GE25833@node.dhcp.inet.fi>
 <54C6494D.80802@roeck-us.net>
 <20150127161657.GA7155@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150127161657.GA7155@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Jan 27, 2015 at 06:16:57PM +0200, Kirill A. Shutemov wrote:
> On Mon, Jan 26, 2015 at 06:03:57AM -0800, Guenter Roeck wrote:
> > On 01/26/2015 04:29 AM, Kirill A. Shutemov wrote:
> > >On Fri, Jan 23, 2015 at 09:52:07PM -0800, Guenter Roeck wrote:
> > >>On Fri, Jan 23, 2015 at 01:55:19PM -0800, Andrew Morton wrote:
> > >>>On Fri, 23 Jan 2015 07:07:56 -0800 Guenter Roeck <linux@roeck-us.net> wrote:
> > >>>
> > >>>>>>
> > >>>>>>qemu:microblaze generates warnings to the console.
> > >>>>>>
> > >>>>>>WARNING: CPU: 0 PID: 32 at mm/mmap.c:2858 exit_mmap+0x184/0x1a4()
> > >>>>>>
> > >>>>>>with various call stacks. See
> > >>>>>>http://server.roeck-us.net:8010/builders/qemu-microblaze-mmotm/builds/15/steps/qemubuildcommand/logs/stdio
> > >>>>>>for details.
> > >>>>>
> > >>>>>Could you try patch below? Completely untested.
> > >>>>>
> > >>>>>>From b584bb8d493794f67484c0b57c161d61c02599bc Mon Sep 17 00:00:00 2001
> > >>>>>From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > >>>>>Date: Fri, 23 Jan 2015 13:08:26 +0200
> > >>>>>Subject: [PATCH] microblaze: define __PAGETABLE_PMD_FOLDED
> > >>>>>
> > >>>>>Microblaze uses custom implementation of PMD folding, but doesn't define
> > >>>>>__PAGETABLE_PMD_FOLDED, which generic code expects to see. Let's fix it.
> > >>>>>
> > >>>>>Defining __PAGETABLE_PMD_FOLDED will drop out unused __pmd_alloc().
> > >>>>>It also fixes problems with recently-introduced pmd accounting.
> > >>>>>
> > >>>>>Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > >>>>>Reported-by: Guenter Roeck <linux@roeck-us.net>
> > >>>>
> > >>>>Tested working.
> > >>>>
> > >>>>Tested-by: Guenter Roeck <linux@roeck-us.net>
> > >>>>
> > >>>>Any idea how to fix the sh problem ?
> > >>>
> > >>>Can you tell us more about it?  All I'm seeing is "qemu:sh fails to
> > >>>shut down", which isn't very clear.
> > >>
> > >>Turns out that the include file defining __PAGETABLE_PMD_FOLDED
> > >>was not always included where used, resulting in a messed up mm_struct.
> > >
> > >What means "messed up" here? It should only affect size of mm_struct.
> > >
> > Plus the offset of all variables after the #ifndef.
> 
> Okay, I guess the problem is that different parts of the kernel see
> different mm_struct depending on include ordering.
> 
> Tried to look for options, but don't see anything better than patch below.
> Andrew, is it okay to you?
> 
> From 0f113e16a058d47f3bc63a3b6ced5296afb934a6 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 27 Jan 2015 17:59:55 +0200
> Subject: [PATCH] mm: add nr_pmds into mm_struct unconditionally
> 
> __PAGETABLE_PMD_FOLDED is defined during <asm/pgtable.h> which is not
> included into <linux/mm_types.h>. And we cannot include it here since
> many of <asm/pgtables> needs <linux/mm_types.h> to define struct page.
> 
> I failed to come up with better solution rather than put nr_pmds into
> mm_struct unconditionally.
> 
> One possible solution would be to expose number of page table levels
> architecture has via Kconfig, but that's ugly and requires changes to
> all architectures.
> 
FWIW, I tried a number of approaches. Ultimately I gave up and concluded
that it has to be either this patch or, as you say here, we would have
to add something like PAGETABLE_PMD_FOLDED as a Kconfig option.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Tested working with all builds and all my qemu tests.

Tested-by: Guenter Roeck <linux@roeck-us.net>

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
