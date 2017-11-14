Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DBC52280246
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 17:27:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o88so11561155wrb.18
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 14:27:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j9sor12143781edf.30.2017.11.14.14.27.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 14:27:20 -0800 (PST)
Date: Wed, 15 Nov 2017 01:27:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
Message-ID: <20171114222718.76w4lmclf6wasbl3@node.shutemov.name>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1711141630210.2044@nanos>
 <20171114202102.crpgiwgv2lu5aboq@node.shutemov.name>
 <alpine.DEB.2.20.1711142131010.2221@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711142131010.2221@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 14, 2017 at 09:54:52PM +0100, Thomas Gleixner wrote:
> On Tue, 14 Nov 2017, Kirill A. Shutemov wrote:
> 
> > On Tue, Nov 14, 2017 at 05:01:50PM +0100, Thomas Gleixner wrote:
> > > @@ -198,11 +199,14 @@ arch_get_unmapped_area_topdown(struct fi
> > >  	/* requesting a specific address */
> > >  	if (addr) {
> > >  		addr = PAGE_ALIGN(addr);
> > > +		if (!mmap_address_hint_valid(addr, len))
> > > +			goto get_unmapped_area;
> > > +
> > 
> > Here and in hugetlb_get_unmapped_area(), we should align the addr after
> > the check, not before. Otherwise the alignment itself can bring us over
> > the borderline as we align up.
> 
> Hmm, then I wonder whether the next check against vm_start_gap() which
> checks against the aligned address is correct:
> 
>                 addr = PAGE_ALIGN(addr);
>                 vma = find_vma(mm, addr);
> 
>                 if (end - len >= addr &&
>                     (!vma || addr + len <= vm_start_gap(vma)))
>                         return addr;

I think the check is correct. The check is against resulting addresses
that end up in vm_start/vm_end. In our case we want to figure out what
user asked for.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
