From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 12/20] x86: Add support for changing memory
	encryption attribute
Date: Fri, 9 Sep 2016 19:23:15 +0200
Message-ID: <20160909172314.ifcteua7nr52mzgs@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223749.29880.10183.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223749.29880.10183.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Aug 22, 2016 at 05:37:49PM -0500, Tom Lendacky wrote:
> This patch adds support to be change the memory encryption attribute for
> one or more memory pages.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/cacheflush.h  |    3 +
>  arch/x86/include/asm/mem_encrypt.h |   13 ++++++
>  arch/x86/mm/mem_encrypt.c          |   43 +++++++++++++++++++++
>  arch/x86/mm/pageattr.c             |   75 ++++++++++++++++++++++++++++++++++++
>  4 files changed, 134 insertions(+)

...

> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
> index 72c292d..0ba9382 100644
> --- a/arch/x86/mm/pageattr.c
> +++ b/arch/x86/mm/pageattr.c
> @@ -1728,6 +1728,81 @@ int set_memory_4k(unsigned long addr, int numpages)
>  					__pgprot(0), 1, 0, NULL);
>  }
>  
> +static int __set_memory_enc_dec(struct cpa_data *cpa)
> +{
> +	unsigned long addr;
> +	int numpages;
> +	int ret;
> +
> +	if (*cpa->vaddr & ~PAGE_MASK) {
> +		*cpa->vaddr &= PAGE_MASK;
> +
> +		/* People should not be passing in unaligned addresses */
> +		WARN_ON_ONCE(1);

Let's make this more user-friendly:

	if (WARN_ONCE(*cpa->vaddr & ~PAGE_MASK, "Misaligned address: 0x%lx\n", *cpa->vaddr))
		*cpa->vaddr &= PAGE_MASK;

> +	}
> +
> +	addr = *cpa->vaddr;
> +	numpages = cpa->numpages;
> +
> +	/* Must avoid aliasing mappings in the highmem code */
> +	kmap_flush_unused();
> +	vm_unmap_aliases();
> +
> +	ret = __change_page_attr_set_clr(cpa, 1);
> +
> +	/* Check whether we really changed something */
> +	if (!(cpa->flags & CPA_FLUSHTLB))
> +		goto out;
> +
> +	/*
> +	 * On success we use CLFLUSH, when the CPU supports it to
> +	 * avoid the WBINVD.
> +	 */
> +	if (!ret && static_cpu_has(X86_FEATURE_CLFLUSH))
> +		cpa_flush_range(addr, numpages, 1);
> +	else
> +		cpa_flush_all(1);

So if we fail (ret != 0) we do WBINVD unconditionally even if we don't
have to?

Don't you want this instead:

        ret = __change_page_attr_set_clr(cpa, 1);
        if (ret)
                goto out;

        /* Check whether we really changed something */
        if (!(cpa->flags & CPA_FLUSHTLB))
                goto out;

        /*
         * On success we use CLFLUSH, when the CPU supports it to
         * avoid the WBINVD.
         */
        if (static_cpu_has(X86_FEATURE_CLFLUSH))
                cpa_flush_range(addr, numpages, 1);
        else
                cpa_flush_all(1);

out:
        return ret;
}

?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
