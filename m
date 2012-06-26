Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A63056B00B5
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 22:58:36 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 08:28:29 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q2wQKT262404
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 08:28:26 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q8T5mg017604
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:29:05 +1000
Message-ID: <1340679504.16381.23.camel@ThinkPad-T420>
Subject: Re: [PATCH SLUB 1/2] duplicate the cache name in saved_alias list
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2012 10:58:24 +0800
In-Reply-To: <4FE84741.9000703@parallels.com>
References: <1340617984.13778.37.camel@ThinkPad-T420>
	 <4FE84741.9000703@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>

On Mon, 2012-06-25 at 15:10 +0400, Glauber Costa wrote:
> On 06/25/2012 01:53 PM, Li Zhong wrote:
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
> >   mm/slub.c |    6 ++++++
> >   1 files changed, 6 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 8c691fa..3dc8ed5 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -5373,6 +5373,11 @@ static int sysfs_slab_alias(struct kmem_cache *s,
> > const char *name)
> >
> >   	al->s = s;
> >   	al->name = name;
> > +	al->name = kstrdup(name, GFP_KERNEL);
> > +	if (!al->name) {
> > +		kfree(al);
> > +		return -ENOMEM;
> > +	}
> >   	al->next = alias_list;
> >   	alias_list = al;
> >   	return 0;
> > @@ -5409,6 +5414,7 @@ static int __init slab_sysfs_init(void)
> >   		if (err)
> >   			printk(KERN_ERR "SLUB: Unable to add boot slab alias"
> >   					" %s to sysfs\n", s->name);
> > +		kfree(al->name);
> >   		kfree(al);
> >   	}
> >
> >
> 
> What's unsafe about the current state of affairs ?
> Whenever we alias, we'll increase the reference counter.
> kmem_cache_destroy will only actually destroy the structure whenever 
> that refcnt reaches zero.
> 
> This means that kfree shouldn't happen until then. So what is exactly 
> that you are seeing?

Maybe I didn't describe it clearly ... It is only about the name string
passed into kmem_cache_create() during early boot. 

kmem_cache_create() checks whether it is mergeable before creating one.
If not mergeable, the name is duplicated: n = kstrdup(name, GFP_KERNEL);

If it is mergeable, it calls sysfs_slab_alias(). If the sysfs is ready
(slab_state == SYSFS ), then the name is duplicated (or dropped if no
SYSFS support ) in sysfs_create_link() for use. 

For the above cases, we could safely kfree the name string after calling
cache create. 

However, During early boot, before sysfs is ready ( slab_state <
SYSFS ), the sysfs_slab_alias() saves the pointer of name in the
alias_list. And those entries in the list are added to sysfs later after
slab_sysfs_init() is called. So we need to keep the name string valid
until slab_sysfs_init() is called to set up the sysfs stuff. By
duplicating the name string here also, we are able to kfree the name
string after calling the cache create. 

> 
> Now, if you ask me, keeping the name around in user-visible files like 
> /proc/slabinfo for caches that are removed already can be a bit 
> confusing (that is because we don't add aliases to the slab_cache list)
> 
> If you want to touch this, one thing you can do is to keep a list of 
> names bundled in an alias. If an alias is removed, you free that name. 
> If that name is the representative name of the bundle, you move to the 
> next one.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
