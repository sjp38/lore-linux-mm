Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id D82A26B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 08:45:05 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id v16so3279411bkz.27
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 05:45:05 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id tv4si8641611bkb.228.2013.11.27.05.45.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 05:45:05 -0800 (PST)
Date: Wed, 27 Nov 2013 14:44:58 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: netfilter: active obj WARN when cleaning up
In-Reply-To: <20131127134015.GA6011@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.02.1311271443580.30673@ionos.tec.linutronix.de>
References: <522B25B5.6000808@oracle.com> <5294F27D.4000108@oracle.com> <20131126230709.GA10948@localhost> <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de> <20131127113939.GL16735@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1311271409280.30673@ionos.tec.linutronix.de>
 <20131127133231.GO16735@n2100.arm.linux.org.uk> <20131127134015.GA6011@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Greg KH <greg@kroah.com>

On Wed, 27 Nov 2013, Russell King - ARM Linux wrote:

> On Wed, Nov 27, 2013 at 01:32:31PM +0000, Russell King - ARM Linux wrote:
> > On Wed, Nov 27, 2013 at 02:29:41PM +0100, Thomas Gleixner wrote:
> > > Though the kobject is the only thing which has a delayed work embedded
> > > inside struct kmem_cache. And the debug object splat points at the
> > > kmem_cache_free() of the struct kmem_cache itself. That's why I
> > > assumed the wreckage around that place. And indeed:
> > > 
> > > kmem_cache_destroy(s)
> > >     __kmem_cache_shutdown(s)
> > >       sysfs_slab_remove(s)
> > >         ....
> > > 	kobject_put(&s->kobj)
> > >            kref_put(&kobj->kref, kobject_release);
> > > 	     kobject_release(kref)
> > >     	       #ifdef CONFIG_DEBUG_KOBJECT_RELEASE
> > > 	         schedule_delayed_work(&kobj->release)
> > > 	       #else
> > > 	        kobject_cleanup(kobj)
> > > 	       #endif
> > > 
> > > So in the CONFIG_DEBUG_KOBJECT_RELEASE=y case, schedule_delayed_work()
> > > _IS_ called which arms the timer. debugobjects catches the attempt to
> > > free struct kmem_cache which contains the armed timer.
> > 
> > You fail to show where the free is in the above path.
> 
> Right, there's a kmem_cache_free(kmem_cache, s); by the slob code
> after the above sequence, which is The Bug(tm).
> 
> As I said, a kobject has its own lifetime.  If you embed that into
> another structure, that structure inherits the lifetime of the kobject,
> which is from the point at which it's created to the point at which the
> kobject's release function is called.
> 
> So no, the code here is buggy.  The kobject debugging has yet again
> found a violation of the kobject lifetime rules.  slub needs fixing.

I leave that discussion to you, greg and the slub folks.

/me prepares deck chair, drinks and popcorn 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
