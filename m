Date: Tue, 21 Nov 2006 10:26:16 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/2] fix call to alloc_bootmem after bootmem has been
 freed
Message-Id: <20061121102616.47d03ccc.akpm@osdl.org>
In-Reply-To: <20061121190213.1700761b@localhost>
References: <20061115193049.3457b44c@localhost>
	<20061115193238.4d23900c@localhost>
	<20061121085535.9c62b54f.akpm@osdl.org>
	<20061121190213.1700761b@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Krafft <krafft@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006 19:02:13 +0100
Christian Krafft <krafft@de.ibm.com> wrote:

> > > Index: linux/mm/page_alloc.c
> > > ===================================================================
> > > --- linux.orig/mm/page_alloc.c
> > > +++ linux/mm/page_alloc.c
> > > @@ -1931,7 +1931,7 @@ int zone_wait_table_init(struct zone *zo
> > >  	alloc_size = zone->wait_table_hash_nr_entries
> > >  					* sizeof(wait_queue_head_t);
> > >
> > > - 	if (system_state == SYSTEM_BOOTING) {
> > > +	if (!slab_is_available()) {
> > >  		zone->wait_table = (wait_queue_head_t *)
> > >  			alloc_bootmem_node(pgdat, alloc_size);
> > >  	} else {
> > 
> > I don't think that slab_is_available() is an appropriate way of working out
> > if we can call vmalloc().
> 
> Afaik slab_is_available() is the generic replacement for mem_init_done, which exists only on powerpc. 
> If thats not appropriate, I dont know why. However, SYSTEM_BOOTING is definitively wrong.

slab is a very different thing from vmalloc.  One could easily envisage
situations (now or in the future) in which slab is ready, but vmalloc is
not (more likely vice versa).

It'd be better to add a new vmalloc_is_available.  (Just an int - no need
for a helper function).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
