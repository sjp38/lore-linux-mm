Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC926B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 07:54:59 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id w61so1075564wes.25
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 04:54:58 -0700 (PDT)
Received: from eu1sys200aog118.obsmtp.com (eu1sys200aog118.obsmtp.com [207.126.144.145])
        by mx.google.com with SMTP id n7si4814331wie.68.2014.07.30.04.53.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 04:54:56 -0700 (PDT)
Message-ID: <53D8DCC5.7050205@mellanox.com>
Date: Wed, 30 Jul 2014 14:53:41 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] hmm: heterogeneous memory management v3
References: <1402706913-7432-1-git-send-email-j.glisse@gmail.com> <1402706913-7432-2-git-send-email-j.glisse@gmail.com> <1402706913-7432-3-git-send-email-j.glisse@gmail.com> <1402706913-7432-4-git-send-email-j.glisse@gmail.com> <1402706913-7432-5-git-send-email-j.glisse@gmail.com> <53D641A2.9050000@mellanox.com> <20140728153948.GA3132@redhat.com>
In-Reply-To: <20140728153948.GA3132@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: =?ISO-8859-1?Q?J=E9r=F4me_Glisse?= <j.glisse@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, torvalds@linux-foundation.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

On 28/07/2014 18:39, Jerome Glisse wrote:
> On Mon, Jul 28, 2014 at 03:27:14PM +0300, Haggai Eran wrote:
>> On 14/06/2014 03:48, Jerome Glisse wrote:> From: Jerome Glisse <jglisse@redhat.com>
>>>
>>> Motivation:
>>>
>>> ...
>>>
>>> The aim of the heterogeneous memory management is to provide a common API that
>>> can be use by any such devices in order to mirror process address. The hmm code
>>> provide an unique entry point and interface itself with the core mm code of the
>>> linux kernel avoiding duplicate implementation and shielding device driver code
>>> from core mm code.
>>>
>>> Moreover, hmm also intend to provide support for migrating memory to device
>>> private memory, allowing device to work on its own fast local memory. The hmm
>>> code would be responsible to intercept cpu page fault on migrated range of and
>>> to migrate it back to system memory allowing cpu to resume its access to the
>>> memory.
>>>
>>> Another feature hmm intend to provide is support for atomic operation for the
>>> device even if the bus linking the device and the cpu do not have any such
>>> capabilities.
>>>
>>> We expect that graphic processing unit and network interface to be among the
>>> first users of such api.
>>
>> Hi,
>>
>> Sorry I'm only now replying to this email. I'm hoping my feedback is still relevant :)
>>
> 
> Any feedback is welcome.
> 
>> At Mellanox we are currently working on similar technology for avoiding
>> pinning memory for RDMA [1]. We currently have our own MMU notifier code
>> but once the HMM makes it into the kernel I hope we will be able to use it.
>>
>> I have a couple of questions below:
>>
>>>
>>> Hardware requirement:
>>>
>>> Because hmm is intended to be use by device driver there are minimum features
>>> requirement for the hardware mmu :
>>>   - hardware have its own page table per process (can be share btw != devices)
>>>   - hardware mmu support page fault and suspend execution until the page fault
>>>     is serviced by hmm code. The page fault must also trigger some form of
>>>     interrupt so that hmm code can be call by the device driver.
>>>   - hardware must support at least read only mapping (otherwise it can not
>>>     access read only range of the process address space).
>>>
>>> For better memory management it is highly recommanded that the device also
>>> support the following features :
>>>   - hardware mmu set access bit in its page table on memory access (like cpu).
>>>   - hardware page table can be updated from cpu or through a fast path.
>>>   - hardware provide advanced statistic over which range of memory it access
>>>     the most.
>>>   - hardware differentiate atomic memory access from regular access allowing
>>>     to support atomic operation even on platform that do not have atomic
>>>     support with there bus link with the device.
>>>
>>> Implementation:
>>>
>>> ...
>>
>>> +
>>> +/* struct hmm_event - used to serialize change to overlapping range of address.
>>> + *
>>> + * @list:       List of pending|in progress event.
>>> + * @faddr:      First address (inclusive) for the range this event affect.
>>> + * @laddr:      Last address (exclusive) for the range this event affect.
>>> + * @iaddr:      First invalid address.
>>> + * @fences:     List of device fences associated with this event.
>>> + * @etype:      Event type (munmap, migrate, truncate, ...).
>>> + * @backoff:    Should this event backoff ie a new event render it obsolete.
>>> + */
>>> +struct hmm_event {
>>> +	struct list_head	list;
>>> +	unsigned long		faddr;
>>> +	unsigned long		laddr;
>>> +	unsigned long		iaddr;
>>> +	struct list_head	fences;
>>> +	enum hmm_etype		etype;
>>> +	bool			backoff;
>>
>> The backoff field is always being set to false in this patch, right? Is
>> it intended to be used only for device page migration?
> 
> Correct, migration to remote memory might happen concurently with other
> memory event that render migration pointless.
> 
> 
>>
>>> +};
>>> +
>>> +
>>> +
>>> +
>>> +/* hmm_device - Each device driver must register one and only one hmm_device.
>>> + *
>>> + * The hmm_device is the link btw hmm and each device driver.
>>> + */
>>> +
>>> +/* struct hmm_device_operations - hmm device operation callback
>>> + */
>>> +struct hmm_device_ops {
>>> +	/* device_destroy - free hmm_device (call when refcount drop to 0).
>>> +	 *
>>> +	 * @device: The device hmm specific structure.
>>> +	 */
>>> +	void (*device_destroy)(struct hmm_device *device);
>>> +
>>> +	/* mirror_release() - device must stop using the address space.
>>> +	 *
>>> +	 * @mirror: The mirror that link process address space with the device.
>>> +	 *
>>> +	 * Called when as result of hmm_mirror_unregister or when mm is being
>>> +	 * destroy.
>>> +	 *
>>> +	 * It's illegal for the device to call any hmm helper function after
>>> +	 * this call back. The device driver must kill any pending device
>>> +	 * thread and wait for completion of all of them.
>>> +	 *
>>> +	 * Note that even after this callback returns the device driver might
>>> +	 * get call back from hmm. Callback will stop only once mirror_destroy
>>> +	 * is call.
>>> +	 */
>>> +	void (*mirror_release)(struct hmm_mirror *hmm_mirror);
>>> +
>>> +	/* mirror_destroy - free hmm_mirror (call when refcount drop to 0).
>>> +	 *
>>> +	 * @mirror: The mirror that link process address space with the device.
>>> +	 */
>>> +	void (*mirror_destroy)(struct hmm_mirror *mirror);
>>> +
>>> +	/* fence_wait() - to wait on device driver fence.
>>> +	 *
>>> +	 * @fence:      The device driver fence struct.
>>> +	 * Returns:     0 on success,-EIO on error, -EAGAIN to wait again.
>>> +	 *
>>> +	 * Called when hmm want to wait for all operations associated with a
>>> +	 * fence to complete (including device cache flush if the event mandate
>>> +	 * it).
>>> +	 *
>>> +	 * Device driver must free fence and associated resources if it returns
>>> +	 * something else thant -EAGAIN. On -EAGAIN the fence must not be free
>>> +	 * as hmm will call back again.
>>> +	 *
>>> +	 * Return error if scheduled operation failed or if need to wait again.
>>> +	 * -EIO    Some input/output error with the device.
>>> +	 * -EAGAIN The fence not yet signaled, hmm reschedule waiting thread.
>>> +	 *
>>> +	 * All other return value trigger warning and are transformed to -EIO.
>>> +	 */
>>> +	int (*fence_wait)(struct hmm_fence *fence);
>>> +
>>> +	/* fence_destroy() - destroy fence structure.
>>> +	 *
>>> +	 * @fence:  Fence structure to destroy.
>>> +	 *
>>> +	 * Called when all reference on a fence are gone.
>>> +	 */
>>> +	void (*fence_destroy)(struct hmm_fence *fence);
>>> +
>>> +	/* update() - update device mmu for a range of address.
>>> +	 *
>>> +	 * @mirror: The mirror that link process address space with the device.
>>> +	 * @vma:    The vma into which the update is taking place.
>>> +	 * @faddr:  First address in range (inclusive).
>>> +	 * @laddr:  Last address in range (exclusive).
>>> +	 * @etype:  The type of memory event (unmap, read only, ...).
>>> +	 * Returns: Valid fence ptr or NULL on success otherwise ERR_PTR.
>>> +	 *
>>> +	 * Called to update device mmu permission/usage for a range of address.
>>> +	 * The event type provide the nature of the update :
>>> +	 *   - range is no longer valid (munmap).
>>> +	 *   - range protection changes (mprotect, COW, ...).
>>> +	 *   - range is unmapped (swap, reclaim, page migration, ...).
>>> +	 *   - ...
>>> +	 *
>>> +	 * Any event that block further write to the memory must also trigger a
>>> +	 * device cache flush and everything has to be flush to local memory by
>>> +	 * the time the wait callback return (if this callback returned a fence
>>> +	 * otherwise everything must be flush by the time the callback return).
>>> +	 *
>>> +	 * Device must properly call set_page_dirty on any page the device did
>>> +	 * write to since last call to update.
>>> +	 *
>>> +	 * The driver should return a fence pointer or NULL on success. Device
>>> +	 * driver should return fence and delay wait for the operation to the
>>> +	 * febce wait callback. Returning a fence allow hmm to batch update to
>>> +	 * several devices and delay wait on those once they all have scheduled
>>> +	 * the update.
>>> +	 *
>>> +	 * Device driver must not fail lightly, any failure result in device
>>> +	 * process being kill.
>>> +	 *
>>> +	 * Return fence or NULL on success, error value otherwise :
>>> +	 * -ENOMEM Not enough memory for performing the operation.
>>> +	 * -EIO    Some input/output error with the device.
>>> +	 *
>>> +	 * All other return value trigger warning and are transformed to -EIO.
>>> +	 */
>>> +	struct hmm_fence *(*update)(struct hmm_mirror *mirror,
>>> +				    struct vm_area_struct *vma,
>>> +				    unsigned long faddr,
>>> +				    unsigned long laddr,
>>> +				    enum hmm_etype etype);
>>> +
>>> +	/* fault() - fault range of address on the device mmu.
>>> +	 *
>>> +	 * @mirror: The mirror that link process address space with the device.
>>> +	 * @faddr:  First address in range (inclusive).
>>> +	 * @laddr:  Last address in range (exclusive).
>>> +	 * @pfns:   Array of pfn for the range (each of the pfn is valid).
>>> +	 * @fault:  The fault structure provided by device driver.
>>> +	 * Returns: 0 on success, error value otherwise.
>>> +	 *
>>> +	 * Called to give the device driver each of the pfn backing a range of
>>> +	 * address. It is only call as a result of a call to hmm_mirror_fault.
>>> +	 *
>>> +	 * Note that the pfns array content is only valid for the duration of
>>> +	 * the callback. Once the device driver callback return further memory
>>> +	 * activities might invalidate the value of the pfns array. The device
>>> +	 * driver will be inform of such changes through the update callback.
>>> +	 *
>>> +	 * Allowed return value are :
>>> +	 * -ENOMEM Not enough memory for performing the operation.
>>> +	 * -EIO    Some input/output error with the device.
>>> +	 *
>>> +	 * Device driver must not fail lightly, any failure result in device
>>> +	 * process being kill.
>>> +	 *
>>> +	 * Return error if scheduled operation failed. Valid value :
>>> +	 * -ENOMEM Not enough memory for performing the operation.
>>> +	 * -EIO    Some input/output error with the device.
>>> +	 *
>>> +	 * All other return value trigger warning and are transformed to -EIO.
>>> +	 */
>>> +	int (*fault)(struct hmm_mirror *mirror,
>>> +		     unsigned long faddr,
>>> +		     unsigned long laddr,
>>> +		     pte_t *ptep,
>>> +		     struct hmm_event *event);
>>> +};
>>
>> I noticed that the device will receive PFNs as a result of a page fault.
>> I assume most devices will also need to call dma_map_page on the
>> physical address to get a bus address to use. Do you think it would make
>> sense to handle mapping and unmapping pages inside HMM?
> 
> We thought about this and this is not an easy task, on simple computer all
> PCI/PCIE device will share the same iommu domain as they are behind the
> same bridge/iommu. But on more complex architecture there can be several
> iommu and each device can be behind different iommu domain.
> 
> So this would mean a 1:N relationship btw page and domains it is use on.
> Which would require non trivial data structure (ie something with a list
> or alike) with the memory consumption that goes with it.
> 
> So i think on that front it is better to have the device driver do the
> dma_map_page and use the value which it stores inside its device page table
> to do the dma_unmap_page when necessary.
> 
> Of course if you have ideas on how to solve the multi-domains and each
> device possibly behind different domain, i welcome anything on that front.

I was thinking that if the alternative is that each driver maps its own
pages, we can share that code by storing the dma addresses as part of
each hmm_mirror. Sharing the code also provides the opportunity to have
a single dma address per page in the case where there's only one domain.

> 
>>
>>> ...
>>
>>> +
>>> +static void hmm_update_mirrors(struct hmm *hmm,
>>> +			       struct vm_area_struct *vma,
>>> +			       struct hmm_event *event)
>>> +{
>>> +	struct hmm_mirror *mirror;
>>> +	struct hmm_fence *fence = NULL, *tmp;
>>> +	int ticket;
>>> +
>>> +retry:
>>> +	ticket = srcu_read_lock(&srcu);
>>> +	/* Because of retry we might already have scheduled some mirror
>>> +	 * skip those.
>>> +	 */
>>> +	mirror = list_first_entry(&hmm->mirrors,
>>> +				  struct hmm_mirror,
>>> +				  mlist);
>>> +	mirror = fence ? fence->mirror : mirror;
>>> +	list_for_each_entry_continue(mirror, &hmm->mirrors, mlist) {
>>> +		struct hmm_device *device = mirror->device;
>>> +
>>> +		fence = device->ops->update(mirror, vma, event->faddr,
>>> +					    event->laddr, event->etype);
>>> +		if (fence) {
>>> +			if (IS_ERR(fence)) {
>>> +				srcu_read_unlock(&srcu, ticket);
>>> +				hmm_mirror_cleanup(mirror);
>>> +				goto retry;
>>> +			}
>>> +			kref_init(&fence->kref);
>>> +			fence->mirror = mirror;
>>> +			list_add_tail(&fence->list, &event->fences);
>>> +		}
>>> +	}
>>> +	srcu_read_unlock(&srcu, ticket);
>>> +
>>> +	if (!fence)
>>> +		/* Nothing to wait for. */
>>> +		return;
>>> +
>>> +	io_schedule();
>>> +	list_for_each_entry_safe(fence, tmp, &event->fences, list) {
>>> +		struct hmm_device *device;
>>> +		int r;
>>> +
>>> +		mirror = fence->mirror;
>>> +		device = mirror->device;
>>> +
>>> +		r = hmm_device_fence_wait(device, fence);
>>> +		if (r)
>>> +			hmm_mirror_cleanup(mirror);
>>> +	}
>>> +}
>>> +
>>> +
>>
>> It seems like the code ignores any error the update operation may
>> return, except for cleaning up the mirror. If I understand correctly,
>> having an error here would mean that the device cannot invalidate the
>> pages it has access to, and they cannot be released. Isn't that right?
>>
> 
> The function name is probably not explicit but hmm_mirror_cleanup is like
> a hmm_mirror_destroy. It will ask the device driver to stop using the address
> space ie any update failure from the device driver is a fatal failure for
> hmm and hmm consider that the mirroring must stops.
> 
>>> ...
>>
>>> +
>>> +/* hmm_mirror - per device mirroring functions.
>>> + *
>>> + * Each device that mirror a process has a uniq hmm_mirror struct. A process
>>> + * can be mirror by several devices at the same time.
>>> + *
>>> + * Below are all the functions and there helpers use by device driver to mirror
>>> + * the process address space. Those functions either deals with updating the
>>> + * device page table (through hmm callback). Or provide helper functions use by
>>> + * the device driver to fault in range of memory in the device page table.
>>> + */
>>> +
>>> +static void hmm_mirror_cleanup(struct hmm_mirror *mirror)
>>> +{
>>> +	struct vm_area_struct *vma;
>>> +	struct hmm_device *device = mirror->device;
>>> +	struct hmm_event event;
>>> +	struct hmm *hmm = mirror->hmm;
>>> +
>>> +	spin_lock(&hmm->lock);
>>> +	if (mirror->dead) {
>>> +		spin_unlock(&hmm->lock);
>>> +		return;
>>> +	}
>>> +	mirror->dead = true;
>>> +	list_del(&mirror->mlist);
>>> +	spin_unlock(&hmm->lock);
>>> +	synchronize_srcu(&srcu);
>>> +	INIT_LIST_HEAD(&mirror->mlist);
>>> +
>>> +	event.etype = HMM_UNREGISTER;
>>> +	event.faddr = 0UL;
>>> +	event.laddr = -1L;
>>> +	vma = find_vma_intersection(hmm->mm, event.faddr, event.laddr);
>>> +	for (; vma; vma = vma->vm_next) {
>>> +		struct hmm_fence *fence;
>>> +
>>> +		fence = device->ops->update(mirror, vma, vma->vm_start,
>>> +					    vma->vm_end, event.etype);
>>> +		if (fence && !IS_ERR(fence)) {
>>> +			kref_init(&fence->kref);
>>> +			fence->mirror = mirror;
>>> +			INIT_LIST_HEAD(&fence->list);
>>> +			hmm_device_fence_wait(device, fence);
>>> +		}
>>
>> Here too the code ignores any error from update.
> 
> Like said above, this function actualy terminate the device driver mirror
> and thus any further error is ignored. This have been change in lastest
> version of the patchset. But idea stays the same any error on update from
> a device driver terminate the mirror.

Okay. I guess the driver should handle this internally if there's such a
critical error. It can reset its device or something like that.

> 
> http://cgit.freedesktop.org/~glisse/linux/log/?h=hmm

Thanks, I'll take a look.

Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
