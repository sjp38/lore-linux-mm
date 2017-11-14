Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A77BF6B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 14:21:16 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 5so4412690wmk.8
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 11:21:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor12065613edk.31.2017.11.14.11.21.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 11:21:15 -0800 (PST)
Date: Tue, 14 Nov 2017 22:21:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
Message-ID: <20171114192113.t7pq5p2n5emmiw2n@node.shutemov.name>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1711141630210.2044@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711141630210.2044@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 14, 2017 at 05:01:50PM +0100, Thomas Gleixner wrote:
> On Tue, 14 Nov 2017, Kirill A. Shutemov wrote:
> > --- a/arch/x86/mm/hugetlbpage.c
> > +++ b/arch/x86/mm/hugetlbpage.c
> > @@ -166,11 +166,20 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
> >  
> >  	if (addr) {
> >  		addr = ALIGN(addr, huge_page_size(h));
> > +		if (TASK_SIZE - len >= addr)
> > +			goto get_unmapped_area;
> 
> That's wrong. You got it right in arch_get_unmapped_area_topdown() ...

Ouch.

Please ignore selftest patch. I'll rework it to cover hugetlb.

> > +
> > +		/* See a comment in arch_get_unmapped_area_topdown */
> 
> This is lame, really.
> 
> > +		if ((addr > DEFAULT_MAP_WINDOW) !=
> > +				(addr + len > DEFAULT_MAP_WINDOW))
> > +			goto get_unmapped_area;
> 
> Instead of duplicating that horrible formatted condition and adding this
> lousy comment why can't you just put all of it (including the TASK_SIZE
> check) into a proper validation function and put the comment there?
> 
> The fixed up variant of your patch below does that.
> 
> Aside of that please spend a bit more time on describing things precisely
> at the technical and factual level next time. I fixed that up (once more)
> both in the comment and the changelog.
> 
> Please double check.

Works fine.

> +bool mmap_address_hint_valid(unsigned long addr, unsigned long len)
> +{
> +	if (TASK_SIZE - len < addr)
> +		return false;
> +#if CONFIG_PGTABLE_LEVELS >= 5
> +	return (addr > DEFAULT_MAP_WINDOW) == (addr + len > DEFAULT_MAP_WINDOW);

Is it micro optimization? I don't feel it necessary. It's not that hot
codepath to care about few cycles. (And one more place to care about for
boot-time switching.)

If you think it's needed, maybe IS_ENABLED() instead?

> +#else
> +	return true;
> +#endif
> +}

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
