Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6A0E6B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:38:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id y18so63757692itc.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:38:04 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0163.hostedemail.com. [216.40.44.163])
        by mx.google.com with ESMTPS id j90si6935061ioi.119.2017.03.16.11.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 11:38:03 -0700 (PDT)
Message-ID: <1489689476.13953.3.camel@perches.com>
Subject: Re: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening
 printks
From: Joe Perches <joe@perches.com>
Date: Thu, 16 Mar 2017 11:37:56 -0700
In-Reply-To: <20170316113056.GG464@jagdpanzerIV.localdomain>
References: <cover.1489628459.git.joe@perches.com>
	 <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
	 <20170316113056.GG464@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2017-03-16 at 20:30 +0900, Sergey Senozhatsky wrote:
> On (03/15/17 18:43), Joe Perches wrote:
> [..]
> > -	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
> > -		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> > -		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
> > -		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> > -		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
> > -		" free:%lu free_pcp:%lu free_cma:%lu\n",
> > -		global_node_page_state(NR_ACTIVE_ANON),
> > -		global_node_page_state(NR_INACTIVE_ANON),
> > -		global_node_page_state(NR_ISOLATED_ANON),
> > -		global_node_page_state(NR_ACTIVE_FILE),
> > -		global_node_page_state(NR_INACTIVE_FILE),
> > -		global_node_page_state(NR_ISOLATED_FILE),
> > -		global_node_page_state(NR_UNEVICTABLE),
> > -		global_node_page_state(NR_FILE_DIRTY),
> > -		global_node_page_state(NR_WRITEBACK),
> > -		global_node_page_state(NR_UNSTABLE_NFS),
> > -		global_page_state(NR_SLAB_RECLAIMABLE),
> > -		global_page_state(NR_SLAB_UNRECLAIMABLE),
> > -		global_node_page_state(NR_FILE_MAPPED),
> > -		global_node_page_state(NR_SHMEM),
> > -		global_page_state(NR_PAGETABLE),
> > -		global_page_state(NR_BOUNCE),
> > -		global_page_state(NR_FREE_PAGES),
> > -		free_pcp,
> > -		global_page_state(NR_FREE_CMA_PAGES));
> > +	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n",
> > +	       global_node_page_state(NR_ACTIVE_ANON),
> > +	       global_node_page_state(NR_INACTIVE_ANON),
> > +	       global_node_page_state(NR_ISOLATED_ANON));
> > +	printk("active_file:%lu inactive_file:%lu isolated_file:%lu\n",
> > +	       global_node_page_state(NR_ACTIVE_FILE),
> > +	       global_node_page_state(NR_INACTIVE_FILE),
> > +	       global_node_page_state(NR_ISOLATED_FILE));
> > +	printk("unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n",
> > +	       global_node_page_state(NR_UNEVICTABLE),
> > +	       global_node_page_state(NR_FILE_DIRTY),
> > +	       global_node_page_state(NR_WRITEBACK),
> > +	       global_node_page_state(NR_UNSTABLE_NFS));
> > +	printk("slab_reclaimable:%lu slab_unreclaimable:%lu\n",
> > +	       global_page_state(NR_SLAB_RECLAIMABLE),
> > +	       global_page_state(NR_SLAB_UNRECLAIMABLE));
> > +	printk("mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
> > +	       global_node_page_state(NR_FILE_MAPPED),
> > +	       global_node_page_state(NR_SHMEM),
> > +	       global_page_state(NR_PAGETABLE),
> > +	       global_page_state(NR_BOUNCE));
> > +	printk("free:%lu free_pcp:%lu free_cma:%lu\n",
> > +	       global_page_state(NR_FREE_PAGES),
> > +	       free_pcp,
> > +	       global_page_state(NR_FREE_CMA_PAGES));
> 
> a side note:
> 
> this can make it harder to read, in _the worst case_. one printk()
> guaranteed that we would see a single line in the serial log/etc.
> the sort of a problem with multiple printks is that printks coming
> from other CPUs will split that "previously single" line.

Not true.  Note the multiple \n uses in the original code.

> just a notice. up to MM people to decide.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
