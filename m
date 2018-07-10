Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B17946B0270
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:37:45 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s3-v6so13465205plp.21
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:37:45 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id r25-v6si16926959pge.104.2018.07.10.16.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:37:44 -0700 (PDT)
Subject: Re: [RFC PATCH v2 16/27] mm: Modify can_follow_write_pte/pmd for
 shadow stack
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-17-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <de510df6-7ea9-edc6-9c49-2f80f16472b4@linux.intel.com>
Date: Tue, 10 Jul 2018 16:37:43 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-17-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> There are three possible shadow stack PTE settings:
> 
>   Normal SHSTK PTE: (R/O + DIRTY_HW)
>   SHSTK PTE COW'ed: (R/O + DIRTY_HW)
>   SHSTK PTE shared as R/O data: (R/O + DIRTY_SW)
> 
> Update can_follow_write_pte/pmd for the shadow stack.

First of all, thanks for the excellent patch headers.  It's nice to have
that reference every time even though it's repeated.

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

Can we just pass the VMA in here?  This use is OK-ish, but I generally
detest true/false function arguments because you can't tell what they
are when they show up without a named variable.

But...  Why does this even matter?  Your own example showed that all
shadowstack PTEs have either DIRTY_HW or DIRTY_SW set, and pte_dirty()
checks both.

That makes this check seem a bit superfluous.
