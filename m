Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA1216B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 15:45:01 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u16so5645763pfh.7
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:45:01 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w34si3383031pla.163.2017.12.14.12.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 12:45:00 -0800 (PST)
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
Date: Thu, 14 Dec 2017 12:44:58 -0800
MIME-Version: 1.0
In-Reply-To: <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On 12/14/2017 06:37 AM, Peter Zijlstra wrote:
> I'm also looking at pte_access_permitted() in handle_pte_fault(); that
> looks very dodgy to me. How does that not result in endlessly CoW'ing
> the same page over and over when we have a PKEY disallowing write access
> on that page?

I'm not seeing the pte_access_permitted() in handle_pte_fault().  I
assume that's something you added in this series.

But, one of the ways that we keep pkeys from causing these kinds of
repeating loops when interacting with other things is this hunk in the
page fault code:

> static inline int
> access_error(unsigned long error_code, struct vm_area_struct *vma)
> {
...
>         /*
>          * Read or write was blocked by protection keys.  This is
>          * always an unconditional error and can never result in
>          * a follow-up action to resolve the fault, like a COW.
>          */
>         if (error_code & PF_PK)
>                 return 1;

That short-circuits the page fault pretty quickly.  So, basically, the
rule is: if the hardware says you tripped over pkey permissions, you
die.  We don't try to do anything to the underlying page *before* saying
that you die.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
