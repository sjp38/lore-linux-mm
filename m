Date: Sun, 31 Jul 2005 07:09:00 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
Message-ID: <20050731120900.GE2254@lnx-holt.americas.sgi.com>
References: <20050730205319.GA1233@lnx-holt.americas.sgi.com> <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com> <42EC2ED6.2070700@yahoo.com.au> <20050731105234.GA2254@lnx-holt.americas.sgi.com> <42ECB0EC.4000808@yahoo.com.au> <20050731113059.GC2254@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050731113059.GC2254@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just for good measure, I added some counters to the do_no_page
and tweaked my earlier a little.  I made the check look more like:

                atomic64_inc(&do_no_page_collisions);
                if (write_access && !pte_write(*page_table)) {
                        ret=VM_FAULT_RACE;
                        atomic64_inc(&do_no_page_asked_write_got_read);
                }

After running the system for a while, I looked at the counters,
for the 1162 collisions I had, the write_got_read only incremented
4 times.  I am running a customer test program.  Don't really know
what it does, but I believe it is dealing with a large preinitialized
data block which they DIO write data from a file into various areas
of the block at the same time as other threads are reading through
the pages looking for work to do.

During normal run, without their application, I have not seen the
do_no_page_asked_write_got_read increment in the more than 1/2 hour
of run time.

So far, I think the case for setting VM_FAULT_RACE only when there
is a conflict for writable seems strong.

Thanks,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
