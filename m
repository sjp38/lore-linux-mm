Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26C036B517E
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 08:31:23 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w126-v6so7319100qka.11
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 05:31:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a185-v6si4707291qke.251.2018.08.30.05.31.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 05:31:21 -0700 (PDT)
Subject: Re: [PATCH RFCv2 0/6] mm: online/offline_pages called w.o.
 mem_hotplug_lock
References: <20180821104418.12710-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <37ea507e-b16d-ae8d-4da8-128b621869f2@redhat.com>
Date: Thu, 30 Aug 2018 14:31:12 +0200
MIME-Version: 1.0
In-Reply-To: <20180821104418.12710-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <lenb@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mathieu Malaterre <malat@debian.org>, Michael Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>, Michal Hocko <mhocko@suse.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rashmica Gupta <rashmica.g@gmail.com>, Stephen Hemminger <sthemmin@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>

On 21.08.2018 12:44, David Hildenbrand wrote:
> This is the same approach as in the first RFC, but this time without
> exporting device_hotplug_lock (requested by Greg) and with some more
> details and documentation regarding locking. Tested only on x86 so far.
> 

I'll be on vacation for two weeks starting on Saturday. If there are no
comments I'll send this as !RFC once I return.

Thanks!

> --------------------------------------------------------------------------
> 
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
> 
> RFC -> RFCv2:
> - Don't export device_hotplug_lock, provide proper remove_memory/add_memory
>   wrappers.
> - Split up the patches a bit.
> - Try to improve powernv memtrace locking
> - Add some documentation for locking that matches my knowledge
> 
> David Hildenbrand (6):
>   mm/memory_hotplug: make remove_memory() take the device_hotplug_lock
>   mm/memory_hotplug: make add_memory() take the device_hotplug_lock
>   mm/memory_hotplug: fix online/offline_pages called w.o.
>     mem_hotplug_lock
>   powerpc/powernv: hold device_hotplug_lock when calling device_online()
>   powerpc/powernv: hold device_hotplug_lock in memtrace_offline_pages()
>   memory-hotplug.txt: Add some details about locking internals
> 
>  Documentation/memory-hotplug.txt              | 39 +++++++++++-
>  arch/powerpc/platforms/powernv/memtrace.c     | 14 +++--
>  .../platforms/pseries/hotplug-memory.c        |  8 +--
>  drivers/acpi/acpi_memhotplug.c                |  4 +-
>  drivers/base/memory.c                         | 22 +++----
>  drivers/xen/balloon.c                         |  3 +
>  include/linux/memory_hotplug.h                |  4 +-
>  mm/memory_hotplug.c                           | 59 +++++++++++++++----
>  8 files changed, 115 insertions(+), 38 deletions(-)
> 


-- 

Thanks,

David / dhildenb
