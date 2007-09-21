Date: Fri, 21 Sep 2007 01:55:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/9] oom: change all_unreclaimable zone member to flags
Message-Id: <20070921015548.ba20de5b.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007 13:23:17 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> @@ -1871,10 +1874,8 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	 * not have reclaimable pages and if we should not delay the allocation
>  	 * then do not scan.
>  	 */
> -	if (!(gfp_mask & __GFP_WAIT) ||
> -		zone->all_unreclaimable ||
> -		atomic_read(&zone->reclaim_in_progress) > 0 ||
> -		(current->flags & PF_MEMALLOC))
> +	if (!(gfp_mask & __GFP_WAIT) || zone_is_all_unreclaimable(zone) ||
> +		zone_is_reclaim_locked(zone) || (current->flags & PF_MEMALLOC))
>  			return 0;

It would be nice to convert this somewhat crappy code to use
test_and_set_bit(ZONE_RECLAIM_LOCKED) sometime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
