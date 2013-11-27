Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1E56B0036
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 18:34:19 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so10863608pdj.18
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 15:34:19 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id sn7si35091988pab.196.2013.11.27.15.34.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Nov 2013 15:34:18 -0800 (PST)
Date: Wed, 27 Nov 2013 15:34:15 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: netfilter: active obj WARN when cleaning up
Message-ID: <20131127233415.GB19270@kroah.com>
References: <522B25B5.6000808@oracle.com>
 <5294F27D.4000108@oracle.com>
 <20131126230709.GA10948@localhost>
 <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de>
 <20131127113939.GL16735@n2100.arm.linux.org.uk>
 <alpine.DEB.2.02.1311271409280.30673@ionos.tec.linutronix.de>
 <20131127133231.GO16735@n2100.arm.linux.org.uk>
 <20131127134015.GA6011@n2100.arm.linux.org.uk>
 <alpine.DEB.2.02.1311271443580.30673@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271443580.30673@ionos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Nov 27, 2013 at 02:44:58PM +0100, Thomas Gleixner wrote:
> On Wed, 27 Nov 2013, Russell King - ARM Linux wrote:
> 
> > On Wed, Nov 27, 2013 at 01:32:31PM +0000, Russell King - ARM Linux wrote:
> > > On Wed, Nov 27, 2013 at 02:29:41PM +0100, Thomas Gleixner wrote:
> > > > Though the kobject is the only thing which has a delayed work embedded
> > > > inside struct kmem_cache. And the debug object splat points at the
> > > > kmem_cache_free() of the struct kmem_cache itself. That's why I
> > > > assumed the wreckage around that place. And indeed:
> > > > 
> > > > kmem_cache_destroy(s)
> > > >     __kmem_cache_shutdown(s)
> > > >       sysfs_slab_remove(s)
> > > >         ....
> > > > 	kobject_put(&s->kobj)
> > > >            kref_put(&kobj->kref, kobject_release);
> > > > 	     kobject_release(kref)
> > > >     	       #ifdef CONFIG_DEBUG_KOBJECT_RELEASE
> > > > 	         schedule_delayed_work(&kobj->release)
> > > > 	       #else
> > > > 	        kobject_cleanup(kobj)
> > > > 	       #endif
> > > > 
> > > > So in the CONFIG_DEBUG_KOBJECT_RELEASE=y case, schedule_delayed_work()
> > > > _IS_ called which arms the timer. debugobjects catches the attempt to
> > > > free struct kmem_cache which contains the armed timer.
> > > 
> > > You fail to show where the free is in the above path.
> > 
> > Right, there's a kmem_cache_free(kmem_cache, s); by the slob code
> > after the above sequence, which is The Bug(tm).
> > 
> > As I said, a kobject has its own lifetime.  If you embed that into
> > another structure, that structure inherits the lifetime of the kobject,
> > which is from the point at which it's created to the point at which the
> > kobject's release function is called.
> > 
> > So no, the code here is buggy.  The kobject debugging has yet again
> > found a violation of the kobject lifetime rules.  slub needs fixing.
> 
> I leave that discussion to you, greg and the slub folks.

/me grabs some popcorn from tglx

It's really not that much of a discussion, Documentation/kobject.txt has
said this for years, it's as if no one even reads documentation
anymore...

If you embed a kobject into a structure, you have to use the kobject for
the reference counting of the structure, otherwise it's a bug.  If you
don't want to use a kobject to reference count the structure, don't
embed it into it, use a pointer.

Are "slabs" never freed in the slub allocator?  Surely someone should
have seen the huge "this kobject doesn't have a release function" error
message that the kernel should have spit out for it?

Just make the kobject "dynamic" instead of embedded in struct kmem_cache
and all will be fine.  I can't believe this code has been broken for
this long.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
