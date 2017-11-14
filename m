Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 285396B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 15:55:07 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t139so4504583wmt.7
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 12:55:07 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t5si6343595wma.139.2017.11.14.12.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 12:55:05 -0800 (PST)
Date: Tue, 14 Nov 2017 21:54:52 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
In-Reply-To: <20171114202102.crpgiwgv2lu5aboq@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1711142131010.2221@nanos>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1711141630210.2044@nanos> <20171114202102.crpgiwgv2lu5aboq@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Nov 2017, Kirill A. Shutemov wrote:

> On Tue, Nov 14, 2017 at 05:01:50PM +0100, Thomas Gleixner wrote:
> > @@ -198,11 +199,14 @@ arch_get_unmapped_area_topdown(struct fi
> >  	/* requesting a specific address */
> >  	if (addr) {
> >  		addr = PAGE_ALIGN(addr);
> > +		if (!mmap_address_hint_valid(addr, len))
> > +			goto get_unmapped_area;
> > +
> 
> Here and in hugetlb_get_unmapped_area(), we should align the addr after
> the check, not before. Otherwise the alignment itself can bring us over
> the borderline as we align up.

Hmm, then I wonder whether the next check against vm_start_gap() which
checks against the aligned address is correct:

                addr = PAGE_ALIGN(addr);
                vma = find_vma(mm, addr);

                if (end - len >= addr &&
                    (!vma || addr + len <= vm_start_gap(vma)))
                        return addr;

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
