Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A0B586B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 12:12:49 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1788013pab.28
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 09:12:49 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id ay4si2895914pbc.91.2014.07.30.09.12.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 09:12:48 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1798488pab.0
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 09:12:48 -0700 (PDT)
Message-ID: <53D9197C.2050000@gmail.com>
Date: Wed, 30 Jul 2014 19:12:44 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 04/22] Change direct_access calling convention
References: <cover.1406058387.git.matthew.r.wilcox@intel.com> <b78b33d94b669a5fbd02e06f2493b43dd5d77698.1406058387.git.matthew.r.wilcox@intel.com> <53D9174C.7040906@gmail.com>
In-Reply-To: <53D9174C.7040906@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: willy@linux.intel.com

On 07/30/2014 07:03 PM, Boaz Harrosh wrote:
<>
>> +long bdev_direct_access(struct block_device *bdev, sector_t sector,
>> +			void **addr, unsigned long *pfn, long size)
>> +{
>> +	const struct block_device_operations *ops = bdev->bd_disk->fops;
>> +	if (!ops->direct_access)
>> +		return -EOPNOTSUPP;
> 
> You need to check alignment on PAGE_SIZE since this API requires it, do
> to pfn defined to a page_number.
> 
> (Unless you want to define another output-param like page_offset.
>  but this exercise can be left to the caller)
> 
> You also need to check against the partition boundary. so something like:
> 
> + 	if (sector & (PAGE_SECTORS-1))
> + 		return -EINVAL;
> +	if (unlikely(sector + size > part_nr_sects_read(bdev->bd_part)))

Off course I was wrong here size is in bytes not in sectors. Which points
out that maybe this API needs to be in sectors.

[Actually it needs to be in pages both size and offset, because of return of
pfn, but its your call.]

Anyway my code above needs to be fixed with
	(size + 512 -1) / 512

Thanks
Boaz

> + 		return -ERANGE;
> 
> Then perhaps you can remove that check from drivers
> 
>> +	return ops->direct_access(bdev, sector + get_start_sect(bdev), addr,
>> +					pfn, size);
>> +}
>> +EXPORT_SYMBOL_GPL(bdev_direct_access);
<>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
