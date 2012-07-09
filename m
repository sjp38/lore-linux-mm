Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 243996B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:01:16 -0400 (EDT)
Date: Mon, 9 Jul 2012 09:01:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH SLAB 1/2 v3] duplicate the cache name in SLUB's saved_alias
 list, SLAB, and SLOB
In-Reply-To: <1341801721.2439.29.camel@ThinkPad-T420>
Message-ID: <alpine.DEB.2.00.1207090859420.27737@router.home>
References: <1341561286.24895.9.camel@ThinkPad-T420> <alpine.DEB.2.00.1207060855320.26441@router.home> <1341801721.2439.29.camel@ThinkPad-T420>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>, Wanlong Gao <gaowanlong@cn.fujitsu.com>, Glauber Costa <glommer@parallels.com>


> I was pointed by Glauber to the slab common code patches. I need some
> more time to read the patches. Now I think the slab/slot changes in this
> v3 are not needed, and can be ignored.

That may take some kernel cycles. You have a current issue here that needs
to be fixed.

> >  	down_write(&slub_lock);
> > -	s = find_mergeable(size, align, flags, name, ctor);
> > +	s = find_mergeable(size, align, flags, n, ctor);
> >  	if (s) {
> >  		s->refcount++;
> >  		/*
>
> 		......
> 		up_write(&slub_lock);
> 		return s;
> 	}
>
> Here, the function returns without name string n be kfreed.

That is intentional since the string n is still referenced by the entry
that sysfs_slab_alias has created.

> But we couldn't kfree n here, because in sysfs_slab_alias(), if
> (slab_state < SYS_FS), the name need to be kept valid until
> slab_sysfs_init() is finished adding the entry into sysfs.

Right that is why it is not freed and that is what fixes the issue you
see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
