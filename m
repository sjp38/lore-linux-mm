Date: Tue, 21 Nov 2006 08:55:35 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/2] fix call to alloc_bootmem after bootmem has been
 freed
Message-Id: <20061121085535.9c62b54f.akpm@osdl.org>
In-Reply-To: <20061115193238.4d23900c@localhost>
References: <20061115193049.3457b44c@localhost>
	<20061115193238.4d23900c@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Krafft <krafft@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006 19:32:38 +0100
Christian Krafft <krafft@de.ibm.com> wrote:

> In some cases it might happen, that alloc_bootmem is beeing called
> after bootmem pages have been freed. This is, because the condition
> SYSTEM_BOOTING is still true after bootmem has been freed.
> 
> Signed-off-by: Christian Krafft <krafft@de.ibm.com>
> 
> Index: linux/mm/page_alloc.c
> ===================================================================
> --- linux.orig/mm/page_alloc.c
> +++ linux/mm/page_alloc.c
> @@ -1931,7 +1931,7 @@ int zone_wait_table_init(struct zone *zo
>  	alloc_size = zone->wait_table_hash_nr_entries
>  					* sizeof(wait_queue_head_t);
>  
> - 	if (system_state == SYSTEM_BOOTING) {
> +	if (!slab_is_available()) {
>  		zone->wait_table = (wait_queue_head_t *)
>  			alloc_bootmem_node(pgdat, alloc_size);
>  	} else {

I don't think that slab_is_available() is an appropriate way of working out
if we can call vmalloc().

Also, a more complete description of the problem is needed, please.  Which
caller is incorrectly allocating bootmem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
