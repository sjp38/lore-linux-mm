Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 007766B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 07:05:24 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b189so3098809wmd.5
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 04:05:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l51sor3354853edc.8.2017.11.14.04.05.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 04:05:23 -0800 (PST)
Date: Tue, 14 Nov 2017 15:05:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
Message-ID: <20171114120520.u3cyxw42wqvvnnf6@node.shutemov.name>
References: <20171107130539.52676-1-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1711131642370.1851@nanos>
 <20171113164154.fp5fd2seozbmxcbs@node.shutemov.name>
 <alpine.DEB.2.20.1711131754590.1851@nanos>
 <alpine.DEB.2.20.1711132010470.2097@nanos>
 <20171113200657.pk56mxofg2t2xbi6@node.shutemov.name>
 <alpine.DEB.2.20.1711132205290.2097@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711132205290.2097@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 13, 2017 at 10:14:36PM +0100, Thomas Gleixner wrote:
> On Mon, 13 Nov 2017, Kirill A. Shutemov wrote:
> > On Mon, Nov 13, 2017 at 08:14:54PM +0100, Thomas Gleixner wrote:
> > > > > It will succeed with 5-level paging.
> > > > 
> > > > And why is this allowed?
> > > > 
> > > > > It should be safe as with 4-level paging such request would fail and it's
> > > > > reasonable to expect that userspace is not relying on the failure to
> > > > > function properly.
> > > > 
> > > > Huch?
> > > > 
> > > > The first rule when looking at user space is that is broken or
> > > > hostile. Reasonable and user space are mutually exclusive.
> > > 
> > > Aside of that in case of get_unmapped_area:
> > > 
> > > If va_unmapped_area() fails, then the address and the len which caused the
> > > overlap check to trigger are handed in to arch_get_unmapped_area(), which
> > > again can create an invalid mapping if I'm not missing something.
> > > 
> > > If mappings which overlap the boundary are invalid then we have to make
> > > sure at all ends that they wont happen.
> > 
> > They are not invalid.
> > 
> > The patch tries to address following theoretical issue:
> > 
> > We have an application that tries, for some reason, to allocate memory
> > with mmap(addr), without MAP_FIXED, where addr is near the borderline of
> > 47-bit address space and addr+len is above the border.
> > 
> > On 4-level paging machine this request would succeed, but the address will
> > always be within 47-bit VA -- cannot allocate by hint address, ignore it.
> > 
> > If the application cannot handle high address this might be an issue on
> > 5-level paging machine as such call would succeed *and* allocate memory by
> > the specified hint address. In this case part of the mapping would be
> > above the border line and may lead to misbehaviour.
> > 
> > I hope this makes any sense :)
> 
> I can see where you are heading to. Now the case I was looking at is:
> 
> arch_get_unmapped_area_topdown()
> 
> 	addr0 = addr;
> 	
> 	....
> 	if (addr) {
> 		if (cross_border(addr, len))
> 			goto get_unmapped_area;
> 		...
> 	}
> get_unmapped_area:
> 	...
> 	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
> 
> 	   ^^^ evaluates to false because addr < DEFAULT_MAP_WINDOW
> 
> 	addr - vm_unmapped_area(&info);
> 
> 	   ^^^ fails for whatever reason.
> 
> bottomup:
> 	return arch_get_unmapped_area(.., addr0, len, ....);
> 
> 
> AFAICT arch_get_unmapped_area() can allocate a mapping which crosses the
> border, i.e. a mapping which you want to prevent for the !MAP_FIXED case.

No, it can't as long as addr0 is below DEFAULT_MAP_WINDOW:

arch_get_unmapped_area()
{
	...
	find_start_end(addr, flags, &begin, &end);
	// end is DEFAULT_MAP_WINDOW here, since addr is below the border
	...
	if (addr) {
		...
		// end - len is less than addr, so the condition below is
		// false.
		if (end - len >= addr &&
		    (!vma || addr + len <= vm_start_gap(vma)))
			return addr;
	}
	...
	info.high_limit = end;
	...
	return vm_unmapped_area(&info);
}

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
