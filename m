From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v4 27/28] x86: Add support to encrypt the kernel
	in-place
Date: Wed, 1 Mar 2017 18:36:23 +0100
Message-ID: <20170301173623.zcf35xgyrhmo25a7@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
	<20170216154808.19244.475.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170216154808.19244.475.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Brijesh Singh <brijesh.singh-5C7GfCeVMHo@public.gmane.org>, Toshimitsu Kani <toshi.kani-ZPxbGqLxI0U@public.gmane.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Larry Woodman <lwoodman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Thu, Feb 16, 2017 at 09:48:08AM -0600, Tom Lendacky wrote:
> This patch adds the support to encrypt the kernel in-place. This is
> done by creating new page mappings for the kernel - a decrypted
> write-protected mapping and an encrypted mapping. The kernel is encyrpted

s/encyrpted/encrypted/

> by copying the kernel through a temporary buffer.

"... by copying it... "

> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---

...

> +ENTRY(sme_encrypt_execute)
> +
> +#ifdef CONFIG_AMD_MEM_ENCRYPT
> +	/*
> +	 * Entry parameters:
> +	 *   RDI - virtual address for the encrypted kernel mapping
> +	 *   RSI - virtual address for the decrypted kernel mapping
> +	 *   RDX - length of kernel
> +	 *   RCX - address of the encryption workarea

						     , including:

> +	 *     - stack page (PAGE_SIZE)
> +	 *     - encryption routine page (PAGE_SIZE)
> +	 *     - intermediate copy buffer (PMD_PAGE_SIZE)
> +	 *    R8 - address of the pagetables to use for encryption
> +	 */
> +
> +	/* Set up a one page stack in the non-encrypted memory area */
> +	movq	%rcx, %rax
> +	addq	$PAGE_SIZE, %rax
> +	movq	%rsp, %rbp

%rbp is callee-saved and you're overwriting it here. You need to push it
first.

> +	movq	%rax, %rsp
> +	push	%rbp
> +
> +	push	%r12
> +	push	%r13

In general, just do all pushes on function entry and the pops on exit,
like the compiler does.

> +	movq	%rdi, %r10
> +	movq	%rsi, %r11
> +	movq	%rdx, %r12
> +	movq	%rcx, %r13
> +
> +	/* Copy encryption routine into the workarea */
> +	movq	%rax, %rdi
> +	leaq	.Lencrypt_start(%rip), %rsi
> +	movq	$(.Lencrypt_stop - .Lencrypt_start), %rcx
> +	rep	movsb
> +
> +	/* Setup registers for call */
> +	movq	%r10, %rdi
> +	movq	%r11, %rsi
> +	movq	%r8, %rdx
> +	movq	%r12, %rcx
> +	movq	%rax, %r8
> +	addq	$PAGE_SIZE, %r8
> +
> +	/* Call the encryption routine */
> +	call	*%rax
> +
> +	pop	%r13
> +	pop	%r12
> +
> +	pop	%rsp			/* Restore original stack pointer */
> +.Lencrypt_exit:

Please put side comments like this here:

ENTRY(sme_encrypt_execute)

#ifdef CONFIG_AMD_MEM_ENCRYPT
        /*
         * Entry parameters:
         *   RDI - virtual address for the encrypted kernel mapping
         *   RSI - virtual address for the decrypted kernel mapping
         *   RDX - length of kernel
         *   RCX - address of the encryption workarea
         *     - stack page (PAGE_SIZE)
         *     - encryption routine page (PAGE_SIZE)
         *     - intermediate copy buffer (PMD_PAGE_SIZE)
         *    R8 - address of the pagetables to use for encryption
         */

        /* Set up a one page stack in the non-encrypted memory area */
        movq    %rcx, %rax                      # %rax = workarea
        addq    $PAGE_SIZE, %rax                # %rax += 4096
        movq    %rsp, %rbp                      # stash stack ptr
        movq    %rax, %rsp                      # set new stack
        push    %rbp                            # needs to happen before the mov %rsp, %rbp

        push    %r12
        push    %r13

        movq    %rdi, %r10                      # encrypted kernel
        movq    %rsi, %r11                      # decrypted kernel
        movq    %rdx, %r12                      # kernel length
        movq    %rcx, %r13                      # workarea
	...

and so on.

...

> diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
> index 25af15d..07cbb90 100644
> --- a/arch/x86/kernel/mem_encrypt_init.c
> +++ b/arch/x86/kernel/mem_encrypt_init.c
> @@ -16,9 +16,200 @@
>  #ifdef CONFIG_AMD_MEM_ENCRYPT
>  
>  #include <linux/mem_encrypt.h>
> +#include <linux/mm.h>
> +
> +#include <asm/sections.h>
> +
> +extern void sme_encrypt_execute(unsigned long, unsigned long, unsigned long,
> +				void *, pgd_t *);

This belongs into mem_encrypt.h. And I think it already came up: please
use names for those params.

> +
> +#define PGD_FLAGS	_KERNPG_TABLE_NOENC
> +#define PUD_FLAGS	_KERNPG_TABLE_NOENC
> +#define PMD_FLAGS	__PAGE_KERNEL_LARGE_EXEC
> +
> +static void __init *sme_pgtable_entry(pgd_t *pgd, void *next_page,
> +				      void *vaddr, pmdval_t pmd_val)
> +{

sme_populate() or so sounds better.

> +	pud_t *pud;
> +	pmd_t *pmd;
> +
> +	pgd += pgd_index((unsigned long)vaddr);
> +	if (pgd_none(*pgd)) {
> +		pud = next_page;
> +		memset(pud, 0, sizeof(*pud) * PTRS_PER_PUD);
> +		native_set_pgd(pgd,
> +			       native_make_pgd((unsigned long)pud + PGD_FLAGS));

Let it stick out, no need for those "stairs" in the vertical alignment :)

> +		next_page += sizeof(*pud) * PTRS_PER_PUD;
> +	} else {
> +		pud = (pud_t *)(native_pgd_val(*pgd) & ~PTE_FLAGS_MASK);
> +	}
> +
> +	pud += pud_index((unsigned long)vaddr);
> +	if (pud_none(*pud)) {
> +		pmd = next_page;
> +		memset(pmd, 0, sizeof(*pmd) * PTRS_PER_PMD);
> +		native_set_pud(pud,
> +			       native_make_pud((unsigned long)pmd + PUD_FLAGS));
> +		next_page += sizeof(*pmd) * PTRS_PER_PMD;
> +	} else {
> +		pmd = (pmd_t *)(native_pud_val(*pud) & ~PTE_FLAGS_MASK);
> +	}
> +
> +	pmd += pmd_index((unsigned long)vaddr);
> +	if (pmd_none(*pmd) || !pmd_large(*pmd))
> +		native_set_pmd(pmd, native_make_pmd(pmd_val));
> +
> +	return next_page;
> +}
> +
> +static unsigned long __init sme_pgtable_calc(unsigned long start,
> +					     unsigned long end)
> +{
> +	unsigned long addr, total;
> +
> +	total = 0;
> +	addr = start;
> +	while (addr < end) {
> +		unsigned long pgd_end;
> +
> +		pgd_end = (addr & PGDIR_MASK) + PGDIR_SIZE;
> +		if (pgd_end > end)
> +			pgd_end = end;
> +
> +		total += sizeof(pud_t) * PTRS_PER_PUD * 2;
> +
> +		while (addr < pgd_end) {
> +			unsigned long pud_end;
> +
> +			pud_end = (addr & PUD_MASK) + PUD_SIZE;
> +			if (pud_end > end)
> +				pud_end = end;
> +
> +			total += sizeof(pmd_t) * PTRS_PER_PMD * 2;

That "* 2" is?

> +
> +			addr = pud_end;

So			addr += PUD_SIZE;

?

> +		}
> +
> +		addr = pgd_end;

So		addr += PGD_SIZE;

?

> +	total += sizeof(pgd_t) * PTRS_PER_PGD;
> +
> +	return total;
> +}
>  
>  void __init sme_encrypt_kernel(void)
>  {
> +	pgd_t *pgd;
> +	void *workarea, *next_page, *vaddr;
> +	unsigned long kern_start, kern_end, kern_len;
> +	unsigned long index, paddr, pmd_flags;
> +	unsigned long exec_size, full_size;
> +
> +	/* If SME is not active then no need to prepare */

That comment is obvious.

> +	if (!sme_active())
> +		return;
> +
> +	/* Set the workarea to be after the kernel */
> +	workarea = (void *)ALIGN(__pa_symbol(_end), PMD_PAGE_SIZE);
> +
> +	/*
> +	 * Prepare for encrypting the kernel by building new pagetables with
> +	 * the necessary attributes needed to encrypt the kernel in place.
> +	 *
> +	 *   One range of virtual addresses will map the memory occupied
> +	 *   by the kernel as encrypted.
> +	 *
> +	 *   Another range of virtual addresses will map the memory occupied
> +	 *   by the kernel as decrypted and write-protected.
> +	 *
> +	 *     The use of write-protect attribute will prevent any of the
> +	 *     memory from being cached.
> +	 */
> +
> +	/* Physical address gives us the identity mapped virtual address */
> +	kern_start = __pa_symbol(_text);
> +	kern_end = ALIGN(__pa_symbol(_end), PMD_PAGE_SIZE) - 1;

So
	kern_end = (unsigned long)workarea - 1;

?

Also, you can make that workarea be unsigned long and cast it to void *
only when needed so that you don't need to cast it in here for the
calculations.

> +	kern_len = kern_end - kern_start + 1;
> +
> +	/*
> +	 * Calculate required number of workarea bytes needed:
> +	 *   executable encryption area size:
> +	 *     stack page (PAGE_SIZE)
> +	 *     encryption routine page (PAGE_SIZE)
> +	 *     intermediate copy buffer (PMD_PAGE_SIZE)
> +	 *   pagetable structures for workarea (in case not currently mapped)
> +	 *   pagetable structures for the encryption of the kernel
> +	 */
> +	exec_size = (PAGE_SIZE * 2) + PMD_PAGE_SIZE;
> +
> +	full_size = exec_size;
> +	full_size += ALIGN(exec_size, PMD_PAGE_SIZE) / PMD_PAGE_SIZE *
> +		     sizeof(pmd_t) * PTRS_PER_PMD;
> +	full_size += sme_pgtable_calc(kern_start, kern_end + exec_size);
> +
> +	next_page = workarea + exec_size;

So next_page is the next free page after the workarea, correct? Because
of all things, *that* certainly needs a comment. It took me a while to
decipher what's going on here and I'm still not 100% clear.

> +	/* Make sure the current pagetables have entries for the workarea */
> +	pgd = (pgd_t *)native_read_cr3();
> +	paddr = (unsigned long)workarea;
> +	while (paddr < (unsigned long)workarea + full_size) {
> +		vaddr = (void *)paddr;
> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
> +					      paddr + PMD_FLAGS);
> +
> +		paddr += PMD_PAGE_SIZE;
> +	}
> +	native_write_cr3(native_read_cr3());

Why not

	native_write_cr3((unsigned long)pgd);

?

Now you can actually acknowledge that the code block in between changed
the hierarchy in pgd and you're reloading it.

> +	/* Calculate a PGD index to be used for the decrypted mapping */
> +	index = (pgd_index(kern_end + full_size) + 1) & (PTRS_PER_PGD - 1);
> +	index <<= PGDIR_SHIFT;

So call it decrypt_mapping_pgd or so. index doesn't say anything. Also,
move it right above where it is being used. This function is very hard
to follow as it is.

> +	/* Set and clear the PGD */

This needs more text: we're building a new temporary pagetable which
will have A, B and C mapped into it and blablabla...

> +	pgd = next_page;
> +	memset(pgd, 0, sizeof(*pgd) * PTRS_PER_PGD);
> +	next_page += sizeof(*pgd) * PTRS_PER_PGD;
> +
> +	/* Add encrypted (identity) mappings for the kernel */
> +	pmd_flags = PMD_FLAGS | _PAGE_ENC;
> +	paddr = kern_start;
> +	while (paddr < kern_end) {
> +		vaddr = (void *)paddr;
> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
> +					      paddr + pmd_flags);
> +
> +		paddr += PMD_PAGE_SIZE;
> +	}
> +
> +	/* Add decrypted (non-identity) mappings for the kernel */
> +	pmd_flags = (PMD_FLAGS & ~_PAGE_CACHE_MASK) | (_PAGE_PAT | _PAGE_PWT);
> +	paddr = kern_start;
> +	while (paddr < kern_end) {
> +		vaddr = (void *)(paddr + index);
> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
> +					      paddr + pmd_flags);
> +
> +		paddr += PMD_PAGE_SIZE;
> +	}
> +
> +	/* Add the workarea to both mappings */
> +	paddr = kern_end + 1;

	paddr = (unsigned long)workarea;

Now this makes sense when I read the comment above it.

> +	while (paddr < (kern_end + exec_size)) {

... which actually wants that exec_size to be called workarea_size. Then
it'll make more sense.

And then the thing above:

	next_page = workarea + exec_size;

would look like:

	next_page = workarea + workarea_size;

which would make even more sense. And since you have stuff called _start
and _end, you can do:

	next_page = workarea_start + workarea_size;

and not it would make most sense. Eva! :-)

> +		vaddr = (void *)paddr;
> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
> +					      paddr + PMD_FLAGS);
> +
> +		vaddr = (void *)(paddr + index);
> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
> +					      paddr + PMD_FLAGS);
> +
> +		paddr += PMD_PAGE_SIZE;
> +	}
> +
> +	/* Perform the encryption */
> +	sme_encrypt_execute(kern_start, kern_start + index, kern_len,
> +			    workarea, pgd);
> +

Phew, that's one tough patch to review. I'd like to review it again in
your next submission.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
