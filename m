Received: from localhost (riel@localhost)
	by brutus.conectiva.com.br (8.11.1/8.11.1) with ESMTP id eAHFA4e01301
	for <linux-mm@kvack.org>; Fri, 17 Nov 2000 13:10:08 -0200
Message-ID: <3A146EDA.36D1F9C4@redhat.com>
Date: Thu, 16 Nov 2000 18:33:46 -0500
From: Bob Matthews <bmatthews@redhat.com>
MIME-Version: 1.0
Subject: Hung kswapd (2.4.0-t11p5)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.21.0011171310020.371@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: johnsonm@redhat.com
List-ID: <linux-mm.kvack.org>

Rik,

Al Viro suggested I send this bug report to you.  We're running some
heavy duty kernel stress tests and have been able to cook up a case
which reliably locks up the machine, and has done so on every 2.4.0
kernel we've tried.  No OOPS is generated.

Machine:  8 x PIII, 550Mhz, 8GB
Config: 2.4.0-test11-p5, 64GB Himem support, 8 x 128MB swap partitions
all pri=0

We run 5 parallel 'memtst' processes.  Each memtst malloc's 1900 MB of
memory and then steps through it writing 0xaaaaaaaa + i at mem[i].  It
then verifies what was written and repeats the process.

The lockup occurs very soon after the machine first dips in to swap
(according to /usr/bin/top.)

According to sysrq, most of the processes are waiting here:

(gdb) list *0xc0131d10
0xc0131d10 is in wakeup_kswapd (vmscan.c:1137).
1132	
1133		if (waitqueue_active(&kswapd_wait))
1134			wake_up(&kswapd_wait);
1135		schedule();
1136	
1137		remove_wait_queue(&kswapd_done, &wait);
1138		__set_current_state(TASK_RUNNING);
1139	}
1140	
1141	/*

kswapd itself appears to be stuck here:

(gdb) list *0xc01394c2
0xc01394c2 is in create_buffers (buffer.c:1240).
1235	
1236		/* 
1237		 * Set our state for sleeping, then check again for buffer heads.
1238		 * This ensures we won't miss a wake_up from an interrupt.
1239		 */
1240		wait_event(buffer_wait, nr_unused_buffer_heads >=
MAX_BUF_PER_PAGE);
1241		goto try_again;
1242	}
1243	
1244	static int create_page_buffers(int rw, struct page *page, kdev_t
dev, int b[], int size)

I threw a show_stack into the sysreq-T code and got this stack
traceback:

(gdb) list *0xc0139535
0xc0139535 is in create_page_buffers (buffer.c:1257).
1252		 * Allocate async buffer heads pointing to this page, just for
I/O.
1253		 * They don't show up in the buffer hash table, but they *are*
1254		 * registered in page->buffers.
1255		 */
1256		head = create_buffers(page, size, 1);
1257		if (page->buffers)
1258			BUG();
1259		if (!head)
1260			BUG();
1261		tail = head;
(gdb) list *0xc013ac6b
0xc013ac6b is in brw_page (buffer.c:2091).
2086		 * create_page_buffers() might sleep.
2087		 */
2088		fresh = 0;
2089		if (!page->buffers) {
2090			create_page_buffers(rw, page, dev, b, size);
2091			fresh = 1;
2092		}
2093		if (!page->buffers)
2094			BUG();
2095	
(gdb) list *0xc0131f56
0xc0131f56 is in rw_swap_page_base (page_io.c:89).
84	
85	 	/* Note! For consistency we do all of the logic,
86	 	 * decrementing the page count, and unlocking the page in the
87	 	 * swap lock map - in the IO completion handler.
88	 	 */
89	 	if (!wait)
90	 		return 1;
91	
92	 	wait_on_page(page);
93		/* This shouldn't happen, but check to be sure. */
(gdb) list *0xc01300e5
0xc01300e5 is in lru_cache_add (swap.c:263).
258			BUG();
259		DEBUG_ADD_PAGE
260		add_page_to_active_list(page);
261		/* This should be relatively rare */
262		if (!page->age)
263			deactivate_page_nolock(page);
264		spin_unlock(&pagemap_lru_lock);
265	}
266	
267	/**
(gdb) list *0xc01289bc
0xc01289bc is in add_to_page_cache_locked
(/usr/src/linux/include/asm/spinlock.h:94).
89			spin_lock_string
90			:"=m" (lock->lock) : : "memory");
91	}
92	
93	static inline void spin_unlock(spinlock_t *lock)
94	{
95	#if SPINLOCK_DEBUG
96		if (lock->magic != SPINLOCK_MAGIC)
97			BUG();
98		if (!spin_is_locked(lock))
(gdb) list *0xc0132027
0xc0132027 is in rw_swap_page (page_io.c:119).
114			PAGE_BUG(page);
115		if (!PageSwapCache(page))
116			PAGE_BUG(page);
117		if (page->mapping != &swapper_space)
118			PAGE_BUG(page);
119		if (!rw_swap_page_base(rw, entry, page, wait))
120			UnlockPage(page);
121	}
122	
123	/*
(gdb) list *0xc01305db
0xc01305db is in try_to_swap_out (vmscan.c:205).
200		set_pte(page_table, swp_entry_to_pte(entry));
201		spin_unlock(&mm->page_table_lock);
202	
203		/* OK, do a physical asynchronous write to swap.  */
204		rw_swap_page(WRITE, page, 0);
205		deactivate_page(page);
206	
207	out_free_success:
208		page_cache_release(page);
209		return 1;
(gdb) list *0xc01307f5
0xc01307f5 is in swap_out_vma (vmscan.c:259).
254		do {
255			int result;
256			mm->swap_address = address + PAGE_SIZE;
257			result = try_to_swap_out(mm, vma, address, pte, gfp_mask);
258			if (result)
259				return result;
260			if (!mm->swap_cnt)
261				return 0;
262			address += PAGE_SIZE;
263			pte++;

It's not clear to me whether the swapper is hung here, or if the sysrq-T
is always catching it at the same place, but the machine is pretty much
useless at this point.  We are also seeing another symptom which may be
related.  Just before the lockup, the console fills with "alloc_page:
0-order allocation failed" messages.  I throttled these back to print
just 1 out of every 100,000 messages.  We typically get several hundred
thousand before the lock up.

If I can provide any more information to you, please don't hesitate to
contact me.

Bob

-- 
Bob Matthews
Red Hat, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
