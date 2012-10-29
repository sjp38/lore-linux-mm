Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id D51CB6B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 08:15:08 -0400 (EDT)
Date: Mon, 29 Oct 2012 08:15:06 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 07/16] net,9p: use new hashtable implementation
Message-ID: <20121029121506.GA11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-7-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351450948-15618-7-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> Switch 9p error table to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in 9p.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  net/9p/error.c | 21 ++++++++++-----------
>  1 file changed, 10 insertions(+), 11 deletions(-)
> 
> diff --git a/net/9p/error.c b/net/9p/error.c
> index 2ab2de7..a5cc7dd 100644
> --- a/net/9p/error.c
> +++ b/net/9p/error.c
> @@ -34,7 +34,7 @@
>  #include <linux/jhash.h>
>  #include <linux/errno.h>
>  #include <net/9p/9p.h>
> -
> +#include <linux/hashtable.h>

missing newline.

>  /**
>   * struct errormap - map string errors from Plan 9 to Linux numeric ids
>   * @name: string sent over 9P
> @@ -50,8 +50,8 @@ struct errormap {
>  	struct hlist_node list;
>  };
>  
> -#define ERRHASHSZ		32
> -static struct hlist_head hash_errmap[ERRHASHSZ];
> +#define ERR_HASH_BITS 5
> +static DEFINE_HASHTABLE(hash_errmap, ERR_HASH_BITS);
>  
>  /* FixMe - reduce to a reasonable size */
>  static struct errormap errmap[] = {
> @@ -193,18 +193,17 @@ static struct errormap errmap[] = {
>  int p9_error_init(void)
>  {
>  	struct errormap *c;
> -	int bucket;
> +	u32 hash;
>  
>  	/* initialize hash table */
> -	for (bucket = 0; bucket < ERRHASHSZ; bucket++)
> -		INIT_HLIST_HEAD(&hash_errmap[bucket]);
> +	hash_init(hash_errmap);

As for most of the other patches in this series, the hash_init is
redundant for a statically defined hash table.

Thanks,

Mathieu

>  
>  	/* load initial error map into hash table */
>  	for (c = errmap; c->name != NULL; c++) {
>  		c->namelen = strlen(c->name);
> -		bucket = jhash(c->name, c->namelen, 0) % ERRHASHSZ;
> +		hash = jhash(c->name, c->namelen, 0);
>  		INIT_HLIST_NODE(&c->list);
> -		hlist_add_head(&c->list, &hash_errmap[bucket]);
> +		hash_add(hash_errmap, &c->list, hash);
>  	}
>  
>  	return 1;
> @@ -223,13 +222,13 @@ int p9_errstr2errno(char *errstr, int len)
>  	int errno;
>  	struct hlist_node *p;
>  	struct errormap *c;
> -	int bucket;
> +	u32 hash;
>  
>  	errno = 0;
>  	p = NULL;
>  	c = NULL;
> -	bucket = jhash(errstr, len, 0) % ERRHASHSZ;
> -	hlist_for_each_entry(c, p, &hash_errmap[bucket], list) {
> +	hash = jhash(errstr, len, 0);
> +	hash_for_each_possible(hash_errmap, c, p, list, hash) {
>  		if (c->namelen == len && !memcmp(c->name, errstr, len)) {
>  			errno = c->val;
>  			break;
> -- 
> 1.7.12.4
> 

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
