From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 07/20] x86: Provide general kernel support for
 memory encryption
Date: Thu, 8 Sep 2016 15:55:51 +0200
Message-ID: <20160908135551.3gtbwezbb7xpyud2@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223646.29880.28794.stgit@tlendack-t1.amdoffice.net>
 <20160906093113.GA18319@pd.tnic>
 <f4125cae-63af-f8c7-086f-e297ce480a07@amd.com>
 <20160907155535.i7wh46uxxa2bj3ik@pd.tnic>
 <bc8f22db-b6f9-951f-145c-fed919098cbe@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <bc8f22db-b6f9-951f-145c-fed919098cbe-5C7GfCeVMHo@public.gmane.org>
Sender: linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>, Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov@google.>
List-Id: linux-mm.kvack.org

On Thu, Sep 08, 2016 at 08:26:27AM -0500, Tom Lendacky wrote:
> When does this value get initialized?  Since _PAGE_ENC is #defined to
> sme_me_mask, which is not set until the boot process begins, I'm afraid
> we'd end up using the initial value of sme_me_mask, which is zero.  Do
> I have that right?

Hmm, but then that would hold true for all the other defines where you
OR-in _PAGE_ENC, no?

In any case, the preprocessed source looks like this:

pmdval_t early_pmd_flags = (((((((pteval_t)(1)) << 0) | (((pteval_t)(1)) << 1) | (((pteval_t)(1)) << 6) | (((pteval_t)(1)) << 5) | (((pteval_t)(1)) << 8)) | (((pteval_t)(1)) << 63)) | (((pteval_t)(1)) << 7)) | sme_me_mask) & ~((((pteval_t)(1)) << 8) | (((pteval_t)(1)) << 63));

but the problem is later, when building:

arch/x86/kernel/head64.c:39:28: error: initializer element is not constant
 pmdval_t early_pmd_flags = (__PAGE_KERNEL_LARGE | _PAGE_ENC) & ~(_PAGE_GLOBAL | _PAGE_NX);
                            ^
scripts/Makefile.build:153: recipe for target 'arch/x86/kernel/head64.s' failed

so I guess not. :-\

Ok, then at least please put the early_pmd_flags init after
sme_early_init() along with a small comment explaning what happens.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
