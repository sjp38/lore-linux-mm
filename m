Received: from localhost (sanket@localhost)
	by mailhub.cdac.ernet.in (8.11.4/8.11.4) with ESMTP id g4A5Uqg15734
	for <linux-mm@kvack.org>; Fri, 10 May 2002 11:00:53 +0530 (IST)
Date: Fri, 10 May 2002 11:00:52 +0530 (IST)
From: Sanket Rathi <sanket.rathi@cdac.ernet.in>
Subject: page table entries
Message-ID: <Pine.GSO.4.10.10205101049310.14865-100000@mailhub.cdac.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi
i have perform a test on page table entries. i allocate a buffer through
vmalloc in kernel module and travers page table through that returned
address. following is kernel module



int init_module(void)
{
    unsigned long address, phyadd, pfnum, ioadd;
    pgd_t *pgdp ;
    pmd_t *pmdp ;
    pte_t *ptep ;
    struct page *page_s ;
    printk("\n---------------Entering init_module.--------------------\n") ;

    address = (unsigned long) vmalloc (10) ;
    printk("\naddress=%lx", address) ;

    pgdp = pgd_offset_k(address) ;
    printk("\n\npgdp=%lx", (unsigned long) pgdp) ;
    printk("\npgd_val=%lx", pgd_val(*pgdp)) ;

    pmdp = pmd_offset(pgdp, address) ;
    printk("\n\npmdp=%lx", (unsigned long) pmdp) ;
    printk("\npmd_val=%lx", pmd_val(*pmdp)) ;

    ptep = pte_offset(pmdp, address) ;
    printk("\n\nptep=%lx", (unsigned long) ptep) ;
    printk("\npte_val=%lx", pte_val(*ptep)) ; 



    page_s = pte_page(*ptep) ;
    printk("\nkernel virtual  address=%lx",(unsigned long)
page_s->virtual) ;

    ioadd = virt_to_bus(page_s->virtual) ;
    printk("\nio address virt_to_bus=%lx", ioadd) ;

    printk("\n\n---------------Exiting init_module.------------------\n") ;

    return 0 ;
}



when i install the above module the output is as following


---------------Entering init_module.---------------------

address=c28d8000

pgdp=c0101c28
pgd_val=10af063

pmdp=c0101c28
pmd_val=10af063

ptep=c10af360
pte_val=1516063

kernel virtual  address=c1516000
io address virt_to_bus=1516000

---------------Exiting init_module.----------------------

The problem is i am not able to understand that why the pgd_val, pmd_val
and pte_val contain 0x63 in last two positions actually they are page
address so their last 3 position(in hex) should be zero like in io
address.
can somebody help me


Thanks in Advance


 --- Sanket Rathi

--------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
