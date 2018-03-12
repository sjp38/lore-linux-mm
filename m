Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18FE76B0007
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 18:37:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p2so10068973wre.19
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 15:37:09 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v15si1597031eda.425.2018.03.12.15.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 15:37:07 -0700 (PDT)
Date: Mon, 12 Mar 2018 22:36:38 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180312223632.GA6124@castle>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180312211742.GR30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180312211742.GR30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Mar 12, 2018 at 09:17:42PM +0000, Al Viro wrote:
> On Mon, Mar 05, 2018 at 01:37:43PM +0000, Roman Gushchin wrote:
> > diff --git a/fs/dcache.c b/fs/dcache.c
> > index 5c7df1df81ff..a0312d73f575 100644
> > --- a/fs/dcache.c
> > +++ b/fs/dcache.c
> > @@ -273,8 +273,16 @@ static void __d_free(struct rcu_head *head)
> >  static void __d_free_external(struct rcu_head *head)
> >  {
> >  	struct dentry *dentry = container_of(head, struct dentry, d_u.d_rcu);
> > -	kfree(external_name(dentry));
> > -	kmem_cache_free(dentry_cache, dentry); 
> > +	struct external_name *name = external_name(dentry);
> > +	unsigned long bytes;
> > +
> > +	bytes = dentry->d_name.len + offsetof(struct external_name, name[1]);
> > +	mod_node_page_state(page_pgdat(virt_to_page(name)),
> > +			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
> > +			    -kmalloc_size(kmalloc_index(bytes)));
> > +
> > +	kfree(name);
> > +	kmem_cache_free(dentry_cache, dentry);
> >  }
> 
> That can't be right - external names can be freed in release_dentry_name_snapshot()
> and copy_name() as well.  When do you want kfree_rcu() paths accounted for, BTW?
> At the point where we are freeing them, or where we are scheduling their freeing?

Ah, I see...

I think, it's better to account them when we're actually freeing,
otherwise we will have strange path:
(indirectly) reclaimable -> unreclaimable -> free

Do you agree?

Although it shouldn't be that important in practice.

Thank you!

--
