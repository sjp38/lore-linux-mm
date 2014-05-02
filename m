Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 39C696B0055
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:53:10 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j5so4672965qga.36
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:10 -0700 (PDT)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id e7si2070420qai.157.2014.05.02.06.53.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:53:09 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id cm18so3179595qab.8
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:09 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 07/11] hmm: support moving anonymous page to remote memory
Date: Fri,  2 May 2014 09:52:06 -0400
Message-Id: <1399038730-25641-8-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Motivation:

Migrating to device memory can allow device to access memory through a link
with far greater bandwidth as well as with lower latency. Migration to device
memory is of course only meaningfull if the memory will only be access by the
device over a long period of time.

Because hmm aim to only provide an API to facilitate such use it does not
deal with policy on when, what and to migrate to remote memory. It is expected
that device driver that use hmm will have the informations to make such choice.

Implementation:

This use a two level structure to track remote memory. The first level is a
range structure that match a range of address with a specific remote memory
object. This allow for different range of address to point to the same remote
memory object (usefull for shared memory).

The second level is a structure holding informations specific to hmm about the
remote memory. This remote memory structure are allocated by device driver and
thus can be included inside the remote memory structure that is specific to the
device driver.

Each remote memory is given a range of unique id. Those unique id are use to
create special hmm swap entry. For anonymous memory the cpu page table entry
are set to this hmm swap entry and on cpu page fault the unique id is use to
find the remote memory and migrate it back to system memory.

Other event than cpu page fault can trigger migration back to system memory.
For instance on fork, to simplify things, the remote memory is migrated back
to system memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm.h          |  469 ++++++++-
 include/linux/mmu_notifier.h |    1 +
 include/linux/swap.h         |   12 +-
 include/linux/swapops.h      |   33 +-
 mm/hmm.c                     | 2307 ++++++++++++++++++++++++++++++++++++++++--
 mm/memcontrol.c              |   46 +
 mm/memory.c                  |    7 +
 7 files changed, 2768 insertions(+), 107 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index e9c7722..96f41c4 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -56,10 +56,10 @@
 
 struct hmm_device;
 struct hmm_device_ops;
-struct hmm_migrate;
 struct hmm_mirror;
 struct hmm_fault;
 struct hmm_event;
+struct hmm_rmem;
 struct hmm;
 
 /* The hmm provide page informations to the device using hmm pfn value. Below
@@ -67,15 +67,34 @@ struct hmm;
  * type of page, dirty page, page is locked or not, ...).
  *
  *   HMM_PFN_VALID_PAGE this means the pfn correspond to valid page.
- *   HMM_PFN_VALID_ZERO this means the pfn is the special zero page.
+ *   HMM_PFN_VALID_ZERO this means the pfn is the special zero page either use
+ *     it or directly clear rmem with zero what ever is the fastest method for
+ *     the device.
  *   HMM_PFN_DIRTY set when the page is dirty.
  *   HMM_PFN_WRITE is set if there is no need to call page_mkwrite
+ *   HMM_PFN_LOCK is only set while the rmem object is under going migration.
+ *   HMM_PFN_LMEM_UPTODATE the page that is in the rmem pfn array has uptodate.
+ *   HMM_PFN_RMEM_UPTODATE the rmem copy of the page is uptodate.
+ *
+ * Device driver only need to worry about :
+ *   HMM_PFN_VALID_PAGE
+ *   HMM_PFN_VALID_ZERO
+ *   HMM_PFN_DIRTY
+ *   HMM_PFN_WRITE
+ * Device driver must set/clear following flag after successfull dma :
+ *   HMM_PFN_LMEM_UPTODATE
+ *   HMM_PFN_RMEM_UPTODATE
+ * All the others flags are for hmm internal use only.
  */
 #define HMM_PFN_SHIFT		(PAGE_SHIFT)
+#define HMM_PFN_CLEAR		(((1UL << HMM_PFN_SHIFT) - 1UL) & ~0x3UL)
 #define HMM_PFN_VALID_PAGE	(0UL)
 #define HMM_PFN_VALID_ZERO	(1UL)
 #define HMM_PFN_DIRTY		(2UL)
 #define HMM_PFN_WRITE		(3UL)
+#define HMM_PFN_LOCK		(4UL)
+#define HMM_PFN_LMEM_UPTODATE	(5UL)
+#define HMM_PFN_RMEM_UPTODATE	(6UL)
 
 static inline struct page *hmm_pfn_to_page(unsigned long pfn)
 {
@@ -95,6 +114,28 @@ static inline void hmm_pfn_set_dirty(unsigned long *pfn)
 	set_bit(HMM_PFN_DIRTY, pfn);
 }
 
+static inline void hmm_pfn_set_lmem_uptodate(unsigned long *pfn)
+{
+	set_bit(HMM_PFN_LMEM_UPTODATE, pfn);
+}
+
+static inline void hmm_pfn_set_rmem_uptodate(unsigned long *pfn)
+{
+	set_bit(HMM_PFN_RMEM_UPTODATE, pfn);
+}
+
+static inline void hmm_pfn_clear_lmem_uptodate(unsigned long *pfn)
+{
+	clear_bit(HMM_PFN_LMEM_UPTODATE, pfn);
+}
+
+static inline void hmm_pfn_clear_rmem_uptodate(unsigned long *pfn)
+{
+	clear_bit(HMM_PFN_RMEM_UPTODATE, pfn);
+}
+
+
+
 
 /* hmm_fence - device driver fence to wait for device driver operations.
  *
@@ -283,6 +324,255 @@ struct hmm_device_ops {
 			  unsigned long laddr,
 			  unsigned long *pfns,
 			  struct hmm_fault *fault);
+
+	/* rmem_alloc - allocate a new rmem object.
+	 *
+	 * @device: Device into which to allocate the remote memory.
+	 * @fault:  The fault for which this remote memory is allocated.
+	 * Returns: Valid rmem ptr on success, NULL or ERR_PTR otherwise.
+	 *
+	 * This allow migration to remote memory to operate in several steps.
+	 * First the hmm code will clamp the range that can migrated and will
+	 * unmap pages and prepare them for migration.
+	 *
+	 * It is only once migration is done with all above step that we know
+	 * how much memory can be migrated which is when rmem_alloc is call to
+	 * allocate the device rmem object to which memory should be migrated.
+	 *
+	 * Device driver can decide through this callback to abort migration
+	 * by returning NULL, or it can decide to continue with migration by
+	 * returning a properly allocated rmem object.
+	 *
+	 * Return rmem or NULL on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	struct hmm_rmem *(*rmem_alloc)(struct hmm_device *device,
+				       struct hmm_fault *fault);
+
+	/* rmem_update() - update device mmu for a range of remote memory.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @rmem:   The remote memory under update.
+	 * @faddr:  First address in range (inclusive).
+	 * @laddr:  Last address in range (exclusive).
+	 * @fuid:   First uid of the remote memory at which the update begin.
+	 * @etype:  The type of memory event (unmap, fini, read only, ...).
+	 * @dirty:  Device driver should call hmm_pfn_set_dirty.
+	 * Returns: Valid fence ptr or NULL on success otherwise ERR_PTR.
+	 *
+	 * Called to update device mmu permission/usage for a range of remote
+	 * memory. The event type provide the nature of the update :
+	 *   - range is no longer valid (munmap).
+	 *   - range protection changes (mprotect, COW, ...).
+	 *   - range is unmapped (swap, reclaim, page migration, ...).
+	 *   - ...
+	 *
+	 * Any event that block further write to the memory must also trigger a
+	 * device cache flush and everything has to be flush to remote memory by
+	 * the time the wait callback return (if this callback returned a fence
+	 * otherwise everything must be flush by the time the callback return).
+	 *
+	 * Device must properly call hmm_pfn_set_dirty on any page the device
+	 * did write to since last call to update_rmem. This is only needed if
+	 * the dirty parameter is true.
+	 *
+	 * The driver should return a fence pointer or NULL on success. It is
+	 * advice to return fence and delay wait for the operation to complete
+	 * to the wait callback. Returning a fence allow hmm to batch update to
+	 * several devices and delay wait on those once they all have scheduled
+	 * the update.
+	 *
+	 * Device driver must not fail lightly, any failure result in device
+	 * process being kill.
+	 *
+	 * Return fence or NULL on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	struct hmm_fence *(*rmem_update)(struct hmm_mirror *mirror,
+					 struct hmm_rmem *rmem,
+					 unsigned long faddr,
+					 unsigned long laddr,
+					 unsigned long fuid,
+					 enum hmm_etype etype,
+					 bool dirty);
+
+	/* rmem_fault() - fault range of rmem on the device mmu.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @rmem:   The rmem backing this range.
+	 * @faddr:  First address in range (inclusive).
+	 * @laddr:  Last address in range (exclusive).
+	 * @fuid:   First rmem unique id (inclusive).
+	 * @fault:  The fault structure provided by device driver.
+	 * Returns: 0 on success, error value otherwise.
+	 *
+	 * Called to give the device driver the remote memory that is backing a
+	 * range of memory. The device driver can only map rmem page with write
+	 * permission only if the HMM_PFN_WRITE bit is set. If device want to
+	 * write to this range of rmem it can call hmm_mirror_fault.
+	 *
+	 * Return error if scheduled operation failed. Valid value :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*rmem_fault)(struct hmm_mirror *mirror,
+			  struct hmm_rmem *rmem,
+			  unsigned long faddr,
+			  unsigned long laddr,
+			  unsigned long fuid,
+			  struct hmm_fault *fault);
+
+	/* rmem_to_lmem - copy remote memory to local memory.
+	 *
+	 * @rmem:   The remote memory structure.
+	 * @fuid:   First rmem unique id (inclusive) of range to copy.
+	 * @luid:   Last rmem unique id (exclusive) of range to copy.
+	 * Returns: Valid fence ptr or NULL on success otherwise ERR_PTR.
+	 *
+	 * This is call to copy remote memory back to local memory. The device
+	 * driver need to schedule the dma to copy the remote memory to the
+	 * pages given by the pfns array. Device driver should return a fence
+	 * or an error pointer.
+	 *
+	 * If device driver does not return a fence then the device driver must
+	 * wait until the dma is done and all device cache are flush. Moreover
+	 * device driver must set the HMM_PFN_LMEM_UPTODATE on all successfully
+	 * copied pages (setting this flag can be delayed to the fence_wait
+	 * callback).
+	 *
+	 * If a valid fence is returned then hmm will wait on it and reschedule
+	 * any thread that need rescheduling.
+	 *
+	 * DEVICE DRIVER MUST ABSOLUTELY TRY TO MAKE THIS CALL WORK OTHERWISE
+	 * CPU THREAD WILL GET A SIGBUS.
+	 *
+	 * DEVICE DRIVER MUST SET HMM_PFN_LMEM_UPTODATE ON ALL SUCCESSFULLY
+	 * COPIED PAGES.
+	 *
+	 * Return fence or NULL on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	struct hmm_fence *(*rmem_to_lmem)(struct hmm_rmem *rmem,
+					  unsigned long fuid,
+					  unsigned long luid);
+
+	/* lmem_to_rmem - copy local memory to remote memory.
+	 *
+	 * @rmem:   The remote memory structure.
+	 * @fuid:   First rmem unique id (inclusive) of range to copy.
+	 * @luid:   Last rmem unique id (exclusive) of range to copy.
+	 * Returns: Valid fence ptr or NULL on success otherwise ERR_PTR.
+	 *
+	 * This is call to copy local memory to remote memory. The driver need
+	 * to schedule the dma to copy the local memory from the pages given by
+	 * the pfns array, to the remote memory.
+	 *
+	 * Device driver should return a fence or an error pointer. If device
+	 * driver does not return a fence then the it must wait until the dma
+	 * is done. The device driver must set the HMM_PFN_RMEM_UPTODATE on all
+	 * successfully copied pages.
+	 *
+	 * If a valid fence is returned then hmm will wait on it and reschedule
+	 * any thread that need rescheduling.
+	 *
+	 * Failure will result in aborting migration to remote memory.
+	 *
+	 * DEVICE DRIVER MUST SET HMM_PFN_RMEM_UPTODATE ON ALL SUCCESSFULLY
+	 * COPIED PAGES.
+	 *
+	 * Return fence or NULL on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	struct hmm_fence *(*lmem_to_rmem)(struct hmm_rmem *rmem,
+					  unsigned long fuid,
+					  unsigned long luid);
+
+	/* rmem_split - split rmem.
+	 *
+	 * @rmem:   The remote memory to split.
+	 * @fuid:   First rmem unique id (inclusive) of range to split.
+	 * @luid:   Last rmem unique id (exclusive) of range to split.
+	 * Returns: 0 on success, error value otherwise.
+	 *
+	 * Split remote memory, first the device driver must allocate a new
+	 * remote memory struct, second it must call hmm_rmem_split_new and
+	 * last it must transfer private driver resource from splited rmem to
+	 * the new remote memory struct.
+	 *
+	 * Device driver _can not_ adjust nor the fuid nor the luid.
+	 *
+	 * Failure should be forwarded if any of the step fails. The device
+	 * driver does not need to worry about freeing the new remote memory
+	 * object once hmm_rmem_split_new is call as it will be freed through
+	 * the rmem_destroy callback if anything fails.
+	 *
+	 * DEVICE DRIVER MUST ABSOLUTELY TRY TO MAKE THIS CALL WORK OTHERWISE
+	 * THE WHOLE RMEM WILL BE MIGRATED BACK TO LMEM.
+	 *
+	 * Return error if operation failed. Valid value :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*rmem_split)(struct hmm_rmem *rmem,
+			  unsigned long fuid,
+			  unsigned long luid);
+
+	/* rmem_split_adjust - split rmem.
+	 *
+	 * @rmem:   The remote memory to split.
+	 * @fuid:   First rmem unique id (inclusive) of range to split.
+	 * @luid:   Last rmem unique id (exclusive) of range to split.
+	 * Returns: 0 on success, error value otherwise.
+	 *
+	 * Split remote memory, first the device driver must allocate a new
+	 * remote memory struct, second it must call hmm_rmem_split_new and
+	 * last it must transfer private driver resource from splited rmem to
+	 * the new remote memory struct.
+	 *
+	 * Device driver _can_ adjust the fuid or the luid with constraint that
+	 * adjusted_fuid <= fuid and adjusted_luid >= luid.
+	 *
+	 * Failure should be forwarded if any of the step fails. The device
+	 * driver does not need to worry about freeing the new remote memory
+	 * object once hmm_rmem_split_new is call as it will be freed through
+	 * the rmem_destroy callback if anything fails.
+	 *
+	 * DEVICE DRIVER MUST ABSOLUTELY TRY TO MAKE THIS CALL WORK OTHERWISE
+	 * THE WHOLE RMEM WILL BE MIGRATED BACK TO LMEM.
+	 *
+	 * Return error if operation failed. Valid value :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*rmem_split_adjust)(struct hmm_rmem *rmem,
+				 unsigned long fuid,
+				 unsigned long luid);
+
+	/* rmem_destroy - destroy rmem.
+	 *
+	 * @rmem:   The remote memory to destroy.
+	 *
+	 * Destroying remote memory structure once all ref are gone.
+	 */
+	void (*rmem_destroy)(struct hmm_rmem *rmem);
 };
 
 /* struct hmm_device - per device hmm structure
@@ -292,6 +582,7 @@ struct hmm_device_ops {
  * @mutex:      Mutex protecting mirrors list.
  * @ops:        The hmm operations callback.
  * @name:       Device name (uniquely identify the device on the system).
+ * @wait_queue: Wait queue for remote memory operations.
  *
  * Each device that want to mirror an address space must register one of this
  * struct (only once).
@@ -302,6 +593,8 @@ struct hmm_device {
 	struct mutex			mutex;
 	const struct hmm_device_ops	*ops;
 	const char			*name;
+	wait_queue_head_t		wait_queue;
+	bool				rmem;
 };
 
 /* hmm_device_register() - register a device with hmm.
@@ -322,6 +615,88 @@ struct hmm_device *hmm_device_unref(struct hmm_device *device);
 
 
 
+/* hmm_rmem - The rmem struct hold hmm infos of a remote memory block.
+ *
+ * The device driver should derivate its remote memory tracking structure from
+ * the hmm_rmem structure. The hmm_rmem structure dos not hold any infos about
+ * the specific of the remote memory block (device address or anything else).
+ * It solely store informations needed for finding rmem when cpu try to access
+ * it.
+ */
+
+/* struct hmm_rmem - remote memory block
+ *
+ * @kref:           Reference count.
+ * @device:         The hmm device the remote memory is allocated on.
+ * @event:          The event currently associated with the rmem.
+ * @lock:           Lock protecting the ranges list and event field.
+ * @ranges:         The list of address ranges that point to this rmem.
+ * @node:           Node for rmem unique id tree.
+ * @pgoff:          Page offset into file (in PAGE_SIZE not PAGE_CACHE_SIZE).
+ * @fuid:           First unique id associated with this specific hmm_rmem.
+ * @fuid:           Last unique id associated with this specific hmm_rmem.
+ * @subtree_luid:   Optimization for red and black interval tree.
+ * @pfns:           Array of pfn for local memory when some is attached.
+ * @dead:           The remote memory is no longer valid restart lookup.
+ *
+ * Each hmm_rmem has a uniq range of id that is use to uniquely identify remote
+ * memory on cpu side. Those uniq id do not relate in any way with the device
+ * physical address at which the remote memory is located.
+ */
+struct hmm_rmem {
+	struct kref		kref;
+	struct hmm_device	*device;
+	struct hmm_event	*event;
+	spinlock_t		lock;
+	struct list_head	ranges;
+	struct rb_node		node;
+	unsigned long		pgoff;
+	unsigned long		fuid;
+	unsigned long		luid;
+	unsigned long		subtree_luid;
+	unsigned long		*pfns;
+	bool			dead;
+};
+
+struct hmm_rmem *hmm_rmem_ref(struct hmm_rmem *rmem);
+struct hmm_rmem *hmm_rmem_unref(struct hmm_rmem *rmem);
+
+/* hmm_rmem_split_new - helper to split rmem.
+ *
+ * @rmem:   The remote memory to split.
+ * @new:    The new remote memory struct.
+ * Returns: 0 on success, error value otherwise.
+ *
+ * The new remote memory struct must be allocated by the device driver and its
+ * fuid and lui field must be set to the range the device wish to new rmem to
+ * cover.
+ *
+ * Moreover all below conditions must be true :
+ *   (new->fuid < new->luid)
+ *   (new->fuid >= rmem->fuid && new->luid <= rmem->luid)
+ *   (new->fuid == rmem->fuid || new->luid == rmem->luid)
+ *
+ * This hmm helper function will split range and perform internal hmm update on
+ * behalf of the device driver.
+ *
+ * Note that this function must be call by the rmem_split and rmem_split_adjust
+ * callback.
+ *
+ * Once this function is call the device driver should not try to free the new
+ * rmem structure no matter what is the return value. Moreover if the function
+ * return 0 then the device driver should properly update the new rmem struct.
+ *
+ * Return error if operation failed. Valid value :
+ * -EINVAL If one of the above condition is false.
+ * -ENOMEM If it failed to allocate memory.
+ * 0 on success.
+ */
+int hmm_rmem_split_new(struct hmm_rmem *rmem,
+		       struct hmm_rmem *new);
+
+
+
+
 /* hmm_mirror - device specific mirroring functions.
  *
  * Each device that mirror a process has a uniq hmm_mirror struct associating
@@ -406,6 +781,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
  */
 struct hmm_fault {
 	struct vm_area_struct	*vma;
+	struct hmm_rmem		*rmem;
 	unsigned long		faddr;
 	unsigned long		laddr;
 	unsigned long		*pfns;
@@ -450,6 +826,56 @@ struct hmm_mirror *hmm_mirror_unref(struct hmm_mirror *mirror);
 
 
 
+/* hmm_migrate - Memory migration from local memory to remote memory.
+ *
+ * Below are functions that handle migration from local memory to remote memory
+ * (represented by hmm_rmem struct). This is a multi-step process first the
+ * range is unmap, then the device driver depending on the size of the unmaped
+ * range can decide to proceed or abort the migration.
+ */
+
+/* hmm_migrate_rmem_to_lmem() - force migration of some rmem to lmem.
+ *
+ * @mirror: The mirror that link process address space with the device.
+ * @faddr:  First address of the range to migrate to lmem.
+ * @laddr:  Last address of the range to migrate to lmem.
+ * Returns: 0 on success, -EIO or -EINVAL.
+ *
+ * This migrate any remote memory behind a range of address to local memory.
+ *
+ * Returns:
+ * 0 success.
+ * -EINVAL if invalid argument.
+ * -EIO if one of the device driver returned this error.
+ */
+int hmm_migrate_rmem_to_lmem(struct hmm_mirror *mirror,
+			     unsigned long faddr,
+			     unsigned long laddr);
+
+/* hmm_migrate_lmem_to_rmem() - call to migrate lmem to rmem.
+ *
+ * @migrate:    The migration temporary struct.
+ * @mirror:     The mirror that link process address space with the device.
+ * Returns:     0, -EINVAL, -ENOMEM, -EFAULT, -EACCES, -ENODEV, -EBUSY, -EIO.
+ *
+ * On success the migrate struct is updated with the range that was migrated.
+ *
+ * Returns:
+ * 0 success.
+ * -EINVAL if invalid argument.
+ * -ENOMEM if failing to allocate memory.
+ * -EFAULT if range of address is invalid (no vma backing any of the range).
+ * -EACCES if vma backing the range is special vma.
+ * -ENODEV if mirror is in process of being destroy.
+ * -EBUSY if range can not be migrated (many different reasons).
+ * -EIO if one of the device driver returned this error.
+ */
+int hmm_migrate_lmem_to_rmem(struct hmm_fault *fault,
+			     struct hmm_mirror *mirror);
+
+
+
+
 /* Functions used by core mm code. Device driver should not use any of them. */
 void __hmm_destroy(struct mm_struct *mm);
 static inline void hmm_destroy(struct mm_struct *mm)
@@ -459,12 +885,51 @@ static inline void hmm_destroy(struct mm_struct *mm)
 	}
 }
 
+/* hmm_mm_fault() - call when cpu pagefault on special hmm pte entry.
+ *
+ * @mm:             The mm of the thread triggering the fault.
+ * @vma:            The vma in which the fault happen.
+ * @addr:           The address of the fault.
+ * @pte:            Pointer to the pte entry inside the cpu page table.
+ * @pmd:            Pointer to the pmd entry into which the pte is.
+ * @fault_flags:    Fault flags (read, write, ...).
+ * @orig_pte:       The original pte value when this fault happened.
+ *
+ * When the cpu try to access a range of memory that is in remote memory it
+ * fault in face of hmm special swap pte which will end up calling this
+ * function that should trigger the appropriate memory migration.
+ *
+ * Returns:
+ *   0 if some one else already migrated the rmem back.
+ *   VM_FAULT_SIGBUS on any i/o error during migration.
+ *   VM_FAULT_OOM if it fails to allocate memory for migration.
+ *   VM_FAULT_MAJOR on successfull migration.
+ */
+int hmm_mm_fault(struct mm_struct *mm,
+		 struct vm_area_struct *vma,
+		 unsigned long addr,
+		 pte_t *pte,
+		 pmd_t *pmd,
+		 unsigned int fault_flags,
+		 pte_t orig_pte);
+
 #else /* !CONFIG_HMM */
 
 static inline void hmm_destroy(struct mm_struct *mm)
 {
 }
 
+static inline int hmm_mm_fault(struct mm_struct *mm,
+			       struct vm_area_struct *vma,
+			       unsigned long addr,
+			       pte_t *pte,
+			       pmd_t *pmd,
+			       unsigned int fault_flags,
+			       pte_t orig_pte)
+{
+	return VM_FAULT_SIGBUS;
+}
+
 #endif /* !CONFIG_HMM */
 
 #endif
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 0794a73b..bb2c23f 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -42,6 +42,7 @@ enum mmu_action {
 	MMU_FAULT_WP,
 	MMU_THP_SPLIT,
 	MMU_THP_FAULT_WP,
+	MMU_HMM,
 };
 
 #ifdef CONFIG_MMU_NOTIFIER
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 5a14b92..0739b32 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -70,8 +70,18 @@ static inline int current_is_kswapd(void)
 #define SWP_HWPOISON_NUM 0
 #endif
 
+/*
+ * HMM (heterogeneous memory management) used when data is in remote memory.
+ */
+#ifdef CONFIG_HMM
+#define SWP_HMM_NUM 1
+#define SWP_HMM			(MAX_SWAPFILES + SWP_MIGRATION_NUM + SWP_HWPOISON_NUM)
+#else
+#define SWP_HMM_NUM 0
+#endif
+
 #define MAX_SWAPFILES \
-	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
+	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM - SWP_HMM_NUM)
 
 /*
  * Magic header for a swap area. The first part of the union is
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 6adfb7b..9a490d3 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -188,7 +188,38 @@ static inline int is_hwpoison_entry(swp_entry_t swp)
 }
 #endif
 
-#if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
+#ifdef CONFIG_HMM
+
+static inline swp_entry_t make_hmm_entry(unsigned long pgoff)
+{
+	/* We don't need to keep the page pfn, so use offset to store writeable
+	 * flag.
+	 */
+	return swp_entry(SWP_HMM, pgoff);
+}
+
+static inline unsigned long hmm_entry_uid(swp_entry_t entry)
+{
+	return swp_offset(entry);
+}
+
+static inline int is_hmm_entry(swp_entry_t entry)
+{
+	return unlikely(swp_type(entry) == SWP_HMM);
+}
+#else /* !CONFIG_HMM */
+#define make_hmm_entry(page, write) swp_entry(0, 0)
+static inline int is_hmm_entry(swp_entry_t swp)
+{
+	return 0;
+}
+
+static inline void make_hmm_entry_read(swp_entry_t *entry)
+{
+}
+#endif /* !CONFIG_HMM */
+
+#if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION) || defined(CONFIG_HMM)
 static inline int non_swap_entry(swp_entry_t entry)
 {
 	return swp_type(entry) >= MAX_SWAPFILES;
diff --git a/mm/hmm.c b/mm/hmm.c
index 2b8986c..599d4f6 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -77,6 +77,9 @@
 /* global SRCU for all MMs */
 static struct srcu_struct srcu;
 
+static spinlock_t _hmm_rmems_lock;
+static struct rb_root _hmm_rmems = RB_ROOT;
+
 
 
 
@@ -94,6 +97,7 @@ struct hmm_event {
 	unsigned long		faddr;
 	unsigned long		laddr;
 	struct list_head	fences;
+	struct list_head	ranges;
 	enum hmm_etype		etype;
 	bool			backoff;
 };
@@ -106,6 +110,7 @@ struct hmm_event {
  * @mirrors:        List of all mirror for this mm (one per device)
  * @mmu_notifier:   The mmu_notifier of this mm
  * @wait_queue:     Wait queue for synchronization btw cpu and device
+ * @ranges:         Tree of rmem ranges (sorted by address).
  * @events:         Events.
  * @nevents:        Number of events currently happening.
  * @dead:           The mm is being destroy.
@@ -122,6 +127,7 @@ struct hmm {
 	struct list_head	pending;
 	struct mmu_notifier	mmu_notifier;
 	wait_queue_head_t	wait_queue;
+	struct rb_root		ranges;
 	struct hmm_event	events[HMM_MAX_EVENTS];
 	int			nevents;
 	bool			dead;
@@ -132,137 +138,1456 @@ static struct mmu_notifier_ops hmm_notifier_ops;
 static inline struct hmm *hmm_ref(struct hmm *hmm);
 static inline struct hmm *hmm_unref(struct hmm *hmm);
 
-static int hmm_mirror_update(struct hmm_mirror *mirror,
-			     struct vm_area_struct *vma,
-			     unsigned long faddr,
-			     unsigned long laddr,
-			     struct hmm_event *event);
-static void hmm_mirror_cleanup(struct hmm_mirror *mirror);
+static void hmm_rmem_clear_range(struct hmm_rmem *rmem,
+				 struct vm_area_struct *vma,
+				 unsigned long faddr,
+				 unsigned long laddr,
+				 unsigned long fuid);
+static void hmm_rmem_poison_range(struct hmm_rmem *rmem,
+				  struct mm_struct *mm,
+				  struct vm_area_struct *vma,
+				  unsigned long faddr,
+				  unsigned long laddr,
+				  unsigned long fuid);
+
+static int hmm_mirror_rmem_update(struct hmm_mirror *mirror,
+				  struct hmm_rmem *rmem,
+				  unsigned long faddr,
+				  unsigned long laddr,
+				  unsigned long fuid,
+				  struct hmm_event *event,
+				  bool dirty);
+static int hmm_mirror_update(struct hmm_mirror *mirror,
+			     struct vm_area_struct *vma,
+			     unsigned long faddr,
+			     unsigned long laddr,
+			     struct hmm_event *event);
+static void hmm_mirror_cleanup(struct hmm_mirror *mirror);
+
+static int hmm_device_fence_wait(struct hmm_device *device,
+				 struct hmm_fence *fence);
+
+
+
+
+/* hmm_event - use to synchronize various mm events with each others.
+ *
+ * During life time of process various mm events will happen, hmm serialize
+ * event that affect overlapping range of address. The hmm_event are use for
+ * that purpose.
+ */
+
+static inline bool hmm_event_overlap(struct hmm_event *a, struct hmm_event *b)
+{
+	return !((a->laddr <= b->faddr) || (a->faddr >= b->laddr));
+}
+
+static inline unsigned long hmm_event_size(struct hmm_event *event)
+{
+	return (event->laddr - event->faddr);
+}
+
+
+
+
+/* hmm_fault_mm - used for reading cpu page table on device fault.
+ *
+ * This code deals with reading the cpu page table to find the pages that are
+ * backing a range of address. It is use as an helper to the device page fault
+ * code.
+ */
+
+/* struct hmm_fault_mm - used for reading cpu page table on device fault.
+ *
+ * @mm:     The mm of the process the device fault is happening in.
+ * @vma:    The vma in which the fault is happening.
+ * @faddr:  The first address for the range the device want to fault.
+ * @laddr:  The last address for the range the device want to fault.
+ * @pfns:   Array of hmm pfns (contains the result of the fault).
+ * @write:  Is this write fault.
+ */
+struct hmm_fault_mm {
+	struct mm_struct	*mm;
+	struct vm_area_struct	*vma;
+	unsigned long		faddr;
+	unsigned long		laddr;
+	unsigned long		*pfns;
+	bool			write;
+};
+
+static int hmm_fault_mm_fault_pmd(pmd_t *pmdp,
+				  unsigned long faddr,
+				  unsigned long laddr,
+				  struct mm_walk *walk)
+{
+	struct hmm_fault_mm *fault_mm = walk->private;
+	unsigned long idx, *pfns;
+	pte_t *ptep;
+
+	idx = (faddr - fault_mm->faddr) >> PAGE_SHIFT;
+	pfns = &fault_mm->pfns[idx];
+	memset(pfns, 0, ((laddr - faddr) >> PAGE_SHIFT) * sizeof(long));
+	if (pmd_none(*pmdp)) {
+		return -ENOENT;
+	}
+
+	if (pmd_trans_huge(*pmdp)) {
+		/* FIXME */
+		return -EINVAL;
+	}
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmdp)) {
+		return -EINVAL;
+	}
+
+	ptep = pte_offset_map(pmdp, faddr);
+	for (; faddr != laddr; ++ptep, ++pfns, faddr += PAGE_SIZE) {
+		pte_t pte = *ptep;
+
+		if (pte_none(pte)) {
+			if (fault_mm->write) {
+				ptep++;
+				break;
+			}
+			*pfns = my_zero_pfn(faddr) << HMM_PFN_SHIFT;
+			set_bit(HMM_PFN_VALID_ZERO, pfns);
+			continue;
+		}
+		if (!pte_present(pte) || (fault_mm->write && !pte_write(pte))) {
+			/* Need to inc ptep so unmap unlock on right pmd. */
+			ptep++;
+			break;
+		}
+		if (fault_mm->write && !pte_write(pte)) {
+			/* Need to inc ptep so unmap unlock on right pmd. */
+			ptep++;
+			break;
+		}
+
+		*pfns = pte_pfn(pte) << HMM_PFN_SHIFT;
+		set_bit(HMM_PFN_VALID_PAGE, pfns);
+		if (pte_write(pte)) {
+			set_bit(HMM_PFN_WRITE, pfns);
+		}
+		/* Consider the page as hot as a device want to use it. */
+		mark_page_accessed(pfn_to_page(pte_pfn(pte)));
+		fault_mm->laddr = faddr + PAGE_SIZE;
+	}
+	pte_unmap(ptep - 1);
+
+	return (faddr == laddr) ? 0 : -ENOENT;
+}
+
+static int hmm_fault_mm_fault(struct hmm_fault_mm *fault_mm)
+{
+	struct mm_walk walk = {0};
+	unsigned long faddr, laddr;
+	int ret;
+
+	faddr = fault_mm->faddr;
+	laddr = fault_mm->laddr;
+	fault_mm->laddr = faddr;
+
+	walk.pmd_entry = hmm_fault_mm_fault_pmd;
+	walk.mm = fault_mm->mm;
+	walk.private = fault_mm;
+
+	ret = walk_page_range(faddr, laddr, &walk);
+	return ret;
+}
+
+
+
+
+/* hmm_range - address range backed by remote memory.
+ *
+ * Each address range backed by remote memory is tracked so that on cpu page
+ * fault for a given address we can find the corresponding remote memory. We
+ * use a separate structure from remote memory as several different address
+ * range can point to the same remote memory (in case of shared mapping).
+ */
+
+/* struct hmm_range - address range backed by remote memory.
+ *
+ * @kref:           Reference count.
+ * @rmem:           Remote memory that back this address range.
+ * @mirror:         Mirror with which this range is associated.
+ * @fuid:           First unique id of rmem for this range.
+ * @faddr:          First address (inclusive) of the range.
+ * @laddr:          Last address (exclusive) of the range.
+ * @subtree_laddr:  Optimization for red black interval tree.
+ * @rlist:          List of all range associated with same rmem.
+ * @elist:          List of all range associated with an event.
+ */
+struct hmm_range {
+	struct kref		kref;
+	struct hmm_rmem		*rmem;
+	struct hmm_mirror	*mirror;
+	unsigned long		fuid;
+	unsigned long		faddr;
+	unsigned long		laddr;
+	unsigned long		subtree_laddr;
+	struct rb_node		node;
+	struct list_head	rlist;
+	struct list_head	elist;
+};
+
+static inline unsigned long hmm_range_faddr(struct hmm_range *range)
+{
+	return range->faddr;
+}
+
+static inline unsigned long hmm_range_laddr(struct hmm_range *range)
+{
+	return range->laddr - 1UL;
+}
+
+INTERVAL_TREE_DEFINE(struct hmm_range,
+		     node,
+		     unsigned long,
+		     subtree_laddr,
+		     hmm_range_faddr,
+		     hmm_range_laddr,,
+		     hmm_range_tree)
+
+static inline unsigned long hmm_range_npages(struct hmm_range *range)
+{
+	return (range->laddr - range->faddr) >> PAGE_SHIFT;
+}
+
+static inline unsigned long hmm_range_fuid(struct hmm_range *range)
+{
+	return range->fuid;
+}
+
+static inline unsigned long hmm_range_luid(struct hmm_range *range)
+{
+	return range->fuid + hmm_range_npages(range);
+}
+
+static void hmm_range_destroy(struct kref *kref)
+{
+	struct hmm_range *range;
+
+	range = container_of(kref, struct hmm_range, kref);
+	BUG_ON(!list_empty(&range->elist));
+	BUG_ON(!list_empty(&range->rlist));
+	BUG_ON(!RB_EMPTY_NODE(&range->node));
+
+	range->rmem = hmm_rmem_unref(range->rmem);
+	range->mirror = hmm_mirror_unref(range->mirror);
+	kfree(range);
+}
+
+static struct hmm_range *hmm_range_unref(struct hmm_range *range)
+{
+	if (range) {
+		kref_put(&range->kref, hmm_range_destroy);
+	}
+	return NULL;
+}
+
+static void hmm_range_init(struct hmm_range *range,
+			   struct hmm_mirror *mirror,
+			   struct hmm_rmem *rmem,
+			   unsigned long faddr,
+			   unsigned long laddr,
+			   unsigned long fuid)
+{
+	kref_init(&range->kref);
+	range->mirror = hmm_mirror_ref(mirror);
+	range->rmem = hmm_rmem_ref(rmem);
+	range->fuid = fuid;
+	range->faddr = faddr;
+	range->laddr = laddr;
+	RB_CLEAR_NODE(&range->node);
+
+	spin_lock(&rmem->lock);
+	list_add_tail(&range->rlist, &rmem->ranges);
+	if (rmem->event) {
+		list_add_tail(&range->elist, &rmem->event->ranges);
+	}
+	spin_unlock(&rmem->lock);
+}
+
+static void hmm_range_insert(struct hmm_range *range)
+{
+	struct hmm_mirror *mirror = range->mirror;
+
+	spin_lock(&mirror->hmm->lock);
+	if (RB_EMPTY_NODE(&range->node)) {
+		hmm_range_tree_insert(range, &mirror->hmm->ranges);
+	}
+	spin_unlock(&mirror->hmm->lock);
+}
+
+static inline void hmm_range_adjust_locked(struct hmm_range *range,
+					   unsigned long faddr,
+					   unsigned long laddr)
+{
+	if (!RB_EMPTY_NODE(&range->node)) {
+		hmm_range_tree_remove(range, &range->mirror->hmm->ranges);
+	}
+	if (faddr < range->faddr) {
+		range->fuid -= ((range->faddr - faddr) >> PAGE_SHIFT);
+	} else {
+		range->fuid += ((faddr - range->faddr) >> PAGE_SHIFT);
+	}
+	range->faddr = faddr;
+	range->laddr = laddr;
+	hmm_range_tree_insert(range, &range->mirror->hmm->ranges);
+}
+
+static int hmm_range_split(struct hmm_range *range,
+			   unsigned long saddr)
+{
+	struct hmm_mirror *mirror = range->mirror;
+	struct hmm_range *new;
+
+	if (range->faddr >= saddr) {
+		BUG();
+		return -EINVAL;
+	}
+
+	new = kmalloc(sizeof(struct hmm_range), GFP_KERNEL);
+	if (new == NULL) {
+		return -ENOMEM;
+	}
+
+	hmm_range_init(new,mirror,range->rmem,range->faddr,saddr,range->fuid);
+	spin_lock(&mirror->hmm->lock);
+	hmm_range_adjust_locked(range, saddr, range->laddr);
+	hmm_range_tree_insert(new, &mirror->hmm->ranges);
+	spin_unlock(&mirror->hmm->lock);
+	return 0;
+}
+
+static void hmm_range_fini(struct hmm_range *range)
+{
+	struct hmm_rmem *rmem = range->rmem;
+	struct hmm *hmm = range->mirror->hmm;
+
+	spin_lock(&hmm->lock);
+	if (!RB_EMPTY_NODE(&range->node)) {
+		hmm_range_tree_remove(range, &hmm->ranges);
+		RB_CLEAR_NODE(&range->node);
+	}
+	spin_unlock(&hmm->lock);
+
+	spin_lock(&rmem->lock);
+	list_del_init(&range->elist);
+	list_del_init(&range->rlist);
+	spin_unlock(&rmem->lock);
+
+	hmm_range_unref(range);
+}
+
+static void hmm_range_fini_clear(struct hmm_range *range,
+				 struct vm_area_struct *vma)
+{
+	hmm_rmem_clear_range(range->rmem, vma, range->faddr,
+			     range->laddr, range->fuid);
+	hmm_range_fini(range);
+}
+
+static inline bool hmm_range_reserve(struct hmm_range *range,
+				     struct hmm_event *event)
+{
+	bool reserved = false;
+
+	spin_lock(&range->rmem->lock);
+	if (range->rmem->event == NULL || range->rmem->event == event) {
+		range->rmem->event = event;
+		list_add_tail(&range->elist, &range->rmem->event->ranges);
+		reserved = true;
+	}
+	spin_unlock(&range->rmem->lock);
+	return reserved;
+}
+
+static inline void hmm_range_release(struct hmm_range *range,
+				     struct hmm_event *event)
+{
+	struct hmm_device *device = NULL;
+	spin_lock(&range->rmem->lock);
+	if (range->rmem->event != event) {
+		spin_unlock(&range->rmem->lock);
+		WARN_ONCE(1,"hmm: trying to release range from wrong event.\n");
+		return;
+	}
+	list_del_init(&range->elist);
+	if (list_empty(&range->rmem->event->ranges)) {
+		range->rmem->event = NULL;
+		device = range->rmem->device;
+	}
+	spin_unlock(&range->rmem->lock);
+
+	if (device) {
+		wake_up(&device->wait_queue);
+	}
+}
+
+
+
+
+/* hmm_rmem - The remote memory.
+ *
+ * Below are functions that deals with remote memory.
+ */
+
+/* struct hmm_rmem_mm - used during memory migration from/to rmem.
+ *
+ * @vma:            The vma that cover the range.
+ * @rmem:           The remote memory object.
+ * @faddr:          The first address in the range.
+ * @laddr:          The last address in the range.
+ * @fuid:           The first uid for the range.
+ * @rmeap_pages:    List of page to remap.
+ * @tlb:            For gathering cpu tlb flushes.
+ * @force_flush:    Force cpu tlb flush.
+ */
+struct hmm_rmem_mm {
+	struct vm_area_struct	*vma;
+	struct hmm_rmem		*rmem;
+	unsigned long		faddr;
+	unsigned long		laddr;
+	unsigned long		fuid;
+	struct list_head	remap_pages;
+	struct mmu_gather	tlb;
+	int			force_flush;
+};
+
+/* Interval tree for the hmm_rmem object. Providing the following functions :
+ * hmm_rmem_tree_insert(struct hmm_rmem *, struct rb_root *)
+ * hmm_rmem_tree_remove(struct hmm_rmem *, struct rb_root *)
+ * hmm_rmem_tree_iter_first(struct rb_root *, fpgoff, lpgoff)
+ * hmm_rmem_tree_iter_next(struct hmm_rmem *, fpgoff, lpgoff)
+ */
+static inline unsigned long hmm_rmem_fuid(struct hmm_rmem *rmem)
+{
+	return rmem->fuid;
+}
+
+static inline unsigned long hmm_rmem_luid(struct hmm_rmem *rmem)
+{
+	return rmem->luid - 1UL;
+}
+
+INTERVAL_TREE_DEFINE(struct hmm_rmem,
+		     node,
+		     unsigned long,
+		     subtree_luid,
+		     hmm_rmem_fuid,
+		     hmm_rmem_luid,,
+		     hmm_rmem_tree)
+
+static inline unsigned long hmm_rmem_npages(struct hmm_rmem *rmem)
+{
+	return (rmem->luid - rmem->fuid);
+}
+
+static inline unsigned long hmm_rmem_size(struct hmm_rmem *rmem)
+{
+	return hmm_rmem_npages(rmem) << PAGE_SHIFT;
+}
+
+static void hmm_rmem_free(struct hmm_rmem *rmem)
+{
+	unsigned long i;
+
+	for (i = 0; i < hmm_rmem_npages(rmem); ++i) {
+		struct page *page;
+
+		page = hmm_pfn_to_page(rmem->pfns[i]);
+		if (!page || test_bit(HMM_PFN_VALID_ZERO, &rmem->pfns[i])) {
+			continue;
+		}
+		/* Fake mapping so that page_remove_rmap behave as we want. */
+		VM_BUG_ON(page_mapcount(page));
+		atomic_set(&page->_mapcount, 0);
+		page_remove_rmap(page);
+		page_cache_release(page);
+		rmem->pfns[i] = 0;
+	}
+	kfree(rmem->pfns);
+	rmem->pfns = NULL;
+
+	spin_lock(&_hmm_rmems_lock);
+	if (!RB_EMPTY_NODE(&rmem->node)) {
+		hmm_rmem_tree_remove(rmem, &_hmm_rmems);
+		RB_CLEAR_NODE(&rmem->node);
+	}
+	spin_unlock(&_hmm_rmems_lock);
+}
+
+static void hmm_rmem_destroy(struct kref *kref)
+{
+	struct hmm_device *device;
+	struct hmm_rmem *rmem;
+
+	rmem = container_of(kref, struct hmm_rmem, kref);
+	device = rmem->device;
+	BUG_ON(!list_empty(&rmem->ranges));
+	hmm_rmem_free(rmem);
+	device->ops->rmem_destroy(rmem);
+}
+
+struct hmm_rmem *hmm_rmem_ref(struct hmm_rmem *rmem)
+{
+	if (rmem) {
+		kref_get(&rmem->kref);
+		return rmem;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(hmm_rmem_ref);
+
+struct hmm_rmem *hmm_rmem_unref(struct hmm_rmem *rmem)
+{
+	if (rmem) {
+		kref_put(&rmem->kref, hmm_rmem_destroy);
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(hmm_rmem_unref);
+
+static void hmm_rmem_init(struct hmm_rmem *rmem,
+			  struct hmm_device *device)
+{
+	kref_init(&rmem->kref);
+	rmem->device = device;
+	rmem->fuid = 0;
+	rmem->luid = 0;
+	rmem->pfns = NULL;
+	rmem->dead = false;
+	INIT_LIST_HEAD(&rmem->ranges);
+	spin_lock_init(&rmem->lock);
+	RB_CLEAR_NODE(&rmem->node);
+}
+
+static int hmm_rmem_alloc(struct hmm_rmem *rmem, unsigned long npages)
+{
+	rmem->pfns = kzalloc(sizeof(long) * npages, GFP_KERNEL);
+	if (rmem->pfns == NULL) {
+		return -ENOMEM;
+	}
+
+	spin_lock(&_hmm_rmems_lock);
+	if (_hmm_rmems.rb_node == NULL) {
+		rmem->fuid = 1;
+		rmem->luid = 1 + npages;
+	} else {
+		struct hmm_rmem *head;
+
+		head = container_of(_hmm_rmems.rb_node,struct hmm_rmem,node);
+		/* The subtree_luid of root node is the current luid. */
+		rmem->fuid = head->subtree_luid;
+		rmem->luid = head->subtree_luid + npages;
+	}
+	/* The rmem uid value must fit into swap entry. FIXME can we please
+	 * have an ARCH define for the maximum swap entry value !
+	 */
+	if (rmem->luid < MM_MAX_SWAP_PAGES) {
+		hmm_rmem_tree_insert(rmem, &_hmm_rmems);
+		spin_unlock(&_hmm_rmems_lock);
+		return 0;
+	}
+	spin_unlock(&_hmm_rmems_lock);
+	rmem->fuid = 0;
+	rmem->luid = 0;
+	return -ENOSPC;
+}
+
+static struct hmm_rmem *hmm_rmem_find(unsigned long uid)
+{
+	struct hmm_rmem *rmem;
+
+	spin_lock(&_hmm_rmems_lock);
+	rmem = hmm_rmem_tree_iter_first(&_hmm_rmems, uid, uid);
+	hmm_rmem_ref(rmem);
+	spin_unlock(&_hmm_rmems_lock);
+	return rmem;
+}
+
+int hmm_rmem_split_new(struct hmm_rmem *rmem,
+		       struct hmm_rmem *new)
+{
+	struct hmm_range *range, *next;
+	unsigned long i, pgoff, npages;
+
+	hmm_rmem_init(new, rmem->device);
+
+	/* Sanity check, the new rmem is either at the begining or at the end
+	 * of the old rmem it can not be in the middle.
+	 */
+	if (!(new->fuid < new->luid)) {
+		hmm_rmem_unref(new);
+		return -EINVAL;
+	}
+	if (!(new->fuid >= rmem->fuid && new->luid <= rmem->luid)) {
+		hmm_rmem_unref(new);
+		return -EINVAL;
+	}
+	if (!(new->fuid == rmem->fuid || new->luid == rmem->luid)) {
+		hmm_rmem_unref(new);
+		return -EINVAL;
+	}
+
+	npages = hmm_rmem_npages(new);
+	new->pfns = kzalloc(sizeof(long) * npages, GFP_KERNEL);
+	if (new->pfns == NULL) {
+		hmm_rmem_unref(new);
+		return -ENOMEM;
+	}
+
+retry:
+	spin_lock(&rmem->lock);
+	list_for_each_entry (range, &rmem->ranges, rlist) {
+		if (hmm_range_fuid(range) < new->fuid &&
+		    hmm_range_luid(range) > new->fuid) {
+			unsigned long soff;
+			int ret;
+
+			soff = ((new->fuid - range->fuid) << PAGE_SHIFT);
+			spin_unlock(&rmem->lock);
+			ret = hmm_range_split(range, soff + range->faddr);
+			if (ret) {
+				hmm_rmem_unref(new);
+				return ret;
+			}
+			goto retry;
+		}
+		if (hmm_range_fuid(range) < new->luid &&
+		    hmm_range_luid(range) > new->luid) {
+			unsigned long soff;
+			int ret;
+
+			soff = ((new->luid - range->fuid) << PAGE_SHIFT);
+			spin_unlock(&rmem->lock);
+			ret = hmm_range_split(range, soff + range->faddr);
+			if (ret) {
+				hmm_rmem_unref(new);
+				return ret;
+			}
+			goto retry;
+		}
+	}
+	spin_unlock(&rmem->lock);
+
+	spin_lock(&_hmm_rmems_lock);
+	hmm_rmem_tree_remove(rmem, &_hmm_rmems);
+	if (new->fuid != rmem->fuid) {
+		for (i = 0, pgoff = (new->fuid-rmem->fuid); i < npages; ++i) {
+			new->pfns[i] = rmem->pfns[i + pgoff];
+		}
+		rmem->luid = new->fuid;
+	} else {
+		for (i = 0; i < npages; ++i) {
+			new->pfns[i] = rmem->pfns[i];
+		}
+		rmem->fuid = new->luid;
+		for (i = 0, pgoff = npages; i < hmm_rmem_npages(rmem); ++i) {
+			rmem->pfns[i] = rmem->pfns[i + pgoff];
+		}
+	}
+	hmm_rmem_tree_insert(rmem, &_hmm_rmems);
+	hmm_rmem_tree_insert(new, &_hmm_rmems);
+
+	/* No need to lock the new ranges list as we are holding the
+	 * rmem uid tree lock and thus no one can find about the new
+	 * rmem yet.
+	 */
+	spin_lock(&rmem->lock);
+	list_for_each_entry_safe (range, next, &rmem->ranges, rlist) {
+		if (range->fuid >= rmem->fuid) {
+			continue;
+		}
+		list_del(&range->rlist);
+		list_add_tail(&range->rlist, &new->ranges);
+	}
+	spin_unlock(&rmem->lock);
+	spin_unlock(&_hmm_rmems_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_rmem_split_new);
+
+static int hmm_rmem_split(struct hmm_rmem *rmem,
+			  unsigned long fuid,
+			  unsigned long luid,
+			  bool adjust)
+{
+	struct hmm_device *device = rmem->device;
+	int ret;
+
+	if (fuid < rmem->fuid || luid > rmem->luid) {
+		WARN_ONCE(1, "hmm: rmem split received invalid range.\n");
+		return -EINVAL;
+	}
+
+	if (fuid == rmem->fuid && luid == rmem->luid) {
+		return 0;
+	}
+
+	if (adjust) {
+		ret = device->ops->rmem_split_adjust(rmem, fuid, luid);
+	} else {
+		ret = device->ops->rmem_split(rmem, fuid, luid);
+	}
+	return ret;
+}
+
+static void hmm_rmem_clear_range_page(struct hmm_rmem_mm *rmem_mm,
+				      unsigned long addr,
+				      pte_t *ptep,
+				      pmd_t *pmdp)
+{
+	struct vm_area_struct *vma = rmem_mm->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long uid;
+	pte_t pte;
+
+	uid = ((addr - rmem_mm->faddr) >> PAGE_SHIFT) + rmem_mm->fuid;
+	pte = ptep_get_and_clear(mm, addr, ptep);
+	if (!pte_same(pte, swp_entry_to_pte(make_hmm_entry(uid)))) {
+//		print_bad_pte(vma, addr, ptep, NULL);
+		set_pte_at(mm, addr, ptep, pte);
+	}
+}
+
+static int hmm_rmem_clear_range_pmd(pmd_t *pmdp,
+				    unsigned long addr,
+				    unsigned long next,
+				    struct mm_walk *walk)
+{
+	struct hmm_rmem_mm *rmem_mm = walk->private;
+	struct vm_area_struct *vma = rmem_mm->vma;
+	spinlock_t *ptl;
+	pte_t *ptep;
+
+	if (pmd_none(*pmdp)) {
+		return 0;
+	}
+
+	if (pmd_trans_huge(*pmdp)) {
+		/* This can not happen we do split huge page during unmap. */
+		BUG();
+		return 0;
+	}
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmdp)) {
+		/* FIXME I do not think this can happen at this point given
+		 * that during unmap all thp pmd were split.
+		 */
+		BUG();
+		return 0;
+	}
+
+	ptep = pte_offset_map_lock(vma->vm_mm, pmdp, addr, &ptl);
+	for (; addr != next; ++ptep, addr += PAGE_SIZE) {
+		hmm_rmem_clear_range_page(rmem_mm, addr, ptep, pmdp);
+	}
+	pte_unmap_unlock(ptep - 1, ptl);
+
+	return 0;
+}
+
+static void hmm_rmem_clear_range(struct hmm_rmem *rmem,
+				 struct vm_area_struct *vma,
+				 unsigned long faddr,
+				 unsigned long laddr,
+				 unsigned long fuid)
+{
+	struct hmm_rmem_mm rmem_mm;
+	struct mm_walk walk = {0};
+	unsigned long i, idx, npages;
+
+	rmem_mm.vma = vma;
+	rmem_mm.rmem = rmem;
+	rmem_mm.faddr = faddr;
+	rmem_mm.laddr = laddr;
+	rmem_mm.fuid = fuid;
+	walk.pmd_entry = hmm_rmem_clear_range_pmd;
+	walk.mm = vma->vm_mm;
+	walk.private = &rmem_mm;
+
+	/* No need to call mmu notifier the range was either unmaped or inside
+	 * video memory. In latter case invalidation must have happen prior to
+	 * this function being call.
+	 */
+	walk_page_range(faddr, laddr, &walk);
+
+	npages = (laddr - faddr) >> PAGE_SHIFT;
+	for (i = 0, idx = fuid - rmem->fuid; i < npages; ++i, ++idx) {
+		if (current->mm == vma->vm_mm) {
+			sync_mm_rss(vma->vm_mm);
+		}
+
+		/* Properly uncharge memory. */
+		mem_cgroup_uncharge_mm(vma->vm_mm);
+		add_mm_counter(vma->vm_mm, MM_ANONPAGES, -1);
+	}
+}
+
+static void hmm_rmem_poison_range_page(struct hmm_rmem_mm *rmem_mm,
+				       struct vm_area_struct *vma,
+				       unsigned long addr,
+				       pte_t *ptep,
+				       pmd_t *pmdp)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long uid;
+	pte_t pte;
+
+	uid = ((addr - rmem_mm->faddr) >> PAGE_SHIFT) + rmem_mm->fuid;
+	pte = ptep_get_and_clear(mm, addr, ptep);
+	if (!pte_same(pte, swp_entry_to_pte(make_hmm_entry(uid)))) {
+//		print_bad_pte(vma, addr, ptep, NULL);
+		set_pte_at(mm, addr, ptep, pte);
+	} else {
+		/* The 0 fuid is special poison value. */
+		pte = swp_entry_to_pte(make_hmm_entry(0));
+		set_pte_at(mm, addr, ptep, pte);
+	}
+}
+
+static int hmm_rmem_poison_range_pmd(pmd_t *pmdp,
+				     unsigned long addr,
+				     unsigned long next,
+				     struct mm_walk *walk)
+{
+	struct hmm_rmem_mm *rmem_mm = walk->private;
+	struct vm_area_struct *vma = rmem_mm->vma;
+	spinlock_t *ptl;
+	pte_t *ptep;
+
+	if (!vma) {
+		vma = find_vma(walk->mm, addr);
+	}
+
+	if (pmd_none(*pmdp)) {
+		return 0;
+	}
+
+	if (pmd_trans_huge(*pmdp)) {
+		/* This can not happen we do split huge page during unmap. */
+		BUG();
+		return 0;
+	}
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmdp)) {
+		/* FIXME I do not think this can happen at this point given
+		 * that during unmap all thp pmd were split.
+		 */
+		BUG();
+		return 0;
+	}
+
+	ptep = pte_offset_map_lock(vma->vm_mm, pmdp, addr, &ptl);
+	for (; addr != next; ++ptep, addr += PAGE_SIZE) {
+		hmm_rmem_poison_range_page(rmem_mm, vma, addr, ptep, pmdp);
+	}
+	pte_unmap_unlock(ptep - 1, ptl);
+
+	return 0;
+}
+
+static void hmm_rmem_poison_range(struct hmm_rmem *rmem,
+				  struct mm_struct *mm,
+				  struct vm_area_struct *vma,
+				  unsigned long faddr,
+				  unsigned long laddr,
+				  unsigned long fuid)
+{
+	struct hmm_rmem_mm rmem_mm;
+	struct mm_walk walk = {0};
+
+	rmem_mm.vma = vma;
+	rmem_mm.rmem = rmem;
+	rmem_mm.faddr = faddr;
+	rmem_mm.laddr = laddr;
+	rmem_mm.fuid = fuid;
+	walk.pmd_entry = hmm_rmem_poison_range_pmd;
+	walk.mm = mm;
+	walk.private = &rmem_mm;
+
+	/* No need to call mmu notifier the range was either unmaped or inside
+	 * video memory. In latter case invalidation must have happen prior to
+	 * this function being call.
+	 */
+	walk_page_range(faddr, laddr, &walk);
+}
+
+static int hmm_rmem_remap_page(struct hmm_rmem_mm *rmem_mm,
+			       unsigned long addr,
+			       pte_t *ptep,
+			       pmd_t *pmdp)
+{
+	struct vm_area_struct *vma = rmem_mm->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	struct hmm_rmem *rmem = rmem_mm->rmem;
+	unsigned long idx, uid;
+	struct page *page;
+	pte_t pte;
+
+	uid = rmem_mm->fuid + ((rmem_mm->faddr - addr) >> PAGE_SHIFT);
+	idx = (uid - rmem_mm->fuid);
+	pte = ptep_get_and_clear(mm, addr, ptep);
+	if (!pte_same(pte,swp_entry_to_pte(make_hmm_entry(uid)))) {
+		set_pte_at(mm, addr, ptep, pte);
+		if (vma->vm_file) {
+			/* Just ignore it, it might means that the shared page
+			 * backing this address was remapped right after being
+			 * added to the pagecache.
+			 */
+			return 0;
+		} else {
+//			print_bad_pte(vma, addr, ptep, NULL);
+			return -EFAULT;
+		}
+	}
+	page = hmm_pfn_to_page(rmem->pfns[idx]);
+	if (!page) {
+		/* Nothing to do. */
+		return 0;
+	}
+
+	/* The remap code must lock page prior to remapping. */
+	BUG_ON(PageHuge(page));
+	if (test_bit(HMM_PFN_VALID_PAGE, &rmem->pfns[idx])) {
+		BUG_ON(!PageLocked(page));
+		pte = mk_pte(page, vma->vm_page_prot);
+		if (test_bit(HMM_PFN_WRITE, &rmem->pfns[idx])) {
+			pte = pte_mkwrite(pte);
+		}
+		if (test_bit(HMM_PFN_DIRTY, &rmem->pfns[idx])) {
+			pte = pte_mkdirty(pte);
+		}
+		get_page(page);
+		/* Private anonymous page. */
+		page_add_anon_rmap(page, vma, addr);
+		/* FIXME is this necessary ? I do not think so. */
+		if (!reuse_swap_page(page)) {
+			/* Page is still mapped in another process. */
+			pte = pte_wrprotect(pte);
+		}
+	} else {
+		/* Special zero page. */
+		pte = pte_mkspecial(pfn_pte(page_to_pfn(page),
+				    vma->vm_page_prot));
+	}
+	set_pte_at(mm, addr, ptep, pte);
+
+	return 0;
+}
+
+static int hmm_rmem_remap_pmd(pmd_t *pmdp,
+			      unsigned long addr,
+			      unsigned long next,
+			      struct mm_walk *walk)
+{
+	struct hmm_rmem_mm *rmem_mm = walk->private;
+	struct vm_area_struct *vma = rmem_mm->vma;
+	spinlock_t *ptl;
+	pte_t *ptep;
+	int ret = 0;
+
+	if (pmd_none(*pmdp)) {
+		return 0;
+	}
+
+	if (pmd_trans_huge(*pmdp)) {
+		/* This can not happen we do split huge page during unmap. */
+		BUG();
+		return -EINVAL;
+	}
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmdp)) {
+		/* No pmd here. */
+		return 0;
+	}
+
+	ptep = pte_offset_map_lock(vma->vm_mm, pmdp, addr, &ptl);
+	for (; addr != next; ++ptep, addr += PAGE_SIZE) {
+		ret = hmm_rmem_remap_page(rmem_mm, addr, ptep, pmdp);
+		if (ret) {
+			/* Increment ptep so unlock works on correct pte. */
+			ptep++;
+			break;
+		}
+	}
+	pte_unmap_unlock(ptep - 1, ptl);
+
+	return ret;
+}
+
+static int hmm_rmem_remap_anon(struct hmm_rmem *rmem,
+			       struct vm_area_struct *vma,
+			       unsigned long faddr,
+			       unsigned long laddr,
+			       unsigned long fuid)
+{
+	struct hmm_rmem_mm rmem_mm;
+	struct mm_walk walk = {0};
+	int ret;
+
+	rmem_mm.vma = vma;
+	rmem_mm.rmem = rmem;
+	rmem_mm.faddr = faddr;
+	rmem_mm.laddr = laddr;
+	rmem_mm.fuid = fuid;
+	walk.pmd_entry = hmm_rmem_remap_pmd;
+	walk.mm = vma->vm_mm;
+	walk.private = &rmem_mm;
+
+	/* No need to call mmu notifier the range was either unmaped or inside
+	 * video memory. In latter case invalidation must have happen prior to
+	 * this function being call.
+	 */
+	ret = walk_page_range(faddr, laddr, &walk);
+
+	return ret;
+}
+
+static int hmm_rmem_unmap_anon_page(struct hmm_rmem_mm *rmem_mm,
+				    unsigned long addr,
+				    pte_t *ptep,
+				    pmd_t *pmdp)
+{
+	struct vm_area_struct *vma = rmem_mm->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	struct hmm_rmem *rmem = rmem_mm->rmem;
+	unsigned long idx, uid;
+	struct page *page;
+	pte_t pte;
+
+	/* New pte value. */
+	uid = ((addr - rmem_mm->faddr) >> PAGE_SHIFT) + rmem_mm->fuid;
+	idx = uid - rmem->fuid;
+	pte = ptep_get_and_clear_full(mm, addr, ptep, rmem_mm->tlb.fullmm);
+	tlb_remove_tlb_entry((&rmem_mm->tlb), ptep, addr);
+	rmem->pfns[idx] = 0;
+
+	if (pte_none(pte)) {
+		if (mem_cgroup_charge_anon(NULL, mm, GFP_KERNEL)) {
+			return -ENOMEM;
+		}
+		add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
+		/* Zero pte means nothing is there and thus nothing to copy. */
+		pte = swp_entry_to_pte(make_hmm_entry(uid));
+		set_pte_at(mm, addr, ptep, pte);
+		rmem->pfns[idx] = my_zero_pfn(addr) << HMM_PFN_SHIFT;
+		set_bit(HMM_PFN_VALID_ZERO, &rmem->pfns[idx]);
+		if (vma->vm_flags & VM_WRITE) {
+			set_bit(HMM_PFN_WRITE, &rmem->pfns[idx]);
+		}
+		set_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx]);
+		rmem_mm->laddr = addr + PAGE_SIZE;
+		return 0;
+	}
+	if (!pte_present(pte)) {
+		/* Page is not present it must be faulted, restore pte. */
+		set_pte_at(mm, addr, ptep, pte);
+		return -ENOENT;
+	}
+
+	page = pfn_to_page(pte_pfn(pte));
+	/* FIXME do we want to be able to unmap mlocked page ? */
+	if (PageMlocked(page)) {
+		set_pte_at(mm, addr, ptep, pte);
+		return -EBUSY;
+	}
+
+	rmem->pfns[idx] = pte_pfn(pte) << HMM_PFN_SHIFT;
+	if (is_zero_pfn(pte_pfn(pte))) {
+		set_bit(HMM_PFN_VALID_ZERO, &rmem->pfns[idx]);
+		set_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx]);
+	} else {
+		flush_cache_page(vma, addr, pte_pfn(pte));
+		set_bit(HMM_PFN_VALID_PAGE, &rmem->pfns[idx]);
+		set_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx]);
+		/* Anonymous private memory always writeable. */
+		if (pte_dirty(pte)) {
+			set_bit(HMM_PFN_DIRTY, &rmem->pfns[idx]);
+		}
+		if (trylock_page(page)) {
+			set_bit(HMM_PFN_LOCK, &rmem->pfns[idx]);
+		}
+		rmem_mm->force_flush=!__tlb_remove_page(&rmem_mm->tlb,page);
+
+		/* tlb_flush_mmu drop one ref so take an extra ref here. */
+		get_page(page);
+	}
+	if (vma->vm_flags & VM_WRITE) {
+		set_bit(HMM_PFN_WRITE, &rmem->pfns[idx]);
+	}
+	rmem_mm->laddr = addr + PAGE_SIZE;
+
+	pte = swp_entry_to_pte(make_hmm_entry(uid));
+	set_pte_at(mm, addr, ptep, pte);
+
+	/* What a journey ! */
+	return 0;
+}
+
+static int hmm_rmem_unmap_pmd(pmd_t *pmdp,
+			      unsigned long addr,
+			      unsigned long next,
+			      struct mm_walk *walk)
+{
+	struct hmm_rmem_mm *rmem_mm = walk->private;
+	struct vm_area_struct *vma = rmem_mm->vma;
+	spinlock_t *ptl;
+	pte_t *ptep;
+	int ret = 0;
+
+	if (pmd_none(*pmdp)) {
+		if (unlikely(__pte_alloc(vma->vm_mm, vma, pmdp, addr))) {
+			return -ENOENT;
+		}
+	}
+
+	if (pmd_trans_huge(*pmdp)) {
+		/* FIXME this will dead lock because it does mmu_notifier_range_invalidate */
+		split_huge_page_pmd(vma, addr, pmdp);
+		return -EAGAIN;
+	}
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmdp)) {
+		/* It is already be handled above. */
+		BUG();
+		return -EINVAL;
+	}
+
+again:
+	ptep = pte_offset_map_lock(vma->vm_mm, pmdp, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+	for (; addr != next; ++ptep, addr += PAGE_SIZE) {
+		ret = hmm_rmem_unmap_anon_page(rmem_mm, addr,
+					       ptep, pmdp);
+		if (ret || rmem_mm->force_flush) {
+			/* Increment ptep so unlock works on correct
+			 * pte.
+			 */
+			ptep++;
+			break;
+		}
+	}
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(ptep - 1, ptl);
+
+	/* mmu_gather ran out of room to batch pages, we break out of the PTE
+	 * lock to avoid doing the potential expensive TLB invalidate and
+	 * page-free while holding it.
+	 */
+	if (rmem_mm->force_flush) {
+		unsigned long old_end;
+
+		rmem_mm->force_flush = 0;
+		/*
+		 * Flush the TLB just for the previous segment,
+		 * then update the range to be the remaining
+		 * TLB range.
+		 */
+		old_end = rmem_mm->tlb.end;
+		rmem_mm->tlb.end = addr;
+
+		tlb_flush_mmu(&rmem_mm->tlb);
+
+		rmem_mm->tlb.start = addr;
+		rmem_mm->tlb.end = old_end;
+
+		if (!ret && addr != next) {
+			goto again;
+		}
+	}
+
+	return ret;
+}
+
+static int hmm_rmem_unmap_anon(struct hmm_rmem *rmem,
+			       struct vm_area_struct *vma,
+			       unsigned long faddr,
+			       unsigned long laddr)
+{
+	struct hmm_rmem_mm rmem_mm;
+	struct mm_walk walk = {0};
+	unsigned long i, npages;
+	int ret;
+
+	if (vma->vm_file) {
+		return -EINVAL;
+	}
 
-static int hmm_device_fence_wait(struct hmm_device *device,
-				 struct hmm_fence *fence);
+	npages = (laddr - faddr) >> PAGE_SHIFT;
+	rmem->pgoff = faddr;
+	rmem_mm.vma = vma;
+	rmem_mm.rmem = rmem;
+	rmem_mm.faddr = faddr;
+	rmem_mm.laddr = faddr;
+	rmem_mm.fuid = rmem->fuid;
+	memset(rmem->pfns, 0, sizeof(long) * npages);
+
+	rmem_mm.force_flush = 0;
+	walk.pmd_entry = hmm_rmem_unmap_pmd;
+	walk.mm = vma->vm_mm;
+	walk.private = &rmem_mm;
+
+	mmu_notifier_invalidate_range_start(walk.mm,vma,faddr,laddr,MMU_HMM);
+	tlb_gather_mmu(&rmem_mm.tlb, walk.mm, faddr, laddr);
+	tlb_start_vma(&rmem_mm.tlb, rmem_mm->vma);
+	ret = walk_page_range(faddr, laddr, &walk);
+	tlb_end_vma(&rmem_mm.tlb, rmem_mm->vma);
+	tlb_finish_mmu(&rmem_mm.tlb, faddr, laddr);
+	mmu_notifier_invalidate_range_end(walk.mm, vma, faddr, laddr, MMU_HMM);
 
+	/* Before migrating page we must lock them. Here we lock all page we
+	 * could not lock while holding pte lock.
+	 */
+	npages = (rmem_mm.laddr - faddr) >> PAGE_SHIFT;
+	for (i = 0; i < npages; ++i) {
+		struct page *page;
 
+		if (test_bit(HMM_PFN_VALID_ZERO, &rmem->pfns[i])) {
+			continue;
+		}
 
+		page = hmm_pfn_to_page(rmem->pfns[i]);
+		if (!test_bit(HMM_PFN_LOCK, &rmem->pfns[i])) {
+			lock_page(page);
+			set_bit(HMM_PFN_LOCK, &rmem->pfns[i]);
+		}
+	}
 
-/* hmm_event - use to synchronize various mm events with each others.
- *
- * During life time of process various mm events will happen, hmm serialize
- * event that affect overlapping range of address. The hmm_event are use for
- * that purpose.
- */
+	return ret;
+}
 
-static inline bool hmm_event_overlap(struct hmm_event *a, struct hmm_event *b)
+static inline int hmm_rmem_unmap(struct hmm_rmem *rmem,
+				 struct vm_area_struct *vma,
+				 unsigned long faddr,
+				 unsigned long laddr)
 {
-	return !((a->laddr <= b->faddr) || (a->faddr >= b->laddr));
+	if (vma->vm_file) {
+		return -EBUSY;
+	} else {
+		return hmm_rmem_unmap_anon(rmem, vma, faddr, laddr);
+	}
 }
 
-static inline unsigned long hmm_event_size(struct hmm_event *event)
+static int hmm_rmem_alloc_pages(struct hmm_rmem *rmem,
+				struct vm_area_struct *vma,
+				unsigned long addr)
 {
-	return (event->laddr - event->faddr);
-}
+	unsigned long i, npages = hmm_rmem_npages(rmem);
+	unsigned long *pfns = rmem->pfns;
+	struct mm_struct *mm = vma ? vma->vm_mm : NULL;
+	int ret = 0;
 
+	if (vma && !(vma->vm_file)) {
+		if (unlikely(anon_vma_prepare(vma))) {
+			return -ENOMEM;
+		}
+	}
 
+	for (i = 0; i < npages; ++i, addr += PAGE_SIZE) {
+		struct page *page;
 
+		/* (i) This does happen if vma is being split and rmem split
+		 * failed thus we are falling back to full rmem migration and
+		 * there might not be a vma covering all the address (ie some
+		 * of the migration is useless but to make code simpler we just
+		 * copy more stuff than necessary).
+		 */
+		if (vma && addr >= vma->vm_end) {
+			vma = mm ? find_vma(mm, addr) : NULL;
+		}
 
-/* hmm_fault_mm - used for reading cpu page table on device fault.
- *
- * This code deals with reading the cpu page table to find the pages that are
- * backing a range of address. It is use as an helper to the device page fault
- * code.
- */
+		/* No need to clear page they will be dma to of course this does
+		 * means we trust the device driver.
+		 */
+		if (!vma) {
+			/* See above (i) for when this does happen. */
+			page = alloc_page(GFP_HIGHUSER_MOVABLE);
+		} else {
+			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, addr);
+		}
+		if (!page) {
+			ret = ret ? ret : -ENOMEM;
+			continue;
+		}
+		lock_page(page);
+		pfns[i] = page_to_pfn(page) << HMM_PFN_SHIFT;
+		set_bit(HMM_PFN_WRITE, &pfns[i]);
+		set_bit(HMM_PFN_LOCK, &pfns[i]);
+		set_bit(HMM_PFN_VALID_PAGE, &pfns[i]);
+		page_add_new_anon_rmap(page, vma, addr);
+	}
 
-/* struct hmm_fault_mm - used for reading cpu page table on device fault.
- *
- * @mm:     The mm of the process the device fault is happening in.
- * @vma:    The vma in which the fault is happening.
- * @faddr:  The first address for the range the device want to fault.
- * @laddr:  The last address for the range the device want to fault.
- * @pfns:   Array of hmm pfns (contains the result of the fault).
- * @write:  Is this write fault.
- */
-struct hmm_fault_mm {
-	struct mm_struct	*mm;
-	struct vm_area_struct	*vma;
-	unsigned long		faddr;
-	unsigned long		laddr;
-	unsigned long		*pfns;
-	bool			write;
-};
+	return ret;
+}
 
-static int hmm_fault_mm_fault_pmd(pmd_t *pmdp,
-				  unsigned long faddr,
-				  unsigned long laddr,
-				  struct mm_walk *walk)
+int hmm_rmem_migrate_to_lmem(struct hmm_rmem *rmem,
+			     struct vm_area_struct *vma,
+			     unsigned long addr,
+			     unsigned long fuid,
+			     unsigned long luid,
+			     bool adjust)
 {
-	struct hmm_fault_mm *fault_mm = walk->private;
-	unsigned long idx, *pfns;
-	pte_t *ptep;
+	struct hmm_device *device = rmem->device;
+	struct hmm_range *range, *next;
+	struct hmm_fence *fence, *tmp;
+	struct mm_struct *mm = vma ? vma->vm_mm : NULL;
+	struct list_head fences;
+	unsigned long i;
+	int ret = 0;
 
-	idx = (faddr - fault_mm->faddr) >> PAGE_SHIFT;
-	pfns = &fault_mm->pfns[idx];
-	memset(pfns, 0, ((laddr - faddr) >> PAGE_SHIFT) * sizeof(long));
-	if (pmd_none(*pmdp)) {
-		return -ENOENT;
+	BUG_ON(vma && ((addr < vma->vm_start) || (addr >= vma->vm_end)));
+
+	/* Ignore split error will fallback to full migration. */
+	hmm_rmem_split(rmem, fuid, luid, adjust);
+
+	if (rmem->fuid > fuid || rmem->luid < luid) {
+		WARN_ONCE(1, "hmm: rmem split out of constraint.\n");
+		ret = -EINVAL;
+		goto error;
 	}
 
-	if (pmd_trans_huge(*pmdp)) {
-		/* FIXME */
-		return -EINVAL;
+	/* Adjust start address for page allocation if necessary. */
+	if (vma && (rmem->fuid < fuid)) {
+		if (((addr-vma->vm_start)>>PAGE_SHIFT) < (fuid-rmem->fuid)) {
+			/* FIXME can this happen ? I would say now but right
+			 * now i can not hold in my brain all code path that
+			 * leads to this place.
+			 */
+			vma = NULL;
+		} else {
+			addr -= ((fuid - rmem->fuid) << PAGE_SHIFT);
+		}
 	}
 
-	if (pmd_none_or_trans_huge_or_clear_bad(pmdp)) {
-		return -EINVAL;
+	ret = hmm_rmem_alloc_pages(rmem, vma, addr);
+	if (ret) {
+		goto error;
 	}
 
-	ptep = pte_offset_map(pmdp, faddr);
-	for (; faddr != laddr; ++ptep, ++pfns, faddr += PAGE_SIZE) {
-		pte_t pte = *ptep;
+	INIT_LIST_HEAD(&fences);
 
-		if (pte_none(pte)) {
-			if (fault_mm->write) {
-				ptep++;
-				break;
-			}
-			*pfns = my_zero_pfn(faddr) << HMM_PFN_SHIFT;
-			set_bit(HMM_PFN_VALID_ZERO, pfns);
-			continue;
+	/* No need to lock because at this point no one else can modify the
+	 * ranges list.
+	 */
+	list_for_each_entry (range, &rmem->ranges, rlist) {
+		fence = device->ops->rmem_update(range->mirror,
+						 range->rmem,
+						 range->faddr,
+						 range->laddr,
+						 range->fuid,
+						 HMM_MIGRATE_TO_LMEM,
+						 false);
+		if (IS_ERR(fence)) {
+			ret = PTR_ERR(fence);
+			goto error;
 		}
-		if (!pte_present(pte) || (fault_mm->write && !pte_write(pte))) {
-			/* Need to inc ptep so unmap unlock on right pmd. */
-			ptep++;
-			break;
+		if (fence) {
+			list_add_tail(&fence->list, &fences);
 		}
+	}
 
-		*pfns = pte_pfn(pte) << HMM_PFN_SHIFT;
-		set_bit(HMM_PFN_VALID_PAGE, pfns);
-		if (pte_write(pte)) {
-			set_bit(HMM_PFN_WRITE, pfns);
+	list_for_each_entry_safe (fence, tmp, &fences, list) {
+		int r;
+
+		r = hmm_device_fence_wait(device, fence);
+		ret = ret ? min(ret, r) : r;
+	}
+	if (ret) {
+		goto error;
+	}
+
+	fence = device->ops->rmem_to_lmem(rmem, rmem->fuid, rmem->luid);
+	if (IS_ERR(fence)) {
+		/* FIXME Check return value. */
+		ret = PTR_ERR(fence);
+		goto error;
+	}
+
+	if (fence) {
+		INIT_LIST_HEAD(&fence->list);
+		ret = hmm_device_fence_wait(device, fence);
+		if (ret) {
+			goto error;
 		}
-		/* Consider the page as hot as a device want to use it. */
-		mark_page_accessed(pfn_to_page(pte_pfn(pte)));
-		fault_mm->laddr = faddr + PAGE_SIZE;
 	}
-	pte_unmap(ptep - 1);
 
-	return (faddr == laddr) ? 0 : -ENOENT;
-}
+	/* Now the remote memory is officialy dead and nothing below can fails
+	 * badly.
+	 */
+	rmem->dead = true;
 
-static int hmm_fault_mm_fault(struct hmm_fault_mm *fault_mm)
-{
-	struct mm_walk walk = {0};
-	unsigned long faddr, laddr;
-	int ret;
+	/* No need to lock because at this point no one else can modify the
+	 * ranges list.
+	 */
+	list_for_each_entry_safe (range, next, &rmem->ranges, rlist) {
+		VM_BUG_ON(!vma);
+		VM_BUG_ON(range->faddr < vma->vm_start);
+		VM_BUG_ON(range->laddr > vma->vm_end);
+
+		/* The remapping fail only if something goes terribly wrong. */
+		ret = hmm_rmem_remap_anon(rmem, vma, range->faddr,
+					  range->laddr, range->fuid);
+		if (ret) {
+			WARN_ONCE(1, "hmm: something is terribly wrong.\n");
+			hmm_rmem_poison_range(rmem, mm, vma, range->faddr,
+					      range->laddr, range->fuid);
+		}
+		hmm_range_fini(range);
+	}
 
-	faddr = fault_mm->faddr;
-	laddr = fault_mm->laddr;
-	fault_mm->laddr = faddr;
+	for (i = 0; i < hmm_rmem_npages(rmem); ++i) {
+		struct page *page = hmm_pfn_to_page(rmem->pfns[i]);
 
-	walk.pmd_entry = hmm_fault_mm_fault_pmd;
-	walk.mm = fault_mm->mm;
-	walk.private = fault_mm;
+		unlock_page(page);
+		mem_cgroup_transfer_charge_anon(page, mm);
+		page_remove_rmap(page);
+		page_cache_release(page);
+		rmem->pfns[i] = 0UL;
+	}
+	return 0;
 
-	ret = walk_page_range(faddr, laddr, &walk);
+error:
+	/* No need to lock because at this point no one else can modify the
+	 * ranges list.
+	 */
+	/* There is two case here :
+	 * (1) rmem is mirroring shared memory in which case we are facing the
+	 *     issue of poisoning all the mapping in all the process for that
+	 *     file.
+	 * (2) rmem is mirroring private memory, easy case poison all ranges
+	 *     referencing the rmem.
+	 */
+	for (i = 0; i < hmm_rmem_npages(rmem); ++i) {
+		struct page *page = hmm_pfn_to_page(rmem->pfns[i]);
+
+		if (!page) {
+			if (vma && !(vma->vm_flags & VM_SHARED)) {
+				/* Properly uncharge memory. */
+				mem_cgroup_uncharge_mm(mm);
+			}
+			continue;
+		}
+		/* Properly uncharge memory. */
+		mem_cgroup_transfer_charge_anon(page, mm);
+		if (!test_bit(HMM_PFN_LOCK, &rmem->pfns[i])) {
+			unlock_page(page);
+		}
+		page_remove_rmap(page);
+		page_cache_release(page);
+		rmem->pfns[i] = 0UL;
+	}
+	list_for_each_entry_safe (range, next, &rmem->ranges, rlist) {
+		mm = range->mirror->hmm->mm;
+		hmm_rmem_poison_range(rmem, mm, NULL, range->faddr,
+				      range->laddr, range->fuid);
+		hmm_range_fini(range);
+	}
 	return ret;
 }
 
@@ -285,6 +1610,7 @@ static int hmm_init(struct hmm *hmm, struct mm_struct *mm)
 	INIT_LIST_HEAD(&hmm->mirrors);
 	INIT_LIST_HEAD(&hmm->pending);
 	spin_lock_init(&hmm->lock);
+	hmm->ranges = RB_ROOT;
 	init_waitqueue_head(&hmm->wait_queue);
 
 	for (i = 0; i < HMM_MAX_EVENTS; ++i) {
@@ -298,6 +1624,12 @@ static int hmm_init(struct hmm *hmm, struct mm_struct *mm)
 	return ret;
 }
 
+static inline bool hmm_event_cover_range(struct hmm_event *a,
+					 struct hmm_range *b)
+{
+	return ((a->faddr <= b->faddr) && (a->laddr >= b->laddr));
+}
+
 static enum hmm_etype hmm_event_mmu(enum mmu_action action)
 {
 	switch (action) {
@@ -326,6 +1658,7 @@ static enum hmm_etype hmm_event_mmu(enum mmu_action action)
 	case MMU_MUNMAP:
 		return HMM_MUNMAP;
 	case MMU_SOFT_DIRTY:
+	case MMU_HMM:
 	default:
 		return HMM_NONE;
 	}
@@ -357,6 +1690,8 @@ static void hmm_destroy_kref(struct kref *kref)
 	mm->hmm = NULL;
 	mmu_notifier_unregister(&hmm->mmu_notifier, mm);
 
+	BUG_ON(!RB_EMPTY_ROOT(&hmm->ranges));
+
 	if (!list_empty(&hmm->mirrors)) {
 		BUG();
 		printk(KERN_ERR "destroying an hmm with still active mirror\n"
@@ -410,6 +1745,7 @@ out:
 	event->laddr = laddr;
 	event->backoff = false;
 	INIT_LIST_HEAD(&event->fences);
+	INIT_LIST_HEAD(&event->ranges);
 	hmm->nevents++;
 	list_add_tail(&event->list, &hmm->pending);
 
@@ -447,11 +1783,116 @@ wait:
 	goto retry_wait;
 }
 
+static int hmm_migrate_to_lmem(struct hmm *hmm,
+			       struct vm_area_struct *vma,
+			       unsigned long faddr,
+			       unsigned long laddr,
+			       bool adjust)
+{
+	struct hmm_range *range;
+	struct hmm_rmem *rmem;
+	int ret = 0;
+
+	if (unlikely(anon_vma_prepare(vma))) {
+		return -ENOMEM;
+	}
+
+retry:
+	spin_lock(&hmm->lock);
+	range = hmm_range_tree_iter_first(&hmm->ranges, faddr, laddr - 1);
+	while (range && faddr < laddr) {
+		struct hmm_device *device;
+		unsigned long fuid, luid, cfaddr, claddr;
+		int r;
+
+		cfaddr = max(faddr, range->faddr);
+		claddr = min(laddr, range->laddr);
+		fuid = range->fuid + ((cfaddr - range->faddr) >> PAGE_SHIFT);
+		luid = fuid + ((claddr - cfaddr) >> PAGE_SHIFT);
+		faddr = min(range->laddr, laddr);
+		rmem = hmm_rmem_ref(range->rmem);
+		device = rmem->device;
+		spin_unlock(&hmm->lock);
+
+		r = hmm_rmem_migrate_to_lmem(rmem, vma, cfaddr, fuid,
+					     luid, adjust);
+		hmm_rmem_unref(rmem);
+		if (r) {
+			ret = ret ? ret : r;
+			hmm_mirror_cleanup(range->mirror);
+			goto retry;
+		}
+
+		spin_lock(&hmm->lock);
+		range = hmm_range_tree_iter_first(&hmm->ranges,faddr,laddr-1);
+	}
+	spin_unlock(&hmm->lock);
+
+	return ret;
+}
+
+static unsigned long hmm_ranges_reserve(struct hmm *hmm, struct hmm_event *event)
+{
+	struct hmm_range *range;
+	unsigned long faddr, laddr, count = 0;
+
+	faddr = event->faddr;
+	laddr = event->laddr;
+
+retry:
+	spin_lock(&hmm->lock);
+	range = hmm_range_tree_iter_first(&hmm->ranges, faddr, laddr - 1);
+	while (range) {
+		if (!hmm_range_reserve(range, event)) {
+			struct hmm_rmem *rmem = hmm_rmem_ref(range->rmem);
+			spin_unlock(&hmm->lock);
+			wait_event(hmm->wait_queue, rmem->event != NULL);
+			hmm_rmem_unref(rmem);
+			goto retry;
+		}
+
+		if (list_empty(&range->elist)) {
+			list_add_tail(&range->elist, &event->ranges);
+			count++;
+		}
+
+		range = hmm_range_tree_iter_next(range, faddr, laddr - 1);
+	}
+	spin_unlock(&hmm->lock);
+
+	return count;
+}
+
+static void hmm_ranges_release(struct hmm *hmm, struct hmm_event *event)
+{
+	struct hmm_range *range, *next;
+
+	list_for_each_entry_safe (range, next, &event->ranges, elist) {
+		hmm_range_release(range, event);
+	}
+}
+
 static void hmm_update_mirrors(struct hmm *hmm,
 			       struct vm_area_struct *vma,
 			       struct hmm_event *event)
 {
 	unsigned long faddr, laddr;
+	bool migrate = false;
+
+	switch (event->etype) {
+	case HMM_COW:
+		migrate = true;
+		break;
+	case HMM_MUNMAP:
+		migrate = vma->vm_file ? true : false;
+		break;
+	default:
+		break;
+	}
+
+	if (hmm_ranges_reserve(hmm, event) && migrate) {
+		hmm_migrate_to_lmem(hmm,vma,event->faddr,event->laddr,false);
+	}
 
 	for (faddr = event->faddr; faddr < event->laddr; faddr = laddr) {
 		struct hmm_mirror *mirror;
@@ -494,6 +1935,7 @@ retry_ranges:
 			}
 		}
 	}
+	hmm_ranges_release(hmm, event);
 }
 
 static int hmm_fault_mm(struct hmm *hmm,
@@ -529,6 +1971,98 @@ static int hmm_fault_mm(struct hmm *hmm,
 	return 0;
 }
 
+/* see include/linux/hmm.h */
+int hmm_mm_fault(struct mm_struct *mm,
+		 struct vm_area_struct *vma,
+		 unsigned long addr,
+		 pte_t *pte,
+		 pmd_t *pmd,
+		 unsigned int fault_flags,
+		 pte_t opte)
+{
+	struct hmm_mirror *mirror = NULL;
+	struct hmm_device *device;
+	struct hmm_event *event;
+	struct hmm_range *range;
+	struct hmm_rmem *rmem = NULL;
+	unsigned long uid, faddr, laddr;
+	swp_entry_t entry;
+	struct hmm *hmm = hmm_ref(mm->hmm);
+	int ret;
+
+	if (!hmm) {
+		BUG();
+		return VM_FAULT_SIGBUS;
+	}
+
+	/* Find the corresponding rmem. */
+	entry = pte_to_swp_entry(opte);
+	if (!is_hmm_entry(entry)) {
+		//print_bad_pte(vma, addr, opte, NULL);
+		hmm_unref(hmm);
+		return VM_FAULT_SIGBUS;
+	}
+	uid = hmm_entry_uid(entry);
+	if (!uid) {
+		/* Poisonous hmm swap entry. */
+		hmm_unref(hmm);
+		return VM_FAULT_SIGBUS;
+	}
+
+	rmem = hmm_rmem_find(uid);
+	if (!rmem) {
+		hmm_unref(hmm);
+		if (pte_same(*pte, opte)) {
+			//print_bad_pte(vma, addr, opte, NULL);
+			return VM_FAULT_SIGBUS;
+		}
+		return 0;
+	}
+
+	faddr = addr & PAGE_MASK;
+	/* FIXME use the readahead value as a hint on how much to migrate. */
+	laddr = min(faddr + (16 << PAGE_SHIFT), vma->vm_end);
+	spin_lock(&rmem->lock);
+	list_for_each_entry (range, &rmem->ranges, rlist) {
+		if (faddr < range->faddr || faddr >= range->laddr) {
+			continue;
+		}
+		if (range->mirror->hmm == hmm) {
+			laddr = min(laddr, range->laddr);
+			mirror = hmm_mirror_ref(range->mirror);
+			break;
+		}
+	}
+	spin_unlock(&rmem->lock);
+	hmm_rmem_unref(rmem);
+	hmm_unref(hmm);
+	if (mirror == NULL) {
+		if (pte_same(*pte, opte)) {
+			//print_bad_pte(vma, addr, opte, NULL);
+			return VM_FAULT_SIGBUS;
+		}
+		return 0;
+	}
+
+	device = rmem->device;
+	event = hmm_event_get(hmm, faddr, laddr, HMM_MIGRATE_TO_LMEM);
+	hmm_ranges_reserve(hmm, event);
+	ret = hmm_migrate_to_lmem(hmm, vma, faddr, laddr, true);
+	hmm_ranges_release(hmm, event);
+	hmm_event_unqueue(hmm, event);
+	hmm_mirror_unref(mirror);
+	switch (ret) {
+	case 0:
+		break;
+	case -ENOMEM:
+		return VM_FAULT_OOM;
+	default:
+		return VM_FAULT_SIGBUS;
+	}
+
+	return VM_FAULT_MAJOR;
+}
+
 
 
 
@@ -726,16 +2260,15 @@ static struct mmu_notifier_ops hmm_notifier_ops = {
  * device page table (through hmm callback). Or provide helper functions use by
  * the device driver to fault in range of memory in the device page table.
  */
-
-static int hmm_mirror_update(struct hmm_mirror *mirror,
-			     struct vm_area_struct *vma,
-			     unsigned long faddr,
-			     unsigned long laddr,
-			     struct hmm_event *event)
+
+static int hmm_mirror_lmem_update(struct hmm_mirror *mirror,
+				  unsigned long faddr,
+				  unsigned long laddr,
+				  struct hmm_event *event,
+				  bool dirty)
 {
 	struct hmm_device *device = mirror->device;
 	struct hmm_fence *fence;
-	bool dirty = !!(vma->vm_file);
 
 	fence = device->ops->lmem_update(mirror, faddr, laddr,
 					 event->etype, dirty);
@@ -749,6 +2282,175 @@ static int hmm_mirror_update(struct hmm_mirror *mirror,
 	return 0;
 }
 
+static int hmm_mirror_rmem_update(struct hmm_mirror *mirror,
+				  struct hmm_rmem *rmem,
+				  unsigned long faddr,
+				  unsigned long laddr,
+				  unsigned long fuid,
+				  struct hmm_event *event,
+				  bool dirty)
+{
+	struct hmm_device *device = mirror->device;
+	struct hmm_fence *fence;
+
+	fence = device->ops->rmem_update(mirror, rmem, faddr, laddr,
+					 fuid, event->etype, dirty);
+	if (fence) {
+		if (IS_ERR(fence)) {
+			return PTR_ERR(fence);
+		}
+		fence->mirror = mirror;
+		list_add_tail(&fence->list, &event->fences);
+	}
+	return 0;
+}
+
+static int hmm_mirror_update(struct hmm_mirror *mirror,
+			     struct vm_area_struct *vma,
+			     unsigned long faddr,
+			     unsigned long laddr,
+			     struct hmm_event *event)
+{
+	struct hmm *hmm = mirror->hmm;
+	unsigned long caddr = faddr;
+	bool free = false, dirty = !!(vma->vm_flags & VM_SHARED);
+	int ret;
+
+	switch (event->etype) {
+	case HMM_MUNMAP:
+		free = true;
+		break;
+	default:
+		break;
+	}
+
+	for (; caddr < laddr;) {
+		struct hmm_range *range;
+		unsigned long naddr;
+
+		spin_lock(&hmm->lock);
+		range = hmm_range_tree_iter_first(&hmm->ranges,caddr,laddr-1);
+		if (range && range->mirror != mirror) {
+			range = NULL;
+		}
+		spin_unlock(&hmm->lock);
+
+		/* At this point the range is on the event list and thus it can
+		 * not disappear.
+		 */
+		BUG_ON(range && list_empty(&range->elist));
+
+		if (!range || (range->faddr > caddr)) {
+			naddr = range ? range->faddr : laddr;
+			ret = hmm_mirror_lmem_update(mirror, caddr, naddr,
+						     event, dirty);
+			if (ret) {
+				return ret;
+			}
+			caddr = naddr;
+		}
+		if (range) {
+			unsigned long fuid;
+
+			naddr = min(range->laddr, laddr);
+			fuid = range->fuid+((caddr-range->faddr)>>PAGE_SHIFT);
+			ret = hmm_mirror_rmem_update(mirror,range->rmem,caddr,
+						     naddr,fuid,event,dirty);
+			caddr = naddr;
+			if (ret) {
+				return ret;
+			}
+			if (free) {
+				BUG_ON((caddr > range->faddr) ||
+				       (naddr < range->laddr));
+				hmm_range_fini_clear(range, vma);
+			}
+		}
+	}
+	return 0;
+}
+
+static unsigned long hmm_mirror_ranges_reserve(struct hmm_mirror *mirror,
+					       struct hmm_event *event)
+{
+	struct hmm_range *range;
+	unsigned long faddr, laddr, count = 0;
+	struct hmm *hmm = mirror->hmm;
+
+	faddr = event->faddr;
+	laddr = event->laddr;
+
+retry:
+	spin_lock(&hmm->lock);
+	range = hmm_range_tree_iter_first(&hmm->ranges, faddr, laddr - 1);
+	while (range) {
+		if (range->mirror == mirror) {
+			if (!hmm_range_reserve(range, event)) {
+				struct hmm_rmem *rmem;
+
+				rmem = hmm_rmem_ref(range->rmem);
+				spin_unlock(&hmm->lock);
+				wait_event(hmm->wait_queue, rmem->event!=NULL);
+				hmm_rmem_unref(rmem);
+				goto retry;
+			}
+			if (list_empty(&range->elist)) {
+				list_add_tail(&range->elist, &event->ranges);
+				count++;
+			}
+		}
+		range = hmm_range_tree_iter_next(range, faddr, laddr - 1);
+	}
+	spin_unlock(&hmm->lock);
+
+	return count;
+}
+
+static void hmm_mirror_ranges_migrate(struct hmm_mirror *mirror,
+				      struct vm_area_struct *vma,
+				      struct hmm_event *event)
+{
+	struct hmm_range *range;
+	struct hmm *hmm = mirror->hmm;
+
+	spin_lock(&hmm->lock);
+	range = hmm_range_tree_iter_first(&hmm->ranges,
+					  vma->vm_start,
+					  vma->vm_end - 1);
+	while (range) {
+		struct hmm_rmem *rmem;
+
+		if (range->mirror != mirror) {
+			goto next;
+		}
+		rmem = hmm_rmem_ref(range->rmem);
+		spin_unlock(&hmm->lock);
+
+		hmm_rmem_migrate_to_lmem(rmem, vma, range->faddr,
+					 hmm_range_fuid(range),
+					 hmm_range_luid(range),
+					 true);
+		hmm_rmem_unref(rmem);
+
+		spin_lock(&hmm->lock);
+	next:
+		range = hmm_range_tree_iter_first(&hmm->ranges,
+						  vma->vm_start,
+						  vma->vm_end - 1);
+	}
+	spin_unlock(&hmm->lock);
+}
+
+static void hmm_mirror_ranges_release(struct hmm_mirror *mirror,
+				      struct hmm_event *event)
+{
+	struct hmm_range *range, *next;
+
+	list_for_each_entry_safe (range, next, &event->ranges, elist) {
+		hmm_range_release(range, event);
+	}
+}
+
 static void hmm_mirror_cleanup(struct hmm_mirror *mirror)
 {
 	struct vm_area_struct *vma;
@@ -778,11 +2480,16 @@ static void hmm_mirror_cleanup(struct hmm_mirror *mirror)
 		faddr = max(faddr, vma->vm_start);
 		laddr = vma->vm_end;
 
+		hmm_mirror_ranges_reserve(mirror, event);
+
 		hmm_mirror_update(mirror, vma, faddr, laddr, event);
 		list_for_each_entry_safe (fence, next, &event->fences, list) {
 			hmm_device_fence_wait(device, fence);
 		}
 
+		hmm_mirror_ranges_migrate(mirror, vma, event);
+		hmm_mirror_ranges_release(mirror, event);
+
 		if (laddr >= vma->vm_end) {
 			vma = vma->vm_next;
 		}
@@ -949,6 +2656,33 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
 
+static int hmm_mirror_rmem_fault(struct hmm_mirror *mirror,
+				 struct hmm_fault *fault,
+				 struct vm_area_struct *vma,
+				 struct hmm_range *range,
+				 struct hmm_event *event,
+				 unsigned long faddr,
+				 unsigned long laddr,
+				 bool write)
+{
+	struct hmm_device *device = mirror->device;
+	struct hmm_rmem *rmem = range->rmem;
+	unsigned long fuid, luid, npages;
+	int ret;
+
+	if (range->mirror != mirror) {
+		/* Returning -EAGAIN will force cpu page fault path. */
+		return -EAGAIN;
+	}
+
+	npages = (range->laddr - range->faddr) >> PAGE_SHIFT;
+	fuid = range->fuid + ((faddr - range->faddr) >> PAGE_SHIFT);
+	luid = fuid + npages;
+
+	ret = device->ops->rmem_fault(mirror, rmem, faddr, laddr, fuid, fault);
+	return ret;
+}
+
 static int hmm_mirror_lmem_fault(struct hmm_mirror *mirror,
 				 struct hmm_fault *fault,
 				 unsigned long faddr,
@@ -995,6 +2729,7 @@ int hmm_mirror_fault(struct hmm_mirror *mirror,
 retry:
 	down_read(&hmm->mm->mmap_sem);
 	event = hmm_event_get(hmm, caddr, naddr, HMM_DEVICE_FAULT);
+	hmm_ranges_reserve(hmm, event);
 	/* FIXME handle gate area ? and guard page */
 	vma = find_extend_vma(hmm->mm, caddr);
 	if (!vma) {
@@ -1031,6 +2766,29 @@ retry:
 
 	for (; caddr < event->laddr;) {
 		struct hmm_fault_mm fault_mm;
+		struct hmm_range *range;
+
+		spin_lock(&hmm->lock);
+		range = hmm_range_tree_iter_first(&hmm->ranges,
+						  caddr,
+						  naddr - 1);
+		if (range && range->faddr > caddr) {
+			naddr = range->faddr;
+			range = NULL;
+		}
+		spin_unlock(&hmm->lock);
+		if (range) {
+			naddr = min(range->laddr, event->laddr);
+			ret = hmm_mirror_rmem_fault(mirror,fault,vma,range,
+						    event,caddr,naddr,write);
+			if (ret) {
+				do_fault = (ret == -EAGAIN);
+				goto out;
+			}
+			caddr = naddr;
+			naddr = event->laddr;
+			continue;
+		}
 
 		fault_mm.mm = vma->vm_mm;
 		fault_mm.vma = vma;
@@ -1067,6 +2825,7 @@ retry:
 	}
 
 out:
+	hmm_ranges_release(hmm, event);
 	hmm_event_unqueue(hmm, event);
 	if (do_fault && !event->backoff && !mirror->dead) {
 		do_fault = false;
@@ -1092,6 +2851,334 @@ EXPORT_SYMBOL(hmm_mirror_fault);
 
 
 
+/* hmm_migrate - Memory migration to/from local memory from/to remote memory.
+ *
+ * Below are functions that handle migration to/from local memory from/to
+ * remote memory (rmem).
+ *
+ * Migration to remote memory is a multi-step process first pages are unmap and
+ * missing page are either allocated or accounted as new allocation. Then pages
+ * are copied to remote memory. Finaly the remote memory is faulted so that the
+ * device driver update the device page table.
+ *
+ * Device driver can decide to abort migration to remote memory at any step of
+ * the process by returning special value from the callback corresponding to
+ * the step.
+ *
+ * Migration to local memory is simpler. First pages are allocated then remote
+ * memory is copied into those pages. Once dma is done the pages are remapped
+ * inside the cpu page table or inside the page cache (for shared memory) and
+ * finaly the rmem is freed.
+ */
+
+/* see include/linux/hmm.h */
+int hmm_migrate_rmem_to_lmem(struct hmm_mirror *mirror,
+			     unsigned long faddr,
+			     unsigned long laddr)
+{
+	struct hmm *hmm = mirror->hmm;
+	struct vm_area_struct *vma;
+	struct hmm_event *event;
+	unsigned long next;
+	int ret = 0;
+
+	event = hmm_event_get(hmm, faddr, laddr, HMM_MIGRATE_TO_LMEM);
+	if (!hmm_ranges_reserve(hmm, event)) {
+		hmm_event_unqueue(hmm, event);
+		return 0;
+	}
+
+	hmm_mirror_ref(mirror);
+	down_read(&hmm->mm->mmap_sem);
+	vma = find_vma(hmm->mm, faddr);
+	faddr = max(vma->vm_start, faddr);
+	for (; vma && (faddr < laddr); faddr = next) {
+		next = min(laddr, vma->vm_end);
+
+		ret = hmm_migrate_to_lmem(hmm, vma, faddr, next, true);
+		if (ret) {
+			break;
+		}
+
+		vma = vma->vm_next;
+		next = max(vma->vm_start, next);
+	}
+	up_read(&hmm->mm->mmap_sem);
+	hmm_ranges_release(hmm, event);
+	hmm_event_unqueue(hmm, event);
+	hmm_mirror_unref(mirror);
+	return ret;
+}
+EXPORT_SYMBOL(hmm_migrate_rmem_to_lmem);
+
+static void hmm_migrate_abort(struct hmm_mirror *mirror,
+			      struct hmm_fault *fault,
+			      unsigned long *pfns,
+			      unsigned long fuid)
+{
+	struct vm_area_struct *vma = fault->vma;
+	struct hmm_rmem rmem;
+	unsigned long i, npages;
+
+	npages = (fault->laddr - fault->faddr) >> PAGE_SHIFT;
+	for (i = npages - 1; i > 0; --i) {
+		if (pfns[i]) {
+			break;
+		}
+		npages = i;
+	}
+	if (!npages) {
+		return;
+	}
+
+	/* Fake temporary rmem object. */
+	hmm_rmem_init(&rmem, mirror->device);
+	rmem.fuid = fuid;
+	rmem.luid = fuid + npages;
+	rmem.pfns = pfns;
+
+	if (!(vma->vm_file)) {
+		unsigned long faddr, laddr;
+
+		faddr = fault->faddr;
+		laddr = faddr + (npages << PAGE_SHIFT);
+
+		/* The remapping fail only if something goes terribly wrong. */
+		if (hmm_rmem_remap_anon(&rmem, vma, faddr, laddr, fuid)) {
+
+			WARN_ONCE(1, "hmm: something is terribly wrong.\n");
+			hmm_rmem_poison_range(&rmem, vma->vm_mm, vma,
+					      faddr, laddr, fuid);
+		}
+	} else {
+		BUG();
+	}
+
+	/* Ok officialy dead. */
+	if (fault->rmem) {
+		fault->rmem->dead = true;
+	}
+
+	for (i = 0; i < npages; ++i) {
+		struct page *page = hmm_pfn_to_page(pfns[i]);
+
+		if (!page) {
+			pfns[i] = 0;
+			continue;
+		}
+		if (test_bit(HMM_PFN_VALID_ZERO, &pfns[i])) {
+			/* Properly uncharge memory. */
+			add_mm_counter(vma->vm_mm, MM_ANONPAGES, -1);
+			mem_cgroup_uncharge_mm(vma->vm_mm);
+			pfns[i] = 0;
+			continue;
+		}
+		if (test_bit(HMM_PFN_LOCK, &pfns[i])) {
+			unlock_page(page);
+			clear_bit(HMM_PFN_LOCK, &pfns[i]);
+		}
+		page_remove_rmap(page);
+		page_cache_release(page);
+		pfns[i] = 0;
+	}
+}
+
+/* see include/linux/hmm.h */
+int hmm_migrate_lmem_to_rmem(struct hmm_fault *fault,
+			     struct hmm_mirror *mirror)
+{
+	struct vm_area_struct *vma;
+	struct hmm_device *device;
+	struct hmm_range *range;
+	struct hmm_fence *fence;
+	struct hmm_event *event;
+	struct hmm_rmem rmem;
+	unsigned long i, npages;
+	struct hmm *hmm;
+	int ret;
+
+	mirror = hmm_mirror_ref(mirror);
+	if (!fault || !mirror || fault->faddr > fault->laddr) {
+		return -EINVAL;
+	}
+	if (mirror->dead) {
+		hmm_mirror_unref(mirror);
+		return -ENODEV;
+	}
+	hmm = mirror->hmm;
+	device = mirror->device;
+	if (!device->rmem) {
+		hmm_mirror_unref(mirror);
+		return -EINVAL;
+	}
+	fault->rmem = NULL;
+	fault->faddr = fault->faddr & PAGE_MASK;
+	fault->laddr = PAGE_ALIGN(fault->laddr);
+	hmm_rmem_init(&rmem, mirror->device);
+	event = hmm_event_get(hmm, fault->faddr, fault->laddr,
+			      HMM_MIGRATE_TO_RMEM);
+	rmem.event = event;
+	hmm = mirror->hmm;
+
+	range = kmalloc(sizeof(struct hmm_range), GFP_KERNEL);
+	if (range == NULL) {
+		hmm_event_unqueue(hmm, event);
+		hmm_mirror_unref(mirror);
+		return -ENOMEM;
+	}
+
+	down_read(&hmm->mm->mmap_sem);
+	vma = find_vma_intersection(hmm->mm, fault->faddr, fault->laddr);
+	if (!vma) {
+		kfree(range);
+		range = NULL;
+		ret = -EFAULT;
+		goto out;
+	}
+	/* FIXME support HUGETLB */
+	if ((vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP | VM_HUGETLB))) {
+		kfree(range);
+		range = NULL;
+		ret = -EACCES;
+		goto out;
+	}
+	if (vma->vm_file) {
+		kfree(range);
+		range = NULL;
+		ret = -EBUSY;
+		goto out;
+	}
+	/* Adjust range to this vma only. */
+	event->faddr = fault->faddr = max(fault->faddr, vma->vm_start);
+	event->laddr  =fault->laddr = min(fault->laddr, vma->vm_end);
+	npages = (fault->laddr - fault->faddr) >> PAGE_SHIFT;
+	fault->vma = vma;
+
+	ret = hmm_rmem_alloc(&rmem, npages);
+	if (ret) {
+		kfree(range);
+		range = NULL;
+		goto out;
+	}
+
+	/* Prior to unmapping add to the hmm range tree so any pagefault can
+	 * find the proper range.
+	 */
+	hmm_range_init(range, mirror, &rmem, fault->faddr,
+		       fault->laddr, rmem.fuid);
+	hmm_range_insert(range);
+
+	ret = hmm_rmem_unmap(&rmem, vma, fault->faddr, fault->laddr);
+	if (ret) {
+		hmm_migrate_abort(mirror, fault, rmem.pfns, rmem.fuid);
+		goto out;
+	}
+
+	fault->rmem = device->ops->rmem_alloc(device, fault);
+	if (IS_ERR(fault->rmem)) {
+		ret = PTR_ERR(fault->rmem);
+		hmm_migrate_abort(mirror, fault, rmem.pfns, rmem.fuid);
+		goto out;
+	}
+	if (fault->rmem == NULL) {
+		hmm_migrate_abort(mirror, fault, rmem.pfns, rmem.fuid);
+		ret = 0;
+		goto out;
+	}
+	if (event->backoff) {
+		ret = -EBUSY;
+		hmm_migrate_abort(mirror, fault, rmem.pfns, rmem.fuid);
+		goto out;
+	}
+
+	hmm_rmem_init(fault->rmem, mirror->device);
+	spin_lock(&_hmm_rmems_lock);
+	fault->rmem->event = event;
+	hmm_rmem_tree_remove(&rmem, &_hmm_rmems);
+	fault->rmem->fuid = rmem.fuid;
+	fault->rmem->luid = rmem.luid;
+	hmm_rmem_tree_insert(fault->rmem, &_hmm_rmems);
+	fault->rmem->pfns = rmem.pfns;
+	range->rmem = fault->rmem;
+	list_del_init(&range->rlist);
+	list_add_tail(&range->rlist, &fault->rmem->ranges);
+	rmem.event = NULL;
+	spin_unlock(&_hmm_rmems_lock);
+
+	fence = device->ops->lmem_to_rmem(fault->rmem,rmem.fuid,rmem.luid);
+	if (IS_ERR(fence)) {
+		hmm_migrate_abort(mirror, fault, rmem.pfns, rmem.fuid);
+		goto out;
+	}
+
+	ret = hmm_device_fence_wait(device, fence);
+	if (ret) {
+		hmm_migrate_abort(mirror, fault, rmem.pfns, rmem.fuid);
+		goto out;
+	}
+
+	ret = device->ops->rmem_fault(mirror, range->rmem, range->faddr,
+				      range->laddr, range->fuid, NULL);
+	if (ret) {
+		hmm_migrate_abort(mirror, fault, rmem.pfns, rmem.fuid);
+		goto out;
+	}
+
+	for (i = 0; i < npages; ++i) {
+		struct page *page = hmm_pfn_to_page(rmem.pfns[i]);
+
+		if (test_bit(HMM_PFN_VALID_ZERO, &rmem.pfns[i])) {
+			rmem.pfns[i] = rmem.pfns[i] & HMM_PFN_CLEAR;
+			continue;
+		}
+		/* We only decrement now the page count so that cow happen
+		 * properly while page is in fligh.
+		 */
+		if (PageAnon(page)) {
+			unlock_page(page);
+			page_remove_rmap(page);
+			page_cache_release(page);
+			rmem.pfns[i] &= HMM_PFN_CLEAR;
+		} else {
+			/* Otherwise this means the page is in pagecache. Keep
+			 * a reference and page count elevated.
+			 */
+			clear_bit(HMM_PFN_LOCK, &rmem.pfns[i]);
+			/* We do not want side effect of page_remove_rmap ie
+			 * zone page accounting udpate but we do want zero
+			 * mapcount so writeback works properly.
+			 */
+			atomic_add(-1, &page->_mapcount);
+			unlock_page(page);
+		}
+	}
+
+	hmm_mirror_ranges_release(mirror, event);
+	hmm_event_unqueue(hmm, event);
+	up_read(&hmm->mm->mmap_sem);
+	hmm_mirror_unref(mirror);
+	return 0;
+
+out:
+	if (!fault->rmem) {
+		kfree(rmem.pfns);
+		spin_lock(&_hmm_rmems_lock);
+		hmm_rmem_tree_remove(&rmem, &_hmm_rmems);
+		spin_unlock(&_hmm_rmems_lock);
+	}
+	hmm_mirror_ranges_release(mirror, event);
+	hmm_event_unqueue(hmm, event);
+	up_read(&hmm->mm->mmap_sem);
+	hmm_range_unref(range);
+	hmm_rmem_unref(fault->rmem);
+	hmm_mirror_unref(mirror);
+	return ret;
+}
+EXPORT_SYMBOL(hmm_migrate_lmem_to_rmem);
+
+
+
+
 /* hmm_device - Each device driver must register one and only one hmm_device
  *
  * The hmm_device is the link btw hmm and each device driver.
@@ -1140,9 +3227,22 @@ int hmm_device_register(struct hmm_device *device, const char *name)
 	BUG_ON(!device->ops->lmem_fault);
 
 	kref_init(&device->kref);
+	device->rmem = false;
 	device->name = name;
 	mutex_init(&device->mutex);
 	INIT_LIST_HEAD(&device->mirrors);
+	init_waitqueue_head(&device->wait_queue);
+
+	if (device->ops->rmem_alloc &&
+	    device->ops->rmem_update &&
+	    device->ops->rmem_fault &&
+	    device->ops->rmem_to_lmem &&
+	    device->ops->lmem_to_rmem &&
+	    device->ops->rmem_split &&
+	    device->ops->rmem_split_adjust &&
+	    device->ops->rmem_destroy) {
+		device->rmem = true;
+	}
 
 	return 0;
 }
@@ -1179,6 +3279,7 @@ static int __init hmm_module_init(void)
 {
 	int ret;
 
+	spin_lock_init(&_hmm_rmems_lock);
 	ret = init_srcu_struct(&srcu);
 	if (ret) {
 		return ret;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ceaf4d7..88e4acd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -56,6 +56,7 @@
 #include <linux/oom.h>
 #include <linux/lockdep.h>
 #include <linux/file.h>
+#include <linux/hmm.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -6649,6 +6650,8 @@ one_by_one:
  *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
  *     target for charge migration. if @target is not NULL, the entry is stored
  *     in target->ent.
+ *   3(MC_TARGET_HMM): if it is hmm entry, target->page is either NULL or point
+ *     to page to move charge.
  *
  * Called with pte lock held.
  */
@@ -6661,6 +6664,7 @@ enum mc_target_type {
 	MC_TARGET_NONE = 0,
 	MC_TARGET_PAGE,
 	MC_TARGET_SWAP,
+	MC_TARGET_HMM,
 };
 
 static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
@@ -6690,6 +6694,9 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
 	struct page *page = NULL;
 	swp_entry_t ent = pte_to_swp_entry(ptent);
 
+	if (is_hmm_entry(ent)) {
+		return swp_to_radix_entry(ent);
+	}
 	if (!move_anon() || non_swap_entry(ent))
 		return NULL;
 	/*
@@ -6764,6 +6771,10 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 
 	if (!page && !ent.val)
 		return ret;
+	if (radix_tree_exceptional_entry(page)) {
+		ret = MC_TARGET_HMM;
+		return ret;
+	}
 	if (page) {
 		pc = lookup_page_cgroup(page);
 		/*
@@ -7077,6 +7088,41 @@ put:			/* get_mctgt_type() gets the page */
 				mc.moved_swap++;
 			}
 			break;
+		case MC_TARGET_HMM:
+			if (target.page) {
+				page = target.page;
+				pc = lookup_page_cgroup(page);
+				if (!mem_cgroup_move_account(page, 1, pc,
+							     mc.from, mc.to)) {
+					mc.precharge--;
+					/* we uncharge from mc.from later. */
+					mc.moved_charge++;
+				}
+				put_page(page);
+			} else if (vma->vm_flags & VM_SHARED) {
+				/* Some one migrated the memory after we did
+				 * the pagecache lookup.
+				 */
+				/* FIXME can the precharge/moved_charge then
+				 * becomes wrong ?
+				 */
+				pte_unmap_unlock(pte - 1, ptl);
+				cond_resched();
+				goto retry;
+			} else {
+				unsigned long flags;
+
+				move_lock_mem_cgroup(mc.from, &flags);
+				move_lock_mem_cgroup(mc.to, &flags);
+				mem_cgroup_charge_statistics(mc.from, NULL, true, -1);
+				mem_cgroup_charge_statistics(mc.to, NULL, true, 1);
+				move_unlock_mem_cgroup(mc.to, &flags);
+				move_unlock_mem_cgroup(mc.from, &flags);
+				mc.precharge--;
+				/* we uncharge from mc.from later. */
+				mc.moved_charge++;
+			}
+			break;
 		default:
 			break;
 		}
diff --git a/mm/memory.c b/mm/memory.c
index 1e164a1..d35bc65 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -53,6 +53,7 @@
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
+#include <linux/hmm.h>
 #include <linux/kallsyms.h>
 #include <linux/swapops.h>
 #include <linux/elf.h>
@@ -851,6 +852,9 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 					if (pte_swp_soft_dirty(*src_pte))
 						pte = pte_swp_mksoft_dirty(pte);
 					set_pte_at(src_mm, addr, src_pte, pte);
+				} else if (is_hmm_entry(entry)) {
+					/* FIXME do we want to handle rblk fork, just mapcount rblk if so. */
+					BUG_ON(1);
 				}
 			}
 		}
@@ -3079,6 +3083,9 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			migration_entry_wait(mm, pmd, address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
+		} else if (is_hmm_entry(entry)) {
+			ret = hmm_mm_fault(mm, vma, address, page_table,
+					   pmd, flags, orig_pte);
 		} else {
 			print_bad_pte(vma, address, orig_pte, NULL);
 			ret = VM_FAULT_SIGBUS;
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
