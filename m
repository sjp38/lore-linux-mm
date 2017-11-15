Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09EC36B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:39:52 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n74so581867wmi.3
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:39:51 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o65si18213518wrc.248.2017.11.15.03.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 03:39:50 -0800 (PST)
Date: Wed, 15 Nov 2017 12:39:40 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
In-Reply-To: <20171115112702.e2m66wons37imtcj@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1711151238500.1805@nanos>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1711141630210.2044@nanos> <20171114202102.crpgiwgv2lu5aboq@node.shutemov.name> <alpine.DEB.2.20.1711142131010.2221@nanos> <20171114222718.76w4lmclf6wasbl3@node.shutemov.name>
 <alpine.DEB.2.20.1711142354520.2221@nanos> <20171115112702.e2m66wons37imtcj@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 15 Nov 2017, Kirill A. Shutemov wrote:
> On Wed, Nov 15, 2017 at 12:00:46AM +0100, Thomas Gleixner wrote:
> > On Wed, 15 Nov 2017, Kirill A. Shutemov wrote:
> > > On Tue, Nov 14, 2017 at 09:54:52PM +0100, Thomas Gleixner wrote:
> > > > On Tue, 14 Nov 2017, Kirill A. Shutemov wrote:
> > > > 
> > > > > On Tue, Nov 14, 2017 at 05:01:50PM +0100, Thomas Gleixner wrote:
> > > > > > @@ -198,11 +199,14 @@ arch_get_unmapped_area_topdown(struct fi
> > > > > >  	/* requesting a specific address */
> > > > > >  	if (addr) {
> > > > > >  		addr = PAGE_ALIGN(addr);
> > > > > > +		if (!mmap_address_hint_valid(addr, len))
> > > > > > +			goto get_unmapped_area;
> > > > > > +
> > > > > 
> > > > > Here and in hugetlb_get_unmapped_area(), we should align the addr after
> > > > > the check, not before. Otherwise the alignment itself can bring us over
> > > > > the borderline as we align up.
> > > > 
> > > > Hmm, then I wonder whether the next check against vm_start_gap() which
> > > > checks against the aligned address is correct:
> > > > 
> > > >                 addr = PAGE_ALIGN(addr);
> > > >                 vma = find_vma(mm, addr);
> > > > 
> > > >                 if (end - len >= addr &&
> > > >                     (!vma || addr + len <= vm_start_gap(vma)))
> > > >                         return addr;
> > > 
> > > I think the check is correct. The check is against resulting addresses
> > > that end up in vm_start/vm_end. In our case we want to figure out what
> > > user asked for.
> > 
> > Well, but then checking just against the user supplied addr is only half of
> > the story.
> > 
> >     addr = boundary - PAGE_SIZE - PAGE_SIZE / 2;
> >     len = PAGE_SIZE - PAGE_SIZE / 2;
> > 
> > That fits, but then after alignment we end up with
> > 
> >     addr = boudary - PAGE_SIZE;
> > 
> > and due to len > PAGE_SIZE this will result in a mapping which crosses the
> > boundary, right? So checking against the PAGE_ALIGN(addr) should be the
> > right thing to do.
> 
> IIUC, this is only the case if 'len' is not aligned, right?
> 
> >From what I see we expect caller to align it (and mm/mmap.c does this, I
> haven't checked other callers).
> 
> And hugetlb would actively reject non-aligned len.
> 
> I *think* we should be fine with checking unaligned 'addr'.

I think we should keep it consistent for the normal and the huge case and
just check aligned and be done with it.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
