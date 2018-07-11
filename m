Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D11F46B026D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:12:38 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s16-v6so14414346plr.22
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 02:12:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z12-v6si17140728pgu.692.2018.07.11.02.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 02:12:37 -0700 (PDT)
Date: Wed, 11 Jul 2018 11:12:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v2 15/27] mm/mprotect: Prevent mprotect from changing
 shadow stack
Message-ID: <20180711091232.GU2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-16-yu-cheng.yu@intel.com>
 <04800c52-1f86-c485-ba7c-2216d8c4966f@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04800c52-1f86-c485-ba7c-2216d8c4966f@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, Jul 10, 2018 at 04:10:08PM -0700, Dave Hansen wrote:
> On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> 
> This still needs a changelog, even if you think it's simple.
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -446,6 +446,15 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
> >  	error = -ENOMEM;
> >  	if (!vma)
> >  		goto out;
> > +
> > +	/*
> > +	 * Do not allow changing shadow stack memory.
> > +	 */
> > +	if (vma->vm_flags & VM_SHSTK) {
> > +		error = -EINVAL;
> > +		goto out;
> > +	}
> > +
> 
> I think this is a _bit_ draconian.  Why shouldn't we be able to use
> protection keys with a shadow stack?  Or, set it to PROT_NONE?

Right, and then there's also madvise() and some of the other accessors.

Why do we need to disallow this? AFAICT the worst that can happen is
that a process wrecks itself, so what?
