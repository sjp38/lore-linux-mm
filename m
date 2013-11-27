Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id D11746B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 08:33:03 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so6633035wgg.28
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 05:33:03 -0800 (PST)
Received: from caramon.arm.linux.org.uk (caramon.arm.linux.org.uk. [78.32.30.218])
        by mx.google.com with ESMTPS id a5si21303213wjb.32.2013.11.27.05.33.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 05:33:03 -0800 (PST)
Date: Wed, 27 Nov 2013 13:32:31 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: netfilter: active obj WARN when cleaning up
Message-ID: <20131127133231.GO16735@n2100.arm.linux.org.uk>
References: <522B25B5.6000808@oracle.com> <5294F27D.4000108@oracle.com> <20131126230709.GA10948@localhost> <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de> <20131127113939.GL16735@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1311271409280.30673@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271409280.30673@ionos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Greg KH <greg@kroah.com>

On Wed, Nov 27, 2013 at 02:29:41PM +0100, Thomas Gleixner wrote:
> Though the kobject is the only thing which has a delayed work embedded
> inside struct kmem_cache. And the debug object splat points at the
> kmem_cache_free() of the struct kmem_cache itself. That's why I
> assumed the wreckage around that place. And indeed:
> 
> kmem_cache_destroy(s)
>     __kmem_cache_shutdown(s)
>       sysfs_slab_remove(s)
>         ....
> 	kobject_put(&s->kobj)
>            kref_put(&kobj->kref, kobject_release);
> 	     kobject_release(kref)
>     	       #ifdef CONFIG_DEBUG_KOBJECT_RELEASE
> 	         schedule_delayed_work(&kobj->release)
> 	       #else
> 	        kobject_cleanup(kobj)
> 	       #endif
> 
> So in the CONFIG_DEBUG_KOBJECT_RELEASE=y case, schedule_delayed_work()
> _IS_ called which arms the timer. debugobjects catches the attempt to
> free struct kmem_cache which contains the armed timer.

You fail to show where the free is in the above path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
