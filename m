Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id ED7746B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 08:42:32 -0400 (EDT)
Date: Mon, 29 Oct 2012 08:42:29 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 09/16] SUNRPC/cache: use new hashtable implementation
Message-ID: <20121029124229.GC11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-9-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351450948-15618-9-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> Switch cache to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in the cache implementation.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  net/sunrpc/cache.c | 20 +++++++++-----------
>  1 file changed, 9 insertions(+), 11 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index fc2f7aa..0490546 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -28,6 +28,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/mutex.h>
>  #include <linux/pagemap.h>
> +#include <linux/hashtable.h>
>  #include <asm/ioctls.h>
>  #include <linux/sunrpc/types.h>
>  #include <linux/sunrpc/cache.h>
> @@ -524,19 +525,18 @@ EXPORT_SYMBOL_GPL(cache_purge);
>   * it to be revisited when cache info is available
>   */
>  
> -#define	DFR_HASHSIZE	(PAGE_SIZE/sizeof(struct list_head))
> -#define	DFR_HASH(item)	((((long)item)>>4 ^ (((long)item)>>13)) % DFR_HASHSIZE)
> +#define	DFR_HASH_BITS	9

If we look at a bit of history, mainly commit:

commit 1117449276bb909b029ed0b9ba13f53e4784db9d
Author: NeilBrown <neilb@suse.de>
Date:   Thu Aug 12 17:04:08 2010 +1000

    sunrpc/cache: change deferred-request hash table to use hlist.


we'll notice that the only reason why the prior DFR_HASHSIZE was using

  (PAGE_SIZE/sizeof(struct list_head))

instead of

  (PAGE_SIZE/sizeof(struct hlist_head))

is because it has been forgotten in that commit. The intent there is to
make the hash table array fit the page size.

By defining DFR_HASH_BITS arbitrarily to "9", this indeed fulfills this
purpose on architectures with 4kB page size and 64-bit pointers, but not
on some powerpc configurations, and Tile architectures, which have more
exotic 64kB page size, and of course on the far less exotic 32-bit
pointer architectures.

So defining e.g.:

#include <linux/log2.h>

#define DFR_HASH_BITS  (PAGE_SHIFT - ilog2(BITS_PER_LONG))

would keep the intended behavior in all cases: use one page for the hash
array.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
