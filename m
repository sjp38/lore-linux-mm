Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDCD56B0038
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 09:00:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y90so26509767wrb.1
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 06:00:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o49si22925168wrc.144.2017.03.20.06.00.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Mar 2017 06:00:54 -0700 (PDT)
Date: Mon, 20 Mar 2017 14:00:52 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening
 printks
Message-ID: <20170320130052.GA4008@pathway.suse.cz>
References: <cover.1489628459.git.joe@perches.com>
 <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
 <20170316113056.GG464@jagdpanzerIV.localdomain>
 <1489689476.13953.3.camel@perches.com>
 <20170317015600.GA426@jagdpanzerIV.localdomain>
 <1489865495.13953.19.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489865495.13953.19.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>

On Sat 2017-03-18 12:31:35, Joe Perches wrote:
> (adding Petr and Steven to cc's)
> 
> On Fri, 2017-03-17 at 10:56 +0900, Sergey Senozhatsky wrote:
> > On (03/16/17 11:37), Joe Perches wrote:
> > > On Thu, 2017-03-16 at 20:30 +0900, Sergey Senozhatsky wrote:
> > > > On (03/15/17 18:43), Joe Perches wrote:
> > > > [..]
> > > > > -	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
> > > > > -		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> > > > > -		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
> > > > > -		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> > > > > -		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
> > > > > -		" free:%lu free_pcp:%lu free_cma:%lu\n",
> > > > > -		global_node_page_state(NR_ACTIVE_ANON),
> > > > > -		global_node_page_state(NR_INACTIVE_ANON),
> > > > > -		global_node_page_state(NR_ISOLATED_ANON),
> > > > > -		global_node_page_state(NR_ACTIVE_FILE),
> > > > > -		global_node_page_state(NR_INACTIVE_FILE),
> > > > > -		global_node_page_state(NR_ISOLATED_FILE),
> > > > > -		global_node_page_state(NR_UNEVICTABLE),
> > > > > -		global_node_page_state(NR_FILE_DIRTY),
> > > > > -		global_node_page_state(NR_WRITEBACK),
> > > > > -		global_node_page_state(NR_UNSTABLE_NFS),
> > > > > -		global_page_state(NR_SLAB_RECLAIMABLE),
> > > > > -		global_page_state(NR_SLAB_UNRECLAIMABLE),
> > > > > -		global_node_page_state(NR_FILE_MAPPED),
> > > > > -		global_node_page_state(NR_SHMEM),
> > > > > -		global_page_state(NR_PAGETABLE),
> > > > > -		global_page_state(NR_BOUNCE),
> > > > > -		global_page_state(NR_FREE_PAGES),
> > > > > -		free_pcp,
> > > > > -		global_page_state(NR_FREE_CMA_PAGES));
> []
> > > > > a side note:
> > > > 
> > > > this can make it harder to read, in _the worst case_. one printk()
> > > > guaranteed that we would see a single line in the serial log/etc.
> > > > the sort of a problem with multiple printks is that printks coming
> > > > from other CPUs will split that "previously single" line.
> > > 
> > > Not true.  Note the multiple \n uses in the original code.
> > 
> > one printk call ends up in logbuf as a single entry and, thus, we print
> > it to the serial console in one shot (what is the correct english word
> > to use here?). multiple printks result in multiple logbuf entries, and
> > printks from other CPUs can mix in.
> > 
> > so the difference is:
> > 
> > 
> > 	CPU0						CPU1
> > 							printk(foo\n)
> > printk(..isolated_anon\n...isolated_file\n...)
> > 							printk(bar\n)
> > 
> > vs
> > 
> > 	CPU0						CPU1
> > printk(..isolated_anon\n)
> > 							printk(foo\n)
> > printk(...isolated_file\n)
> > 							printk(bar\n)
> > printk(...\n)
> > 
> > not the same thing.
> > 
> > and the slower the serial console is the more messages potentially
> > can appear between "..isolated_anon\n" and "...isolated_file\n".
> 
> Right.  For the definition of "single line", meaning "contiguous
> block" and not single line.
> 
> Perhaps there would be some value in having a generic mechanism
> for the dump_stack use of "atomic_t dump_lock", where a thread
> can grab exclusive use of the printk subsystem for a short period
> to keep messages from being interleaved by other processes.

This sounds a bit scary to me. A globally blocking chain of
printk() calls might open another can of deadlocks. Also, IMHO,
dumping stack is a non-trivial operation, especially when
we need to read debuginfo.

Another solution would be to somehow reuse the per-CPU buffers
used by vprintk_safe(). An API for buffering printk messages
would be useful also for continuous lines. But this need to
be well designed.

Anyway, this should probably be discussed separately. We are too
far from the original problem. The fact is that printk() does
not prevent interleaving lines from different CPUs and probably
won't be in a near future. I am not sure in which situations
the affected messages are printed and if such an interleaving
is probable or not.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
