Date: Sun, 19 May 2002 14:28:40 +0530
From: Abhishek Nayani <abhi@kernelnewbies.org>
Subject: working of balance_classzone()
Message-ID: <20020519085840.GA3660@SandStorm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

	I was commenting the code of balance_classzone() and am stuck up
at some point. The code in question is:

	if (likely(__freed)) {
	/* pick from the last inserted so we're lifo */
		entry = local_pages->next;
		do {
		     tmp = list_entry(entry, struct page, list);
---->>		     if (tmp->index == order && memclass(page_zone(tmp), classzone)) {
				list_del(entry);
				current->nr_local_pages--;
				set_page_count(tmp, 1);
				page = tmp;
				.................


	According to the code of __free_pages_ok(), when we try to free
pages with PF_FREE_PAGES set (as is done in balance_classzone() before
the call to try_to_free_pages()) only one block of pages of some order
is added to the local_pages member of the current task. Also
nr_local_pages is 1 if there is a block of pages else it is 0 (ie. being
used as a flag).

[related code: local_freelist:
	           if (current->nr_local_pages)
	                goto back_local_freelist;]



	So the code in balance_classzone() looks very suspicious as it
is acting as if there were many blocks of free pages of different orders
on the list and we are trying to get the block of the correct order and
then freeing the rest in reverse order.... 

	Since there is only one block, we can cut the code to just check
the order of that block, if its greater than our requirement, call
rmqueue() else return NULL. 

	If i am missing something or u've not understood my doubt,
please let me know...


					Bye,
						Abhi.
	
--------------------------------------------------------------------------
"I can only show you the door, you have to walk through it..." - Morpheus
--------------------------------------------------------------------------
Home Page: http://www.abhi.tk
-----BEGIN GEEK CODE BLOCK------------------------------------------------
GCS d+ s:- a-- C+++ UL P+ L+++ E- W++ N+ o K- w--- O-- M- V- PS PE Y PGP 
t+ 5 X+ R- tv+ b+++ DI+ D G e++ h! !r y- 
------END GEEK CODE BLOCK-------------------------------------------------

----- End forwarded message -----
					Bye,
						Abhi.
	
--------------------------------------------------------------------------
"I can only show you the door, you have to walk through it..." - Morpheus
--------------------------------------------------------------------------
Home Page: http://www.abhi.tk
-----BEGIN GEEK CODE BLOCK------------------------------------------------
GCS d+ s:- a-- C+++ UL P+ L+++ E- W++ N+ o K- w--- O-- M- V- PS PE Y PGP 
t+ 5 X+ R- tv+ b+++ DI+ D G e++ h! !r y- 
------END GEEK CODE BLOCK-------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
