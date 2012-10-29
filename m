Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 951D16B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:25:54 -0400 (EDT)
Date: Mon, 29 Oct 2012 09:25:52 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 14/16] net,rds: use new hashtable implementation
Message-ID: <20121029132552.GB16391@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-14-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351450948-15618-14-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> Switch rds to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in rds.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  net/rds/bind.c       |  28 +++++++++-----
>  net/rds/connection.c | 102 +++++++++++++++++++++++----------------------------
>  2 files changed, 63 insertions(+), 67 deletions(-)
> 
> diff --git a/net/rds/bind.c b/net/rds/bind.c
> index 637bde5..79d65ce 100644
> --- a/net/rds/bind.c
> +++ b/net/rds/bind.c
> @@ -36,16 +36,16 @@
>  #include <linux/if_arp.h>
>  #include <linux/jhash.h>
>  #include <linux/ratelimit.h>
> +#include <linux/hashtable.h>
>  #include "rds.h"
>  
> -#define BIND_HASH_SIZE 1024
> -static struct hlist_head bind_hash_table[BIND_HASH_SIZE];
> +#define BIND_HASH_BITS 10
> +static DEFINE_HASHTABLE(bind_hash_table, BIND_HASH_BITS);
>  static DEFINE_SPINLOCK(rds_bind_lock);
>  
> -static struct hlist_head *hash_to_bucket(__be32 addr, __be16 port)
> +static u32 rds_hash(__be32 addr, __be16 port)
>  {
> -	return bind_hash_table + (jhash_2words((u32)addr, (u32)port, 0) &
> -				  (BIND_HASH_SIZE - 1));
> +	return jhash_2words((u32)addr, (u32)port, 0);
>  }
>  
>  static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
> @@ -53,12 +53,12 @@ static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
>  {
>  	struct rds_sock *rs;
>  	struct hlist_node *node;
> -	struct hlist_head *head = hash_to_bucket(addr, port);
> +	u32 key = rds_hash(addr, port);
>  	u64 cmp;
>  	u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
>  
>  	rcu_read_lock();
> -	hlist_for_each_entry_rcu(rs, node, head, rs_bound_node) {
> +	hash_for_each_possible_rcu(bind_hash_table, rs, node, rs_bound_node, key) {

here too, key will be hashed twice:

- once by jhash_2words,
- once by hash_32(),

is this intended ?

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
