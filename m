Message-ID: <20020719183646.32486.qmail@web14310.mail.yahoo.com>
Date: Fri, 19 Jul 2002 11:36:46 -0700 (PDT)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: [patch] Useless locking in mm/numa.c
In-Reply-To: <3D376567.4040307@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com, Andrew Morton <akpm@zip.com.au>, Martin Bligh <mjbligh@us.ibm.com>, linux-mm@kvack.org, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I think I put in the locks in the initial version of
the file becase the idea was that 
show_free_areas_node() could be invoked from any cpu
in a multinode system (via the sysrq keys or other
intr sources), and the spin lock would provide 
sanity in the print out. 

For nonnuma discontig machines, isn't the spin lock
providing protection in the pgdat list chain walking
in _alloc_pages()?

Kanoj

--- Matthew Dobson <colpatch@us.ibm.com> wrote:
> There is a lock that is apparently protecting
> nothing.  The node_lock spinlock 
> in mm/numa.c is protecting read-only accesses to
> pgdat_list.  Here is a patch 
> to get rid of it.
> 
> Cheers!
> 
> -Matt
> > --- linux-2.5.26-vanilla/mm/numa.c	Tue Jul 16
> 16:49:30 2002
> +++ linux-2.5.26-vanilla/mm/numa.c.fixed	Thu Jul 18
> 17:59:35 2002
> @@ -44,15 +44,11 @@
>  
>  #define LONG_ALIGN(x)
> (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
>  
> -static spinlock_t node_lock = SPIN_LOCK_UNLOCKED;
> -
>  void show_free_areas_node(pg_data_t *pgdat)
>  {
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&node_lock, flags);
>  	show_free_areas_core(pgdat);
> -	spin_unlock_irqrestore(&node_lock, flags);
>  }
>  
>  /*
> @@ -106,11 +102,9 @@
>  #ifdef CONFIG_NUMA
>  	temp = NODE_DATA(numa_node_id());
>  #else
> -	spin_lock_irqsave(&node_lock, flags);
>  	if (!next) next = pgdat_list;
>  	temp = next;
>  	next = next->node_next;
> -	spin_unlock_irqrestore(&node_lock, flags);
>  #endif
>  	start = temp;
>  	while (temp) {
> 


__________________________________________________
Do You Yahoo!?
Yahoo! Autos - Get free new car price quotes
http://autos.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
