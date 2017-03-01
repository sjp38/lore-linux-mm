Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9C86B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 08:07:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b5so25533501pfa.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 05:07:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a91si4586421pld.245.2017.03.01.05.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 05:07:29 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v21D4Q9L066832
	for <linux-mm@kvack.org>; Wed, 1 Mar 2017 08:07:28 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28wxrarkrw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Mar 2017 08:07:26 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 1 Mar 2017 13:07:22 -0000
Date: Wed, 1 Mar 2017 13:51:05 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm, add_memory_resource: hold device_hotplug lock over
 mem_hotplug_{begin, done}
References: <alpine.LFD.2.20.1702261231580.3067@schleppi.fritz.box>
 <20170227162031.GA27937@dhcp22.suse.cz>
 <20170228115729.GB13872@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228115729.GB13872@osiris>
Message-Id: <20170301125105.GA5208@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>

On Tue, Feb 28, 2017 at 12:57:29PM +0100, Heiko Carstens wrote:
> On Mon, Feb 27, 2017 at 05:20:31PM +0100, Michal Hocko wrote:
> > [CC Rafael]
> > 
> > I've got lost in the acpi indirection (again). I can see
> > acpi_device_hotplug calling lock_device_hotplug() but i cannot find a
> > path down to add_memory() which might call add_memory_resource. But the
> > patch below sounds suspicious to me. Is it possible that this could lead
> > to a deadlock. I would suspect that it is the s390 code which needs to
> > do the locking. But I would have to double check - it is really easy to
> > get lost there.
> 
> To me it rather looks like bfc8c90139eb ("mem-hotplug: implement
> get/put_online_mems") introduced quite subtle and probably wrong locking
> rules.
> 
> The patch introduced mem_hotplug_begin() in order to have something like
> cpu_hotplug_begin() for memory. Note that for cpu hotplug all
> cpu_hotplug_begin() calls are serialized by cpu_maps_update_begin().
> 
> Especially this makes sure that active_writer can only be changed by one
> process. (See also Dan's commit which introduced the lock_device_hotplug()
> calls: https://marc.info/?l=linux-kernel&m=148693912419972&w=2 )
> 
> If you look at the above commit bfc8c90139eb: there is nothing like
> cpu_maps_update_begin() for memory. And therefore it's possible to have
> concurrent writers to active_writer.
> 
> It looks like now lock_device_hotplug() is supposed to be the new
> cpu_maps_update_begin() for memory. But.. this looks like a mess, unless I
> read the code completely wrong ;)

[Full quote since I now hopefully use a non-bouncing email address from
Vladimir]

Since it is anything but obvious why Dan wrote in changelog of b5d24fda9c3d
("mm, devm_memremap_pages: hold device_hotplug lock over
mem_hotplug_{begin, done}") that write accesses to
mem_hotplug.active_writer are coordinated via lock_device_hotplug() I'd
rather propose a new private memory_add_remove_lock which has similar
semantics like the cpu_add_remove_lock for cpu hotplug (see patch below).

However instead of sprinkling locking/unlocking of that new lock around all
calls of mem_hotplug_begin() and mem_hotplug_end() simply include locking
and unlocking into these two functions.

This still allows get_online_mems() and put_online_mems() to work, while at
the same time preventing mem_hotplug.active_writer corruption.

Any opinions?

---
 kernel/memremap.c   | 4 ----
 mm/memory_hotplug.c | 6 +++++-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 06123234f118..07e85e5229da 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -247,11 +247,9 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
 
-	lock_device_hotplug();
 	mem_hotplug_begin();
 	arch_remove_memory(align_start, align_size);
 	mem_hotplug_done();
-	unlock_device_hotplug();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
@@ -364,11 +362,9 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_pfn_remap;
 
-	lock_device_hotplug();
 	mem_hotplug_begin();
 	error = arch_add_memory(nid, align_start, align_size, true);
 	mem_hotplug_done();
-	unlock_device_hotplug();
 	if (error)
 		goto err_add_memory;
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1d3ed58f92ab..6ee6e6a17310 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -124,9 +124,12 @@ void put_online_mems(void)
 
 }
 
+/* Needed to serialize write accesses to mem_hotplug.active_writer. */
+static DEFINE_MUTEX(memory_add_remove_lock);
+
 void mem_hotplug_begin(void)
 {
-	assert_held_device_hotplug();
+	mutex_lock(&memory_add_remove_lock);
 
 	mem_hotplug.active_writer = current;
 
@@ -146,6 +149,7 @@ void mem_hotplug_done(void)
 	mem_hotplug.active_writer = NULL;
 	mutex_unlock(&mem_hotplug.lock);
 	memhp_lock_release();
+	mutex_unlock(&memory_add_remove_lock);
 }
 
 /* add this memory to iomem resource */
-- 
2.8.4

> > On Sun 26-02-17 12:42:44, Sebastian Ott wrote:
> > > With 4.10.0-10265-gc4f3f22 the following warning is triggered on s390:
> > > 
> > > WARNING: CPU: 6 PID: 1 at drivers/base/core.c:643 assert_held_device_hotplug+0x4a/0x58
> > > [    5.731214] Call Trace:
> > > [    5.731219] ([<000000000067b8b0>] assert_held_device_hotplug+0x40/0x58)
> > > [    5.731225]  [<0000000000337914>] mem_hotplug_begin+0x34/0xc8
> > > [    5.731231]  [<00000000008b897e>] add_memory_resource+0x7e/0x1f8
> > > [    5.731236]  [<00000000008b8bd2>] add_memory+0xda/0x130
> > > [    5.731243]  [<0000000000d7f0dc>] add_memory_merged+0x15c/0x178
> > > [    5.731247]  [<0000000000d7f3a6>] sclp_detect_standby_memory+0x2ae/0x2f8
> > > [    5.731252]  [<00000000001002ba>] do_one_initcall+0xa2/0x150
> > > [    5.731258]  [<0000000000d3adc0>] kernel_init_freeable+0x228/0x2d8
> > > [    5.731263]  [<00000000008b6572>] kernel_init+0x2a/0x140
> > > [    5.731267]  [<00000000008c3972>] kernel_thread_starter+0x6/0xc
> > > [    5.731272]  [<00000000008c396c>] kernel_thread_starter+0x0/0xc
> > > [    5.731276] no locks held by swapper/0/1.
> > > [    5.731280] Last Breaking-Event-Address:
> > > [    5.731285]  [<000000000067b8b6>] assert_held_device_hotplug+0x46/0x58
> > > [    5.731292] ---[ end trace 46480df21194c96a ]---
> > 
> > such an informtion belongs to the changelog
> > 
> > > ----->8
> > > mm, add_memory_resource: hold device_hotplug lock over mem_hotplug_{begin, done}
> > > 
> > > With commit 3fc219241 ("mm: validate device_hotplug is held for memory hotplug")
> > > a lock assertion was added to mem_hotplug_begin() which led to a warning
> > > when add_memory() is called. Fix this by acquiring device_hotplug_lock in
> > > add_memory_resource().
> > > 
> > > Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
> > > ---
> > >  mm/memory_hotplug.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index 1d3ed58..c633bbc 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -1361,6 +1361,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
> > >  		new_pgdat = !p;
> > >  	}
> > >  
> > > +	lock_device_hotplug();
> > >  	mem_hotplug_begin();
> > >  
> > >  	/*
> > > @@ -1416,6 +1417,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
> > >  
> > >  out:
> > >  	mem_hotplug_done();
> > > +	unlock_device_hotplug();
> > >  	return ret;
> > >  }
> > >  EXPORT_SYMBOL_GPL(add_memory_resource);
> > > -- 
> > > 2.3.0
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
