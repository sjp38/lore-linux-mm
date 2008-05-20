Date: Tue, 20 May 2008 15:48:51 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH] memory hotplug: fix early allocation handling
Message-ID: <20080520144850.GO4146@shadowen.org>
References: <20080520105145.GA24526@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080520105145.GA24526@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, May 20, 2008 at 12:51:45PM +0200, Heiko Carstens wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Trying to add memory via add_memory() from within an initcall function
> results in
> 
> bootmem alloc of 163840 bytes failed!
> Kernel panic - not syncing: Out of memory
> 
> This is caused by zone_wait_table_init() which uses system_state to
> decide if it should use the bootmem allocator or not.
> When initcalls are handled the system_state is still SYSTEM_BOOTING
> but the bootmem allocator doesn't work anymore. So the allocation
> will fail.
> 
> To fix this use slab_is_available() instead as indicator like we do
> it everywhere else.
> 
> Cc: Andy Whitcroft <apw@shadowen.org>
> Cc: Dave Hansen <haveblue@us.ibm.com>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -2804,7 +2804,7 @@ int zone_wait_table_init(struct zone *zo
>  	alloc_size = zone->wait_table_hash_nr_entries
>  					* sizeof(wait_queue_head_t);
>  
> - 	if (system_state == SYSTEM_BOOTING) {
> + 	if (!slab_is_available()) {
>  		zone->wait_table = (wait_queue_head_t *)
>  			alloc_bootmem_node(pgdat, alloc_size);
>  	} else {

It would be nice to be able to check that bootmem is enabled separatly
from whether slab is available, as I am sure there is a time where
neither is available during the change over.  But the change looks
reasonable as we cannot use vmalloc until slab is working.

Reviewed-by: Andy Whitcroft <apw@shadowen.org>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
