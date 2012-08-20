Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 6AE936B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:46:10 -0400 (EDT)
Date: Mon, 20 Aug 2012 19:46:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/5] mempolicy: fix refcount leak in
 mpol_set_shared_policy()
In-Reply-To: <1345480594-27032-5-git-send-email-mgorman@suse.de>
Message-ID: <00000139459223d7-93a9c53f-6724-4a4b-b675-cd25d8d53c71-000000@email.amazonses.com>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de> <1345480594-27032-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, 20 Aug 2012, Mel Gorman wrote:

> @@ -2318,9 +2323,7 @@ void mpol_free_shared_policy(struct shared_policy *p)
>  	while (next) {
>  		n = rb_entry(next, struct sp_node, nd);
>  		next = rb_next(&n->nd);
> -		rb_erase(&n->nd, &p->root);

Looks like we need to keep the above line? sp_delete does not remove the
tree entry.

> -		mpol_put(n->policy);
> -		kmem_cache_free(sn_cache, n);
> +		sp_delete(p, n);
>  	}
>  	mutex_unlock(&p->mutex);
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
