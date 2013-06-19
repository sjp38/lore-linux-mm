Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id B80BC6B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 05:12:37 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id aq17so11604248iec.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 02:12:37 -0700 (PDT)
Message-ID: <1371633148.2984.18.camel@ThinkPad-T5421>
Subject: Re: [PATCH v11 25/25] list_lru: dynamically adjust node arrays
From: Li Zhong <lizhongfs@gmail.com>
Reply-To: lizhongfs@gmail.com
Date: Wed, 19 Jun 2013 17:12:28 +0800
In-Reply-To: <20130619073154.GA1990@localhost.localdomain>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
	 <1370550898-26711-26-git-send-email-glommer@openvz.org>
	 <1371548521.2984.6.camel@ThinkPad-T5421>
	 <20130619073154.GA1990@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Glauber Costa <glommer@openvz.org>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>

On Wed, 2013-06-19 at 11:31 +0400, Glauber Costa wrote:
> On Tue, Jun 18, 2013 at 05:42:01PM +0800, Li Zhong wrote:
> > On Fri, 2013-06-07 at 00:34 +0400, Glauber Costa wrote:
>  > 
> > > diff --git a/fs/super.c b/fs/super.c
> > > index 85a6104..1b6ef7b 100644
> > > --- a/fs/super.c
> > > +++ b/fs/super.c
> > > @@ -199,8 +199,12 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
> > >  		INIT_HLIST_NODE(&s->s_instances);
> > >  		INIT_HLIST_BL_HEAD(&s->s_anon);
> > >  		INIT_LIST_HEAD(&s->s_inodes);
> > > -		list_lru_init(&s->s_dentry_lru);
> > > -		list_lru_init(&s->s_inode_lru);
> > > +
> > > +		if (list_lru_init(&s->s_dentry_lru))
> > > +			goto err_out;
> > > +		if (list_lru_init(&s->s_inode_lru))
> > > +			goto err_out_dentry_lru;
> > > +
> > >  		INIT_LIST_HEAD(&s->s_mounts);
> > >  		init_rwsem(&s->s_umount);
> > >  		lockdep_set_class(&s->s_umount, &type->s_umount_key);
> > > @@ -240,6 +244,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
> > >  	}
> > >  out:
> > >  	return s;
> > > +
> > > +err_out_dentry_lru:
> > > +	list_lru_destroy(&s->s_dentry_lru);
> > >  err_out:
> > >  	security_sb_free(s);
> > >  #ifdef CONFIG_SMP
> > 
> > It seems we also need to call list_lru_destroy() in destroy_super()? 
> > like below:
> >  
> > -----------
> > diff --git a/fs/super.c b/fs/super.c
> > index b79e732..06ee3af 100644
> > --- a/fs/super.c
> > +++ b/fs/super.c
> > @@ -269,6 +269,8 @@ err_out:
> >   */
> >  static inline void destroy_super(struct super_block *s)
> >  {
> > +	list_lru_destroy(&s->s_inode_lru);
> > +	list_lru_destroy(&s->s_dentry_lru);
> >  #ifdef CONFIG_SMP
> >  	free_percpu(s->s_files);
> >  #endif
> 
> Hi
> 
> Thanks for taking a look at this.
> 
> list_lru_destroy is called by deactivate_lock_super, so we should be fine already.

Sorry, I'm a little confused...

I didn't see list_lru_destroy() called in deactivate_locked_super().
Maybe I missed something? 

But it seems other memory allocated in alloc_super(), are freed in
destroy_super(), e.g. ->s_files, why don't we also free this one here? 

Thanks, Zhong


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
