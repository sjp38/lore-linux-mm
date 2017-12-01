Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68FF56B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 09:23:32 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w95so5916287wrc.20
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 06:23:32 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id 30si5363038wra.131.2017.12.01.06.23.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 06:23:31 -0800 (PST)
Received: from mail-it0-f72.google.com ([209.85.214.72])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <seth.forshee@canonical.com>)
	id 1eKmDy-0000Vw-K0
	for linux-mm@kvack.org; Fri, 01 Dec 2017 14:23:30 +0000
Received: by mail-it0-f72.google.com with SMTP id g2so2103579itf.7
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 06:23:30 -0800 (PST)
Date: Fri, 1 Dec 2017 08:23:27 -0600
From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: Memory hotplug regression in 4.13
Message-ID: <20171201142327.GA16952@ubuntu-xps13>
References: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
 <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
 <20170921054034.judv6ovyg5yks4na@ubuntu-hedt>
 <20170925125825.zpgasjhjufupbias@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925125825.zpgasjhjufupbias@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 25, 2017 at 02:58:25PM +0200, Michal Hocko wrote:
> On Thu 21-09-17 00:40:34, Seth Forshee wrote:
> > On Wed, Sep 20, 2017 at 11:29:31AM +0200, Michal Hocko wrote:
> > > Hi,
> > > I am currently at a conference so I will most probably get to this next
> > > week but I will try to ASAP.
> > > 
> > > On Tue 19-09-17 11:41:14, Seth Forshee wrote:
> > > > Hi Michal,
> > > > 
> > > > I'm seeing oopses in various locations when hotplugging memory in an x86
> > > > vm while running a 32-bit kernel. The config I'm using is attached. To
> > > > reproduce I'm using kvm with the memory options "-m
> > > > size=512M,slots=3,maxmem=2G". Then in the qemu monitor I run:
> > > > 
> > > >   object_add memory-backend-ram,id=mem1,size=512M
> > > >   device_add pc-dimm,id=dimm1,memdev=mem1
> > > > 
> > > > Not long after that I'll see an oops, not always in the same location
> > > > but most often in wp_page_copy, like this one:
> > > 
> > > This is rather surprising. How do you online the memory?
> > 
> > The kernel has CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE=y.
> 
> OK, so the memory gets online automagically at the time when it is
> hotadded. Could you send the full dmesg?
> 
> > > > [   24.673623] BUG: unable to handle kernel paging request at dffff000
> > > > [   24.675569] IP: wp_page_copy+0xa8/0x660
> > > 
> > > could you resolve the IP into the source line?
> > 
> > It seems I don't have that kernel anymore, but I've got a 4.14-rc1 build
> > and the problem still occurs there. It's pointing to the call to
> > __builtin_memcpy in memcpy (include/linux/string.h line 340), which we
> > get to via wp_page_copy -> cow_user_page -> copy_user_highpage.
> 
> Hmm, this is interesting. That would mean that we have successfully
> mapped the destination page but its memory is still not accessible.
> 
> Right now I do not see how the patch you have bisected to could make any
> difference because it only postponed the onlining to be independent but
> your config simply onlines automatically so there shouldn't be any
> semantic change. Maybe there is some sort of off-by-one or something.
> 
> I will try to investigate some more. Do you think it would be possible
> to configure kdump on your system and provide me with the vmcore in some
> way?

Sorry, I got busy with other stuff and this kind of fell off my radar.
It came to my attention again recently though.

I was looking through the hotplug rework changes, and I noticed that
32-bit x86 previously was using ZONE_HIGHMEM as a default but after the
rework it doesn't look like it's possible for memory to be associated
with ZONE_HIGHMEM when onlining. So I made the change below against 4.14
and am now no longer seeing the oopses.

I'm sure this isn't the correct fix, but I think it does confirm that
the problem is that the memory should be associated with ZONE_HIGHMEM
but is not.

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d4b5f29906b9..fddc134c5c3b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -833,6 +833,12 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
 	set_zone_contiguous(zone);
 }
 
+#ifdef CONFIG_HIGHMEM
+static enum zone_type default_zone = ZONE_HIGHMEM;
+#else
+static enum zone_type default_zone = ZONE_NORMAL;
+#endif
+
 /*
  * Returns a default kernel memory zone for the given pfn range.
  * If no kernel zone covers this pfn range it will automatically go
@@ -844,14 +850,14 @@ static struct zone *default_kernel_zone_for_pfn(int nid, unsigned long start_pfn
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	int zid;
 
-	for (zid = 0; zid <= ZONE_NORMAL; zid++) {
+	for (zid = 0; zid <= default_zone; zid++) {
 		struct zone *zone = &pgdat->node_zones[zid];
 
 		if (zone_intersects(zone, start_pfn, nr_pages))
 			return zone;
 	}
 
-	return &pgdat->node_zones[ZONE_NORMAL];
+	return &pgdat->node_zones[default_zone];
 }
 
 static inline struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
