Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD2B6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:11:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x79so10698970lff.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 08:11:41 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id o29si4801898lfg.117.2016.10.19.08.11.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 08:11:39 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id x23so2513834lfi.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 08:11:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1458821494.7860.9.camel@linux.intel.com>
References: <1458713384-25688-1-git-send-email-akash.goel@intel.com> <1458821494.7860.9.camel@linux.intel.com>
From: akash goel <akash.goels@gmail.com>
Date: Wed, 19 Oct 2016 20:41:38 +0530
Message-ID: <CAK_0AV3KKVZOr6WRtFOox-WKQ0wR34ry-hnR=O7aMX8DhgcGhA@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 1/2] shmem: Support for registration of
 Driver/file owner specific ops
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Sourab Gupta <sourab.gupta@intel.com>, "Goel, Akash" <akash.goel@intel.com>

On Thu, Mar 24, 2016 at 5:41 PM, Joonas Lahtinen
<joonas.lahtinen@linux.intel.com> wrote:
> On ke, 2016-03-23 at 11:39 +0530, akash.goel@intel.com wrote:
>> From: Chris Wilson <chris@chris-wilson.co.uk>
>>
>> This provides support for the Drivers or shmem file owners to register
>> a set of callbacks, which can be invoked from the address space operations
>> methods implemented by shmem.
>> This allow the file owners to hook into the shmem address space operations
>> to do some extra/custom operations in addition to the default ones.
>>
>> The private_data field of address_space struct is used to store the pointer
>> to driver specific ops.
>> Currently only one ops field is defined, which is migratepage, but can be
>> extended on need basis.
>>
>> The need for driver specific operations arises since some of the operations
>> (like migratepage) may not be handled completely within shmem, so as to be
>> effective, and would need some driver specific handling also.
>>
>> Specifically, i915.ko would like to participate in migratepage().
>> i915.ko uses shmemfs to provide swappable backing storage for its user
>> objects, but when those objects are in use by the GPU it must pin the entire
>> object until the GPU is idle. As a result, large chunks of memory can be
>> arbitrarily withdrawn from page migration, resulting in premature
>> out-of-memory due to fragmentation. However, if i915.ko can receive the
>> migratepage() request, it can then flush the object from the GPU, remove
>> its pin and thus enable the migration.
>>
>> Since Gfx allocations are one of the major consumer of system memory, its
>> imperative to have such a mechanism to effectively deal with fragmentation.
>> And therefore the need for such a provision for initiating driver specific
>> actions during address space operations.
>>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: linux-mm@kvack.org
>> Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
>> Signed-off-by: Akash Goel <akash.goel@intel.com>
>> ---
>>  include/linux/shmem_fs.h | 17 +++++++++++++++++
>>  mm/shmem.c               | 17 ++++++++++++++++-
>>  2 files changed, 33 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
>> index 4d4780c..6cfa76a 100644
>> --- a/include/linux/shmem_fs.h
>> +++ b/include/linux/shmem_fs.h
>> @@ -34,11 +34,28 @@ struct shmem_sb_info {
>>       struct mempolicy *mpol;     /* default memory policy for mappings */
>>  };
>>
>> +struct shmem_dev_info {
>> +     void *dev_private_data;
>> +     int (*dev_migratepage)(struct address_space *mapping,
>> +                            struct page *newpage, struct page *page,
>> +                            enum migrate_mode mode, void *dev_priv_data);
>
> One might want to have a separate shmem_dev_operations struct or
> similar.
>
Sorry for the very late turnaround.

Sorry couldn't get your point here. Are you suggesting to rename the
structure to shmem_dev_operations ?

>> +};
>> +
>>  static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
>>  {
>>       return container_of(inode, struct shmem_inode_info, vfs_inode);
>>  }
>>
>> +static inline int shmem_set_device_ops(struct address_space *mapping,
>> +                             struct shmem_dev_info *info)
>> +{
>> +     if (mapping->private_data != NULL)
>> +             return -EEXIST;
>> +
>
> I did a quick random peek and most set functions are just void and
> override existing data. I'd suggest the same.
>
>> +     mapping->private_data = info;
>
Fine will change the return type to void and remove the check.

> Also, doesn't this kinda steal the mapping->private_data, might that be
> unexpected for the user? I notice currently it's not being touched at
> all.
>
Sorry by User do you mean the shmem client who called shmem_file_setup() ?
It seems clients are not expected to touch mapping->private_data and
so shmemfs can safely use it.

Best regards
Akash

>> +     return 0;
>> +}
>> +
>>  /*
>>   * Functions in mm/shmem.c called directly from elsewhere:
>>   */
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 440e2a7..f8625c4 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -952,6 +952,21 @@ redirty:
>>       return 0;
>>  }
>>
>> +#ifdef CONFIG_MIGRATION
>> +static int shmem_migratepage(struct address_space *mapping,
>> +                          struct page *newpage, struct page *page,
>> +                          enum migrate_mode mode)
>> +{
>> +     struct shmem_dev_info *dev_info = mapping->private_data;
>> +
>> +     if (dev_info && dev_info->dev_migratepage)
>> +             return dev_info->dev_migratepage(mapping, newpage, page,
>> +                             mode, dev_info->dev_private_data);
>> +
>> +     return migrate_page(mapping, newpage, page, mode);
>> +}
>> +#endif
>> +
>>  #ifdef CONFIG_NUMA
>>  #ifdef CONFIG_TMPFS
>>  static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>> @@ -3168,7 +3183,7 @@ static const struct address_space_operations shmem_aops = {
>>       .write_end      = shmem_write_end,
>>  #endif
>>  #ifdef CONFIG_MIGRATION
>> -     .migratepage    = migrate_page,
>> +     .migratepage    = shmem_migratepage,
>>  #endif
>>       .error_remove_page = generic_error_remove_page,
>>  };
> --
> Joonas Lahtinen
> Open Source Technology Center
> Intel Corporation
> _______________________________________________
> Intel-gfx mailing list
> Intel-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/intel-gfx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
