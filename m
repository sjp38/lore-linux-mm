Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kALI5OF9198968
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 18:05:27 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kALI8E3p2846830
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 18:08:14 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kALI5Nig030654
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 18:05:23 GMT
Date: Tue, 21 Nov 2006 19:02:13 +0100
From: Christian Krafft <krafft@de.ibm.com>
Subject: Re: [patch 1/2] fix call to alloc_bootmem after bootmem has been
 freed
Message-ID: <20061121190213.1700761b@localhost>
In-Reply-To: <20061121085535.9c62b54f.akpm@osdl.org>
References: <20061115193049.3457b44c@localhost>
	<20061115193238.4d23900c@localhost>
	<20061121085535.9c62b54f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006 08:55:35 -0800
Andrew Morton <akpm@osdl.org> wrote:

> On Wed, 15 Nov 2006 19:32:38 +0100
> Christian Krafft <krafft@de.ibm.com> wrote:
> 
> > In some cases it might happen, that alloc_bootmem is beeing called
> > after bootmem pages have been freed. This is, because the condition
> > SYSTEM_BOOTING is still true after bootmem has been freed.
> >
> > Signed-off-by: Christian Krafft <krafft@de.ibm.com>
> >
> > Index: linux/mm/page_alloc.c
> > ===================================================================
> > --- linux.orig/mm/page_alloc.c
> > +++ linux/mm/page_alloc.c
> > @@ -1931,7 +1931,7 @@ int zone_wait_table_init(struct zone *zo
> >  	alloc_size = zone->wait_table_hash_nr_entries
> >  					* sizeof(wait_queue_head_t);
> >
> > - 	if (system_state == SYSTEM_BOOTING) {
> > +	if (!slab_is_available()) {
> >  		zone->wait_table = (wait_queue_head_t *)
> >  			alloc_bootmem_node(pgdat, alloc_size);
> >  	} else {
> 
> I don't think that slab_is_available() is an appropriate way of working out
> if we can call vmalloc().

Afaik slab_is_available() is the generic replacement for mem_init_done, which exists only on powerpc. 
If thats not appropriate, I dont know why. However, SYSTEM_BOOTING is definitively wrong.
 
> Also, a more complete description of the problem is needed, please.  Which
> caller is incorrectly allocating bootmem?
> 

spu_base is causing the call to alloc_bootmem but only, if built into kernel. Other components might have the same problem.

cheers,
ck

-- 
Mit freundlichen Grussen,
kind regards,

Christian Krafft
IBM Systems & Technology Group, 
Linux Kernel Development
IT Specialist

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
