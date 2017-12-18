Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17D8C6B0069
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:54:35 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id g81so8541891ioa.14
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:54:35 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f8si9431075ita.49.2017.12.18.03.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 03:54:34 -0800 (PST)
Date: Mon, 18 Dec 2017 12:54:09 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171218115409.gtsw7ygh53sq2hcd@hirez.programming.kicks-ass.net>
References: <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
 <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
 <20171215080041.zftzuxdonxrtmssq@hirez.programming.kicks-ass.net>
 <20171215102529.vtsjhb7h7jiufkr3@hirez.programming.kicks-ass.net>
 <20171215113838.nqxcjyyhfy4g7ipk@hirez.programming.kicks-ass.net>
 <CAPcyv4ghxbdWoRF6U=PSLLQaUKGx55MzYSPVrtsBug7ETv5ybg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ghxbdWoRF6U=PSLLQaUKGx55MzYSPVrtsBug7ETv5ybg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Dec 15, 2017 at 08:38:02AM -0800, Dan Williams wrote:

> The motivation was that I noticed that get_user_pages_fast() was doing
> a full pud_access_permitted() check, but the get_user_pages() slow
> path was only doing a pud_write() check. That was inconsistent so I
> went to go resolve that across all the pte types and ended up making a
> mess of things,

> I'm fine if the answer is that we should have went the
> other way to only do write checks. However, when I was investigating
> which way to go the aspect that persuaded me to start sprinkling
> p??_access_permitted checks around was that the application behavior
> changed between mmap access and direct-i/o access to the same buffer.

> I assumed that different access behavior between those would be an
> inconsistent surprise to userspace. Although, infinitely looping in
> handle_mm_fault is an even worse surprise, apologies for that.

Well, we all make a mess of things at time. I'm certainly guilty of
that, so no worries there. But it really helps if your Changelogs at
least describe what you're trying to do and why.

So I think I covered what you set out to do. In any case, Linus took the
whole lot back out, so we can look at this afresh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
