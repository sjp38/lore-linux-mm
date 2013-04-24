Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id E028C6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 10:56:17 -0400 (EDT)
Message-ID: <1366814613.10719.20.camel@misato.fc.hp.com>
Subject: Re: [PATCH v3 2/3] resource: Add release_mem_region_adjustable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 24 Apr 2013 08:43:33 -0600
In-Reply-To: <20130424084229.GB29191@ram.oc3035372033.ibm.com>
References: <1365614221-685-1-git-send-email-toshi.kani@hp.com>
	 <1365614221-685-3-git-send-email-toshi.kani@hp.com>
	 <20130410144412.395bf9f2fb8192920175e30a@linux-foundation.org>
	 <1365630585.32127.110.camel@misato.fc.hp.com>
	 <alpine.DEB.2.02.1304101505250.1526@chino.kir.corp.google.com>
	 <20130410152404.e0836af597ba3545b9846672@linux-foundation.org>
	 <1365697802.32127.117.camel@misato.fc.hp.com>
	 <20130424084229.GB29191@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Wed, 2013-04-24 at 16:42 +0800, Ram Pai wrote:
> On Thu, Apr 11, 2013 at 10:30:02AM -0600, Toshi Kani wrote:
> > On Wed, 2013-04-10 at 15:24 -0700, Andrew Morton wrote:
> > > On Wed, 10 Apr 2013 15:08:29 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > > 
> > > > On Wed, 10 Apr 2013, Toshi Kani wrote:
> > > > 
> > > > > > I'll switch it to GFP_ATOMIC.  Which is horridly lame but the
> > > > > > allocation is small and alternatives are unobvious.
> > > > > 
> > > > > Great!  Again, thanks for the update!
> > > > 
> > > > release_mem_region_adjustable() allocates at most one struct resource, so 
> > > > why not do kmalloc(sizeof(struct resource), GFP_KERNEL) before taking 
> > > > resource_lock and then testing whether it's NULL or not when splitting?  
> > > > It unnecessarily allocates memory when there's no split, but 
> > > > __remove_pages() shouldn't be a hotpath.
> > > 
> > > yup.
> > > 
> > > --- a/kernel/resource.c~resource-add-release_mem_region_adjustable-fix-fix
> > > +++ a/kernel/resource.c
> > > @@ -1046,7 +1046,8 @@ int release_mem_region_adjustable(struct
> > >  			resource_size_t start, resource_size_t size)
> > >  {
> > >  	struct resource **p;
> > > -	struct resource *res, *new;
> > > +	struct resource *res;
> > > +	struct resource *new_res;
> > >  	resource_size_t end;
> > >  	int ret = -EINVAL;
> > >  
> > > @@ -1054,6 +1055,9 @@ int release_mem_region_adjustable(struct
> > >  	if ((start < parent->start) || (end > parent->end))
> > >  		return ret;
> > >  
> > > +	/* The kzalloc() result gets checked later */
> > > +	new_res = kzalloc(sizeof(struct resource), GFP_KERNEL);
> > > +
> > >  	p = &parent->child;
> > >  	write_lock(&resource_lock);
> > >  
> > > @@ -1091,32 +1095,33 @@ int release_mem_region_adjustable(struct
> > >  						start - res->start);
> > >  		} else {
> > >  			/* split into two entries */
> > > -			new = kzalloc(sizeof(struct resource), GFP_ATOMIC);
> > > -			if (!new) {
> > > +			if (!new_res) {
> > >  				ret = -ENOMEM;
> > >  				break;
> > >  			}
> > > -			new->name = res->name;
> > > -			new->start = end + 1;
> > > -			new->end = res->end;
> > > -			new->flags = res->flags;
> > > -			new->parent = res->parent;
> > > -			new->sibling = res->sibling;
> > > -			new->child = NULL;
> > > +			new_res->name = res->name;
> > > +			new_res->start = end + 1;
> > > +			new_res->end = res->end;
> > > +			new_res->flags = res->flags;
> > > +			new_res->parent = res->parent;
> > > +			new_res->sibling = res->sibling;
> > > +			new_res->child = NULL;
> > >  
> > >  			ret = __adjust_resource(res, res->start,
> > >  						start - res->start);
> > >  			if (ret) {
> > > -				kfree(new);
> > > +				kfree(new_res);
> > >  				break;
> > >  			}
> > 
> > The kfree() in the if-statement above is not necessary since kfree() is
> > called before the return at the end.  That is, the if-statement needs to
> > be:
> > 	if (ret)
> > 		break;
> > 
> > With this change, I confirmed that all my test cases passed (with all
> > the config debug options this time :).  With the change:
> > 
> > Reviewed-by: Toshi Kani <toshi.kani@hp.com>
> 
> I am not confortable witht the assumption, that when a split takes
> place, the children are assumed to be in the lower entry. Probably a
> warning to that effect,  would help quickly
> nail down the problem, if such a case does encounter ?

Yes, __adjust_resource() fails with -EBUSY when such condition happens.
Hence, release_mem_region_adjustable() returns with -EBUSY, and
__remove_pages() emits a warning message per patch 3/3.  So, it can be
quickly nailed down as this restriction is documented in the comment as
well.

At this point, the children are only used for Kernel code/data/bss as
follows.  Hot-removable memory ranges are located at higher ranges than
them.  So, I decided to simplify the implementation for this initial
version.  We can always enhance it when needed.

# cat /proc/iomem
 :
00100000-defa57ff : System RAM
  01000000-0162f8d1 : Kernel code
  0162f8d2-01ce52bf : Kernel data
  01df1000-01fa5fff : Kernel bss
 :
100000000-31fffffff : System RAM


> Otherwise this looks fine. Sorry for the delayed reply. Was out.
> 
> Reviewed-by: Ram Pai <linuxram@us.ibm.com>

No problem.  Thanks for reviewing!
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
