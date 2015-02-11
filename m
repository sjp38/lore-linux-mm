Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id B2CB36B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 07:25:03 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id p10so3089458wes.2
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 04:25:03 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id au9si1074528wjc.87.2015.02.11.04.25.01
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 04:25:02 -0800 (PST)
Date: Wed, 11 Feb 2015 14:22:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: NULL ptr deref in unlink_file_vma
Message-ID: <20150211122224.GA9769@node.dhcp.inet.fi>
References: <549832E2.8060609@oracle.com>
 <20141222180102.GA8072@node.dhcp.inet.fi>
 <54985D59.5010506@oracle.com>
 <20141222191452.GA20295@node.dhcp.inet.fi>
 <CALYGNiO8-RqqY2gLGeoXvPkbKJabERHfaVLTaUp5s_=-WFR9KA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiO8-RqqY2gLGeoXvPkbKJabERHfaVLTaUp5s_=-WFR9KA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Davidlohr Bueso <dave@stgolabs.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Feb 10, 2015 at 10:42:31PM +0400, Konstantin Khlebnikov wrote:
> On Mon, Dec 22, 2014 at 10:14 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> > On Mon, Dec 22, 2014 at 01:05:13PM -0500, Sasha Levin wrote:
> >> On 12/22/2014 01:01 PM, Kirill A. Shutemov wrote:
> >> > On Mon, Dec 22, 2014 at 10:04:02AM -0500, Sasha Levin wrote:
> >> >> > Hi all,
> >> >> >
> >> >> > While fuzzing with trinity inside a KVM tools guest running the latest -next
> >> >> > kernel, I've stumbled on the following spew:
> >> >> >
> >> >> > [  432.376425] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
> >> >> > [  432.378876] IP: down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)
> >> > Looks like vma->vm_file->mapping is NULL. Somebody freed ->vm_file from
> >> > under us?
> >> >
> >> > I suspect Davidlohr's patchset on i_mmap_lock, but I cannot find any code
> >> > path which could lead to the crash.
> >>
> >> I've reported a different issue which that patchset: https://lkml.org/lkml/2014/12/9/741
> >>
> >> I guess it could be related?
> >
> > Maybe.
> >
> > Other thing:
> >
> >  unmap_mapping_range()
> >    i_mmap_lock_read(mapping);
> >    unmap_mapping_range_tree()
> >      unmap_mapping_range_vma()
> >        zap_page_range_single()
> >          unmap_single_vma()
> >            untrack_pfn()
> >              vma->vm_flags &= ~VM_PAT;
> >
> > It seems we modify ->vm_flags without mmap_sem taken, means we can corrupt
> > them.
> >
> > Sasha could you check if you hit untrack_pfn()?
> >
> > The problem probably was hidden by exclusive i_mmap_lock on
> > unmap_mapping_range(), but it's not exclusive anymore afrer Dave's
> > patchset.
> >
> > Konstantin, you've modified untrack_pfn() back in 2012 to change
> > ->vm_flags. Any coments?
> 
> Hmm. I don't really understand how
> unmap_mapping_range() could be used for VM_PFNMAP mappings
> except unmap() or exit_mmap() where mm is locked anyway.
> Somebody truncates memory mapped device and unmaps mapped PFNs?

Hm. Probably not. But it's not obvious to me what would stop this.
Should we at least have assert on mmap_sem locked in untrack_pfn()?

> If it's a problem then I think VM_PAT could be tuned into hint which
> means PAT tracking was here and we pat should check internal structure
> for details and take actions if pat tracking is still here. As I see
> pat tracking probably also have problems if somebody unmaps that vma
> partially.

IIUC, we only mark a vma with VM_PAT if whole vma is subject for
remap_pfn_range(). I don't see a point in cleaning VM_PAT -- just let it
die with vma. Or do I miss something?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
