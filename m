Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 74ED36B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:30:41 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id uq10so783370igb.5
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:30:41 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.179.29])
        by mx.google.com with ESMTP id lq7si3582871igb.12.2014.02.06.08.09.41
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 08:10:11 -0800 (PST)
Date: Thu, 6 Feb 2014 10:09:39 -0600
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: [RFC] Move the memory_notifier out of the memory_hotplug lock
Message-ID: <20140206160939.GA107343@asylum.americas.sgi.com>
References: <1391617743-150518-1-git-send-email-nzimmer@sgi.com> <alpine.DEB.2.02.1402051217520.5616@chino.kir.corp.google.com> <52F2C4F0.6080608@sgi.com> <alpine.DEB.2.02.1402051512490.24489@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402051512490.24489@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nathan Zimmer <nzimmer@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jiang Liu <liuj97@gmail.com>, Hedi Berriche <hedi@sgi.com>, Mike Travis <travis@sgi.com>

On Wed, Feb 05, 2014 at 03:20:07PM -0800, David Rientjes wrote:
> On Wed, 5 Feb 2014, Nathan Zimmer wrote:
> 
> > > That looks a little problematic, what happens if a nid is being brought
> > > online and a registered callback does something like allocate resources
> > > for the arg->status_change_nid and the above two hunks of this patch end
> > > up racing?
> > > 
> > > Before, a registered callback would be guaranteed to see either a
> > > MEMORY_CANCEL_ONLINE or MEMORY_ONLINE after it has already done
> > > MEMORY_GOING_ONLINE.
> > > 
> > > With your patch, we could race and see one cpu doing MEMORY_GOING_ONLINE,
> > > another cpu doing MEMORY_GOING_ONLINE, and then MEMORY_ONLINE and
> > > MEMORY_CANCEL_ONLINE in either order.
> > > 
> > > So I think this patch will break most registered callbacks that actually
> > > depend on lock_memory_hotplug(), it's a coarse lock for that reason.
> > 
> > Since the argument being passed in is the pfn and size it would be an issue
> > only if two threads attepted to online the same piece of memory. Right?
> > 
> 
> No, I'm referring to registered callbacks that provide a resource for 
> arg->status_change_nid.  An example would be the callbacks I added to the 
> slub allocator in slab_memory_callback().  If we are now able to get a 
> racy MEM_GOING_ONLINE -> MEM_GOING_ONLINE -> MEM_ONLINE -> 
> MEM_CANCEL_ONLINE, which is possible with your patch _and_ the node being 
> successfully onlined at the end, then we get a NULL pointer dereference 
> because the kmem_cache_node for each slab cache has been freed.
> 
Ok I think I see now.  In my testing I had only been onlining parts of nodes.
So all nodes were already had at least some memory online from the beginning.

> > That seems very unlikely but if it can happen it needs to be protected
> > against.
> > 
> 
> The protection for registered memory online or offline callbacks is 
> lock_memory_hotplug() which is eliminated with your patch, the locking for 
> memory_notify() that you're citing is irrelevant.

Would the race still exist if we left the position of the locks alone and 
broke it up by nid, something like this?


diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ee37657..e797e21 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -913,7 +913,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int ret;
 	struct memory_notify arg;
 
-	lock_memory_hotplug();
+	nid = page_to_nid(pfn_to_page(pfn));
+
+	lock_memory_hotplug(nid);
 	/*
 	 * This doesn't need a lock to do pfn_to_page().
 	 * The section can't be removed here because of the
@@ -923,19 +925,19 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	if ((zone_idx(zone) > ZONE_NORMAL || online_type == ONLINE_MOVABLE) &&
 	    !can_online_high_movable(zone)) {
-		unlock_memory_hotplug();
+		unlock_memory_hotplug(nid);
 		return -1;
 	}
 
 	if (online_type == ONLINE_KERNEL && zone_idx(zone) == ZONE_MOVABLE) {
 		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages)) {
-			unlock_memory_hotplug();
+			unlock_memory_hotplug(nid);
 			return -1;
 		}
 	}
 	if (online_type == ONLINE_MOVABLE && zone_idx(zone) == ZONE_MOVABLE - 1) {
 		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages)) {
-			unlock_memory_hotplug();
+			unlock_memory_hotplug(nid);
 			return -1;
 		}
 	}
@@ -947,13 +949,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	arg.nr_pages = nr_pages;
 	node_states_check_changes_online(nr_pages, zone, &arg);
 
-	nid = page_to_nid(pfn_to_page(pfn));
-
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
 	if (ret) {
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		unlock_memory_hotplug();
+		unlock_memory_hotplug(nid);
 		return ret;
 	}
 	/*
@@ -978,7 +978,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		       (((unsigned long long) pfn + nr_pages)
 			    << PAGE_SHIFT) - 1);
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		unlock_memory_hotplug();
+		unlock_memory_hotplug(nid);
 		return ret;
 	}
 
@@ -1006,7 +1006,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
-	unlock_memory_hotplug();
+	unlock_memory_hotplug(nid);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
