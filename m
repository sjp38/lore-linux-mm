Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id DB6196B0078
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:59:45 -0400 (EDT)
Date: Tue, 10 Jul 2012 17:59:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] mm/sparse: remove index_init_lock
Message-ID: <20120710155940.GG19223@tiehlicka.suse.cz>
References: <1341544178-7245-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1341544178-7245-3-git-send-email-shangw@linux.vnet.ibm.com>
 <20120709111304.GA4627@tiehlicka.suse.cz>
 <20120709115935.GA19355@shangw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120709115935.GA19355@shangw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, akpm@linux-foundation.org

On Mon 09-07-12 19:59:35, Gavin Shan wrote:
[...]
> Michal, How about the following changelog?
> 
> ---
> 
> sparse_index_init() is designed to be safe if two copies of it race.  It
> uses "index_init_lock" to ensure that, even in the case of a race, only
> one CPU will manage to do:
> 
> mem_section[root] = section;
> 
> On the other hand, sparse_index_init() is possiblly called during system
> boot stage and hotplug path as follows. We need't lock during system boot
> stage to protect "mem_section[root]" and the function has been protected by
> hotplug mutex "mem_hotplug_mutex" as well in hotplug case. So we needn't the
> spinklock in the function.

The changelog is still hard to read but it's getting there slowly ;)
What about the following?
---
sparse_index_init uses index_init_lock spinlock to protect root
mem_section assignment. The lock is not necessary anymore because the
function is called only during the boot (during paging init which
is executed only from a single CPU) and from the hotplug code (by
add_memory via arch_add_memory) which uses mem_hotplug_mutex.

The lock has been introduced by 28ae55c9 (sparsemem extreme: hotplug
preparation) and sparse_index_init was used only during boot at that
time. 
Later when the hotplug code (and add_memory) was introduced there was
no synchronization so it was possible to online more sections from
the same root probably (though I am not 100% sure about that).
The first synchronization has been added by 6ad696d2 (mm: allow memory
hotplug and hibernation in the same kernel) which has been later
replaced by the mem_hotplug_mutex - 20d6c96b (mem-hotplug: introduce
{un}lock_memory_hotplug()).

Let's remove the lock as it is not needed and it makes the code more
confusing.
---

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
