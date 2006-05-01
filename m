Received: by pproxy.gmail.com with SMTP id i49so1120698pyi
        for <linux-mm@kvack.org>; Sun, 30 Apr 2006 20:07:37 -0700 (PDT)
Message-ID: <aec7e5c30604302007q78c5aec8n6e6da5f34b95b29b@mail.gmail.com>
Date: Mon, 1 May 2006 12:07:37 +0900
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: i386 and PAE: pud_present()
In-Reply-To: <2432524299CCD3CA89BB647D@10.1.1.4>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <aec7e5c30604280040p60cc7c7dqc6fb6fbdd9506a6b@mail.gmail.com>
	 <4451CA41.5070101@yahoo.com.au> <200604281027.22183.ak@suse.de>
	 <2432524299CCD3CA89BB647D@10.1.1.4>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 4/30/06, Dave McCracken <dmccr@us.ibm.com> wrote:
>
> --On Friday, April 28, 2006 10:27:21 +0200 Andi Kleen <ak@suse.de> wrote:
>
> >> Take a look a little further down the page for the comment.
> >>
> >> In i386 + PAE, pud is always present.
> >
> > I think his problem is that the PGD is always present too (in
> > pgtables-nopud.h) Indeed looks strange.
>
> The PGD is always fully populated on i386 if PAE is enabled.  All three of
> the pmd pages are allocated at page table creation time and persist till
> the page table is deleted.

The following code snippet is from some kexec patch of mine. The
function is used to build a new set of page tables which are used when
jumping to the new kernel.

The code should be pretty archtecture independent - the same code
works on x86 and x86_64. And x86/PAE with a workaround.

#ifdef CONFIG_X86_PAE
#undef pud_present
#define pud_present(pud) (pud_val(pud) & _PAGE_PRESENT)
#endif

#define pa_page(page) __pa(page_address(page))

static int create_mapping(struct page *root, struct page **pages,
			  unsigned long va, unsigned long pa)
{
	pgd_t *pgd;
	pud_t *pud;
	pmd_t *pmd;
	pte_t *pte;
	int k = 0;

	pgd = (pgd_t *)page_address(root) + pgd_index(va);
	if (!pgd_present(*pgd))
		set_pgd(pgd, __pgd(pa_page(pages[k++]) | _KERNPG_TABLE));

	pud = pud_offset(pgd, va);
	if (!pud_present(*pud))
		set_pud(pud, __pud(pa_page(pages[k++]) | _KERNPG_TABLE));

	pmd = pmd_offset(pud, va);
	if (!pmd_present(*pmd))
		set_pmd(pmd, __pmd(pa_page(pages[k++]) | _KERNPG_TABLE));

	pte = (pte_t *)page_address(pmd_page(*pmd)) + pte_index(va);
	set_pte(pte, __pte(pa | _PAGE_KERNEL_EXEC));

	return k;
}

Any comments?

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
