Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 013AC6B0093
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 22:49:36 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 08:19:33 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q2nRva7405838
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 08:19:28 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q8Ii3e020258
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:18:45 +1000
Message-ID: <1340678964.16381.20.camel@ThinkPad-T420>
Subject: Re: [PATCH SLUB 1/2] duplicate the cache name in saved_alias list
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2012 10:49:24 +0800
In-Reply-To: <4FE84352.8090303@cn.fujitsu.com>
References: <1340617984.13778.37.camel@ThinkPad-T420>
	 <4FE84352.8090303@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaowanlong@cn.fujitsu.com
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>

On Mon, 2012-06-25 at 18:54 +0800, Wanlong Gao wrote:
> On 06/25/2012 05:53 PM, Li Zhong wrote:
> > SLUB duplicates the cache name in kmem_cache_create(). However if the
> > cache could be merged to others during early booting, the name pointer
> > is saved in saved_alias list, and the string needs to be kept valid
> > before slab_sysfs_init() is called. 
> > 
> > This patch tries to duplicate the cache name in saved_alias list, so
> > that the cache name could be safely kfreed after calling
> > kmem_cache_create(), if that name is kmalloced. 
> > 
> > Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> > ---
> >  mm/slub.c |    6 ++++++
> >  1 files changed, 6 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 8c691fa..3dc8ed5 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -5373,6 +5373,11 @@ static int sysfs_slab_alias(struct kmem_cache *s,
> > const char *name)
> >  
> >  	al->s = s;
> >  	al->name = name;
> > +	al->name = kstrdup(name, GFP_KERNEL);
> 
> dup assigned the al->name ?
> 

Ah, yes, there should be a '-' before the line al->name = name;

Thank you, I will update it. 

> Thanks,
> Wanlong Gao
> 
> > +	if (!al->name) {
> > +		kfree(al);
> > +		return -ENOMEM;
> > +	}
> >  	al->next = alias_list;
> >  	alias_list = al;
> >  	return 0;
> > @@ -5409,6 +5414,7 @@ static int __init slab_sysfs_init(void)
> >  		if (err)
> >  			printk(KERN_ERR "SLUB: Unable to add boot slab alias"
> >  					" %s to sysfs\n", s->name);
> > +		kfree(al->name);
> >  		kfree(al);
> >  	}
> >  
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
