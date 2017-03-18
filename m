Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C8DEB6B0038
	for <linux-mm@kvack.org>; Sat, 18 Mar 2017 15:31:49 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 76so83230128itj.0
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 12:31:49 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0029.hostedemail.com. [216.40.44.29])
        by mx.google.com with ESMTPS id t8si5842830ith.88.2017.03.18.12.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Mar 2017 12:31:49 -0700 (PDT)
Message-ID: <1489865495.13953.19.camel@perches.com>
Subject: Re: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening
 printks
From: Joe Perches <joe@perches.com>
Date: Sat, 18 Mar 2017 12:31:35 -0700
In-Reply-To: <20170317015600.GA426@jagdpanzerIV.localdomain>
References: <cover.1489628459.git.joe@perches.com>
	 <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
	 <20170316113056.GG464@jagdpanzerIV.localdomain>
	 <1489689476.13953.3.camel@perches.com>
	 <20170317015600.GA426@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>

(adding Petr and Steven to cc's)

On Fri, 2017-03-17 at 10:56 +0900, Sergey Senozhatsky wrote:
> On (03/16/17 11:37), Joe Perches wrote:
> > On Thu, 2017-03-16 at 20:30 +0900, Sergey Senozhatsky wrote:
> > > On (03/15/17 18:43), Joe Perches wrote:
> > > [..]
> > > > -	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
> > > > -		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> > > > -		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
> > > > -		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> > > > -		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
> > > > -		" free:%lu free_pcp:%lu free_cma:%lu\n",
> > > > -		global_node_page_state(NR_ACTIVE_ANON),
> > > > -		global_node_page_state(NR_INACTIVE_ANON),
> > > > -		global_node_page_state(NR_ISOLATED_ANON),
> > > > -		global_node_page_state(NR_ACTIVE_FILE),
> > > > -		global_node_page_state(NR_INACTIVE_FILE),
> > > > -		global_node_page_state(NR_ISOLATED_FILE),
> > > > -		global_node_page_state(NR_UNEVICTABLE),
> > > > -		global_node_page_state(NR_FILE_DIRTY),
> > > > -		global_node_page_state(NR_WRITEBACK),
> > > > -		global_node_page_state(NR_UNSTABLE_NFS),
> > > > -		global_page_state(NR_SLAB_RECLAIMABLE),
> > > > -		global_page_state(NR_SLAB_UNRECLAIMABLE),
> > > > -		global_node_page_state(NR_FILE_MAPPED),
> > > > -		global_node_page_state(NR_SHMEM),
> > > > -		global_page_state(NR_PAGETABLE),
> > > > -		global_page_state(NR_BOUNCE),
> > > > -		global_page_state(NR_FREE_PAGES),
> > > > -		free_pcp,
> > > > -		global_page_state(NR_FREE_CMA_PAGES));
[]
> > > > a side note:
> > > 
> > > this can make it harder to read, in _the worst case_. one printk()
> > > guaranteed that we would see a single line in the serial log/etc.
> > > the sort of a problem with multiple printks is that printks coming
> > > from other CPUs will split that "previously single" line.
> > 
> > Not true.  Note the multiple \n uses in the original code.
> 
> one printk call ends up in logbuf as a single entry and, thus, we print
> it to the serial console in one shot (what is the correct english word
> to use here?). multiple printks result in multiple logbuf entries, and
> printks from other CPUs can mix in.
> 
> so the difference is:
> 
> 
> 	CPU0						CPU1
> 							printk(foo\n)
> printk(..isolated_anon\n...isolated_file\n...)
> 							printk(bar\n)
> 
> vs
> 
> 	CPU0						CPU1
> printk(..isolated_anon\n)
> 							printk(foo\n)
> printk(...isolated_file\n)
> 							printk(bar\n)
> printk(...\n)
> 
> not the same thing.
> 
> and the slower the serial console is the more messages potentially
> can appear between "..isolated_anon\n" and "...isolated_file\n".

Right.  For the definition of "single line", meaning "contiguous
block" and not single line.

Perhaps there would be some value in having a generic mechanism
for the dump_stack use of "atomic_t dump_lock", where a thread
can grab exclusive use of the printk subsystem for a short period
to keep messages from being interleaved by other processes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
