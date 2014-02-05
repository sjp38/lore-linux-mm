Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 285986B0036
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 18:20:11 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so953663pad.11
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 15:20:10 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id nf8si30691838pbc.210.2014.02.05.15.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 15:20:10 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so945383pab.5
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 15:20:09 -0800 (PST)
Date: Wed, 5 Feb 2014 15:20:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] Move the memory_notifier out of the memory_hotplug lock
In-Reply-To: <52F2C4F0.6080608@sgi.com>
Message-ID: <alpine.DEB.2.02.1402051512490.24489@chino.kir.corp.google.com>
References: <1391617743-150518-1-git-send-email-nzimmer@sgi.com> <alpine.DEB.2.02.1402051217520.5616@chino.kir.corp.google.com> <52F2C4F0.6080608@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jiang Liu <liuj97@gmail.com>, Hedi Berriche <hedi@sgi.com>, Mike Travis <travis@sgi.com>

On Wed, 5 Feb 2014, Nathan Zimmer wrote:

> > That looks a little problematic, what happens if a nid is being brought
> > online and a registered callback does something like allocate resources
> > for the arg->status_change_nid and the above two hunks of this patch end
> > up racing?
> > 
> > Before, a registered callback would be guaranteed to see either a
> > MEMORY_CANCEL_ONLINE or MEMORY_ONLINE after it has already done
> > MEMORY_GOING_ONLINE.
> > 
> > With your patch, we could race and see one cpu doing MEMORY_GOING_ONLINE,
> > another cpu doing MEMORY_GOING_ONLINE, and then MEMORY_ONLINE and
> > MEMORY_CANCEL_ONLINE in either order.
> > 
> > So I think this patch will break most registered callbacks that actually
> > depend on lock_memory_hotplug(), it's a coarse lock for that reason.
> 
> Since the argument being passed in is the pfn and size it would be an issue
> only if two threads attepted to online the same piece of memory. Right?
> 

No, I'm referring to registered callbacks that provide a resource for 
arg->status_change_nid.  An example would be the callbacks I added to the 
slub allocator in slab_memory_callback().  If we are now able to get a 
racy MEM_GOING_ONLINE -> MEM_GOING_ONLINE -> MEM_ONLINE -> 
MEM_CANCEL_ONLINE, which is possible with your patch _and_ the node being 
successfully onlined at the end, then we get a NULL pointer dereference 
because the kmem_cache_node for each slab cache has been freed.

> That seems very unlikely but if it can happen it needs to be protected
> against.
> 

The protection for registered memory online or offline callbacks is 
lock_memory_hotplug() which is eliminated with your patch, the locking for 
memory_notify() that you're citing is irrelevant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
