Message-Id: <200603150403.k2F43Kg10964@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: BUG in x86_64 hugepage support
Date: Tue, 14 Mar 2006 20:03:20 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060315012000.GC5526@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Nishanth Aravamudan' <nacc@us.ibm.com>, agl@us.ibm.com, david@gibson.dropbear.id.au, ak@suse.de
Cc: linux-mm@kvack.org, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

Nishanth Aravamudan wrote on Tuesday, March 14, 2006 5:20 PM
> While doing some testing of libhugetlbfs, I ran into the following BUGs
> on my x86_64 box when checking mprotect with hugepages (running make
> func in libhugetlbfs is all it took here) (distro is Ubuntu Dapper, runs
> 32-bit userspace).
> 
> So, the first &= results in the lower 11 bits of pte_val(pte) being all
> 0s. By my analysis, this is the problem, pte_modify() on x86_64 is
> clearing the bits we check to see if a pte is a hugetlb one. To see if
> this might be an accurate analysis, I modified _PAGE_CHG_MASK as
> follows:
> 
> 	-#define _PAGE_CHG_MASK	(PTE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
> 	+#define _PAGE_CHG_MASK	(PTE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_PSE | _PAGE_PRESENT)
> 
> That is, forcing the bits we care about to get set in pte_modify(). This
> removed the BUG()s I was seeing in our testing.


I think your analysis looked correct.  Though I don't think you want to
add _PAGE_PRESENT to _PAGE_CHG_MASK.  The reason being newprot suppose
to have correct present bit (based on what the new protection is) and
it will be or'ed to form new pte.

I think _PAGE_PSE bit should be in _PAGE_CHG_MASK.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
