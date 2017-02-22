Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E84326B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 08:04:56 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 89so749397wrr.2
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 05:04:56 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id y62si2084956wmb.48.2017.02.22.05.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 05:04:55 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id i186so357543wmf.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 05:04:55 -0800 (PST)
Date: Wed, 22 Feb 2017 16:04:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and
 PR_GET_MAX_VADDR
Message-ID: <20170222130451.GA23555@node.shutemov.name>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
 <20170218092133.GA17471@node.shutemov.name>
 <20170220131515.GA9502@node.shutemov.name>
 <0d05ac45-a139-6f8e-f98b-71876fbb509d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d05ac45-a139-6f8e-f98b-71876fbb509d@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On Tue, Feb 21, 2017 at 12:46:55PM -0800, Dave Hansen wrote:
> Let me make sure I'm grokking what you're trying to do here.
> 
> On 02/20/2017 05:15 AM, Kirill A. Shutemov wrote:
> > +/* MPX cannot handle addresses above 47-bits yet. */
> > +unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
> > +		unsigned long flags)
> > +{
> > +	if (!kernel_managing_mpx_tables(current->mm))
> > +		return addr;
> > +	if (addr + len <= DEFAULT_MAP_WINDOW)
> > +		return addr;
> 
> At this point, we know MPX management is on and the hint is for memory
> above DEFAULT_MAP_WINDOW?

Right.

> > +	if (flags & MAP_FIXED)
> > +		return -ENOMEM;
> 
> ... and if it's a MAP_FIXED request, fail it.

Yep.

> > +	if (len > DEFAULT_MAP_WINDOW)
> > +		return -ENOMEM;
> 
> What is this case for?  If addr+len wraps?

If len is too big to fit into DEFAULT_MAP_WINDOW there's no point in
resetting hint address as we know we can't satisfy it -- fail early.
> 
> > +	/* Look for unmap area within DEFAULT_MAP_WINDOW */
> > +	return 0;
> > +}
> 
> Otherwise, blow away the hint, which we know is high and needs to
> be discarded?

Right.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
