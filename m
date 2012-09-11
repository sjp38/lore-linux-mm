Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 81CB86B00BE
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 07:10:46 -0400 (EDT)
Received: from csmailer.cs.nctu.edu.tw (localhost [127.0.0.1])
	by csmailer.cs.nctu.edu.tw (Postfix) with ESMTP id 510399BE
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 19:10:45 +0800 (CST)
Received: from alumni.cs.nctu.edu.tw (alumni.cs.nctu.edu.tw [140.113.235.116])
	by csmailer.cs.nctu.edu.tw (Postfix) with ESMTP id 84AEA9BD
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 19:10:29 +0800 (CST)
Received: (from chenwj@localhost)
	by alumni.cs.nctu.edu.tw (8.14.4/8.14.4/Submit) id q8BB9dQY050143
	for linux-mm@kvack.org; Tue, 11 Sep 2012 19:09:39 +0800 (CST)
	(envelope-from chenwj)
Date: Tue, 11 Sep 2012 19:09:39 +0800
From: =?utf-8?B?6Zmz6Z+L5Lu7IChXZWktUmVuIENoZW4p?= <chenwj@iis.sinica.edu.tw>
Subject: What else need to be done if we allocate phys page manually?
Message-ID: <20120911110939.GA49608@cs.nctu.edu.tw>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

  Please let me explain what I am trying to do first. First, I compile
a 64 bit binary so that it'll be loaded above 4G virtual space, so the
virtual space below 4G is empty. I want to make a virtual address below
4G share the same phys page with another virtual address above 4G, so
that read/write vadd1 just like vaddr2.=20


               PGD/PUD/PMD       Page Table
                                 ----------             Phys Page 2
                                |          |             --------
                                |----------|            |        |
                     vaddr2     |   pte 2  | ---------> |        |
                                |----------|            |        |
                                |          |             --------
                                |          |                ^
  4G above                      |          |                |
 ---------------------------------------------              |
                                |          |                |
                                |          |                |
                                |----------|                |
                     vaddr1     |   pte 1  | ---------------
                                |----------|           =20
                                |          |           =20
                                |__________|


Currently, I choose to manually create PUD/PMD/PT associated with vaddr1
, and set pte1 to point to phys page 2 (you can see the attach example
syscall, vadd1 is fixed to 0x10000000 for simplicity). However, the page
I create for PMD in the example will cause memory leak (see below). What
is the proper way to do so that kernel can free the page I allocated
automatically when the application calling the syscall is terminated?

    pmd =3D pmd_offset(pud, vaddr);
    if(pmd_none(*pmd)) {
        page =3D pte_alloc_one(current->mm, vaddr);
        pmd_n =3D mk_pmd(page, pgprot);
        set_pmd(pmd, pmd_n);
    }
=20
  Thanks!

Regards,
chenwj

--=20
Wei-Ren Chen (=E9=99=B3=E9=9F=8B=E4=BB=BB)
Computer Systems Lab, Institute of Information Science,
Academia Sinica, Taiwan (R.O.C.)
Tel:886-2-2788-3799 #1667
Homepage: http://people.cs.nctu.edu.tw/~chenwj

--IJpNTDwzlM2Ie8A6
Content-Type: text/x-csrc; charset=utf-8
Content-Disposition: attachment; filename="syscall.c"

#include <linux/mm.h>
#include <linux/mm_types.h>
#include <linux/sched.h>
#include <asm/pgalloc.h>
#include <asm/tlbflush.h>

// vaddr_h: vaddr above 4G
long sys_set_pte(unsigned long vaddr_h)
{
    unsigned long vaddr = 0x10000000 | (vaddr_h & 0xfff); // make vaddr's pte point to vaddr_h's phys page
    // vaddr and vaddr_h shares the same pgd and pud, need to creat pmd and page table
    pgd_t *pgd;
    pud_t *pud;
    pmd_t *pmd, pmd_n; // pmd_n is for vaddr
    pte_t *pte, *pte_h;
    struct page *page;
    pgprot_t pgprot;
    
    // get vaddr_h's physical page
    pgd = pgd_offset(current->mm, vaddr_h);
    pud = pud_offset(pgd, vaddr_h);
    pmd = pmd_offset(pud, vaddr_h);
    pgprot = __pgprot(pmd_val(*pmd) & 0xfff); // we copy vaddr_h's pmd permission to vaddr's pmd
    pte_h = pte_offset_map(pmd, vaddr_h);
    
    // mapping vaddr_h above 4G to vaddr below 4G alloc page entry
    pgd = pgd_offset(current->mm, vaddr);
    if (pgd_none(*pgd)) {
        printk("pgd entry not found, alloc new pud and set pgd entry\n");
        pgd = pgd_alloc(current->mm);
    }

    pud = pud_offset(pgd, vaddr);
    if(pud_none(*pud)) {
        printk("pud entry not found, alloc new pmd and set pud entry\n");
        pud = pud_alloc(current->mm, pgd, vaddr);
    }
    
    pmd = pmd_offset(pud, vaddr);
    if(pmd_none(*pmd)) {
        printk("pmd entry not found, alloc new pte and set pmd entry\n");
        page = pte_alloc_one(current->mm, vaddr); // allocate pte, i.e., page table
        pmd_n = mk_pmd(page, pgprot); // make a new pmd entry which ponits to page with pgprot permission
        set_pmd(pmd, pmd_n); // replace old pmd entry (pmd) with a new one (pmd_n)
    }

    // pte = page table entry
    pte = pte_offset_map(pmd, vaddr);

    // replace vaddr page table entry (pte) with vaddr_h's one (*pte_h)
    set_pte(pte, *pte_h);
}

--IJpNTDwzlM2Ie8A6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
