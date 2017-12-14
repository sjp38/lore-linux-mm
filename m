Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6C476B0069
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:04:16 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a141so2486657wma.8
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:04:16 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m1si3010749wmm.143.2017.12.14.04.04.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 04:04:15 -0800 (PST)
Date: Thu, 14 Dec 2017 13:03:37 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 00/17] x86/ldt: Use a VMA based read only mapping
In-Reply-To: <20171214112726.742649793@infradead.org>
Message-ID: <alpine.DEB.2.20.1712141302540.4998@nanos>
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Thu, 14 Dec 2017, Peter Zijlstra wrote:
> So here's a second posting of the VMA based LDT implementation; now without
> most of the crazy.
> 
> I took out the write fault handler and the magic LAR touching code.
> 
> Additionally there are a bunch of patches that address generic vm issue.
> 
>  - gup() access control; In specific I looked at accessing !_PAGE_USER pages
>    because these patches rely on not being able to do that.
> 
>  - special mappings; A whole bunch of mmap ops don't make sense on special
>    mappings so disallow them.
> 
> Both things make sense independent of the rest of the series. Similarly, the
> patches that kill that rediculous LDT inherit on exec() are also unquestionably
> good.
> 
> So I think at least the first 6 patches are good, irrespective of the
> VMA approach.
> 
> On the whole VMA approach, Andy I know you hate it with a passion, but I really
> rather like how it ties the LDT to the process that it belongs to and it
> reduces the amount of 'special' pages in the whole PTI mapping.
> 
> I'm not the one going to make the decision on this; but I figured I at least
> post a version without the obvious crap parts of the last one.
> 
> Note: if we were to also disallow munmap() for special mappings (which I
> suppose makes perfect sense) then we could further reduce the actual LDT
> code (we'd no longer need the sm::close callback and related things).

That makes a lot of sense for the other special mapping users like VDSO and
kprobes.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
