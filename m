Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C48DE6B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:23:25 -0400 (EDT)
Date: Mon, 29 Oct 2012 09:23:23 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 13/16] lockd: use new hashtable implementation
Message-ID: <20121029132323.GA16391@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-13-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351450948-15618-13-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> Switch lockd to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in lockd.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  fs/lockd/svcsubs.c | 66 +++++++++++++++++++++++++++++-------------------------
>  1 file changed, 36 insertions(+), 30 deletions(-)
> 
> diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> index 0deb5f6..d223a1f 100644
> --- a/fs/lockd/svcsubs.c
> +++ b/fs/lockd/svcsubs.c
> @@ -20,6 +20,7 @@
>  #include <linux/lockd/share.h>
>  #include <linux/module.h>
>  #include <linux/mount.h>
> +#include <linux/hashtable.h>
>  
>  #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
>  
> @@ -28,8 +29,7 @@
>   * Global file hash table
>   */
>  #define FILE_HASH_BITS		7
> -#define FILE_NRHASH		(1<<FILE_HASH_BITS)
> -static struct hlist_head	nlm_files[FILE_NRHASH];
> +static DEFINE_HASHTABLE(nlm_files, FILE_HASH_BITS);
>  static DEFINE_MUTEX(nlm_file_mutex);
>  
>  #ifdef NFSD_DEBUG
> @@ -68,7 +68,7 @@ static inline unsigned int file_hash(struct nfs_fh *f)
>  	int i;
>  	for (i=0; i<NFS2_FHSIZE;i++)
>  		tmp += f->data[i];
> -	return tmp & (FILE_NRHASH - 1);
> +	return tmp;
>  }
>  
>  /*
> @@ -86,17 +86,17 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
>  {
>  	struct hlist_node *pos;
>  	struct nlm_file	*file;
> -	unsigned int	hash;
> +	unsigned int	key;
>  	__be32		nfserr;
>  
>  	nlm_debug_print_fh("nlm_lookup_file", f);
>  
> -	hash = file_hash(f);
> +	key = file_hash(f);
>  
>  	/* Lock file table */
>  	mutex_lock(&nlm_file_mutex);
>  
> -	hlist_for_each_entry(file, pos, &nlm_files[hash], f_list)
> +	hash_for_each_possible(nlm_files, file, pos, f_list, file_hash(f))

we have a nice example of weirdness about key vs hash here:

1) "key" is computed from file_hash(f)
2) file_hash(f) is computed again and again in hash_for_each_possible()

>  		if (!nfs_compare_fh(&file->f_handle, f))
>  			goto found;
>  
> @@ -123,7 +123,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
>  		goto out_free;
>  	}
>  
> -	hlist_add_head(&file->f_list, &nlm_files[hash]);
> +	hash_add(nlm_files, &file->f_list, key);

3) then we use "key" as parameter to hash_add.

Moreover, we're adding dispersion to the file_hash() with the hash_32()
called under the hook within hashtable.h. Is it an intended behavior ?
This should at the very least be documented in the changelog.

[...]

> +static int __init nlm_init(void)
> +{
> +	hash_init(nlm_files);

Useless.

Thanks,

Mathieu

> +	return 0;
> +}
> +
> +module_init(nlm_init);
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
