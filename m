Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id B238F6B0062
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 07:13:11 -0400 (EDT)
Date: Mon, 9 Jul 2012 13:13:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] mm/sparse: remove index_init_lock
Message-ID: <20120709111304.GA4627@tiehlicka.suse.cz>
References: <1341544178-7245-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1341544178-7245-3-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341544178-7245-3-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, akpm@linux-foundation.org

On Fri 06-07-12 11:09:38, Gavin Shan wrote:
> Apart from call to sparse_index_init() during boot stage, the function
> is mainly used for hotplug case as follows and protected by hotplug

mainly? Who are the others?

> mutex "mem_hotplug_mutex". So we needn't the spinlock in sparse_index_init().

I think you are right but the changelog should be more convincing. It
would be also good to mention the origin motivation for the lock (I
couldn't find it in the history - Dave?).

> 
> 	sparse_index_init
> 	sparse_add_one_section
> 	__add_section
> 	__add_pages
> 	arch_add_memory
> 	add_memory
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  mm/sparse.c |   14 +-------------
>  1 file changed, 1 insertion(+), 13 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 8b8edfb..4437c6c 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -77,7 +77,6 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>  
>  static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  {
> -	static DEFINE_SPINLOCK(index_init_lock);
>  	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
>  	struct mem_section *section;
>  	int ret = 0;
> @@ -88,20 +87,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  	section = sparse_index_alloc(nid);
>  	if (!section)
>  		return -ENOMEM;
> -	/*
> -	 * This lock keeps two different sections from
> -	 * reallocating for the same index
> -	 */
> -	spin_lock(&index_init_lock);
> -
> -	if (mem_section[root]) {
> -		ret = -EEXIST;
> -		goto out;
> -	}
>  
>  	mem_section[root] = section;
> -out:
> -	spin_unlock(&index_init_lock);
> +
>  	return ret;
>  }
>  #else /* !SPARSEMEM_EXTREME */
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
