Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 46CC96B0253
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 16:14:48 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k100so9992750wrc.9
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 13:14:48 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l9si13495156wrf.545.2017.11.13.13.14.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 13:14:47 -0800 (PST)
Date: Mon, 13 Nov 2017 22:14:36 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
In-Reply-To: <20171113200657.pk56mxofg2t2xbi6@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1711132205290.2097@nanos>
References: <20171107130539.52676-1-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1711131642370.1851@nanos> <20171113164154.fp5fd2seozbmxcbs@node.shutemov.name> <alpine.DEB.2.20.1711131754590.1851@nanos> <alpine.DEB.2.20.1711132010470.2097@nanos>
 <20171113200657.pk56mxofg2t2xbi6@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 13 Nov 2017, Kirill A. Shutemov wrote:
> On Mon, Nov 13, 2017 at 08:14:54PM +0100, Thomas Gleixner wrote:
> > > > It will succeed with 5-level paging.
> > > 
> > > And why is this allowed?
> > > 
> > > > It should be safe as with 4-level paging such request would fail and it's
> > > > reasonable to expect that userspace is not relying on the failure to
> > > > function properly.
> > > 
> > > Huch?
> > > 
> > > The first rule when looking at user space is that is broken or
> > > hostile. Reasonable and user space are mutually exclusive.
> > 
> > Aside of that in case of get_unmapped_area:
> > 
> > If va_unmapped_area() fails, then the address and the len which caused the
> > overlap check to trigger are handed in to arch_get_unmapped_area(), which
> > again can create an invalid mapping if I'm not missing something.
> > 
> > If mappings which overlap the boundary are invalid then we have to make
> > sure at all ends that they wont happen.
> 
> They are not invalid.
> 
> The patch tries to address following theoretical issue:
> 
> We have an application that tries, for some reason, to allocate memory
> with mmap(addr), without MAP_FIXED, where addr is near the borderline of
> 47-bit address space and addr+len is above the border.
> 
> On 4-level paging machine this request would succeed, but the address will
> always be within 47-bit VA -- cannot allocate by hint address, ignore it.
> 
> If the application cannot handle high address this might be an issue on
> 5-level paging machine as such call would succeed *and* allocate memory by
> the specified hint address. In this case part of the mapping would be
> above the border line and may lead to misbehaviour.
> 
> I hope this makes any sense :)

I can see where you are heading to. Now the case I was looking at is:

arch_get_unmapped_area_topdown()

	addr0 = addr;
	
	....
	if (addr) {
		if (cross_border(addr, len))
			goto get_unmapped_area;
		...
	}
get_unmapped_area:
	...
	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())

	   ^^^ evaluates to false because addr < DEFAULT_MAP_WINDOW

	addr - vm_unmapped_area(&info);

	   ^^^ fails for whatever reason.

bottomup:
	return arch_get_unmapped_area(.., addr0, len, ....);


AFAICT arch_get_unmapped_area() can allocate a mapping which crosses the
border, i.e. a mapping which you want to prevent for the !MAP_FIXED case.

Thanks,

	tglx

	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
