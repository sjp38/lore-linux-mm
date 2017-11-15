Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE396B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:04:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n8so735258wmg.4
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:04:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b15sor2237811edh.9.2017.11.15.06.04.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 06:04:28 -0800 (PST)
Date: Wed, 15 Nov 2017 17:04:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
Message-ID: <20171115140426.bgvcd3bmegqadm5q@node.shutemov.name>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1711141630210.2044@nanos>
 <20171114202102.crpgiwgv2lu5aboq@node.shutemov.name>
 <alpine.DEB.2.20.1711142131010.2221@nanos>
 <20171114222718.76w4lmclf6wasbl3@node.shutemov.name>
 <alpine.DEB.2.20.1711142354520.2221@nanos>
 <20171115112702.e2m66wons37imtcj@node.shutemov.name>
 <alpine.DEB.2.20.1711151238500.1805@nanos>
 <20171115121042.dt2us5fsuqmepx4i@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115121042.dt2us5fsuqmepx4i@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 15, 2017 at 03:10:42PM +0300, Kirill A. Shutemov wrote:
> On Wed, Nov 15, 2017 at 12:39:40PM +0100, Thomas Gleixner wrote:
> > On Wed, 15 Nov 2017, Kirill A. Shutemov wrote:
> > > On Wed, Nov 15, 2017 at 12:00:46AM +0100, Thomas Gleixner wrote:
> > > > On Wed, 15 Nov 2017, Kirill A. Shutemov wrote:
> > > > > On Tue, Nov 14, 2017 at 09:54:52PM +0100, Thomas Gleixner wrote:
> > > > > > On Tue, 14 Nov 2017, Kirill A. Shutemov wrote:
> > > > > > 
> > > > > > > On Tue, Nov 14, 2017 at 05:01:50PM +0100, Thomas Gleixner wrote:
> > > > > > > > @@ -198,11 +199,14 @@ arch_get_unmapped_area_topdown(struct fi
> > > > > > > >  	/* requesting a specific address */
> > > > > > > >  	if (addr) {
> > > > > > > >  		addr = PAGE_ALIGN(addr);
> > > > > > > > +		if (!mmap_address_hint_valid(addr, len))
> > > > > > > > +			goto get_unmapped_area;
> > > > > > > > +
> > > > > > > 
> > > > > > > Here and in hugetlb_get_unmapped_area(), we should align the addr after
> > > > > > > the check, not before. Otherwise the alignment itself can bring us over
> > > > > > > the borderline as we align up.
> > > > > > 
> > > > > > Hmm, then I wonder whether the next check against vm_start_gap() which
> > > > > > checks against the aligned address is correct:
> > > > > > 
> > > > > >                 addr = PAGE_ALIGN(addr);
> > > > > >                 vma = find_vma(mm, addr);
> > > > > > 
> > > > > >                 if (end - len >= addr &&
> > > > > >                     (!vma || addr + len <= vm_start_gap(vma)))
> > > > > >                         return addr;
> > > > > 
> > > > > I think the check is correct. The check is against resulting addresses
> > > > > that end up in vm_start/vm_end. In our case we want to figure out what
> > > > > user asked for.
> > > > 
> > > > Well, but then checking just against the user supplied addr is only half of
> > > > the story.
> > > > 
> > > >     addr = boundary - PAGE_SIZE - PAGE_SIZE / 2;
> > > >     len = PAGE_SIZE - PAGE_SIZE / 2;
> > > > 
> > > > That fits, but then after alignment we end up with
> > > > 
> > > >     addr = boudary - PAGE_SIZE;
> > > > 
> > > > and due to len > PAGE_SIZE this will result in a mapping which crosses the
> > > > boundary, right? So checking against the PAGE_ALIGN(addr) should be the
> > > > right thing to do.
> > > 
> > > IIUC, this is only the case if 'len' is not aligned, right?
> > > 
> > > >From what I see we expect caller to align it (and mm/mmap.c does this, I
> > > haven't checked other callers).
> > > 
> > > And hugetlb would actively reject non-aligned len.
> > > 
> > > I *think* we should be fine with checking unaligned 'addr'.
> > 
> > I think we should keep it consistent for the normal and the huge case and
> > just check aligned and be done with it.
> 
> Aligned 'addr'? Or 'len'? Both?
> 
> We would have problem with checking aligned addr. I steped it in hugetlb
> case:
> 
>   - User asks for mmap((1UL << 47) - PAGE_SIZE, 2 << 20, MAP_HUGETLB);
> 
>   - On 4-level paging machine this gives us invalid hint address as
>     'TASK_SIZE - len' is more than 'addr'. Goto get_unmapped_area.
> 
>   - On 5-level paging machine hint address gets rounded up to next 2MB
>     boundary that is exactly 1UL << 47 and we happily allocate from full
>     address space which may lead to trouble.

Below is updated patch with self-test.

Output on 5-level paging machine:

mmap(NULL): 0x7fbbad1f3000 - OK
mmap(LOW_ADDR): 0x40000000 - OK
mmap(HIGH_ADDR): 0x4000000000000 - OK
mmap(HIGH_ADDR) again: 0xffffbbad1fb000 - OK
mmap(HIGH_ADDR, MAP_FIXED): 0x4000000000000 - OK
mmap(-1): 0xffffbbad1f9000 - OK
mmap(-1) again: 0xffffbbad1f7000 - OK
mmap((1UL << 47), 2 * PAGE_SIZE): 0x7fbbad1f3000 - OK
mmap((1UL << 47), 2 * PAGE_SIZE / 2): 0x7fbbad1f1000 - OK
mmap((1UL << 47) - PAGE_SIZE, 2 * PAGE_SIZE, MAP_FIXED): 0x7ffffffff000 - OK
mmap(NULL, MAP_HUGETLB): 0x7fbbac400000 - OK
mmap(LOW_ADDR, MAP_HUGETLB): 0x40000000 - OK
mmap(HIGH_ADDR, MAP_HUGETLB): 0x4000000000000 - OK
mmap(HIGH_ADDR, MAP_HUGETLB) again: 0xffffbbace00000 - OK
mmap(HIGH_ADDR, MAP_FIXED | MAP_HUGETLB): 0x4000000000000 - OK
mmap(-1, MAP_HUGETLB): (nil) - OK
mmap(-1, MAP_HUGETLB) again: 0x7fbbac400000 - OK
mmap((1UL << 47), 2UL << 20, MAP_HUGETLB): 0x800000000000 - FAILED
mmap((1UL << 47) - (2UL << 20), 4UL << 20, MAP_FIXED | MAP_HUGETLB): 0x7fffffe00000 - OK

So, only hugetlb is problematic. mmap() aligns addr to PAGE_SIZE.
See round_hint_to_min(). In this case we round address *down* and it works
fine.

Replacing 'addr = ALIGN(addr, huge_page_size(h))' in hugetlbpage.c with
'addr &= huge_page_mask(h)' fixes the issue.
