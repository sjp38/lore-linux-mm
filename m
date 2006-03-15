Message-Id: <4417E359.76F0.0078.0@novell.com>
Date: Wed, 15 Mar 2006 09:50:17 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [discuss] Re: BUG in x86_64 hugepage support
References: <20060315043544.GD5526@us.ibm.com> <200603150708.k2F78wg12642@unix-os.sc.intel.com> <20060315073046.GA5620@us.ibm.com>
In-Reply-To: <20060315073046.GA5620@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: david@gibson.dropbear.id.au, Kenneth W Chen <kenneth.w.chen@intel.com>, linux-mm@kvack.org, Andreas Kleen <ak@suse.de>, agl@us.ibm.com, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

>diff -urpN 2.6.16-rc6-mm1/mm/hugetlb.c 2.6.16-rc6-mm1-dev/mm/hugetlb.c
>--- 2.6.16-rc6-mm1/mm/hugetlb.c	2006-03-14 22:49:44.000000000 -0800
>+++ 2.6.16-rc6-mm1-dev/mm/hugetlb.c	2006-03-14 22:51:31.000000000 -0800
>@@ -740,6 +740,7 @@ void hugetlb_change_protection(struct vm
> 			continue;
> 		if (!pte_none(*ptep)) {
> 			pte = huge_ptep_get_and_clear(mm, address, ptep);
>+			pgprot_val(newprot) |= _PAGE_PSE;
> 			pte = pte_modify(pte, newprot);
> 			set_huge_pte_at(mm, address, ptep, pte);
> 			lazy_mmu_prot_update(pte);

This is architecture independent code - you shouldn't be using _PAGE_PSE here. Probably
x86-64 (and then likely also i386) should define their own set_huge_pte_at(), and use that#
to or in the needed flag?

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
