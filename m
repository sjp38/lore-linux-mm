Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50BE36B0281
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:10:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n19-v6so1024286pgv.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:10:11 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h5-v6si17816374plr.268.2018.07.10.16.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:10:10 -0700 (PDT)
Subject: Re: [RFC PATCH v2 15/27] mm/mprotect: Prevent mprotect from changing
 shadow stack
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-16-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <04800c52-1f86-c485-ba7c-2216d8c4966f@linux.intel.com>
Date: Tue, 10 Jul 2018 16:10:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-16-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>

This still needs a changelog, even if you think it's simple.
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -446,6 +446,15 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
>  	error = -ENOMEM;
>  	if (!vma)
>  		goto out;
> +
> +	/*
> +	 * Do not allow changing shadow stack memory.
> +	 */
> +	if (vma->vm_flags & VM_SHSTK) {
> +		error = -EINVAL;
> +		goto out;
> +	}
> +

I think this is a _bit_ draconian.  Why shouldn't we be able to use
protection keys with a shadow stack?  Or, set it to PROT_NONE?
