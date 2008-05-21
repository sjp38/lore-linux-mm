Date: Wed, 21 May 2008 16:29:14 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] memory hotplug: fix early allocation handling
In-Reply-To: <20080520105145.GA24526@osiris.boeblingen.de.ibm.com>
References: <20080520105145.GA24526@osiris.boeblingen.de.ibm.com>
Message-Id: <20080521162657.587A.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Looks good to me.

Thanks.

Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>



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

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
