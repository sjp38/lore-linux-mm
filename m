Message-ID: <3DF0BAD4.946B1845@scs.ch>
Date: Fri, 06 Dec 2002 15:57:24 +0100
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Question on pte bits
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hello,

Looking at some memory managment functions in 2.4.18, I came accross the function follow_page, which is called by get_user_pages, to parse a processes page tables.

After getting the corresponding page table entry, the function makes a check, which I don't quite understand - if write access is requested to the page, it not only checks
the write permission in the page table entry (with pte_write()), but also the dirty bit (with pte_dirty()). Why does a page need to be dirty in the case write == 1 (see
line 444 in the code excerpt below?

Thanks in advance for any help
with best regards
Martin Maletinsky

P.S. Please put me on CC: in your reply, since I am not in the mailing list.

static struct page * follow_page(struct mm_struct *mm, unsigned long address, int write) 
425 {
426         pgd_t *pgd;
427         pmd_t *pmd;
428         pte_t *ptep, pte;
429 
430         pgd = pgd_offset(mm, address);
431         if (pgd_none(*pgd) || pgd_bad(*pgd))
432                 goto out;
433 
434         pmd = pmd_offset(pgd, address);
435         if (pmd_none(*pmd) || pmd_bad(*pmd))
436                 goto out;
437 
438         ptep = pte_offset_atomic(pmd, address);
439 
440         pte = *ptep;
441         pte_kunmap(ptep);
442         if (pte_present(pte)) {
443                 if (!write ||
444                     (pte_write(pte) && pte_dirty(pte)))
445                         return pte_page(pte);
446         }
447 
448 out:
449         return 0;
450 }


--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
