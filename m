Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E6A576B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 03:32:01 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ea20so4298836lab.36
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 00:32:00 -0700 (PDT)
Date: Wed, 19 Jun 2013 11:31:56 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: [PATCH v11 25/25] list_lru: dynamically adjust node arrays
Message-ID: <20130619073154.GA1990@localhost.localdomain>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
 <1370550898-26711-26-git-send-email-glommer@openvz.org>
 <1371548521.2984.6.camel@ThinkPad-T5421>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371548521.2984.6.camel@ThinkPad-T5421>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <lizhongfs@gmail.com>
Cc: Glauber Costa <glommer@openvz.org>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>

On Tue, Jun 18, 2013 at 05:42:01PM +0800, Li Zhong wrote:
> On Fri, 2013-06-07 at 00:34 +0400, Glauber Costa wrote:
 > 
> > diff --git a/fs/super.c b/fs/super.c
> > index 85a6104..1b6ef7b 100644
> > --- a/fs/super.c
> > +++ b/fs/super.c
> > @@ -199,8 +199,12 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
> >  		INIT_HLIST_NODE(&s->s_instances);
> >  		INIT_HLIST_BL_HEAD(&s->s_anon);
> >  		INIT_LIST_HEAD(&s->s_inodes);
> > -		list_lru_init(&s->s_dentry_lru);
> > -		list_lru_init(&s->s_inode_lru);
> > +
> > +		if (list_lru_init(&s->s_dentry_lru))
> > +			goto err_out;
> > +		if (list_lru_init(&s->s_inode_lru))
> > +			goto err_out_dentry_lru;
> > +
> >  		INIT_LIST_HEAD(&s->s_mounts);
> >  		init_rwsem(&s->s_umount);
> >  		lockdep_set_class(&s->s_umount, &type->s_umount_key);
> > @@ -240,6 +244,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
> >  	}
> >  out:
> >  	return s;
> > +
> > +err_out_dentry_lru:
> > +	list_lru_destroy(&s->s_dentry_lru);
> >  err_out:
> >  	security_sb_free(s);
> >  #ifdef CONFIG_SMP
> 
> It seems we also need to call list_lru_destroy() in destroy_super()? 
> like below:
>  
> -----------
> diff --git a/fs/super.c b/fs/super.c
> index b79e732..06ee3af 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -269,6 +269,8 @@ err_out:
>   */
>  static inline void destroy_super(struct super_block *s)
>  {
> +	list_lru_destroy(&s->s_inode_lru);
> +	list_lru_destroy(&s->s_dentry_lru);
>  #ifdef CONFIG_SMP
>  	free_percpu(s->s_files);
>  #endif

Hi

Thanks for taking a look at this.

list_lru_destroy is called by deactivate_lock_super, so we should be fine already.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
