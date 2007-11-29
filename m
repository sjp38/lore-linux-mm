Date: Thu, 29 Nov 2007 11:42:43 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch](Resend) mm/sparse.c: Improve the error handling for sparse_add_one_section()
In-Reply-To: <20071128124420.GJ2464@hacking>
References: <1196189625.5764.36.camel@localhost> <20071128124420.GJ2464@hacking>
Message-Id: <20071129113903.03E3.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Looks good to me.

Thanks.

Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>



> On Tue, Nov 27, 2007 at 10:53:45AM -0800, Dave Hansen wrote:
> >On Tue, 2007-11-27 at 10:26 +0800, WANG Cong wrote:
> >> 
> >> @@ -414,7 +418,7 @@ int sparse_add_one_section(struct zone *
> >>  out:
> >>         pgdat_resize_unlock(pgdat, &flags);
> >>         if (ret <= 0)
> >> -               __kfree_section_memmap(memmap, nr_pages);
> >> +               kfree(usemap);
> >>         return ret;
> >>  }
> >>  #endif 
> >
> >Why did you get rid of the memmap free here?  A bad return from
> >sparse_init_one_section() indicates that we didn't use the memmap, so it
> >will leak otherwise.
> 
> Sorry, I was confused by the recursion. This one should be OK.
> 
> Thanks.
> 
> 
> 
> Improve the error handling for mm/sparse.c::sparse_add_one_section().  And I
> see no reason to check 'usemap' until holding the 'pgdat_resize_lock'.
> 
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: Dave Hansen <haveblue@us.ibm.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
> Cc: Andy Whitcroft <apw@shadowen.org>
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> 
> ---
> Index: linux-2.6/mm/sparse.c
> ===================================================================
> --- linux-2.6.orig/mm/sparse.c
> +++ linux-2.6/mm/sparse.c
> @@ -391,9 +391,17 @@ int sparse_add_one_section(struct zone *
>  	 * no locking for this, because it does its own
>  	 * plus, it does a kmalloc
>  	 */
> -	sparse_index_init(section_nr, pgdat->node_id);
> +	ret = sparse_index_init(section_nr, pgdat->node_id);
> +	if (ret < 0)
> +		return ret;
>  	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, nr_pages);
> +	if (!memmap)
> +		return -ENOMEM;
>  	usemap = __kmalloc_section_usemap();
> +	if (!usemap) {
> +		__kfree_section_memmap(memmap, nr_pages);
> +		return -ENOMEM;
> +	}
>  
>  	pgdat_resize_lock(pgdat, &flags);
>  
> @@ -403,18 +411,16 @@ int sparse_add_one_section(struct zone *
>  		goto out;
>  	}
>  
> -	if (!usemap) {
> -		ret = -ENOMEM;
> -		goto out;
> -	}
>  	ms->section_mem_map |= SECTION_MARKED_PRESENT;
>  
>  	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
>  out:
>  	pgdat_resize_unlock(pgdat, &flags);
> -	if (ret <= 0)
> +	if (ret <= 0) {
> +		kfree(usemap);
>  		__kfree_section_memmap(memmap, nr_pages);
> +	}
>  	return ret;
>  }
>  #endif

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
