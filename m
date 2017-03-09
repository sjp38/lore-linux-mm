Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 286FB6B043A
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 16:32:26 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id w33so90654571uaw.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 13:32:26 -0800 (PST)
Received: from mail-ua0-x22a.google.com (mail-ua0-x22a.google.com. [2607:f8b0:400c:c08::22a])
        by mx.google.com with ESMTPS id o14si3209844uac.43.2017.03.09.13.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 13:32:25 -0800 (PST)
Received: by mail-ua0-x22a.google.com with SMTP id q7so79432193uaf.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 13:32:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170306220348.79702-2-thgarnie@google.com>
References: <20170306220348.79702-1-thgarnie@google.com> <20170306220348.79702-2-thgarnie@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 9 Mar 2017 13:32:03 -0800
Message-ID: <CALCETrVXHc-EAhBtdhL9FXSW1G2VbohRY4UJuOtpRG1K0Q-Ogg@mail.gmail.com>
Subject: Re: [PATCH v5 2/3] x86: Remap GDT tables in the Fixmap section
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, He Chen <he.chen@linux.intel.com>, Brian Gerst <brgerst@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, lguest@lists.ozlabs.org, kvm list <kvm@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Mon, Mar 6, 2017 at 2:03 PM, Thomas Garnier <thgarnie@google.com> wrote:
> Each processor holds a GDT in its per-cpu structure. The sgdt
> instruction gives the base address of the current GDT. This address can
> be used to bypass KASLR memory randomization. With another bug, an
> attacker could target other per-cpu structures or deduce the base of
> the main memory section (PAGE_OFFSET).
>
> This patch relocates the GDT table for each processor inside the
> Fixmap section. The space is reserved based on number of supported
> processors.
>
> For consistency, the remapping is done by default on 32 and 64-bit.
>
> Each processor switches to its remapped GDT at the end of
> initialization. For hibernation, the main processor returns with the
> original GDT and switches back to the remapping at completion.
>
> This patch was tested on both architectures. Hibernation and KVM were
> both tested specially for their usage of the GDT.

Looks good with minor nitpicks.  Also, have you tested on Xen PV?

(If you aren't set up for it, virtme can do this test quite easily.  I
could run it for you if you like, too.)

> +static inline unsigned long get_current_gdt_rw_vaddr(void)
> +{
> +       return (unsigned long)get_current_gdt_rw();
> +}

This has no callers, so let's remove it.

> +static inline unsigned long get_cpu_gdt_ro_vaddr(int cpu)
> +{
> +       return (unsigned long)get_cpu_gdt_ro(cpu);
> +}

Ditto.

> +static inline unsigned long get_current_gdt_ro_vaddr(void)
> +{
> +       return (unsigned long)get_current_gdt_ro();
> +}

Ditto.

> --- a/arch/x86/xen/enlighten.c
> +++ b/arch/x86/xen/enlighten.c
> @@ -710,7 +710,7 @@ static void load_TLS_descriptor(struct thread_struct *t,
>
>         *shadow = t->tls_array[i];
>
> -       gdt = get_cpu_gdt_table(cpu);
> +       gdt = get_cpu_gdt_rw(cpu);
>         maddr = arbitrary_virt_to_machine(&gdt[GDT_ENTRY_TLS_MIN+i]);
>         mc = __xen_mc_entry(0);

Boris, is this right?  I don't see why it wouldn't be, but Xen is special.

> @@ -504,7 +504,7 @@ void __init lguest_arch_host_init(void)
>                  * byte, not the size, hence the "-1").
>                  */
>                 state->host_gdt_desc.size = GDT_SIZE-1;
> -               state->host_gdt_desc.address = (long)get_cpu_gdt_table(i);
> +               state->host_gdt_desc.address = (long)get_cpu_gdt_rw(i);

I suspect this should be get_cpu_gdt_ro(), but I don't know too much
about lguest.  Hmm, maybe the right thing to do is to give lguest a
nice farewell and retire it.  The last time I tried to test it, I gave
up.


--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
