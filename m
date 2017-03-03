Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6808E6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 13:40:34 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id v125so4466694qkh.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 10:40:34 -0800 (PST)
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com. [209.85.220.175])
        by mx.google.com with ESMTPS id r81si9935100qkr.215.2017.03.03.10.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 10:40:33 -0800 (PST)
Received: by mail-qk0-f175.google.com with SMTP id 1so71140723qkl.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 10:40:32 -0800 (PST)
Subject: Re: [RFC PATCH 04/12] staging: android: ion: Call dma_map_sg for
 syncing and mapping
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-5-git-send-email-labbott@redhat.com>
 <1842876.9VofhAIJSQ@avalon>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <579647db-3b4a-37bd-d322-49b4f25bc7bc@redhat.com>
Date: Fri, 3 Mar 2017 10:40:27 -0800
MIME-Version: 1.0
In-Reply-To: <1842876.9VofhAIJSQ@avalon>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, dri-devel@lists.freedesktop.org
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On 03/03/2017 08:37 AM, Laurent Pinchart wrote:
> Hi Laura,
> 
> Thank you for the patch.
> 
> On Thursday 02 Mar 2017 13:44:36 Laura Abbott wrote:
>> Technically, calling dma_buf_map_attachment should return a buffer
>> properly dma_mapped. Add calls to dma_map_sg to begin_cpu_access to
>> ensure this happens. As a side effect, this lets Ion buffers take
>> advantage of the dma_buf sync ioctls.
>>
>> Signed-off-by: Laura Abbott <labbott@redhat.com>
>> ---
>>  drivers/staging/android/ion/ion.c | 101 +++++++++++++++++------------------
>>  1 file changed, 50 insertions(+), 51 deletions(-)
>>
>> diff --git a/drivers/staging/android/ion/ion.c
>> b/drivers/staging/android/ion/ion.c index ce4adac..a931b30 100644
>> --- a/drivers/staging/android/ion/ion.c
>> +++ b/drivers/staging/android/ion/ion.c
>> @@ -795,10 +795,6 @@ void ion_client_destroy(struct ion_client *client)
>>  }
>>  EXPORT_SYMBOL(ion_client_destroy);
>>
>> -static void ion_buffer_sync_for_device(struct ion_buffer *buffer,
>> -				       struct device *dev,
>> -				       enum dma_data_direction direction);
>> -
>>  static struct sg_table *dup_sg_table(struct sg_table *table)
>>  {
>>  	struct sg_table *new_table;
>> @@ -825,22 +821,43 @@ static struct sg_table *dup_sg_table(struct sg_table
>> *table) return new_table;
>>  }
>>
>> +static void free_duped_table(struct sg_table *table)
>> +{
>> +	sg_free_table(table);
>> +	kfree(table);
>> +}
>> +
>>  static struct sg_table *ion_map_dma_buf(struct dma_buf_attachment
>> *attachment, enum dma_data_direction direction)
>>  {
>>  	struct dma_buf *dmabuf = attachment->dmabuf;
>>  	struct ion_buffer *buffer = dmabuf->priv;
>> +	struct sg_table *table;
>> +	int ret;
>> +
>> +	/*
>> +	 * TODO: Need to sync wrt CPU or device completely owning?
>> +	 */
>> +
>> +	table = dup_sg_table(buffer->sg_table);
>>
>> -	ion_buffer_sync_for_device(buffer, attachment->dev, direction);
>> -	return dup_sg_table(buffer->sg_table);
>> +	if (!dma_map_sg(attachment->dev, table->sgl, table->nents,
>> +			direction)){
>> +		ret = -ENOMEM;
>> +		goto err;
>> +	}
>> +
>> +err:
>> +	free_duped_table(table);
>> +	return ERR_PTR(ret);
>>  }
>>
>>  static void ion_unmap_dma_buf(struct dma_buf_attachment *attachment,
>>  			      struct sg_table *table,
>>  			      enum dma_data_direction direction)
>>  {
>> -	sg_free_table(table);
>> -	kfree(table);
>> +	dma_unmap_sg(attachment->dev, table->sgl, table->nents, direction);
>> +	free_duped_table(table);
>>  }
>>
>>  void ion_pages_sync_for_device(struct device *dev, struct page *page,
>> @@ -864,38 +881,6 @@ struct ion_vma_list {
>>  	struct vm_area_struct *vma;
>>  };
>>
>> -static void ion_buffer_sync_for_device(struct ion_buffer *buffer,
>> -				       struct device *dev,
>> -				       enum dma_data_direction dir)
>> -{
>> -	struct ion_vma_list *vma_list;
>> -	int pages = PAGE_ALIGN(buffer->size) / PAGE_SIZE;
>> -	int i;
>> -
>> -	pr_debug("%s: syncing for device %s\n", __func__,
>> -		 dev ? dev_name(dev) : "null");
>> -
>> -	if (!ion_buffer_fault_user_mappings(buffer))
>> -		return;
>> -
>> -	mutex_lock(&buffer->lock);
>> -	for (i = 0; i < pages; i++) {
>> -		struct page *page = buffer->pages[i];
>> -
>> -		if (ion_buffer_page_is_dirty(page))
>> -			ion_pages_sync_for_device(dev, ion_buffer_page(page),
>> -						  PAGE_SIZE, dir);
>> -
>> -		ion_buffer_page_clean(buffer->pages + i);
>> -	}
>> -	list_for_each_entry(vma_list, &buffer->vmas, list) {
>> -		struct vm_area_struct *vma = vma_list->vma;
>> -
>> -		zap_page_range(vma, vma->vm_start, vma->vm_end - vma-
>> vm_start);
>> -	}
>> -	mutex_unlock(&buffer->lock);
>> -}
>> -
>>  static int ion_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>>  {
>>  	struct ion_buffer *buffer = vma->vm_private_data;
>> @@ -1014,16 +999,24 @@ static int ion_dma_buf_begin_cpu_access(struct
>> dma_buf *dmabuf, struct ion_buffer *buffer = dmabuf->priv;
>>  	void *vaddr;
>>
>> -	if (!buffer->heap->ops->map_kernel) {
>> -		pr_err("%s: map kernel is not implemented by this heap.\n",
>> -		       __func__);
>> -		return -ENODEV;
>> +	/*
>> +	 * TODO: Move this elsewhere because we don't always need a vaddr
>> +	 */
>> +	if (buffer->heap->ops->map_kernel) {
>> +		mutex_lock(&buffer->lock);
>> +		vaddr = ion_buffer_kmap_get(buffer);
>> +		mutex_unlock(&buffer->lock);
>>  	}
>>
>> -	mutex_lock(&buffer->lock);
>> -	vaddr = ion_buffer_kmap_get(buffer);
>> -	mutex_unlock(&buffer->lock);
>> -	return PTR_ERR_OR_ZERO(vaddr);
>> +	/*
>> +	 * Close enough right now? Flag to skip sync?
>> +	 */
>> +	if (!dma_map_sg(buffer->dev->dev.this_device, buffer->sg_table->sgl,
>> +			buffer->sg_table->nents,
>> +                        DMA_BIDIRECTIONAL))
> 
> Aren't the dma_(un)map_* calls supposed to take a real, physical device as 
> their first argument ? Beside, this doesn't seem to be the right place to 
> create the mapping, as you mentioned in the commit message the buffer should 
> be mapped in the dma_buf map handler. This is something that needs to be 
> fixed, especially in the light of the comment in ion_buffer_create():
> 

Yes, this might me a case of me getting the model incorrect again.
dma_buf_{begin,end}_cpu_access do not take a device structure and
from the comments:

/**
 * dma_buf_begin_cpu_access - Must be called before accessing a dma_buf from the
 * cpu in the kernel context. Calls begin_cpu_access to allow exporter-specific
 * preparations. Coherency is only guaranteed in the specified range for the
 * specified access direction.
 * @dmabuf:     [in]    buffer to prepare cpu access for.
 * @direction:  [in]    length of range for cpu access.
 *
 * Can return negative error values, returns 0 on success.
 */

If there are no buffer attachments, I guess the notion of 'coherency'
doesn't apply here so there is no need to do any kind of
syncing/mapping at all vs. trying to find a device out of nowhere.

I'll have to go back and re-think aligning sync/begin_cpu_access calls
and dma_buf_map calls, or more likely not overthink this.


>         /*
>          * this will set up dma addresses for the sglist -- it is not
>          * technically correct as per the dma api -- a specific
>          * device isn't really taking ownership here.  However, in practice on
>          * our systems the only dma_address space is physical addresses.
>          * Additionally, we can't afford the overhead of invalidating every
>          * allocation via dma_map_sg. The implicit contract here is that
>          * memory coming from the heaps is ready for dma, ie if it has a
>          * cached mapping that mapping has been invalidated
>          */
> 
> That's a showstopper in my opinion, the DMA address space can't be restricted 
> to physical addresses, IOMMU have to be supported.
> 

I missed a patch in this series to remove that. If Ion is going to exist outside
of staging it should not be making that assumption at all so I want to drop it.
Any performance implications should be fixed with the skip sync flag.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
