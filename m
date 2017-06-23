Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4916B03C0
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:56:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v60so10939815wrc.7
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:56:28 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id z15si4182678wrz.90.2017.06.23.01.56.26
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 01:56:27 -0700 (PDT)
Date: Fri, 23 Jun 2017 10:56:07 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 31/36] x86/mm, kexec: Allow kexec to be used with SME
Message-ID: <20170623085606.ett5nuiow2ye7p3a@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185545.18967.90815.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185545.18967.90815.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:55:45PM -0500, Tom Lendacky wrote:
> Provide support so that kexec can be used to boot a kernel when SME is
> enabled.
> 
> Support is needed to allocate pages for kexec without encryption.  This
> is needed in order to be able to reboot in the kernel in the same manner
> as originally booted.
> 
> Additionally, when shutting down all of the CPUs we need to be sure to
> flush the caches and then halt. This is needed when booting from a state
> where SME was not active into a state where SME is active (or vice-versa).
> Without these steps, it is possible for cache lines to exist for the same
> physical location but tagged both with and without the encryption bit. This
> can cause random memory corruption when caches are flushed depending on
> which cacheline is written last.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/init.h          |    1 +
>  arch/x86/include/asm/kexec.h         |    8 ++++++++
>  arch/x86/include/asm/pgtable_types.h |    1 +
>  arch/x86/kernel/machine_kexec_64.c   |   22 +++++++++++++++++++++-
>  arch/x86/kernel/process.c            |   17 +++++++++++++++--
>  arch/x86/mm/ident_map.c              |   12 ++++++++----
>  include/linux/kexec.h                |   14 ++++++++++++++
>  kernel/kexec_core.c                  |   12 +++++++++++-
>  8 files changed, 79 insertions(+), 8 deletions(-)

...

> diff --git a/include/linux/kexec.h b/include/linux/kexec.h
> index c9481eb..5d17fd6 100644
> --- a/include/linux/kexec.h
> +++ b/include/linux/kexec.h
> @@ -334,6 +334,20 @@ static inline void *boot_phys_to_virt(unsigned long entry)
>  	return phys_to_virt(boot_phys_to_phys(entry));
>  }
>  
> +#ifndef arch_kexec_post_alloc_pages
> +static inline int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages,
> +					      gfp_t gfp)
> +{
> +	return 0;
> +}
> +#endif

Just a nitpick:

static inline int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages, gfp_t gfp) { return 0; }
static inline void arch_kexec_pre_free_pages(void *vaddr, unsigned int pages) { }

Other than that:

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
