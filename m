Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE1E8E0001
	for <linux-mm@kvack.org>; Sat, 22 Sep 2018 22:34:58 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n17-v6so8605770pff.17
        for <linux-mm@kvack.org>; Sat, 22 Sep 2018 19:34:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j62-v6sor3142157pgd.313.2018.09.22.19.34.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Sep 2018 19:34:57 -0700 (PDT)
Date: Sun, 23 Sep 2018 12:34:52 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v1 0/6] mm: online/offline_pages called w.o.
 mem_hotplug_lock
Message-ID: <20180923023452.GG8537@350D>
References: <20180918114822.21926-1-david@redhat.com>
 <20180919012207.GD8537@350D>
 <f3a13f6a-b34c-8561-884a-23fd9aa60331@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3a13f6a-b34c-8561-884a-23fd9aa60331@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <lenb@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mathieu Malaterre <malat@debian.org>, Michael Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>, Michal Hocko <mhocko@suse.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Philippe Ombredanne <pombredanne@nexb.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rashmica Gupta <rashmica.g@gmail.com>, Stephen Hemminger <sthemmin@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>

On Wed, Sep 19, 2018 at 09:35:07AM +0200, David Hildenbrand wrote:
> Am 19.09.18 um 03:22 schrieb Balbir Singh:
> > On Tue, Sep 18, 2018 at 01:48:16PM +0200, David Hildenbrand wrote:
> >> Reading through the code and studying how mem_hotplug_lock is to be used,
> >> I noticed that there are two places where we can end up calling
> >> device_online()/device_offline() - online_pages()/offline_pages() without
> >> the mem_hotplug_lock. And there are other places where we call
> >> device_online()/device_offline() without the device_hotplug_lock.
> >>
> >> While e.g.
> >> 	echo "online" > /sys/devices/system/memory/memory9/state
> >> is fine, e.g.
> >> 	echo 1 > /sys/devices/system/memory/memory9/online
> >> Will not take the mem_hotplug_lock. However the device_lock() and
> >> device_hotplug_lock.
> >>
> >> E.g. via memory_probe_store(), we can end up calling
> >> add_memory()->online_pages() without the device_hotplug_lock. So we can
> >> have concurrent callers in online_pages(). We e.g. touch in online_pages()
> >> basically unprotected zone->present_pages then.
> >>
> >> Looks like there is a longer history to that (see Patch #2 for details),
> >> and fixing it to work the way it was intended is not really possible. We
> >> would e.g. have to take the mem_hotplug_lock in device/base/core.c, which
> >> sounds wrong.
> >>
> >> Summary: We had a lock inversion on mem_hotplug_lock and device_lock().
> >> More details can be found in patch 3 and patch 6.
> >>
> >> I propose the general rules (documentation added in patch 6):
> >>
> >> 1. add_memory/add_memory_resource() must only be called with
> >>    device_hotplug_lock.
> >> 2. remove_memory() must only be called with device_hotplug_lock. This is
> >>    already documented and holds for all callers.
> >> 3. device_online()/device_offline() must only be called with
> >>    device_hotplug_lock. This is already documented and true for now in core
> >>    code. Other callers (related to memory hotplug) have to be fixed up.
> >> 4. mem_hotplug_lock is taken inside of add_memory/remove_memory/
> >>    online_pages/offline_pages.
> >>
> >> To me, this looks way cleaner than what we have right now (and easier to
> >> verify). And looking at the documentation of remove_memory, using
> >> lock_device_hotplug also for add_memory() feels natural.
> >>
> > 
> > That seems reasonable, but also implies that device_online() would hold
> > back add/remove memory, could you please also document what mode
> > read/write the locks need to be held? For example can the device_hotplug_lock
> > be held in read mode while add/remove memory via (mem_hotplug_lock) is held
> > in write mode?
> 
> device_hotplug_lock is an ordinary mutex. So no option there.
> 
> Only mem_hotplug_lock is a per CPU RW mutex. And as of now it only
> exists to not require get_online_mems()/put_online_mems() to take the
> device_hotplug_lock. Which is perfectly valid, because these users only
> care about memory (not any other devices) not suddenly vanish. And that
> RW lock makes things fast.
> 
> Any modifications (online/offline/add/remove) require the
> mem_hotplug_lock in write.
> 
> I can add some more details to documentation in patch #6.
> 
> "... we should always hold the mem_hotplug_lock (via
> mem_hotplug_begin/mem_hotplug_done) in write mode to serialize memory
> hotplug" ..."
> 
> "In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in
> read mode allows for a quite efficient get_online_mems/put_online_mems
> implementation, so code accessing memory can protect from that memory
> vanishing."
> 
> Would that work for you?

Yes, Thanks

Balbir Singh.
