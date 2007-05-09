Date: Wed, 09 May 2007 11:59:38 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC] memory hotremove patch take 2 [00/10]
Message-Id: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hello.

I rebased and debugged Kame-san's memory hot-remove patches.
This work is not finished yet. (Some pages keep un-removable status)
But, I would like to show current progress of it, because it has
been a long time since previous post, and some bugs are fixed.

If you have concern, please check this. Any comments are welcome.

Thanks.

---

These patches are for memory hot-remove.

How to use
  - kernelcore=xx[GMK] must be specified at boottime option to create
    ZONE_MOVABLE area.
  - After bootup, execute following.
     # echo "offline" > /sys/devices/system/memory/memoryX/status
    


Change log from previous version.
  - Rebase to 2.6.21-mm1.
  - Old original ZONE_MOVABLE code is removed. Mel-san's ZONE_REMOVABLE
    for anti-fragmentation is used.
  - Fix wrong return code check of isolate_lru_page()
  - Page is isolated ASAP, which was source of page migration when
    memory-hotremove. In old code, it uses just put_page(),
    and we expected that migrated source page is catched in
    __free_one_page() as isolated page. But, it is spooled in
    per_cpu_page and used soon for next destination page of migration.
    This was cause of eternal loop in offline_pages().
  - There is a page which is not mapped but added to swapcache in
    swap-in code. It was cause of panic in try_to_unmap(). fixed it.
  - end_pfn is rounded up at memmap_init. If there is a small hole on
    end of section. These page is not initialized.

TODO:
  - There are some pages which are un-removable page on memory stress
    condition. (These pages are set PG_swapcache or PG_mappedtodisk
    without connecting to lru.)
  - Should make i386/x86-64/powerpc interface code. But not yet 
    (really sorry :-( ).
  - If bootmem parameter or efi's memory map is stored by efi, memory
    can't be removed even if it is in removable zone.
  - node hotplug support. (this may needs some amount of patches.)
  - test under heavy work load and more careful race check.
  - Fix where we should allocate migration target page from.
  - Hmmmm.... And so on.

[1] counters patch -- per-zone counter for ZONE_MOVABLE

==page isolation==
[2] page isolation patch ..... basic defintions of page isolation.
[3] drain_all_zone_pages patch ..... drain all cpus' pcp pages.
[4] isolate freed page patch ..... isolate pages in free_area[]

==memory unplug==
offline a section of pages. isolate specified section and migrate
content of used pages to out of section. (Because free pages in a
section is isolated, it never be returned by alloc_pages())
This patch doesn't care where we should allocate migration new pages from.
[5] memory unplug core patch --- maybe need more work.
[6] interface patch          --- "offline" interface support 

==migration nocontext==
Fix race condition of page migration without process context
(not taking mm->sem). This patch delayes kmem_cache_free() of
anon_vma until migration ends.
[7] migration nocontext patch --- support page migration without
    acquiring mm->sem. need careful debug...

==other fixes==
[8] round up end_pfn at memmap_init
[9] page isolation ASAP when memory-hotremove case.
[10] fix swapping-in page panic.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
