From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v3 11/20] x86: Add support for changing memory
	encryption attribute
Date: Thu, 17 Nov 2016 18:39:45 +0100
Message-ID: <20161117173945.gnar3arpyeeh5xm2@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
	<20161110003655.3280.57333.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161110003655.3280.57333.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Larry Woodman <lwoodman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Wed, Nov 09, 2016 at 06:36:55PM -0600, Tom Lendacky wrote:
> This patch adds support to be change the memory encryption attribute for
> one or more memory pages.

"Add support for changing ..."

> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/cacheflush.h  |    3 +
>  arch/x86/include/asm/mem_encrypt.h |   13 ++++++
>  arch/x86/mm/mem_encrypt.c          |   43 +++++++++++++++++++++
>  arch/x86/mm/pageattr.c             |   73 ++++++++++++++++++++++++++++++++++++
>  4 files changed, 132 insertions(+)

...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index 411210d..41cfdf9 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -18,6 +18,7 @@
>  #include <asm/fixmap.h>
>  #include <asm/setup.h>
>  #include <asm/bootparam.h>
> +#include <asm/cacheflush.h>
>  
>  extern pmdval_t early_pmd_flags;
>  int __init __early_make_pgtable(unsigned long, pmdval_t);
> @@ -33,6 +34,48 @@ EXPORT_SYMBOL_GPL(sme_me_mask);
>  /* Buffer used for early in-place encryption by BSP, no locking needed */
>  static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
>  
> +int sme_set_mem_enc(void *vaddr, unsigned long size)
> +{
> +	unsigned long addr, numpages;
> +
> +	if (!sme_me_mask)
> +		return 0;

So those interfaces look duplicated to me: you have exported
sme_set_mem_enc/sme_set_mem_unenc which take @size and then you have
set_memory_enc/set_memory_dec which take numpages.

And then you're testing sme_me_mask in both.

What I'd prefer to have is only *two* set_memory_enc/set_memory_dec
which take size in bytes and one workhorse __set_memory_enc_dec() which
does it all. The user shouldn't have to care about numpages or size or
whatever.

Ok?

> +
> +	addr = (unsigned long)vaddr & PAGE_MASK;
> +	numpages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> +
> +	/*
> +	 * The set_memory_xxx functions take an integer for numpages, make
> +	 * sure it doesn't exceed that.
> +	 */
> +	if (numpages > INT_MAX)
> +		return -EINVAL;
> +
> +	return set_memory_enc(addr, numpages);
> +}
> +EXPORT_SYMBOL_GPL(sme_set_mem_enc);
> +
> +int sme_set_mem_unenc(void *vaddr, unsigned long size)
> +{
> +	unsigned long addr, numpages;
> +
> +	if (!sme_me_mask)
> +		return 0;
> +
> +	addr = (unsigned long)vaddr & PAGE_MASK;
> +	numpages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> +
> +	/*
> +	 * The set_memory_xxx functions take an integer for numpages, make
> +	 * sure it doesn't exceed that.
> +	 */
> +	if (numpages > INT_MAX)
> +		return -EINVAL;
> +
> +	return set_memory_dec(addr, numpages);
> +}
> +EXPORT_SYMBOL_GPL(sme_set_mem_unenc);
> +
>  /*
>   * This routine does not change the underlying encryption setting of the
>   * page(s) that map this memory. It assumes that eventually the memory is
> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
> index b8e6bb5..babf3a6 100644
> --- a/arch/x86/mm/pageattr.c
> +++ b/arch/x86/mm/pageattr.c
> @@ -1729,6 +1729,79 @@ int set_memory_4k(unsigned long addr, int numpages)
>  					__pgprot(0), 1, 0, NULL);
>  }
>  
> +static int __set_memory_enc_dec(struct cpa_data *cpa)
> +{
> +	unsigned long addr;
> +	int numpages;
> +	int ret;
> +
> +	/* People should not be passing in unaligned addresses */
> +	if (WARN_ONCE(*cpa->vaddr & ~PAGE_MASK,
> +		      "misaligned address: %#lx\n", *cpa->vaddr))
> +		*cpa->vaddr &= PAGE_MASK;
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

That label is used only once - just "return ret;" here.

> +	/*
> +	 * On success we use CLFLUSH, when the CPU supports it to
> +	 * avoid the WBINVD.
> +	 */
> +	if (!ret && static_cpu_has(X86_FEATURE_CLFLUSH))
> +		cpa_flush_range(addr, numpages, 1);
> +	else
> +		cpa_flush_all(1);
> +
> +out:
> +	return ret;
> +}
> +
> +int set_memory_enc(unsigned long addr, int numpages)
> +{
> +	struct cpa_data cpa;
> +
> +	if (!sme_me_mask)
> +		return 0;
> +
> +	memset(&cpa, 0, sizeof(cpa));
> +	cpa.vaddr = &addr;
> +	cpa.numpages = numpages;
> +	cpa.mask_set = __pgprot(_PAGE_ENC);
> +	cpa.mask_clr = __pgprot(0);
> +	cpa.pgd = init_mm.pgd;

You could move that...

> +
> +	return __set_memory_enc_dec(&cpa);
> +}
> +EXPORT_SYMBOL(set_memory_enc);
> +
> +int set_memory_dec(unsigned long addr, int numpages)
> +{
> +	struct cpa_data cpa;
> +
> +	if (!sme_me_mask)
> +		return 0;
> +
> +	memset(&cpa, 0, sizeof(cpa));
> +	cpa.vaddr = &addr;
> +	cpa.numpages = numpages;
> +	cpa.mask_set = __pgprot(0);
> +	cpa.mask_clr = __pgprot(_PAGE_ENC);
> +	cpa.pgd = init_mm.pgd;

... and that into __set_memory_enc_dec() too and pass in a "bool dec" or
"bool enc" or so which presets mask_set and mask_clr properly.

See above. I think two functions exported to other in-kernel users are
more than enough.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
