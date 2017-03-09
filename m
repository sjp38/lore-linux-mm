Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD7572808DF
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 16:35:35 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id 62so91133606uas.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 13:35:35 -0800 (PST)
Received: from mail-ua0-x22c.google.com (mail-ua0-x22c.google.com. [2607:f8b0:400c:c08::22c])
        by mx.google.com with ESMTPS id w66si3207995vke.47.2017.03.09.13.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 13:35:34 -0800 (PST)
Received: by mail-ua0-x22c.google.com with SMTP id q7so79514485uaf.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 13:35:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170306220348.79702-3-thgarnie@google.com>
References: <20170306220348.79702-1-thgarnie@google.com> <20170306220348.79702-3-thgarnie@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 9 Mar 2017 13:35:13 -0800
Message-ID: <CALCETrWx9tzmBUthonB_OwMrL6xGd_RbVu+L0v0ohS-kzcBbtw@mail.gmail.com>
Subject: Re: [PATCH v5 3/3] x86: Make the GDT remapping read-only on 64-bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, He Chen <he.chen@linux.intel.com>, Brian Gerst <brgerst@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, lguest@lists.ozlabs.org, kvm list <kvm@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Mon, Mar 6, 2017 at 2:03 PM, Thomas Garnier <thgarnie@google.com> wrote:
> This patch makes the GDT remapped pages read-only to prevent corruption.
> This change is done only on 64-bit.
>
> The native_load_tr_desc function was adapted to correctly handle a
> read-only GDT. The LTR instruction always writes to the GDT TSS entry.
> This generates a page fault if the GDT is read-only. This change checks
> if the current GDT is a remap and swap GDTs as needed. This function was
> tested by booting multiple machines and checking hibernation works
> properly.
>
> KVM SVM and VMX were adapted to use the writeable GDT. On VMX, the
> per-cpu variable was removed for functions to fetch the original GDT.
> Instead of reloading the previous GDT, VMX will reload the fixmap GDT as
> expected. For testing, VMs were started and restored on multiple
> configurations.

I like this patch.

> +
> +/*
> + * The LTR instruction marks the TSS GDT entry as busy. On 64-bit, the GDT is
> + * a read-only remapping. To prevent a page fault, the GDT is switched to the
> + * original writeable version when needed.
> + */
> +#ifdef CONFIG_X86_64
>  static inline void native_load_tr_desc(void)
>  {
> +       struct desc_ptr gdt;
> +       int cpu = raw_smp_processor_id();
> +       bool restore = 0;
> +       struct desc_struct *fixmap_gdt;
> +
> +       native_store_gdt(&gdt);

This part will slow this function down considerably, but with the
recent KVM improvements, I think that there are no callers left that
care about performance, so this should be fine.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
