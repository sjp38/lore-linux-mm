Date: Mon, 2 Aug 1999 18:13:45 -0600 (CST)
From: Kamran Karimi <karimi@cs.uregina.ca>
Subject: Problem swapping out ipc shm pages
Message-ID: <Pine.SGI.3.91.990802181304.18420A-100000@MERCURY.CS.UREGINA.CA>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

 I need to swap out specific pages of an ipc shared memory segment. I 
used to modify the routine shm_swap() in file ipc/shm.c for this. The 
modifications involved changing the segment and page selection code, so 
the new routine would operate on intended pages.

 In recent kernel versions shm_swap has changed considerably. A lot of 
the iteration code (and also the flush_cache_page() and flush_tlb_page()) 
has disappeared. I still tried to get the same effects by modifying 
shm_swap, but failed. 

 Is am providing the code I have tentatively written (and does not work). 
What should be done to make it work?

 Any help is appreciated.

-Kamran

/* this routine swaps out relevant parts of a shared memory. This was 
   constructed by doing some cut and paste on shm_swap. I hope this is 
   done the right way! 

   Depending on the value of dipc_page_size, we may want to swap out more 
than one page.

id: determines the shared memory segment

offset: is an address in the page we want to swap out. We may want to swap 
out the whole segment, in which case we ignore this value 

mode: tell the routine if we want to swap out the whole segment 
*/ 
int dipc_swap_out (int id, int offset, int mode)
{
	pte_t page;
	struct shmid_kernel *shp;
	struct vm_area_struct *shmd=NULL;
	unsigned int swap_nr;
	unsigned long idx;
	int start, end;

	/**printk("dipc_swap_out(%d, %d, %d)\n",id, offset, mode);*/
	shp = shm_segs[id];
	/* no regard for locked shared memories! */
	if(shp == IPC_UNUSED || shp == IPC_NOID)
		return DIPC_FAIL;

	if(mode == SEGMENT) {
		start = 0;
		end = shp->shm_npages;
	}
	else {	
		start = offset / PAGE_SIZE;
		start = start - start % (dipc_page_size / PAGE_SIZE);
		end = start + dipc_page_size / PAGE_SIZE;
		if(end > shp->shm_npages)
			end = shp->shm_npages;
	}
	for(idx = start; idx < end; idx++) { 
		if(!(swap_nr = get_swap_page()))
			return DIPC_FAIL;	
			
		page = __pte(shp->shm_pages[idx]);
		if (!pte_present(page))
			continue;
		
		/* don't have access to gfp_mask arg */
		/*if ((gfp_mask & __GFP_DMA) && !PageDMA(&mem_map[MAP_NR(pte_page(page))]))
			goto check_table;*/

		swap_attempts++;

		/*if (--counter < 0) {
			failed:
			swap_free (swap_nr);
			return 0;
		}*/
			
		/*if (atomic_read(&mem_map[MAP_NR(pte_page(page))].count) != 1)
			goto check_table;*/
		shp->shm_pages[idx] = swap_nr;
		rw_swap_page_nocache (WRITE, swap_nr, (char *) pte_page(page));
		free_page(pte_page(page));
		swap_successes++;
		shm_swp++;
		shm_rss--;
	} /* for idx ... */	
	return DIPC_SUCCESS;
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
