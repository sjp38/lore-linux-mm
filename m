Date: Fri, 15 Jun 2007 07:41:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
In-Reply-To: <20070615184308.d59a9c11.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706150740510.7471@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
 <20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
 <20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
 <20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
 <20070614172936.12b94ad7.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140706370.28544@schroedinger.engr.sgi.com>
 <20070615010217.62908da3.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140909030.29612@schroedinger.engr.sgi.com>
 <20070615011536.beaa79c1.kamezawa.hiroyu@jp.fujitsu.com> <46718320.1010500@csn.ul.ie>
 <20070615073125.f5e4d6e2.kamezawa.hiroyu@jp.fujitsu.com>
 <20070615184308.d59a9c11.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jun 2007, KAMEZAWA Hiroyuki wrote:

>  	/*
> -	 * Establish migration ptes or remove ptes
> +	 * This is a corner case handling.
> +	 * When a new swap-ache is read into, it is linked to LRU
> +	 * and treated as swapcache but has no rmap yet.
> +	 * Calling try_to_unmap() against a page->mapping==NULL page is
> +	 * BUG. So handle it here.
> +	 */
> +	if (!page->mapping)
> +		goto unlock;
> +	/*
> +	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
> +	 * we cannot notice that anon_vma is freed while we migrates a pages
> +	 * This rcu_read_lock() delays freeing anon_vma pointer until the end
> +	 * of migration. File cache pages are no problem because of page_lock()
>  	 */
> +	rcu_read_lock();
>  	try_to_unmap(page, 1);

page->mapping needs to be checked after rcu_read_lock. The mapping may be 
removed and the anon_vma dropped after you checked page->mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
