Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 788494403DA
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:44 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p144so7645772itc.9
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:44 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d15si3050463itc.170.2017.12.14.03.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:43 -0800 (PST)
Message-Id: <20171214112726.742649793@infradead.org>
Date: Thu, 14 Dec 2017 12:27:26 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 00/17] x86/ldt: Use a VMA based read only mapping
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

So here's a second posting of the VMA based LDT implementation; now without
most of the crazy.

I took out the write fault handler and the magic LAR touching code.

Additionally there are a bunch of patches that address generic vm issue.

 - gup() access control; In specific I looked at accessing !_PAGE_USER pages
   because these patches rely on not being able to do that.

 - special mappings; A whole bunch of mmap ops don't make sense on special
   mappings so disallow them.

Both things make sense independent of the rest of the series. Similarly, the
patches that kill that rediculous LDT inherit on exec() are also unquestionably
good.

So I think at least the first 6 patches are good, irrespective of the
VMA approach.

On the whole VMA approach, Andy I know you hate it with a passion, but I really
rather like how it ties the LDT to the process that it belongs to and it
reduces the amount of 'special' pages in the whole PTI mapping.

I'm not the one going to make the decision on this; but I figured I at least
post a version without the obvious crap parts of the last one.

Note: if we were to also disallow munmap() for special mappings (which I
suppose makes perfect sense) then we could further reduce the actual LDT
code (we'd no longer need the sm::close callback and related things).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
