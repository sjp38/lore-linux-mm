Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6126B038F
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 21:56:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q126so120885573pga.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:56:06 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id w3si4967387pfj.422.2017.03.16.18.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 18:56:05 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id o126so7528056pfb.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:56:05 -0700 (PDT)
Date: Fri, 17 Mar 2017 10:56:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening
 printks
Message-ID: <20170317015600.GA426@jagdpanzerIV.localdomain>
References: <cover.1489628459.git.joe@perches.com>
 <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
 <20170316113056.GG464@jagdpanzerIV.localdomain>
 <1489689476.13953.3.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489689476.13953.3.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (03/16/17 11:37), Joe Perches wrote:
> On Thu, 2017-03-16 at 20:30 +0900, Sergey Senozhatsky wrote:
> > On (03/15/17 18:43), Joe Perches wrote:
> > [..]
> > > -	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
> > > -		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> > > -		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
> > > -		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> > > -		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
> > > -		" free:%lu free_pcp:%lu free_cma:%lu\n",
> > > -		global_node_page_state(NR_ACTIVE_ANON),
> > > -		global_node_page_state(NR_INACTIVE_ANON),
> > > -		global_node_page_state(NR_ISOLATED_ANON),
> > > -		global_node_page_state(NR_ACTIVE_FILE),
> > > -		global_node_page_state(NR_INACTIVE_FILE),
> > > -		global_node_page_state(NR_ISOLATED_FILE),
> > > -		global_node_page_state(NR_UNEVICTABLE),
> > > -		global_node_page_state(NR_FILE_DIRTY),
> > > -		global_node_page_state(NR_WRITEBACK),
> > > -		global_node_page_state(NR_UNSTABLE_NFS),
> > > -		global_page_state(NR_SLAB_RECLAIMABLE),
> > > -		global_page_state(NR_SLAB_UNRECLAIMABLE),
> > > -		global_node_page_state(NR_FILE_MAPPED),
> > > -		global_node_page_state(NR_SHMEM),
> > > -		global_page_state(NR_PAGETABLE),
> > > -		global_page_state(NR_BOUNCE),
> > > -		global_page_state(NR_FREE_PAGES),
> > > -		free_pcp,
> > > -		global_page_state(NR_FREE_CMA_PAGES));
> > > +	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n",
> > > +	       global_node_page_state(NR_ACTIVE_ANON),
> > > +	       global_node_page_state(NR_INACTIVE_ANON),
> > > +	       global_node_page_state(NR_ISOLATED_ANON));
> > > +	printk("active_file:%lu inactive_file:%lu isolated_file:%lu\n",
> > > +	       global_node_page_state(NR_ACTIVE_FILE),
> > > +	       global_node_page_state(NR_INACTIVE_FILE),
> > > +	       global_node_page_state(NR_ISOLATED_FILE));
> > > +	printk("unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n",
> > > +	       global_node_page_state(NR_UNEVICTABLE),
> > > +	       global_node_page_state(NR_FILE_DIRTY),
> > > +	       global_node_page_state(NR_WRITEBACK),
> > > +	       global_node_page_state(NR_UNSTABLE_NFS));
> > > +	printk("slab_reclaimable:%lu slab_unreclaimable:%lu\n",
> > > +	       global_page_state(NR_SLAB_RECLAIMABLE),
> > > +	       global_page_state(NR_SLAB_UNRECLAIMABLE));
> > > +	printk("mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
> > > +	       global_node_page_state(NR_FILE_MAPPED),
> > > +	       global_node_page_state(NR_SHMEM),
> > > +	       global_page_state(NR_PAGETABLE),
> > > +	       global_page_state(NR_BOUNCE));
> > > +	printk("free:%lu free_pcp:%lu free_cma:%lu\n",
> > > +	       global_page_state(NR_FREE_PAGES),
> > > +	       free_pcp,
> > > +	       global_page_state(NR_FREE_CMA_PAGES));
> > 
> > a side note:
> > 
> > this can make it harder to read, in _the worst case_. one printk()
> > guaranteed that we would see a single line in the serial log/etc.
> > the sort of a problem with multiple printks is that printks coming
> > from other CPUs will split that "previously single" line.
> 
> Not true.  Note the multiple \n uses in the original code.

one printk call ends up in logbuf as a single entry and, thus, we print
it to the serial console in one shot (what is the correct english word
to use here?). multiple printks result in multiple logbuf entries, and
printks from other CPUs can mix in.

so the difference is:


	CPU0						CPU1
							printk(foo\n)
printk(..isolated_anon\n...isolated_file\n...)
							printk(bar\n)

vs

	CPU0						CPU1
printk(..isolated_anon\n)
							printk(foo\n)
printk(...isolated_file\n)
							printk(bar\n)
printk(...\n)

not the same thing.

and the slower the serial console is the more messages potentially
can appear between "..isolated_anon\n" and "...isolated_file\n".

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
