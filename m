Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 004D36B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 14:26:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q18-v6so20192945pll.3
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:26:48 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x5-v6si23157224pgc.210.2018.07.13.11.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 11:26:47 -0700 (PDT)
Subject: Re: [RFC PATCH v2 16/27] mm: Modify can_follow_write_pte/pmd for
 shadow stack
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-17-yu-cheng.yu@intel.com>
 <de510df6-7ea9-edc6-9c49-2f80f16472b4@linux.intel.com>
 <1531328731.15351.3.camel@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <45a85b01-e005-8cb6-af96-b23ce9b5fca7@linux.intel.com>
Date: Fri, 13 Jul 2018 11:26:46 -0700
MIME-Version: 1.0
In-Reply-To: <1531328731.15351.3.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/11/2018 10:05 AM, Yu-cheng Yu wrote:
> My understanding is that we don't want to follow write pte if the page
> is shared as read-only. A For a SHSTK page, that is (R/O + DIRTY_SW),
> which means the SHSTK page has not been COW'ed. A Is that right?

Let's look at the code again:

> -static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
> +static inline bool can_follow_write_pte(pte_t pte, unsigned int flags,
> +					bool shstk)
>  {
> +	bool pte_cowed = shstk ? is_shstk_pte(pte):pte_dirty(pte);
> +
>  	return pte_write(pte) ||
> -		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
> +		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_cowed);
>  }

This is another case where the naming of pte_*() is biting us vs. the
perversion of the PTE bits.  The lack of comments and explanation inthe
patch is compounding the confusion.

We need to find a way to differentiate "someone can write to this PTE"
from "the write bit is set in this PTE".

In this particular hunk, we need to make it clear that pte_write() is
*never* true for shadowstack PTEs.  In other words, shadow stack VMAs
will (should?) never even *see* a pte_write() PTE.

I think this is a case where you just need to bite the bullet and
bifurcate can_follow_write_pte().  Just separate the shadowstack and
non-shadowstack parts.
