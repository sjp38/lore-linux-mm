Date: Tue, 8 Feb 2005 20:04:52 -0500
From: Bob Picco <bob.picco@hp.com>
Subject: Re: [RFC][PATCH] no per-arch mem_map init
Message-ID: <20050209010452.GA20515@localhost.localdomain>
References: <1107891434.4716.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1107891434.4716.16.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Jesse Barnes <jbarnes@engr.sgi.com>, Bob Picco <bob.picco@hp.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave,

Dave Hansen wrote:	[Tue Feb 08 2005, 02:37:14PM EST]
> This patch has been one of the base patches in the -mhp tree for a bit
> now, and seems to be working pretty well, at least on x86.  I would like
> to submit it upstream, but I want to get a bit more testing first.  Is
> there a chance you ia64 guys could give it a quick test boot to make
> sure that it doesn't screw you over?  
> 
> -- Dave
[snip]
> diff -puN arch/i386/mm/discontig.c~A6-no_arch_mem_map_init arch/i386/mm/discontig.c
> diff -puN arch/ia64/mm/contig.c~A6-no_arch_mem_map_init arch/ia64/mm/contig.c
> --- memhotplug/arch/ia64/mm/contig.c~A6-no_arch_mem_map_init	2005-02-04 15:21:57.000000000 -0800
> +++ memhotplug-dave/arch/ia64/mm/contig.c	2005-02-04 15:21:57.000000000 -0800
> @@ -280,7 +280,7 @@ paging_init (void)
>  		vmem_map = (struct page *) vmalloc_end;
>  		efi_memmap_walk(create_mem_map_page_table, NULL);
>  
> -		mem_map = contig_page_data.node_mem_map = vmem_map;
> +		NODE_DATA(0)->node_mem_map = vmem_map;
This has to be changed to.
		mem_map = NODE_DATA(0)->node_mem_map = vmem_map;
>  		free_area_init_node(0, &contig_page_data, zones_size,
>  				    0, zholes_size);
>  
[snip]
I actually submitted an identical change within my last patchset to lhms.
Not making this change requires changing use of mem_map throughout contig.c
and one BUG assertion in init.c.  I haven't tested this patch but it was
indirectly tested by me in FLATMEM configuration for lhms.

bob
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
