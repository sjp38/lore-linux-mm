Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id F13746B0072
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 14:17:34 -0500 (EST)
Received: by mail-lb0-f172.google.com with SMTP id u10so4398285lbd.17
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 11:17:34 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ap1si19337820lbc.100.2014.12.22.11.17.32
        for <linux-mm@kvack.org>;
        Mon, 22 Dec 2014 11:17:33 -0800 (PST)
Date: Mon, 22 Dec 2014 21:14:52 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: NULL ptr deref in unlink_file_vma
Message-ID: <20141222191452.GA20295@node.dhcp.inet.fi>
References: <549832E2.8060609@oracle.com>
 <20141222180102.GA8072@node.dhcp.inet.fi>
 <54985D59.5010506@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54985D59.5010506@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Davidlohr Bueso <dave@stgolabs.net>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Dec 22, 2014 at 01:05:13PM -0500, Sasha Levin wrote:
> On 12/22/2014 01:01 PM, Kirill A. Shutemov wrote:
> > On Mon, Dec 22, 2014 at 10:04:02AM -0500, Sasha Levin wrote:
> >> > Hi all,
> >> > 
> >> > While fuzzing with trinity inside a KVM tools guest running the latest -next
> >> > kernel, I've stumbled on the following spew:
> >> > 
> >> > [  432.376425] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
> >> > [  432.378876] IP: down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)
> > Looks like vma->vm_file->mapping is NULL. Somebody freed ->vm_file from
> > under us?
> > 
> > I suspect Davidlohr's patchset on i_mmap_lock, but I cannot find any code
> > path which could lead to the crash.
> 
> I've reported a different issue which that patchset: https://lkml.org/lkml/2014/12/9/741
> 
> I guess it could be related?

Maybe.

Other thing:

 unmap_mapping_range()
   i_mmap_lock_read(mapping);
   unmap_mapping_range_tree()
     unmap_mapping_range_vma()
       zap_page_range_single()
         unmap_single_vma()
	   untrack_pfn()
	     vma->vm_flags &= ~VM_PAT;

It seems we modify ->vm_flags without mmap_sem taken, means we can corrupt
them.

Sasha could you check if you hit untrack_pfn()?

The problem probably was hidden by exclusive i_mmap_lock on
unmap_mapping_range(), but it's not exclusive anymore afrer Dave's
patchset.

Konstantin, you've modified untrack_pfn() back in 2012 to change
->vm_flags. Any coments?

For now, I would propose to revert the commit and probably re-introduce it
after v3.19:
