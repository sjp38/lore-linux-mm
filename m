Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6246B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:48:48 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z21-v6so6905232plo.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 01:48:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si18452576plj.411.2018.07.11.01.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 01:48:47 -0700 (PDT)
Date: Wed, 11 Jul 2018 10:48:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v2 11/27] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
Message-ID: <20180711084842.GR2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-12-yu-cheng.yu@intel.com>
 <fbf45667-5388-44a6-1f22-07bcc03e1804@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fbf45667-5388-44a6-1f22-07bcc03e1804@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, Jul 10, 2018 at 03:44:32PM -0700, Dave Hansen wrote:
> On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> > +	/*
> > +	 * On platforms before CET, other threads could race to
> > +	 * create a RO and _PAGE_DIRTY_HW PMD again.  However,
> > +	 * on CET platforms, this is safe without a TLB flush.
> > +	 */
> 
> If I didn't work for Intel, I'd wonder what the heck CET is and what the
> heck it has to do with _PAGE_DIRTY_HW.  I think we need a better comment

And Changelog, the provided one is abysmal.

> than this.  How about:
> 
> 	Some processors can _start_ a write, but end up seeing
> 	a read-only PTE by the time they get to getting the
> 	Dirty bit.  In this case, they will set the Dirty bit,
> 	leaving a read-only, Dirty PTE which looks like a Shadow
> 	Stack PTE.
> 
> 	However, this behavior has been improved and will *not* occur on
> 	processors supporting Shadow Stacks.  Without this guarantee, a
> 	transition to a non-present PTE and flush the TLB would be
> 	needed.

I'm still struggling. I think I get the first paragraph, but then what?
