Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7ACA55F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 20:10:23 -0400 (EDT)
Date: Tue, 7 Apr 2009 19:10:29 -0500
From: Russ Anderson <rja@sgi.com>
Subject: [PATCH 0/2] Migrate data off physical pages with corrected memory errors
Message-ID: <20090408001029.GA27170@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
Cc: Russ Anderson <rja@sgi.com>
List-ID: <linux-mm.kvack.org>

Purpose:

	Physical memory with corrected errors may decay over time into
	uncorrectable errors.  The purpose of this patch is to move the
	data off pages with correctable memory errors before the memory
	goes bad.

	This patch set applies on top of Andi Kleen's POISON patch set.

The patches:

  [1/2] Avoid putting a bad page back on the LRU.

	Avoid putting a bad page back on the LRU after migrating the
	data to a new page.  The reference count on the bad page is
	not decremented to zero to avoid it being reallocated.

  [2/3] Call migration code on correctable errors

	This patch has ia64 specific changes.  It connects the CPE
	handler to the page migration code.  It is implemented as a kernel
	loadable module, similar to the mca recovery code (mca_recovery.ko),
	so that it can be removed to turn off the feature.  Create
	/sys/kernel/badram to print page discard information and to free
	bad pages.

Comments:

	There is always an issue of how agressive the code should be on
	migrating pages.  This patch uses /sys/firmware/badram/migrate_threshold
	to adjust the number of correctable errors before migrating a 
	page.

	Only pages that can be isolated on the LRU are migrated.  Other
	pages, such as compound pages, are not migrated.  That functionality
	could be a future enhancement.

	/sys/kernel/badram/bad_pages is used to display information about
	the bad memory.  The interface can be used to free pages marked bad.

Sample output:

	This is sample output from a system with a DIMM that has correctable
	errors at many addresses.

	linux> ls /sys/firmware/badram/
	bad_pages  cmc_polling_threshold  cpe_polling_threshold  migrate_threshold

	linux> cat /sys/firmware/badram/bad_pages
	Memory marked bad:        704 kB
	Pages marked bad:         11
	Unable to isolate on LRU: 1
	Unable to migrate:        0
	Already marked bad:       2
	Already on list:          0
	List of bad physical pages
 	  0x06871110000 0x06014820000 0x26003b20000 0x26005380000 0x26005390000
 	  0x260053a0000 0x260053b0000 0x260052f0000 0x26004bf0000 0x26004af0000
 	  0x26005330000


		// Free one of the pages
	linux> echo 0x06014820000 > /sys/firmware/badram/bad_pages

		// 10 pages remain on the list
	linux> cat /sys/firmware/badram/bad_pages
	Memory marked bad:        640 kB
	Pages marked bad:         10
	Unable to isolate on LRU: 1
	Unable to migrate:        0
	Already marked bad:       2
	Already on list:          0
	List of bad physical pages
 	  0x06871110000 0x26003b20000 0x26005380000 0x26005390000 0x260053a0000
 	  0x260053b0000 0x260052f0000 0x26004bf0000 0x26004af0000 0x26005330000

		// Free all the bad pages
	linux> echo 0 > /sys/firmware/badram/bad_pages

		// All the pages are freed
	linux> cat /sys/firmware/badram/bad_pages
	Memory marked bad:        0 kB
	Pages marked bad:         0
	Unable to isolate on LRU: 1
	Unable to migrate:        0
	Already marked bad:       2
	Already on list:          0
	List of bad physical pages



Flow of the code description (while testing on IA64):

	1) A user level application test program allocates memory and
	   passes the virtual address of the memory to the error injection
	   driver.

	2) The error injection driver converts the virtual address to
	   physical, functions the Altix hardware to modify the ECC for the
	   physical page, creating a correctable error, and returns to the
	   user application.

	3) The user application reads the memory.

	4) The Altix hardware detects the correctable error and interrupts
	   prom.  SAL builds a CPU error record, then sends a CPE 
	   interrupt to linux.

	5) The linux CPE handler calls the cpe_migrate module (if installed).

	6) cpe_setup_migrate parses the physical address from the CPE record
	   and adds the address to the migrate list (if not already on the
	   list) and wakes up a kernel thread (cpe_process_queue).

	7) cpe_process_queue checks if the threshold has been exceeded and 
	   calls ia64_mca_cpe_move_page.

	8) ia64_mca_cpe_move_page validates the physical address, converts
	   to page, sets PG_memerror flag and calls the migration code
	   (migrate_prep(), isolate_lru_page(), and migrate_pages().  If the
	   page migrates successfully, the bad page is added to badpagelist.

	9) Because PG_Poison is set, the bad page is not added back on the LRU
	   by avoiding calls to move_to_lru().  Avoiding move_to_lru() prevents
	   the page count from being decremented to zero.

	10) If the page fails to migrate, PG_Poison is cleared and the page 
	   returned to the LRU.  If another correctable error occurs on the
	   page another attempt will be made to migrate it.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
