Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 080316B0073
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 21:36:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Tue, 10 Jul 2012 02:22:35 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6A1Zm9S65536184
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:35:51 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6A1Zlqu015102
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:35:48 +1000
Message-ID: <1341884144.2562.18.camel@ThinkPad-T420>
Subject: Re: [PATCH SLAB 1/2 v3] duplicate the cache name in SLUB's
 saved_alias list, SLAB, and SLOB
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Tue, 10 Jul 2012 09:35:44 +0800
In-Reply-To: <alpine.DEB.2.00.1207090859420.27737@router.home>
References: <1341561286.24895.9.camel@ThinkPad-T420>
	 <alpine.DEB.2.00.1207060855320.26441@router.home>
	 <1341801721.2439.29.camel@ThinkPad-T420>
	 <alpine.DEB.2.00.1207090859420.27737@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>, Wanlong Gao <gaowanlong@cn.fujitsu.com>, Glauber Costa <glommer@parallels.com>

On Mon, 2012-07-09 at 09:01 -0500, Christoph Lameter wrote:
> > I was pointed by Glauber to the slab common code patches. I need some
> > more time to read the patches. Now I think the slab/slot changes in this
> > v3 are not needed, and can be ignored.
> 
> That may take some kernel cycles. You have a current issue here that needs
> to be fixed.

I'm a little confused ... and what need I do for the next step? 

> 
> > >  	down_write(&slub_lock);
> > > -	s = find_mergeable(size, align, flags, name, ctor);
> > > +	s = find_mergeable(size, align, flags, n, ctor);
> > >  	if (s) {
> > >  		s->refcount++;
> > >  		/*
> >
> > 		......
> > 		up_write(&slub_lock);
> > 		return s;
> > 	}
> >
> > Here, the function returns without name string n be kfreed.
> 
> That is intentional since the string n is still referenced by the entry
> that sysfs_slab_alias has created.

I'm not sure whether the "referenced by ..." you mentioned is what I
understood. From my understanding:

if slab_state == SYS_FS, after 
	return sysfs_create_link(&slab_kset->kobj, &s->kobj, name); 
is called, the name string passed in sysfs_slab_alias is no longer
referenced (sysfs_new_dirent duplicates the string for sysfs to use).

else, the name sting is referenced by 
	al->name = name;
temporarily. After slab_sysfs_init is finished, the name is not
referenced any more.

So in my patch (slub part), the string is duplicated here, and kfreed in
slab_sysfs_init.

> > But we couldn't kfree n here, because in sysfs_slab_alias(), if
> > (slab_state < SYS_FS), the name need to be kept valid until
> > slab_sysfs_init() is finished adding the entry into sysfs.
> 
> Right that is why it is not freed and that is what fixes the issue you
> see.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
