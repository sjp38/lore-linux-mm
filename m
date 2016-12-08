Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 571266B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 14:22:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so9598181wma.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 11:22:58 -0800 (PST)
Received: from mail-wj0-x241.google.com (mail-wj0-x241.google.com. [2a00:1450:400c:c01::241])
        by mx.google.com with ESMTPS id a1si30571842wjw.115.2016.12.08.11.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 11:22:57 -0800 (PST)
Received: by mail-wj0-x241.google.com with SMTP id he10so41661225wjc.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 11:22:56 -0800 (PST)
Date: Thu, 8 Dec 2016 22:22:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv1 16/28] x86/asm: remove __VIRTUAL_MASK_SHIFT==47
 assert
Message-ID: <20161208192254.GB30380@node.shutemov.name>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-18-kirill.shutemov@linux.intel.com>
 <CALCETrWQagC=D87GiM+PT_j=e+Cva7FSxvmMK4hmC3AMF5t-2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWQagC=D87GiM+PT_j=e+Cva7FSxvmMK4hmC3AMF5t-2Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Dec 08, 2016 at 10:39:57AM -0800, Andy Lutomirski wrote:
> On Thu, Dec 8, 2016 at 8:21 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > We don't need it anymore. 17be0aec74fb ("x86/asm/entry/64: Implement
> > better check for canonical addresses") made canonical address check
> > generic wrt. address width.
> 
> This code existed in part to remind us that this needs very careful
> adjustment when the paging size becomes dynamic.  If you want to
> remove it, please add test cases to tools/testing/selftests/x86 that
> verify:
> 
> a. Either mmap(2^47-4096, ..., MAP_FIXED, ...) fails or that, if it
> succeeds and you put a syscall instruction at the very end, that
> invoking the syscall instruction there works.  The easiest way to do
> this may be to have the selftest literally have a page of text that
> has 4094 0xcc bytes and a syscall and to map that page or perhaps move
> it into place with mremap.  That will avoid annoying W^X userspace
> stuff from messing up the test.  You'll need to handle the signal when
> you fall off the end of the world after the syscall.
> 
> b. Ditto for the new highest possible userspace page.
> 
> c. Ditto for one page earlier to make sure that your test actually works.
> 
> d. For each possible maximum address, call raise(SIGUSR1) and, in the
> signal handler, change RIP to point to the first noncanonical address
> and RCX to match RIP.  Return and catch the resulting exception.  This
> may be easy to integrate into the sigreturn tests, and I can help with
> that.

Thanks, for hints.

I'll come back to you with testcases to verify that they are you wanted
to see.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
