Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA0B36B0297
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:44:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t5-v6so1011282pgt.18
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:44:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r192-v6si17524467pgr.634.2018.07.10.15.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:44:45 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/27] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-12-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <fbf45667-5388-44a6-1f22-07bcc03e1804@linux.intel.com>
Date: Tue, 10 Jul 2018 15:44:32 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-12-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> +	/*
> +	 * On platforms before CET, other threads could race to
> +	 * create a RO and _PAGE_DIRTY_HW PMD again.  However,
> +	 * on CET platforms, this is safe without a TLB flush.
> +	 */

If I didn't work for Intel, I'd wonder what the heck CET is and what the
heck it has to do with _PAGE_DIRTY_HW.  I think we need a better comment
than this.  How about:

	Some processors can _start_ a write, but end up seeing
	a read-only PTE by the time they get to getting the
	Dirty bit.  In this case, they will set the Dirty bit,
	leaving a read-only, Dirty PTE which looks like a Shadow
	Stack PTE.

	However, this behavior has been improved and will *not* occur on
	processors supporting Shadow Stacks.  Without this guarantee, a
	transition to a non-present PTE and flush the TLB would be
	needed.
	
