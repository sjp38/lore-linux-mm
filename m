Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 586A16B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 07:12:39 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v105so10818800wrc.11
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 04:12:39 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i66si7384975wmd.14.2017.11.14.04.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 04:12:38 -0800 (PST)
Date: Tue, 14 Nov 2017 13:11:41 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
In-Reply-To: <20171114120520.u3cyxw42wqvvnnf6@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1711141307290.2044@nanos>
References: <20171107130539.52676-1-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1711131642370.1851@nanos> <20171113164154.fp5fd2seozbmxcbs@node.shutemov.name> <alpine.DEB.2.20.1711131754590.1851@nanos> <alpine.DEB.2.20.1711132010470.2097@nanos>
 <20171113200657.pk56mxofg2t2xbi6@node.shutemov.name> <alpine.DEB.2.20.1711132205290.2097@nanos> <20171114120520.u3cyxw42wqvvnnf6@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Nov 2017, Kirill A. Shutemov wrote:
> On Mon, Nov 13, 2017 at 10:14:36PM +0100, Thomas Gleixner wrote:
> > I can see where you are heading to. Now the case I was looking at is:
> > 
> > arch_get_unmapped_area_topdown()
> > 
> > 	addr0 = addr;
> > 	
> > 	....
> > 	if (addr) {
> > 		if (cross_border(addr, len))
> > 			goto get_unmapped_area;
> > 		...
> > 	}
> > get_unmapped_area:
> > 	...
> > 	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
> > 
> > 	   ^^^ evaluates to false because addr < DEFAULT_MAP_WINDOW
> > 
> > 	addr - vm_unmapped_area(&info);
> > 
> > 	   ^^^ fails for whatever reason.
> > 
> > bottomup:
> > 	return arch_get_unmapped_area(.., addr0, len, ....);
> > 
> > 
> > AFAICT arch_get_unmapped_area() can allocate a mapping which crosses the
> > border, i.e. a mapping which you want to prevent for the !MAP_FIXED case.
> 
> No, it can't as long as addr0 is below DEFAULT_MAP_WINDOW:
> 
> arch_get_unmapped_area()
> {
> 	...
> 	find_start_end(addr, flags, &begin, &end);
> 	// end is DEFAULT_MAP_WINDOW here, since addr is below the border

Sigh, I missed that task_size_64bit() magic in find_start_end().

This is really convoluted and non intuitive. I'm so not looking forward to
debug any failure in that context.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
