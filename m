Received: from localhost (skumar@localhost)
	by hopper.unh.edu (8.11.1/8.11.1) with ESMTP id eAL6iRF461371
	for <linux-mm@kvack.org>; Tue, 21 Nov 2000 01:44:31 -0500 (EST)
Date: Tue, 21 Nov 2000 01:44:27 -0500 (EST)
From: Sunil Kumar <skumar@cisunix.unh.edu>
Subject: How to add a user buffer in page table
Message-ID: <Pine.OSF.4.21.0011210127200.434702-100000@hopper.unh.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All

I was trying to port a function written by me from linux 2.2.12 to
2.4-test9 version. The function put_dbuff_page_into_pt puts a
dedicated buffer into page table.

However I am facing problem since the mk_pte function in 2.2.12 was using
unisgned long as its first parameter and in test9 version mk_pte uses
struct page * as its parameter. 
Also there is no MAP_NR macro in test9. I guess its being replaced by
virt_to_page function in test9.

Here is my functin in 2.2.12 version. In this function get_empty_pgtable
is written by me.

static unsigned long put_dbuff_page_into_pt( struct task_struct *tsp,
                                                    unsigned long phy_addr
)
    {
    pte_t           *page_table;
    unsigned long   linear_address = TO_VIRTUAL(phy_addr);
    int             repeat = 10;
    unsigned long   new_phys = phy_addr;


    do  {/* calculating the position of the page table entry in page table
*/
        if( (page_table = get_empty_pgtable(tsp, linear_address)) == NULL
)
            {
            printk("put_dbuff_page_into_pt: Out of mem for pt.\n");
            return -1;
            }

        if( !pte_none(*page_table) )
            {
            printk("put_dbuff_page_into_pt: PTE_VAL = %lx\n",
		pte_val(*page_table));
            dirty_pages[dp_count] = linear_address;
            dp_count++;
            if(!(new_phys = __get_free_page(GFP_KERNEL)))
                {
                printk("put_dbuff_page_into_pt: No free pages.\n");
                return -1;
                }
            linear_address = TO_VIRTUAL(new_phys);
            repeat--;
            }
        else
            repeat = 0;
        } while(repeat);

    *page_table = mk_pte(new_phys, PAGE_SHARED);
    mem_map_reserve(MAP_NR(new_phys)); 
/*  printk("p_d: l_a=%x\n", linear_address);  */

    return new_phys;
	
    } 
    /* end of function */


If anybody has any clue how to modify the mk_pte function. In 2.2.12
version new_phys was an unsigned long, but in test9 version it expects it
to struct page *.

I guess MAP_NR is to replaced by virt_to_page.


thanks 

Sunil Kumar
Dept of Computer Science
U of New Hampshire
Email:	skumar@cs.unh.edu
Voice:	603-862-0701 (O)
	    295-4618 (R)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
