Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 883FB6B0035
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 08:28:10 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so7265105wev.13
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:28:09 -0700 (PDT)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id cn2si13362203wib.24.2014.07.28.05.28.08
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 05:28:09 -0700 (PDT)
Message-ID: <53D641A2.9050000@mellanox.com>
Date: Mon, 28 Jul 2014 15:27:14 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] hmm: heterogeneous memory management v3
References: <1402706913-7432-1-git-send-email-j.glisse@gmail.com> <1402706913-7432-2-git-send-email-j.glisse@gmail.com> <1402706913-7432-3-git-send-email-j.glisse@gmail.com> <1402706913-7432-4-git-send-email-j.glisse@gmail.com> <1402706913-7432-5-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1402706913-7432-5-git-send-email-j.glisse@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <j.glisse@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, torvalds@linux-foundation.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

On 14/06/2014 03:48, JA(C)rA'me Glisse wrote:> From: JA(C)rA'me Glisse <jglisse@redhat.com>
> 
> Motivation:
> 
> ...
> 
> The aim of the heterogeneous memory management is to provide a common API that
> can be use by any such devices in order to mirror process address. The hmm code
> provide an unique entry point and interface itself with the core mm code of the
> linux kernel avoiding duplicate implementation and shielding device driver code
> from core mm code.
> 
> Moreover, hmm also intend to provide support for migrating memory to device
> private memory, allowing device to work on its own fast local memory. The hmm
> code would be responsible to intercept cpu page fault on migrated range of and
> to migrate it back to system memory allowing cpu to resume its access to the
> memory.
> 
> Another feature hmm intend to provide is support for atomic operation for the
> device even if the bus linking the device and the cpu do not have any such
> capabilities.
> 
> We expect that graphic processing unit and network interface to be among the
> first users of such api.

Hi,

Sorry I'm only now replying to this email. I'm hoping my feedback is still relevant :)

At Mellanox we are currently working on similar technology for avoiding
pinning memory for RDMA [1]. We currently have our own MMU notifier code
but once the HMM makes it into the kernel I hope we will be able to use it.

I have a couple of questions below:

> 
> Hardware requirement:
> 
> Because hmm is intended to be use by device driver there are minimum features
> requirement for the hardware mmu :
>   - hardware have its own page table per process (can be share btw != devices)
>   - hardware mmu support page fault and suspend execution until the page fault
>     is serviced by hmm code. The page fault must also trigger some form of
>     interrupt so that hmm code can be call by the device driver.
>   - hardware must support at least read only mapping (otherwise it can not
>     access read only range of the process address space).
> 
> For better memory management it is highly recommanded that the device also
> support the following features :
>   - hardware mmu set access bit in its page table on memory access (like cpu).
>   - hardware page table can be updated from cpu or through a fast path.
>   - hardware provide advanced statistic over which range of memory it access
>     the most.
>   - hardware differentiate atomic memory access from regular access allowing
>     to support atomic operation even on platform that do not have atomic
>     support with there bus link with the device.
> 
> Implementation:
> 
> ...

> +
> +/* struct hmm_event - used to serialize change to overlapping range of address.
> + *
> + * @list:       List of pending|in progress event.
> + * @faddr:      First address (inclusive) for the range this event affect.
> + * @laddr:      Last address (exclusive) for the range this event affect.
> + * @iaddr:      First invalid address.
> + * @fences:     List of device fences associated with this event.
> + * @etype:      Event type (munmap, migrate, truncate, ...).
> + * @backoff:    Should this event backoff ie a new event render it obsolete.
> + */
> +struct hmm_event {
> +	struct list_head	list;
> +	unsigned long		faddr;
> +	unsigned long		laddr;
> +	unsigned long		iaddr;
> +	struct list_head	fences;
> +	enum hmm_etype		etype;
> +	bool			backoff;

The backoff field is always being set to false in this patch, right? Is
it intended to be used only for device page migration?

> +};
> +
> +
> +
> +
> +/* hmm_device - Each device driver must register one and only one hmm_device.
> + *
> + * The hmm_device is the link btw hmm and each device driver.
> + */
> +
> +/* struct hmm_device_operations - hmm device operation callback
> + */
> +struct hmm_device_ops {
> +	/* device_destroy - free hmm_device (call when refcount drop to 0).
> +	 *
> +	 * @device: The device hmm specific structure.
> +	 */
> +	void (*device_destroy)(struct hmm_device *device);
> +
> +	/* mirror_release() - device must stop using the address space.
> +	 *
> +	 * @mirror: The mirror that link process address space with the device.
> +	 *
> +	 * Called when as result of hmm_mirror_unregister or when mm is being
> +	 * destroy.
> +	 *
> +	 * It's illegal for the device to call any hmm helper function after
> +	 * this call back. The device driver must kill any pending device
> +	 * thread and wait for completion of all of them.
> +	 *
> +	 * Note that even after this callback returns the device driver might
> +	 * get call back from hmm. Callback will stop only once mirror_destroy
> +	 * is call.
> +	 */
> +	void (*mirror_release)(struct hmm_mirror *hmm_mirror);
> +
> +	/* mirror_destroy - free hmm_mirror (call when refcount drop to 0).
> +	 *
> +	 * @mirror: The mirror that link process address space with the device.
> +	 */
> +	void (*mirror_destroy)(struct hmm_mirror *mirror);
> +
> +	/* fence_wait() - to wait on device driver fence.
> +	 *
> +	 * @fence:      The device driver fence struct.
> +	 * Returns:     0 on success,-EIO on error, -EAGAIN to wait again.
> +	 *
> +	 * Called when hmm want to wait for all operations associated with a
> +	 * fence to complete (including device cache flush if the event mandate
> +	 * it).
> +	 *
> +	 * Device driver must free fence and associated resources if it returns
> +	 * something else thant -EAGAIN. On -EAGAIN the fence must not be free
> +	 * as hmm will call back again.
> +	 *
> +	 * Return error if scheduled operation failed or if need to wait again.
> +	 * -EIO    Some input/output error with the device.
> +	 * -EAGAIN The fence not yet signaled, hmm reschedule waiting thread.
> +	 *
> +	 * All other return value trigger warning and are transformed to -EIO.
> +	 */
> +	int (*fence_wait)(struct hmm_fence *fence);
> +
> +	/* fence_destroy() - destroy fence structure.
> +	 *
> +	 * @fence:  Fence structure to destroy.
> +	 *
> +	 * Called when all reference on a fence are gone.
> +	 */
> +	void (*fence_destroy)(struct hmm_fence *fence);
> +
> +	/* update() - update device mmu for a range of address.
> +	 *
> +	 * @mirror: The mirror that link process address space with the device.
> +	 * @vma:    The vma into which the update is taking place.
> +	 * @faddr:  First address in range (inclusive).
> +	 * @laddr:  Last address in range (exclusive).
> +	 * @etype:  The type of memory event (unmap, read only, ...).
> +	 * Returns: Valid fence ptr or NULL on success otherwise ERR_PTR.
> +	 *
> +	 * Called to update device mmu permission/usage for a range of address.
> +	 * The event type provide the nature of the update :
> +	 *   - range is no longer valid (munmap).
> +	 *   - range protection changes (mprotect, COW, ...).
> +	 *   - range is unmapped (swap, reclaim, page migration, ...).
> +	 *   - ...
> +	 *
> +	 * Any event that block further write to the memory must also trigger a
> +	 * device cache flush and everything has to be flush to local memory by
> +	 * the time the wait callback return (if this callback returned a fence
> +	 * otherwise everything must be flush by the time the callback return).
> +	 *
> +	 * Device must properly call set_page_dirty on any page the device did
> +	 * write to since last call to update.
> +	 *
> +	 * The driver should return a fence pointer or NULL on success. Device
> +	 * driver should return fence and delay wait for the operation to the
> +	 * febce wait callback. Returning a fence allow hmm to batch update to
> +	 * several devices and delay wait on those once they all have scheduled
> +	 * the update.
> +	 *
> +	 * Device driver must not fail lightly, any failure result in device
> +	 * process being kill.
> +	 *
> +	 * Return fence or NULL on success, error value otherwise :
> +	 * -ENOMEM Not enough memory for performing the operation.
> +	 * -EIO    Some input/output error with the device.
> +	 *
> +	 * All other return value trigger warning and are transformed to -EIO.
> +	 */
> +	struct hmm_fence *(*update)(struct hmm_mirror *mirror,
> +				    struct vm_area_struct *vma,
> +				    unsigned long faddr,
> +				    unsigned long laddr,
> +				    enum hmm_etype etype);
> +
> +	/* fault() - fault range of address on the device mmu.
> +	 *
> +	 * @mirror: The mirror that link process address space with the device.
> +	 * @faddr:  First address in range (inclusive).
> +	 * @laddr:  Last address in range (exclusive).
> +	 * @pfns:   Array of pfn for the range (each of the pfn is valid).
> +	 * @fault:  The fault structure provided by device driver.
> +	 * Returns: 0 on success, error value otherwise.
> +	 *
> +	 * Called to give the device driver each of the pfn backing a range of
> +	 * address. It is only call as a result of a call to hmm_mirror_fault.
> +	 *
> +	 * Note that the pfns array content is only valid for the duration of
> +	 * the callback. Once the device driver callback return further memory
> +	 * activities might invalidate the value of the pfns array. The device
> +	 * driver will be inform of such changes through the update callback.
> +	 *
> +	 * Allowed return value are :
> +	 * -ENOMEM Not enough memory for performing the operation.
> +	 * -EIO    Some input/output error with the device.
> +	 *
> +	 * Device driver must not fail lightly, any failure result in device
> +	 * process being kill.
> +	 *
> +	 * Return error if scheduled operation failed. Valid value :
> +	 * -ENOMEM Not enough memory for performing the operation.
> +	 * -EIO    Some input/output error with the device.
> +	 *
> +	 * All other return value trigger warning and are transformed to -EIO.
> +	 */
> +	int (*fault)(struct hmm_mirror *mirror,
> +		     unsigned long faddr,
> +		     unsigned long laddr,
> +		     pte_t *ptep,
> +		     struct hmm_event *event);
> +};

I noticed that the device will receive PFNs as a result of a page fault.
I assume most devices will also need to call dma_map_page on the
physical address to get a bus address to use. Do you think it would make
sense to handle mapping and unmapping pages inside HMM?

> ...

> +
> +static void hmm_update_mirrors(struct hmm *hmm,
> +			       struct vm_area_struct *vma,
> +			       struct hmm_event *event)
> +{
> +	struct hmm_mirror *mirror;
> +	struct hmm_fence *fence = NULL, *tmp;
> +	int ticket;
> +
> +retry:
> +	ticket = srcu_read_lock(&srcu);
> +	/* Because of retry we might already have scheduled some mirror
> +	 * skip those.
> +	 */
> +	mirror = list_first_entry(&hmm->mirrors,
> +				  struct hmm_mirror,
> +				  mlist);
> +	mirror = fence ? fence->mirror : mirror;
> +	list_for_each_entry_continue(mirror, &hmm->mirrors, mlist) {
> +		struct hmm_device *device = mirror->device;
> +
> +		fence = device->ops->update(mirror, vma, event->faddr,
> +					    event->laddr, event->etype);
> +		if (fence) {
> +			if (IS_ERR(fence)) {
> +				srcu_read_unlock(&srcu, ticket);
> +				hmm_mirror_cleanup(mirror);
> +				goto retry;
> +			}
> +			kref_init(&fence->kref);
> +			fence->mirror = mirror;
> +			list_add_tail(&fence->list, &event->fences);
> +		}
> +	}
> +	srcu_read_unlock(&srcu, ticket);
> +
> +	if (!fence)
> +		/* Nothing to wait for. */
> +		return;
> +
> +	io_schedule();
> +	list_for_each_entry_safe(fence, tmp, &event->fences, list) {
> +		struct hmm_device *device;
> +		int r;
> +
> +		mirror = fence->mirror;
> +		device = mirror->device;
> +
> +		r = hmm_device_fence_wait(device, fence);
> +		if (r)
> +			hmm_mirror_cleanup(mirror);
> +	}
> +}
> +
> +

It seems like the code ignores any error the update operation may
return, except for cleaning up the mirror. If I understand correctly,
having an error here would mean that the device cannot invalidate the
pages it has access to, and they cannot be released. Isn't that right?

> ...

> +
> +/* hmm_mirror - per device mirroring functions.
> + *
> + * Each device that mirror a process has a uniq hmm_mirror struct. A process
> + * can be mirror by several devices at the same time.
> + *
> + * Below are all the functions and there helpers use by device driver to mirror
> + * the process address space. Those functions either deals with updating the
> + * device page table (through hmm callback). Or provide helper functions use by
> + * the device driver to fault in range of memory in the device page table.
> + */
> +
> +static void hmm_mirror_cleanup(struct hmm_mirror *mirror)
> +{
> +	struct vm_area_struct *vma;
> +	struct hmm_device *device = mirror->device;
> +	struct hmm_event event;
> +	struct hmm *hmm = mirror->hmm;
> +
> +	spin_lock(&hmm->lock);
> +	if (mirror->dead) {
> +		spin_unlock(&hmm->lock);
> +		return;
> +	}
> +	mirror->dead = true;
> +	list_del(&mirror->mlist);
> +	spin_unlock(&hmm->lock);
> +	synchronize_srcu(&srcu);
> +	INIT_LIST_HEAD(&mirror->mlist);
> +
> +	event.etype = HMM_UNREGISTER;
> +	event.faddr = 0UL;
> +	event.laddr = -1L;
> +	vma = find_vma_intersection(hmm->mm, event.faddr, event.laddr);
> +	for (; vma; vma = vma->vm_next) {
> +		struct hmm_fence *fence;
> +
> +		fence = device->ops->update(mirror, vma, vma->vm_start,
> +					    vma->vm_end, event.etype);
> +		if (fence && !IS_ERR(fence)) {
> +			kref_init(&fence->kref);
> +			fence->mirror = mirror;
> +			INIT_LIST_HEAD(&fence->list);
> +			hmm_device_fence_wait(device, fence);
> +		}

Here too the code ignores any error from update.

> +	}
> +
> +	mutex_lock(&device->mutex);
> +	list_del_init(&mirror->dlist);
> +	mutex_unlock(&device->mutex);
> +
> +	mirror->hmm = hmm_unref(hmm);
> +	hmm_mirror_unref(mirror);
> +}
> +
> +static void hmm_mirror_destroy(struct kref *kref)
> +{
> +	struct hmm_mirror *mirror;
> +	struct hmm_device *device;
> +
> +	mirror = container_of(kref, struct hmm_mirror, kref);
> +	device = mirror->device;
> +
> +	BUG_ON(!list_empty(&mirror->mlist));
> +	BUG_ON(!list_empty(&mirror->dlist));
> +
> +	device->ops->mirror_destroy(mirror);
> +	hmm_device_unref(device);
> +}
> +

Thanks,
Haggai

[1] [PATCH v1 for-next 00/16] On demand paging
    http://permalink.gmane.org/gmane.linux.drivers.rdma/21032



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
