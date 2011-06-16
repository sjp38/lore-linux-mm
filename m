Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2F96B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 08:49:26 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 16 Jun 2011 14:48:05 +0200
Message-ID: <1308228485.13240.61.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> +static int __replace_page(struct vm_area_struct *vma, struct page *page,
> +                                       struct page *kpage)
> +{
> +       struct mm_struct *mm =3D vma->vm_mm;
> +       pgd_t *pgd;
> +       pud_t *pud;
> +       pmd_t *pmd;
> +       pte_t *ptep;
> +       spinlock_t *ptl;
> +       unsigned long addr;
> +       int err =3D -EFAULT;
> +
> +       addr =3D page_address_in_vma(page, vma);
> +       if (addr =3D=3D -EFAULT)
> +               goto out;
> +
> +       pgd =3D pgd_offset(mm, addr);
> +       if (!pgd_present(*pgd))
> +               goto out;
> +
> +       pud =3D pud_offset(pgd, addr);
> +       if (!pud_present(*pud))
> +               goto out;
> +
> +       pmd =3D pmd_offset(pud, addr);
> +       if (pmd_trans_huge(*pmd) || (!pmd_present(*pmd)))
> +               goto out;
> +
> +       ptep =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
> +       if (!ptep)
> +               goto out;

Shouldn't we verify that the obtained pte does indeed refer to our @page
here?

> +       get_page(kpage);
> +       page_add_new_anon_rmap(kpage, vma, addr);
> +
> +       flush_cache_page(vma, addr, pte_pfn(*ptep));
> +       ptep_clear_flush(vma, addr, ptep);
> +       set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot=
));
> +
> +       page_remove_rmap(page);
> +       if (!page_mapped(page))
> +               try_to_free_swap(page);
> +       put_page(page);
> +       pte_unmap_unlock(ptep, ptl);
> +       err =3D 0;
> +
> +out:
> +       return err;
> +}=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
