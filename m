Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 771D48E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 21:22:13 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 132-v6so1637736pga.18
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 18:22:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h125-v6sor1868736pgc.242.2018.09.18.18.22.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 18:22:12 -0700 (PDT)
Date: Wed, 19 Sep 2018 11:22:07 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v1 0/6] mm: online/offline_pages called w.o.
 mem_hotplug_lock
Message-ID: <20180919012207.GD8537@350D>
References: <20180918114822.21926-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180918114822.21926-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <lenb@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mathieu Malaterre <malat@debian.org>, Michael Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>, Michal Hocko <mhocko@suse.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Philippe Ombredanne <pombredanne@nexb.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rashmica Gupta <rashmica.g@gmail.com>, Stephen Hemminger <sthemmin@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>

On Tue, Sep 18, 2018 at 01:48:16PM +0200, David Hildenbrand wrote:
> Reading through the code and studying how mem_hotplug_lock is to be used,
> I noticed that there are two places where we can end up calling
> device_online()/device_offline() - online_pages()/offline_pages() without
> the mem_hotplug_lock. And there are other places where we call
> device_online()/device_offline() without the device_hotplug_lock.
> 
> While e.g.
> 	echo "online" > /sys/devices/system/memory/memory9/state
> is fine, e.g.
> 	echo 1 > /sys/devices/system/memory/memory9/online
> Will not take the mem_hotplug_lock. However the device_lock() and
> device_hotplug_lock.
> 
> E.g. via memory_probe_store(), we can end up calling
> add_memory()->online_pages() without the device_hotplug_lock. So we can
> have concurrent callers in online_pages(). We e.g. touch in online_pages()
> basically unprotected zone->present_pages then.
> 
> Looks like there is a longer history to that (see Patch #2 for details),
> and fixing it to work the way it was intended is not really possible. We
> would e.g. have to take the mem_hotplug_lock in device/base/core.c, which
> sounds wrong.
> 
> Summary: We had a lock inversion on mem_hotplug_lock and device_lock().
> More details can be found in patch 3 and patch 6.
> 
> I propose the general rules (documentation added in patch 6):
> 
> 1. add_memory/add_memory_resource() must only be called with
>    device_hotplug_lock.
> 2. remove_memory() must only be called with device_hotplug_lock. This is
>    already documented and holds for all callers.
> 3. device_online()/device_offline() must only be called with
>    device_hotplug_lock. This is already documented and true for now in core
>    code. Other callers (related to memory hotplug) have to be fixed up.
> 4. mem_hotplug_lock is taken inside of add_memory/remove_memory/
>    online_pages/offline_pages.
> 
> To me, this looks way cleaner than what we have right now (and easier to
> verify). And looking at the documentation of remove_memory, using
> lock_device_hotplug also for add_memory() feels natural.
>

That seems reasonable, but also implies that device_online() would hold
back add/remove memory, could you please also document what mode
read/write the locks need to be held? For example can the device_hotplug_lock
be held in read mode while add/remove memory via (mem_hotplug_lock) is held
in write mode?

Balbir Singh.
 
