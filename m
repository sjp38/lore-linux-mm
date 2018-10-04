Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 827916B026F
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 12:11:29 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id v4-v6so8555539plz.21
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 09:11:29 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t21-v6si6087585plj.352.2018.10.04.09.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 09:11:28 -0700 (PDT)
Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BD7D0214C1
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 16:11:27 +0000 (UTC)
Received: by mail-wr1-f50.google.com with SMTP id e4-v6so10586715wrs.0
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 09:11:27 -0700 (PDT)
MIME-Version: 1.0
References: <20180921150553.21016-1-yu-cheng.yu@intel.com> <20180921150553.21016-4-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150553.21016-4-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 4 Oct 2018 09:11:14 -0700
Message-ID: <CALCETrUj5_kc8qr5xNJSyE4Dz18BcYCcgA1i_CvqgJzZiwG+ig@mail.gmail.com>
Subject: Re: [RFC PATCH v4 3/9] x86/cet/ibt: Add IBT legacy code bitmap
 allocation function
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Eugene Syromiatnikov <esyr@redhat.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 8:10 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> Indirect branch tracking provides an optional legacy code bitmap
> that indicates locations of non-IBT compatible code.  When set,
> each bit in the bitmap represents a page in the linear address is
> legacy code.
>
> We allocate the bitmap only when the application requests it.
> Most applications do not need the bitmap.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/kernel/cet.c | 45 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 45 insertions(+)
>
> diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> index 6adfe795d692..a65d9745af08 100644
> --- a/arch/x86/kernel/cet.c
> +++ b/arch/x86/kernel/cet.c
> @@ -314,3 +314,48 @@ void cet_disable_ibt(void)
>         wrmsrl(MSR_IA32_U_CET, r);
>         current->thread.cet.ibt_enabled = 0;
>  }
> +
> +int cet_setup_ibt_bitmap(void)
> +{
> +       u64 r;
> +       unsigned long bitmap;
> +       unsigned long size;
> +
> +       if (!cpu_feature_enabled(X86_FEATURE_IBT))
> +               return -EOPNOTSUPP;
> +
> +       if (!current->thread.cet.ibt_bitmap_addr) {
> +               /*
> +                * Calculate size and put in thread header.
> +                * may_expand_vm() needs this information.
> +                */
> +               size = TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;
> +               current->thread.cet.ibt_bitmap_size = size;
> +               bitmap = do_mmap_locked(0, size, PROT_READ | PROT_WRITE,
> +                                       MAP_ANONYMOUS | MAP_PRIVATE,
> +                                       VM_DONTDUMP);
> +
> +               if (bitmap >= TASK_SIZE) {
> +                       current->thread.cet.ibt_bitmap_size = 0;
> +                       return -ENOMEM;
> +               }
> +
> +               current->thread.cet.ibt_bitmap_addr = bitmap;
> +       }
> +
> +       /*
> +        * Lower bits of MSR_IA32_CET_LEG_IW_EN are for IBT
> +        * settings.  Clear lower bits even bitmap is already
> +        * page-aligned.
> +        */
> +       bitmap = current->thread.cet.ibt_bitmap_addr;
> +       bitmap &= PAGE_MASK;
> +
> +       /*
> +        * Turn on IBT legacy bitmap.
> +        */
> +       rdmsrl(MSR_IA32_U_CET, r);
> +       r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> +       wrmsrl(MSR_IA32_U_CET, r);
> +       return 0;

Why are you writing the MSRs in the case where the bitmap was already allocated?
