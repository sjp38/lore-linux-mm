Date: Tue, 6 Mar 2007 13:32:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [0/16]
Message-Id: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi, this is memory-unplug patch set.......sample.

My purpose is to show how memory-unplug can be implemented on ZONE_MOVABLE.
*Any* comments are welcome. This patch just support ia64, which I can test.
If you want me to add arch support, please mail me.

This patch is a bit old and against 2.6.20-mm2. I'll rebase this and reflect
your comments in the next post (may not soon).
Well booted on ia64 and passed *quick* memory offline test.

I know there are many other works....
- mlocked page off-lru
- anon-witout-swap off-lru
- change zone/node relation ship and create new generic memory management unit
- etc..
So, I think I will have to change amount of part of this patch set.

Anyway, I can't go ahead without some memory encapsulation like ZONE_MOVABLE.

TODO
- add hot-added memory to ZONE_MOVABLE
- show physical memory <-> memory section relation ship.
- node hotplug support. (this may needs some amount of patches.)
- more GFP_MOVABLE checks. Disallow not-movable pages in ZONE_MOVABLE.
- test under heavy work load and more careful race check.
- devide memory unplug core patch into smaller pieces.
- Fix where we should allocate migration target page from.
- more sophisticated boot options. algorythms, controls.
- fix memory encapsulation technique like ZONE_MOVABLE 


Patch series[1]-[16]
== cleanup ==
These patches offerres no functional changes. just changes code.
I like this patch set as clean-up.
[1] zone naming clean up. --- changes #ifdefs around ZONE.
[2] alloc_zeroed_user_highpage clean up --- gathered scatterred defintions.
[3] is_highmem cleaunp --- added is_identity_map() 

== zone movable ==
This ZONE_MOVABLE is based on Mel's ZONE_MOVABLE. some implementation
details are different from his, because of clean-ups[1][2][3].
It seems that pushing ZONE_MOVABLE now is not easy. We(I?)'ll have to
make changes to memory management core for implementing better memory
management structure than zones.
[4] add ZONE_MOVABLE patch
[5] GFP_MOVABLE definition patch
[6] change alloc_zeroed_user_highpage to use ZONE_MOVABLE
[7] change GFP_HIGHUSER callers to use GFP_HIGH_MOVABLE (if they can)
[8] counters patch -- per-zone counter for ZONE_MOVABLE
[9] movable_zone_create patch --- added boot option for creating movable zones.
                                  maybe need more work.
[10] ia64_movable -- creating ZONE_MOVABLE zone on ia64


==page isolation==
page isolation makes page to be *unused* state. Make free pages off-free_area[]
and hide them from system.
[11] page isolation patch ..... basic defintions of page isolation.
[12] drain_all_zone_pages patch ..... drain all cpus' pcp pages.
[13] isolate freed page patch ..... isolate pages in free_area[]

==memory unplug==
offline a section of pages. isolate specified section and migrate contents
of used pages to out of section. (Because free pages in a section is isolated,
it never be returned by alloc_pages())
This patch doesn't care where we should allocate migration new pages from.
[14] memory unplug core patch --- maybe need more work.
[15] interface patch          --- "offline" interface support 

==migration nocontext==
Fix race condition of page migration without process context (not taking mm->sem).
This patch delayes kmem_cache_free() of anon_vma until migration ends.
[16] migration nocontext patch --- support page migration without acquiring mm->sem.
                                   need careful debug...


-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
