Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64B106B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:14:16 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id n3so5863996ioc.0
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:14:16 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d126si3602552ith.168.2017.11.30.05.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 05:14:14 -0800 (PST)
Date: Thu, 30 Nov 2017 14:13:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/6] x86/mm/kaiser: Optimize __native_flush_tlb
Message-ID: <20171130131353.zqiywe532kjca4pj@hirez.programming.kicks-ass.net>
References: <20171129103301.131535445@infradead.org>
 <20171129103512.918991807@infradead.org>
 <20171130124319.ovyierac7ywxzhjy@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130124319.ovyierac7ywxzhjy@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Thu, Nov 30, 2017 at 01:43:19PM +0100, Peter Zijlstra wrote:
> Now the problem is that flush_tlb_kernel_range() is implemented using
> either __flush_tlb_all() or __flush_tlb_single(), and it is that last
> use that is buggered.
> 
> So at the very least we need the below to cure things, but there is
> another inconsistency; do_flush_tlb_all() is used by both
> flush_tlb_all() and flush_tlb_kernel_range() and increments NR_TLB_*,
> do_kernel_range_flush() OTOH does not increment NR_TLB_*. I'm not fixing
> that, but I'll leave a comment around or something, so we can later try
> and figure out what exact statistics we want.

Alternatively, we'd simply kill the entire invlpg path for
flush_tlb_kernel_range() and simply do __flush_tlb_all().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
