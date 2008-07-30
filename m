Subject: [PATCH] Update Unevictable LRU and Mlocked Pages documentation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 30 Jul 2008 17:13:59 -0400
Message-Id: <1217452439.7676.26.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Against:  [27-rc1+]mmotm-080730-0356

Update to: doc-unevictable-lru-and-mlocked-pages-documentation.patch

Update unevictable lru documentation based on review and testing
rework and fixes.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/unevictable-lru.txt |  170 +++++++++++++++++------------------
 1 file changed, 84 insertions(+), 86 deletions(-)

Index: linux-2.6.27-rc1-mmotm-30jul/Documentation/vm/unevictable-lru.txt
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/Documentation/vm/unevictable-lru.txt	2008-07-30 16:17:07.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/Documentation/vm/unevictable-lru.txt	2008-07-30 16:37:31.000000000 -0400
@@ -26,7 +26,7 @@ with the system completely unresponsive.
 The Unevictable LRU infrastructure addresses the following classes of
 unevictable pages:
 
-+ page owned by ram disks or ramfs
++ page owned by ramfs
 + page mapped into SHM_LOCKed shared memory regions
 + page mapped into VM_LOCKED [mlock()ed] vmas
 
@@ -44,14 +44,21 @@ it indicates on which LRU list a page re
 unevictable LRU list is source configurable based on the UNEVICTABLE_LRU Kconfig
 option.
 
-Why maintain unevictable pages on an additional LRU list?  The Linux memory
-management subsystem has well established protocols for managing pages on the
-LRU.  Vmscan is based on LRU lists.  LRU list exist per zone, and we want to
-maintain pages relative to their "home zone".  All of these make the use of
-an additional list, parallel to the LRU active and inactive lists, a natural
-mechanism to employ.  Note, however, that the unevictable list does not
-differentiate between file backed and swap backed [anon] pages.  This
-differentiation is only important while the pages are, in fact, evictable.
+Why maintain unevictable pages on an additional LRU list?  Primarily because
+we want to be able to migrate unevictable pages between nodes--for memory
+deframentation, workload management and memory hotplug.  The linux kernel can
+only migrate pages that it can successfully isolate from the lru lists.
+Therefore, we want to keep the unevictable pages on an lru-like list, where
+they can be found by isolate_lru_page().
+
+Secondarily, the Linux memory management subsystem has well established
+protocols for managing pages on the LRU.  Vmscan is based on LRU lists.
+LRU list exist per zone, and we want to maintain pages relative to their
+"home zone".  All of these make the use of an additional list, parallel to
+the LRU active and inactive lists, a natural mechanism to employ.  Note,
+however, that the unevictable list does not differentiate between file backed
+and swap backed [anon] pages.  This differentiation is only important while
+the pages are, in fact, evictable.
 
 The unevictable LRU list benefits from the "arrayification" of the per-zone
 LRU lists and statistics originally proposed and posted by Christoph Lameter.
@@ -81,23 +88,23 @@ memory.  This can cause the control grou
 Unevictable LRU:  Detecting Unevictable Pages
 
 The function page_evictable(page, vma) in vmscan.c determines whether a
-page is evictable or not.  For ramfs and ram disk [brd] pages and pages in
-SHM_LOCKed regions, page_evictable() tests a new address space flag,
-AS_UNEVICTABLE, in the page's address space using a wrapper function.
-Wrapper functions are used to set, clear and test the flag to reduce the
-requirement for #ifdef's throughout the source code.  AS_UNEVICTABLE is set on
-ramfs inode/mapping when it is created and on ram disk inode/mappings at open
-time.   This flag remains for the life of the inode.
-
-For shared memory regions, AS_UNEVICTABLE is set when an application successfully
-SHM_LOCKs the region and is removed when the region is SHM_UNLOCKed.  Note that
-shmctl(SHM_LOCK, ...) does not populate the page tables for the region as does,
-for example, mlock().   So, we make no special effort to push any pages in the
-SHM_LOCKed region to the unevictable list.  Vmscan will do this when/if it
-encounters the pages during reclaim.  On SHM_UNLOCK, shmctl() scans the pages
-in the region and "rescues" them from the unevictable list if no other condition
-keeps them unevictable.  If a SHM_LOCKed region is destroyed, the pages
-are also "rescued" from the unevictable list in the process of freeing them.
+page is evictable or not.  For ramfs pages and pages in SHM_LOCKed regions,
+page_evictable() tests a new address space flag, AS_UNEVICTABLE, in the page's
+address space using a wrapper function.  Wrapper functions are used to set,
+clear and test the flag to reduce the requirement for #ifdef's throughout the
+source code.  AS_UNEVICTABLE is set on ramfs inode/mapping when it is created.
+This flag remains for the life of the inode.
+
+For shared memory regions, AS_UNEVICTABLE is set when an application
+successfully SHM_LOCKs the region and is removed when the region is
+SHM_UNLOCKed.  Note that shmctl(SHM_LOCK, ...) does not populate the page
+tables for the region as does, for example, mlock().   So, we make no special
+effort to push any pages in the SHM_LOCKed region to the unevictable list.
+Vmscan will do this when/if it encounters the pages during reclaim.  On
+SHM_UNLOCK, shmctl() scans the pages in the region and "rescues" them from the
+unevictable list if no other condition keeps them unevictable.  If a SHM_LOCKed
+region is destroyed, the pages are also "rescued" from the unevictable list in
+the process of freeing them.
 
 page_evictable() detects mlock()ed pages by testing an additional page flag,
 PG_mlocked via the PageMlocked() wrapper.  If the page is NOT mlocked, and a
@@ -110,13 +117,13 @@ VM_LOCKED vmas.
 
 Unevictable Pages and Vmscan [shrink_*_list()]
 
-If unevictable pages are culled in the fault path, or moved to the
-unevictable list at mlock() or mmap() time, vmscan will never encounter the pages
-until they have become evictable again, for example, via munlock() and have
-been "rescued" from the unevictable list.  However, there may be situations where
-we decide, for the sake of expediency, to leave a unevictable page on one of
-the regular active/inactive LRU lists for vmscan to deal with.  Vmscan checks
-for such pages in all of the shrink_{active|inactive|page}_list() functions and
+If unevictable pages are culled in the fault path, or moved to the unevictable
+list at mlock() or mmap() time, vmscan will never encounter the pages until
+they have become evictable again, for example, via munlock() and have been
+"rescued" from the unevictable list.  However, there may be situations where we
+decide, for the sake of expediency, to leave a unevictable page on one of the
+regular active/inactive LRU lists for vmscan to deal with.  Vmscan checks for
+such pages in all of the shrink_{active|inactive|page}_list() functions and
 will "cull" such pages that it encounters--that is, it diverts those pages to
 the unevictable list for the zone being scanned.
 
@@ -133,22 +140,30 @@ whether any VM_LOCKED vmas map the page 
 If try_to_munlock() returns SWAP_MLOCK, shrink_page_list() will cull the page
 without consuming swap space.  try_to_munlock() will be described below.
 
+To "cull" an unevictable page, vmscan simply puts the page back on the lru
+list using putback_lru_page()--the inverse operation to isolate_lru_page()--
+after dropping the page lock.  Because the condition which makes the page
+unevictable may change once the page is unlocked, putback_lru_page() will
+recheck the unevictable state of a page that it places on the unevictable lru
+list.  If the page has become unevictable, putback_lru_page() removes it from
+the list and retries, including the page_unevictable() test.  Because such a
+race is a rare event and movement of pages onto the unevictable list should be
+rare, these extra evictabilty checks should not occur in the majority of calls
+to putback_lru_page().
+
 
 Mlocked Page:  Prior Work
 
-The "Unevictable Mlocked Pages" infrastructure is based on work originally posted
-by Nick Piggin in an RFC patch entitled "mm: mlocked pages off LRU".  Nick's
-posted his patch as an alternative to a patch posted by Christoph Lameter to
-achieve the same objective--hiding mlocked pages from vmscan.  In Nick's patch,
-he used one of the struct page lru list link fields as a count of VM_LOCKED
-vmas that map the page.  This use of the link field for a count prevent the
-management of the pages on an LRU list.  When Nick's patch was integrated with
-the Unevictable LRU work, the count was replaced by walking the reverse map to
-determine whether any VM_LOCKED vmas mapped the page.  More on this below.
-The primary reason for wanting to keep mlocked pages on an LRU list is that
-mlocked pages are migratable, and the LRU list is used to arbitrate tasks
-attempting to migrate the same page.  Whichever task succeeds in "isolating"
-the page from the LRU performs the migration.
+The "Unevictable Mlocked Pages" infrastructure is based on work originally
+posted by Nick Piggin in an RFC patch entitled "mm: mlocked pages off LRU".
+Nick's posted his patch as an alternative to a patch posted by Christoph
+Lameter to achieve the same objective--hiding mlocked pages from vmscan.
+In Nick's patch, he used one of the struct page lru list link fields as a count
+of VM_LOCKED vmas that map the page.  This use of the link field for a count
+prevent the management of the pages on an LRU list.  When Nick's patch was
+integrated with the Unevictable LRU work, the count was replaced by walking the
+reverse map to determine whether any VM_LOCKED vmas mapped the page.  More on
+this below.
 
 
 Mlocked Pages:  Basic Management
@@ -209,7 +224,7 @@ unlock the page and move on.  Worse case
 in a VM_LOCKED vma remaining on a normal LRU list without being
 PageMlocked().  Again, vmscan will detect and cull such pages.
 
-mlock_vma_page(), called with the page locked [N.B., not "mlocked"] will
+mlock_vma_page(), called with the page locked [N.B., not "mlocked"], will
 TestSetPageMlocked() for each page returned by get_user_pages().  We use
 TestSetPageMlocked() because the page might already be mlocked by another
 task/vma and we don't want to do extra work.  We especially do not want to
@@ -225,7 +240,7 @@ mlock_vma_page() is unable to isolate th
 it later if/when it attempts to reclaim the page.
 
 
-Mlocked Pages:  Filtering Vmas
+Mlocked Pages:  Filtering Special Vmas
 
 mlock_fixup() filters several classes of "special" vmas:
 
@@ -295,26 +310,17 @@ ignored for munlock.
 
 If the vma is VM_LOCKED, mlock_fixup() again attempts to merge or split off
 the specified range.  The range is then munlocked via the function
-__munlock_vma_pages_range().  Because the vma access protections could have
-been changed to PROT_NONE after faulting in and mlocking some pages,
-get_user_pages() is unreliable for visiting these pages for munlocking.  We
-don't want to leave pages mlocked(), so __munlock_vma_pages_range() uses a
-custom page table walker to find all pages mapped into the specified range.
-Note that this again assumes that all pages in the mlocked() range are resident
-and mapped by the task's page table.
-
-As with __mlock_vma_pages_range(), unlocking can race with truncation and
-migration.  It is very important that munlock of a page succeeds, lest we
-leak pages by stranding them in the mlocked state on the unevictable list.
-The munlock page walk pte handler resolves the race with page migration
-by checking the pte for a special swap pte indicating that the page is
-being migrated.  If this is the case, the pte handler will wait for the
-migration entry to be replaced and then refetch the pte for the new page.
-Once the pte handler has locked the page, it checks the page_mapping to
-ensure that it still exists.  If not, the handler unlocks the page and
-retries the entire process after refetching the pte.
+__mlock_vma_pages_range()--the same function used to mlock a vma range--
+passing a flag to indicate that munlock() is being performed.
+
+Because the vma access protections could have been changed to PROT_NONE after
+faulting in and mlocking some pages, get_user_pages() was unreliable for visiting
+these pages for munlocking.  Because we don't want to leave pages mlocked(),
+get_user_pages() was enhanced to accept a flag to ignore the permissions when
+fetching the pages--all of which should be resident as a result of previous
+mlock()ing.
 
-The munlock page walk pte handler unlocks individual pages by calling
+For munlock(), __mlock_vma_pages_range() unlocks individual pages by calling
 munlock_vma_page().  munlock_vma_page() unconditionally clears the PG_mlocked
 flag using TestClearPageMlocked().  As with mlock_vma_page(), munlock_vma_page()
 use the Test*PageMlocked() function to handle the case where the page might
@@ -351,23 +357,16 @@ page.  This has been discussed from the 
 respective sections above.  Both processes [migration, m[un]locking], hold
 the page locked.  This provides the first level of synchronization.  Page
 migration zeros out the page_mapping of the old page before unlocking it,
-so m[un]lock can skip these pages.  However, as discussed above, munlock
-must wait for a migrating page to be replaced with the new page to prevent
-the new page from remaining mlocked outside of any VM_LOCKED vma.
-
-To ensure that we don't strand pages on the unevictable list because of a
-race between munlock and migration, we must also prevent the munlock pte
-handler from acquiring the old or new page lock from the time that the
-migration subsystem acquires the old page lock, until either migration
-succeeds and the new page is added to the lru or migration fails and
-the old page is putback to the lru.  The achieve this coordination,
-the migration subsystem places the new page on success, or the old
-page on failure, back on the lru lists before dropping the respective
-page's lock.  It uses the putback_lru_page() function to accomplish this,
-which rechecks the page's overall evictability and adjusts the page
-flags accordingly.  To free the old page on success or the new page on
-failure, the migration subsystem just drops what it knows to be the last
-page reference via put_page().
+so m[un]lock can skip these pages by testing the page mapping under page
+lock.
+
+When completing page migration, we place the new and old pages back onto the
+lru after dropping the page lock.  The "unneeded" page--old page on success,
+new page on failure--will be freed when the reference count held by the
+migration process is released.  To ensure that we don't strand pages on the
+unevictable list because of a race between munlock and migration, page
+migration uses the putback_lru_page() function to add migrated pages back to
+the lru.
 
 
 Mlocked Pages:  mmap(MAP_LOCKED) System Call Handling
@@ -566,8 +565,7 @@ shrink_active_list would never see them.
 
 Some examples of these unevictable pages on the LRU lists are:
 
-1) ramfs and ram disk pages that have been placed on the lru lists when
-   first allocated.
+1) ramfs pages that have been placed on the lru lists when first allocated.
 
 2) SHM_LOCKed shared memory pages.  shmctl(SHM_LOCK) does not attempt to
    allocate or fault in the pages in the shared memory region.  This happens


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
