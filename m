Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D34C06B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:29:33 -0400 (EDT)
Date: Mon, 29 Oct 2012 09:29:31 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 15/16] openvswitch: use new hashtable implementation
Message-ID: <20121029132931.GC16391@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-15-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351450948-15618-15-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
[...]
> -static struct hlist_head *hash_bucket(struct net *net, const char *name)
> -{
> -	unsigned int hash = jhash(name, strlen(name), (unsigned long) net);
> -	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
> -}
> -
>  /**
>   *	ovs_vport_locate - find a port that has already been created
>   *
> @@ -84,13 +76,12 @@ static struct hlist_head *hash_bucket(struct net *net, const char *name)
>   */
>  struct vport *ovs_vport_locate(struct net *net, const char *name)
>  {
> -	struct hlist_head *bucket = hash_bucket(net, name);
>  	struct vport *vport;
>  	struct hlist_node *node;
> +	int key = full_name_hash(name, strlen(name));
>  
> -	hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
> -		if (!strcmp(name, vport->ops->get_name(vport)) &&
> -		    net_eq(ovs_dp_get_net(vport->dp), net))
> +	hash_for_each_possible_rcu(dev_table, vport, node, hash_node, key)

Is applying hash_32() on top of full_name_hash() needed and expected ?

Thanks,

Mathieu

> +		if (!strcmp(name, vport->ops->get_name(vport)))
>  			return vport;
>  
>  	return NULL;
> @@ -174,7 +165,8 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
>  
>  	for (i = 0; i < ARRAY_SIZE(vport_ops_list); i++) {
>  		if (vport_ops_list[i]->type == parms->type) {
> -			struct hlist_head *bucket;
> +			int key;
> +			const char *name;
>  
>  			vport = vport_ops_list[i]->create(parms);
>  			if (IS_ERR(vport)) {
> @@ -182,9 +174,9 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
>  				goto out;
>  			}
>  
> -			bucket = hash_bucket(ovs_dp_get_net(vport->dp),
> -					     vport->ops->get_name(vport));
> -			hlist_add_head_rcu(&vport->hash_node, bucket);
> +			name = vport->ops->get_name(vport);
> +			key = full_name_hash(name, strlen(name));
> +			hash_add_rcu(dev_table, &vport->hash_node, key);
>  			return vport;
>  		}
>  	}
> @@ -225,7 +217,7 @@ void ovs_vport_del(struct vport *vport)
>  {
>  	ASSERT_RTNL();
>  
> -	hlist_del_rcu(&vport->hash_node);
> +	hash_del_rcu(&vport->hash_node);
>  
>  	vport->ops->destroy(vport);
>  }
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
