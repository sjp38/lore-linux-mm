Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD8F66B0285
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:24:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id y7-v6so13379869plt.17
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:24:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p185-v6si17247596pga.476.2018.07.10.16.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:24:42 -0700 (PDT)
Subject: Re: [RFC PATCH v2 12/27] x86/mm: Shadow stack page fault error
 checking
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-13-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <175662bd-f979-ac5f-b78e-480608bdbf55@linux.intel.com>
Date: Tue, 10 Jul 2018 16:24:41 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-13-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> +	/*
> +	 * Verify X86_PF_SHSTK is within a shadow stack VMA.
> +	 * It is always an error if there is a shadow stack
> +	 * fault outside a shadow stack VMA.
> +	 */
> +	if (error_code & X86_PF_SHSTK) {
> +		if (!(vma->vm_flags & VM_SHSTK))
> +			return 1;
> +		return 0;
> +	}

It turns out that a X86_PF_SHSTK just means that the processor faulted
while doing access to something it thinks should be a shadow-stack
virtual address.

But, we *can* have faults on shadow stack accesses for non-shadow-stack
reasons.

I think you need to remove the 'return 0' and let it fall through to the
other access checks that we might be failing.  If it's a shadow stack
access, it has to be a shadow stack VMA.  But, a shadow-stack access
fault to a shadow stack VMA isn't _necessarily_ OK.
