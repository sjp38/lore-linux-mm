Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 9C3106B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 08:51:59 -0400 (EDT)
Date: Tue, 3 Jul 2012 14:51:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120703125154.GB9470@tiehlicka.suse.cz>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
 <20120702094331.GC8050@tiehlicka.suse.cz>
 <20120702134053.GA23800@shangw>
 <20120702154628.GE8050@tiehlicka.suse.cz>
 <20120703033823.GA497@shangw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120703033823.GA497@shangw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, akpm@linux-foundation.org

On Tue 03-07-12 11:38:23, Gavin Shan wrote:
> On Mon, Jul 02, 2012 at 05:46:28PM +0200, Michal Hocko wrote:
> >On Mon 02-07-12 21:40:53, Gavin Shan wrote:
> >> On Mon, Jul 02, 2012 at 11:43:31AM +0200, Michal Hocko wrote:
> >> >On Mon 02-07-12 17:28:56, Gavin Shan wrote:
> >> >> sparse_index_init() is designed to be safe if two copies of it race.  It
> >> >> uses "index_init_lock" to ensure that, even in the case of a race, only
> >> >> one CPU will manage to do:
> >> >> 
> >> >> 	mem_section[root] = section;
> >> >> 
> >> >> However, in the case where two copies of sparse_index_init() _do_ race,
> >> >> the one that loses the race will leak the "section" that
> >> >> sparse_index_alloc() allocated for it.  This patch fixes that leak.
> >> >
> >> >I would still like to hear how we can possibly race in this code path.
> >> >I've thought that memory onlining is done from a single CPU.
> >> >
> >> 
> >> Hi Michael, how about to use the following changelog? :-)
> >> 
> >> -----
> >> 
> >> sparse_index_init() is designed to be safe if two copies of it race.  It
> >> uses "index_init_lock" to ensure that, even in the case of a race, only
> >> one CPU will manage to do:
> >> 
> >> mem_section[root] = section;
> >> 
> >> However, in the case where two copies of sparse_index_init() _do_ race,
> >> which is probablly caused by making online for multiple memory sections
> >> that depend on same entry of array mem_section[] simultaneously from
> >> different CPUs. 
> >
> >And you really think that this clarified the things? You have just
> >tweaked the comment to sound more obscure.
> >
> >OK, so you have pushed me into the code...
> >If you had looked into the hotplug callchain up to add_memory you would
> >have seen that the whole arch_add_memory -> __add_pages -> ... ->
> >sparse_index_init is called with lock_memory_hotplug held so the hotplug
> >cannot run from the multiple CPUs.
> >
> >I do not see any other users apart from  boot time
> >sparse_memory_present_with_active_regions and add_memory so I think that
> >the lock is just a heritage from old days.
> >
> 
> I just had quick go-through on the source code as you suggested and I
> think you're right, Michal. So please drop this :-)
> 
> With CONFIG_ARCH_MEMORY_PROBE enabled on Power machines, following
> functions would be included in hotplug path.

I am not sure why you are mentioning Power arch here, add_memory which
does the locking is arch independent.

> 
> memory_probe_store
> add_memory
> 	lock_memory_hotplug	/* protect the whole hotplug path */
> arch_add_memory
> __add_pages
> __add_section
> sparse_add_one_section
> sparse_index_init
> sparse_index_alloc
> 
> The mutex "mem_hotplug_mutex" will be hold by lock_memory_hotplug() to protect
> the whole hotplug path. 

> However, I'm wandering if we can remove the "index_init_lock" of
> function sparse_index_init() since that sounds duplicate lock.

Heh, that's what I am asking from the very beginning... I do not see any
purpose of the lock but I might be missing something. So make sure you
really understand the locking of this code if you are going to send a
patch to remove the lock.
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
