Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 45FCD6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 12:12:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so80636608wme.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:12:57 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id pu3si17432380lbb.183.2016.05.02.09.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 09:12:56 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id y84so193257470lfc.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:12:55 -0700 (PDT)
Date: Mon, 2 May 2016 19:12:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: GUP guarantees wrt to userspace mappings
Message-ID: <20160502161252.GE24419@node.shutemov.name>
References: <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
 <20160502121402.GB23305@node.shutemov.name>
 <20160502133919.GB4079@gmail.com>
 <20160502150013.GA24419@node.shutemov.name>
 <20160502152249.GA5827@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502152249.GA5827@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 05:22:49PM +0200, Jerome Glisse wrote:
> On Mon, May 02, 2016 at 06:00:13PM +0300, Kirill A. Shutemov wrote:
> > > > Quick look around:
> > > > 
> > > >  - I don't see any check page_count() around __replace_page() in uprobes,
> > > >    so it can easily replace pinned page.
> > > 
> > > Not an issue for existing user as this is only use to instrument code, existing
> > > user do not execute code from virtual address for which they have done a GUP.
> > 
> > Okay, so we can establish that GUP doesn't provide the guarantee in some
> > cases.
> 
> Correct but it use to provide that guarantee in respect to THP.

Yes, the THP regression need to be fixed. I don't argue with that.

> > > >  - KSM has the page_count() check, there's still race wrt GUP_fast: it can
> > > >    take the pin between the check and establishing new pte entry.
> > > 
> > > KSM is not an issue for existing user as they all do get_user_pages() with
> > > write = 1 and the KSM first map page read only before considering to replace
> > > them and check page refcount. So there can be no race with gup_fast there.
> > 
> > In vfio case, 'write' is conditional on IOMMU_WRITE, meaning not all
> > get_user_pages() are with write=1.
> 
> I think this is still fine as it means that device will read only and thus
> you can migrate to different page (ie the guest is not expecting to read back
> anything writen by the device and device writting to the page would be illegal
> and a proper IOMMU would forbid it). So it is like direct-io when you write
> from anonymous memory to a file.

Hm. Okay.

> > > >  - khugepaged: the same story as with KSM.
> > > 
> > > I am assuming you are talking about collapse_huge_page() here, if you look in
> > > that function there is a comment about GUP_fast. Noneless i believe the comment
> > > is wrong as i believe there is an existing race window btw pmdp_collapse_flush()
> > > and __collapse_huge_page_isolate() :
> > > 
> > >   get_user_pages_fast()          | collapse_huge_page()
> > >    gup_pmd_range() -> valid pmd  | ...
> > >                                  | pmdp_collapse_flush() clear pmd
> > >                                  | ...
> > >                                  | __collapse_huge_page_isolate()
> > >                                  | [Above check page count and see no GUP]
> > >    gup_pte_range() -> ref page   |
> > > 
> > > This is a very unlikely race because get_user_pages_fast() can not be preempted
> > > while collapse_huge_page() can be preempted btw pmdp_collapse_flush() and
> > > __collapse_huge_page_isolate(), more over collapse_huge_page() has lot more
> > > instructions to chew on than get_user_pages_fast() btw gup_pmd_range() and
> > > gup_pte_range().
> > 
> > Yes, the race window is small, but there.
> 
> Now that i think again about it, i don't think it exist. pmdp_collapse_flush()
> will flush the tlb and thus send an IPI but get_user_pages_fast() can't be
> preempted so the flush will have to wait for existing get_user_pages_fast() to
> complete. Or am i missunderstanding flush ? So khugepaged is safe from GUP_fast
> point of view like the comment, inside it, says.

You are right. It's safe too.

> > > So as said above, i think existing user of get_user_pages() are not sensitive
> > > to the races you pointed above. I am sure there are some corner case where
> > > the guarantee that GUP pin a page against a virtual address is violated but
> > > i do not think they apply to any existing user of GUP.
> > > 
> > > Note that i would personaly like that this existing assumption about GUP did
> > > not exist. I hate it, but fact is that it does exist and nobody can remember
> > > where the Doc did park the Delorean
> > 
> > The drivers who want the guarantee can provide own ->mmap and have more
> > control on what is visible in userspace.
> > 
> > Alternatively, we have mmu_notifiers to track changes in userspace
> > mappings.
> > 
> 
> Well you can't not rely on special vma here. Qemu alloc anonymous memory and
> hand it over to guest, then a guest driver (ie runing in the guest not on the
> host) try to map that memory and need valid DMA address for it, this is when
> vfio (on the host kernel) starts pining memory of regular anonymous vma (on
> the host). That same memory might back some special vma with ->mmap callback
> but in the guest. Point is there is no driver on the host and no special vma.
> From host point of view this is anonymous memory, but from guest POV it is
> just memory.
> 
> Requiring special vma would need major change to kvm and probably xen, in
> respect on how they support things like PCI passthrough.
> 
> In existing workload, host kernel can not make assumption on how anonymous
> memory is gonna be use.

Any reason why mmu_notifier is not an option?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
