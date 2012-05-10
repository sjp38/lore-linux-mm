Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 000F76B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 17:44:40 -0400 (EDT)
Date: Thu, 10 May 2012 14:44:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 10/10] mm: remove sparsemem allocation details from the
 bootmem allocator
Message-Id: <20120510144439.eba9c486.akpm@linux-foundation.org>
In-Reply-To: <1336390672-14421-11-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
	<1336390672-14421-11-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon,  7 May 2012 13:37:52 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> alloc_bootmem_section() derives allocation area constraints from the
> specified sparsemem section.  This is a bit specific for a generic
> memory allocator like bootmem, though, so move it over to sparsemem.
> 
> As __alloc_bootmem_node_nopanic() already retries failed allocations
> with relaxed area constraints, the fallback code in sparsemem.c can be
> removed and the code becomes a bit more compact overall.
> 
> ...
>
> @@ -332,9 +334,9 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
>  #else
>  static unsigned long * __init
>  sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
> -					 unsigned long count)
> +					 unsigned long size)
>  {
> -	return NULL;
> +	return alloc_bootmem_node_nopanic(pgdat, size)

You've been bad.   Your penance is to runtime test this code with
CONFIG_MEMORY_HOTREMOVE=n!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
