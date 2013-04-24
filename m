Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id DF9496B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 04:42:46 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Wed, 24 Apr 2013 02:42:41 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3026F19D8042
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 02:42:33 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3O8gcnE357870
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 02:42:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3O8gadt006078
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 02:42:38 -0600
Date: Wed, 24 Apr 2013 16:42:29 +0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v3 2/3] resource: Add release_mem_region_adjustable()
Message-ID: <20130424084229.GB29191@ram.oc3035372033.ibm.com>
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1365614221-685-1-git-send-email-toshi.kani@hp.com>
 <1365614221-685-3-git-send-email-toshi.kani@hp.com>
 <20130410144412.395bf9f2fb8192920175e30a@linux-foundation.org>
 <1365630585.32127.110.camel@misato.fc.hp.com>
 <alpine.DEB.2.02.1304101505250.1526@chino.kir.corp.google.com>
 <20130410152404.e0836af597ba3545b9846672@linux-foundation.org>
 <1365697802.32127.117.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365697802.32127.117.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Thu, Apr 11, 2013 at 10:30:02AM -0600, Toshi Kani wrote:
> On Wed, 2013-04-10 at 15:24 -0700, Andrew Morton wrote:
> > On Wed, 10 Apr 2013 15:08:29 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > 
> > > On Wed, 10 Apr 2013, Toshi Kani wrote:
> > > 
> > > > > I'll switch it to GFP_ATOMIC.  Which is horridly lame but the
> > > > > allocation is small and alternatives are unobvious.
> > > > 
> > > > Great!  Again, thanks for the update!
> > > 
> > > release_mem_region_adjustable() allocates at most one struct resource, so 
> > > why not do kmalloc(sizeof(struct resource), GFP_KERNEL) before taking 
> > > resource_lock and then testing whether it's NULL or not when splitting?  
> > > It unnecessarily allocates memory when there's no split, but 
> > > __remove_pages() shouldn't be a hotpath.
> > 
> > yup.
> > 
> > --- a/kernel/resource.c~resource-add-release_mem_region_adjustable-fix-fix
> > +++ a/kernel/resource.c
> > @@ -1046,7 +1046,8 @@ int release_mem_region_adjustable(struct
> >  			resource_size_t start, resource_size_t size)
> >  {
> >  	struct resource **p;
> > -	struct resource *res, *new;
> > +	struct resource *res;
> > +	struct resource *new_res;
> >  	resource_size_t end;
> >  	int ret = -EINVAL;
> >  
> > @@ -1054,6 +1055,9 @@ int release_mem_region_adjustable(struct
> >  	if ((start < parent->start) || (end > parent->end))
> >  		return ret;
> >  
> > +	/* The kzalloc() result gets checked later */
> > +	new_res = kzalloc(sizeof(struct resource), GFP_KERNEL);
> > +
> >  	p = &parent->child;
> >  	write_lock(&resource_lock);
> >  
> > @@ -1091,32 +1095,33 @@ int release_mem_region_adjustable(struct
> >  						start - res->start);
> >  		} else {
> >  			/* split into two entries */
> > -			new = kzalloc(sizeof(struct resource), GFP_ATOMIC);
> > -			if (!new) {
> > +			if (!new_res) {
> >  				ret = -ENOMEM;
> >  				break;
> >  			}
> > -			new->name = res->name;
> > -			new->start = end + 1;
> > -			new->end = res->end;
> > -			new->flags = res->flags;
> > -			new->parent = res->parent;
> > -			new->sibling = res->sibling;
> > -			new->child = NULL;
> > +			new_res->name = res->name;
> > +			new_res->start = end + 1;
> > +			new_res->end = res->end;
> > +			new_res->flags = res->flags;
> > +			new_res->parent = res->parent;
> > +			new_res->sibling = res->sibling;
> > +			new_res->child = NULL;
> >  
> >  			ret = __adjust_resource(res, res->start,
> >  						start - res->start);
> >  			if (ret) {
> > -				kfree(new);
> > +				kfree(new_res);
> >  				break;
> >  			}
> 
> The kfree() in the if-statement above is not necessary since kfree() is
> called before the return at the end.  That is, the if-statement needs to
> be:
> 	if (ret)
> 		break;
> 
> With this change, I confirmed that all my test cases passed (with all
> the config debug options this time :).  With the change:
> 
> Reviewed-by: Toshi Kani <toshi.kani@hp.com>

I am not confortable witht the assumption, that when a split takes
place, the children are assumed to be in the lower entry. Probably a
warning to that effect,  would help quickly
nail down the problem, if such a case does encounter ?

Otherwise this looks fine. Sorry for the delayed reply. Was out.

Reviewed-by: Ram Pai <linuxram@us.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
