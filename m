Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts40-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080716144009.GANX1625.tomts40-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Wed, 16 Jul 2008 10:40:09 -0400
Date: Wed, 16 Jul 2008 10:40:08 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 10/17] LTTng instrumentation - swap
Message-ID: <20080716144008.GG24546@Krystal>
References: <20080715222604.331269462@polymtl.ca> <20080715222748.214360024@polymtl.ca> <1216197576.5232.27.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1216197576.5232.27.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Masami Hiramatsu <mhiramat@redhat.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, "Frank Ch. Eigler" <fche@redhat.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra (peterz@infradead.org) wrote:
> On Tue, 2008-07-15 at 18:26 -0400, Mathieu Desnoyers wrote:
> > plain text document attachment (lttng-instrumentation-swap.patch)
> > Instrumentation of waits caused by swap activity. Also instrumentation
> > swapon/swapoff events to keep track of active swap partitions.
> > 
> > Those tracepoints are used by LTTng.
> > 
> > About the performance impact of tracepoints (which is comparable to markers),
> > even without immediate values optimizations, tests done by Hideo Aoki on ia64
> > show no regression. His test case was using hackbench on a kernel where
> > scheduler instrumentation (about 5 events in code scheduler code) was added.
> > See the "Tracepoints" patch header for performance result detail.
> > 
> > Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> > CC: linux-mm@kvack.org
> > CC: Dave Hansen <haveblue@us.ibm.com>
> > CC: Masami Hiramatsu <mhiramat@redhat.com>
> > CC: 'Peter Zijlstra' <peterz@infradead.org>
> > CC: "Frank Ch. Eigler" <fche@redhat.com>
> > CC: 'Ingo Molnar' <mingo@elte.hu>
> > CC: 'Hideo AOKI' <haoki@redhat.com>
> > CC: Takashi Nishiie <t-nishiie@np.css.fujitsu.com>
> > CC: 'Steven Rostedt' <rostedt@goodmis.org>
> > CC: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> > ---
> >  include/trace/swap.h |   20 ++++++++++++++++++++
> >  mm/memory.c          |    2 ++
> >  mm/page_io.c         |    2 ++
> >  mm/swapfile.c        |    4 ++++
> >  4 files changed, 28 insertions(+)
> > 
> > Index: linux-2.6-lttng/mm/memory.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/memory.c	2008-07-15 13:54:46.000000000 -0400
> > +++ linux-2.6-lttng/mm/memory.c	2008-07-15 14:02:54.000000000 -0400
> > @@ -51,6 +51,7 @@
> >  #include <linux/init.h>
> >  #include <linux/writeback.h>
> >  #include <linux/memcontrol.h>
> > +#include <trace/swap.h>
> >  
> >  #include <asm/pgalloc.h>
> >  #include <asm/uaccess.h>
> > @@ -2213,6 +2214,7 @@ static int do_swap_page(struct mm_struct
> >  		/* Had to read the page from swap area: Major fault */
> >  		ret = VM_FAULT_MAJOR;
> >  		count_vm_event(PGMAJFAULT);
> > +		trace_swap_in(page, entry);
> >  	}
> >  
> >  	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> > Index: linux-2.6-lttng/mm/page_io.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/page_io.c	2008-07-15 13:54:46.000000000 -0400
> > +++ linux-2.6-lttng/mm/page_io.c	2008-07-15 14:02:54.000000000 -0400
> > @@ -17,6 +17,7 @@
> >  #include <linux/bio.h>
> >  #include <linux/swapops.h>
> >  #include <linux/writeback.h>
> > +#include <trace/swap.h>
> >  #include <asm/pgtable.h>
> >  
> >  static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
> > @@ -114,6 +115,7 @@ int swap_writepage(struct page *page, st
> >  		rw |= (1 << BIO_RW_SYNC);
> >  	count_vm_event(PSWPOUT);
> >  	set_page_writeback(page);
> > +	trace_swap_out(page);
> >  	unlock_page(page);
> >  	submit_bio(rw, bio);
> >  out:
> > Index: linux-2.6-lttng/mm/swapfile.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/swapfile.c	2008-07-15 13:54:46.000000000 -0400
> > +++ linux-2.6-lttng/mm/swapfile.c	2008-07-15 14:02:54.000000000 -0400
> > @@ -32,6 +32,7 @@
> >  #include <asm/pgtable.h>
> >  #include <asm/tlbflush.h>
> >  #include <linux/swapops.h>
> > +#include <trace/swap.h>
> >  
> >  DEFINE_SPINLOCK(swap_lock);
> >  unsigned int nr_swapfiles;
> > @@ -1310,6 +1311,7 @@ asmlinkage long sys_swapoff(const char _
> >  	swap_map = p->swap_map;
> >  	p->swap_map = NULL;
> >  	p->flags = 0;
> > +	trace_swap_file_close(swap_file);
> >  	spin_unlock(&swap_lock);
> >  	mutex_unlock(&swapon_mutex);
> >  	vfree(swap_map);
> > @@ -1695,6 +1697,7 @@ asmlinkage long sys_swapon(const char __
> >  	} else {
> >  		swap_info[prev].next = p - swap_info;
> >  	}
> > +	trace_swap_file_open(swap_file, name);
> >  	spin_unlock(&swap_lock);
> >  	mutex_unlock(&swapon_mutex);
> >  	error = 0;
> > @@ -1796,6 +1799,7 @@ get_swap_info_struct(unsigned type)
> >  {
> >  	return &swap_info[type];
> >  }
> > +EXPORT_SYMBOL_GPL(get_swap_info_struct);
> 
> I'm not too happy with this export.
> 

Would it make more sense to turn get_swap_info_struct into a static
inline in swap.h ?

Mathieu

> >  
> >  /*
> >   * swap_lock prevents swap_map being freed. Don't grab an extra
> > Index: linux-2.6-lttng/include/trace/swap.h
> > ===================================================================
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ linux-2.6-lttng/include/trace/swap.h	2008-07-15 14:02:54.000000000 -0400
> > @@ -0,0 +1,20 @@
> > +#ifndef _TRACE_SWAP_H
> > +#define _TRACE_SWAP_H
> > +
> > +#include <linux/swap.h>
> > +#include <linux/tracepoint.h>
> > +
> > +DEFINE_TRACE(swap_in,
> > +	TPPROTO(struct page *page, swp_entry_t entry),
> > +	TPARGS(page, entry));
> > +DEFINE_TRACE(swap_out,
> > +	TPPROTO(struct page *page),
> > +	TPARGS(page));
> > +DEFINE_TRACE(swap_file_open,
> > +	TPPROTO(struct file *file, char *filename),
> > +	TPARGS(file, filename));
> > +DEFINE_TRACE(swap_file_close,
> > +	TPPROTO(struct file *file),
> > +	TPARGS(file));
> > +
> > +#endif
> > 
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
