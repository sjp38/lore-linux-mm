Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF4096B029E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 11:22:40 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n85so102031011pfi.4
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 08:22:40 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id i68si5639962pgc.178.2016.11.10.08.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 08:22:39 -0800 (PST)
Subject: Re: [PATCH 1/2] shmem: Support for registration of driver/file owner
 specific ops
References: <1478271776-1194-1-git-send-email-akash.goel@intel.com>
 <alpine.LSU.2.11.1611092057460.6221@eggly.anvils>
From: "Goel, Akash" <akash.goel@intel.com>
Message-ID: <e2ba6054-c090-16a5-6a33-42b5061b16ba@intel.com>
Date: Thu, 10 Nov 2016 21:52:34 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1611092057460.6221@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, linux-kernel@vger.linux.org, Sourab Gupta <sourab.gupta@intel.com>, akash.goels@gmail.com, akash.goel@intel.com



On 11/10/2016 11:06 AM, Hugh Dickins wrote:
> On Fri, 4 Nov 2016, akash.goel@intel.com wrote:
>> From: Chris Wilson <chris@chris-wilson.co.uk>
>>
>> This provides support for the drivers or shmem file owners to register
>> a set of callbacks, which can be invoked from the address space
>> operations methods implemented by shmem.  This allow the file owners to
>> hook into the shmem address space operations to do some extra/custom
>> operations in addition to the default ones.
>>
>> The private_data field of address_space struct is used to store the
>> pointer to driver specific ops.  Currently only one ops field is defined,
>> which is migratepage, but can be extended on an as-needed basis.
>>
>> The need for driver specific operations arises since some of the
>> operations (like migratepage) may not be handled completely within shmem,
>> so as to be effective, and would need some driver specific handling also.
>> Specifically, i915.ko would like to participate in migratepage().
>> i915.ko uses shmemfs to provide swappable backing storage for its user
>> objects, but when those objects are in use by the GPU it must pin the
>> entire object until the GPU is idle.  As a result, large chunks of memory
>> can be arbitrarily withdrawn from page migration, resulting in premature
>> out-of-memory due to fragmentation.  However, if i915.ko can receive the
>> migratepage() request, it can then flush the object from the GPU, remove
>> its pin and thus enable the migration.
>>
>> Since gfx allocations are one of the major consumer of system memory, its
>> imperative to have such a mechanism to effectively deal with
>> fragmentation.  And therefore the need for such a provision for initiating
>> driver specific actions during address space operations.
>
> Thank you for persisting with this, and sorry for all my delay.
>
>>
>> v2:
>> - Drop dev_ prefix from the members of shmem_dev_info structure. (Joonas)
>> - Change the return type of shmem_set_device_op() to void and remove the
>>   check for pre-existing data. (Joonas)
>> - Rename shmem_set_device_op() to shmem_set_dev_info() to be consistent
>>   with shmem_dev_info structure. (Joonas)
>>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.linux.org
>> Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
>> Signed-off-by: Akash Goel <akash.goel@intel.com>
>> Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
>
> That doesn't seem quite right: the From line above implies that Chris
> wrote it, and should be first Signer; but perhaps the From line is wrong.
>
Chris only wrote this patch initially, will do the required correction.

>> ---
>>  include/linux/shmem_fs.h | 13 +++++++++++++
>>  mm/shmem.c               | 17 ++++++++++++++++-
>>  2 files changed, 29 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
>> index ff078e7..454c3ba 100644
>> --- a/include/linux/shmem_fs.h
>> +++ b/include/linux/shmem_fs.h
>> @@ -39,11 +39,24 @@ struct shmem_sb_info {
>>  	unsigned long shrinklist_len; /* Length of shrinklist */
>>  };
>>
>> +struct shmem_dev_info {
>> +	void *private_data;
>> +	int (*migratepage)(struct address_space *mapping,
>> +			   struct page *newpage, struct page *page,
>> +			   enum migrate_mode mode, void *dev_priv_data);
>
> Aren't the private_data field and dev_priv_data arg a little bit
> confusing and redundant?  Can't the migratepage() deduce dev_priv
> for itself from mapping->private_data (perhaps wrapped by a
> shmem_get_dev_info()), by using container_of()?
>
Yes looks like migratepage() can deduce dev_priv from mapping->private_data.
Can we keep the private_data as a placeholder ?. Will 
s/dev_priv_data/private_data/.

As per your suggestion, in the other patch, object pointer can be 
derived from mapping->private_data (container_of) and dev_priv in turn 
can be derived from object pointer.

>> +};
>> +
>>  static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
>>  {
>>  	return container_of(inode, struct shmem_inode_info, vfs_inode);
>>  }
>>
>> +static inline void shmem_set_dev_info(struct address_space *mapping,
>> +				      struct shmem_dev_info *info)
>> +{
>> +	mapping->private_data = info;
>
> Nit: if this stays as is, I'd prefer dev_info there and above,
> since shmem.c uses info all over for its shmem_inode_info pointer.
> But in second patch I suggest obj_info may be better than dev_info.
>
Fine will s/info/dev_info.

Best regards
Akash

>> +}
>> +
>>  /*
>>   * Functions in mm/shmem.c called directly from elsewhere:
>>   */
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index ad7813d..fce8de3 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -1290,6 +1290,21 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>>  	return 0;
>>  }
>>
>> +#ifdef CONFIG_MIGRATION
>> +static int shmem_migratepage(struct address_space *mapping,
>> +			     struct page *newpage, struct page *page,
>> +			     enum migrate_mode mode)
>> +{
>> +	struct shmem_dev_info *dev_info = mapping->private_data;
>> +
>> +	if (dev_info && dev_info->migratepage)
>> +		return dev_info->migratepage(mapping, newpage, page,
>> +					     mode, dev_info->private_data);
>> +
>> +	return migrate_page(mapping, newpage, page, mode);
>> +}
>> +#endif
>> +
>>  #if defined(CONFIG_NUMA) && defined(CONFIG_TMPFS)
>>  static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>>  {
>> @@ -3654,7 +3669,7 @@ static void shmem_destroy_inodecache(void)
>>  	.write_end	= shmem_write_end,
>>  #endif
>>  #ifdef CONFIG_MIGRATION
>> -	.migratepage	= migrate_page,
>> +	.migratepage	= shmem_migratepage,
>>  #endif
>>  	.error_remove_page = generic_error_remove_page,
>>  };
>> --
>> 1.9.2
>
> I didn't like this very much; but every time I tried to "improve" it,
> found good reasons why you chose the way you did (modularity of i915,
> constness of a_ops, reluctance to copy and modify a_ops, reluctance
> to export those shmem methods separately).
>
> I think perhaps later we just add a gem_ops pointer to shmem_inode_info,
> for i915 or other gems to fill in as they wish (and shmem divert off to
> them if set, as you've done); but for now you're trying to avoid
> enlarging the shmem inode, okay.
>
> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
