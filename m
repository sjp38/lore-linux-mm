Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5C0D6B027F
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:08:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a23-v6so3324754pfo.23
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:08:32 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w13-v6si13211422ply.454.2018.07.10.16.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:08:31 -0700 (PDT)
Subject: Re: [RFC PATCH v2 14/27] mm: Handle THP/HugeTLB shadow stack page
 fault
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-15-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <4ba0410c-eadf-19f7-1931-ee7f9e38fde8@linux.intel.com>
Date: Tue, 10 Jul 2018 16:08:30 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-15-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> @@ -1347,6 +1353,8 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  		pmd_t entry;
>  		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +		if (is_shstk_mapping(vma->vm_flags))
> +			entry = pmd_mkdirty_shstk(entry);

This pattern is repeated enough that it makes me wonder if we should
just be doing the shadowstack PTE creation in mk_huge_pmd() itself.

Or, should we just be setting the shadowstack pte bit combination in
vma->vm_page_prot so we don't have to go set it explicitly every time?
