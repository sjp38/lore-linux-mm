Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8D06B02DA
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:42:01 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g187so21190944itc.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:42:01 -0800 (PST)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id 68si17088665iov.239.2016.11.15.14.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:42:00 -0800 (PST)
Received: by mail-it0-x231.google.com with SMTP id c20so178658243itb.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:42:00 -0800 (PST)
Subject: Re: [PATCH/RFC] mm: don't cap request size based on read-ahead
 setting
References: <7d8739c2-09ea-8c1f-cef7-9b8b40766c6a@kernel.dk>
 <20161115222734.GA2300@cmpxchg.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <65f0b407-6fe5-8ba9-4c10-5259e195a038@kernel.dk>
Date: Tue, 15 Nov 2016 15:41:58 -0700
MIME-Version: 1.0
In-Reply-To: <20161115222734.GA2300@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 11/15/2016 03:27 PM, Johannes Weiner wrote:
> Hi Jens,
>
> On Thu, Nov 10, 2016 at 10:00:37AM -0700, Jens Axboe wrote:
>> Hi,
>>
>> We ran into a funky issue, where someone doing 256K buffered reads saw
>> 128K requests at the device level. Turns out it is read-ahead capping
>> the request size, since we use 128K as the default setting. This doesn't
>> make a lot of sense - if someone is issuing 256K reads, they should see
>> 256K reads, regardless of the read-ahead setting.
>>
>> To make matters more confusing, there's an odd interaction with the
>> fadvise hint setting. If we tell the kernel we're doing sequential IO on
>> this file descriptor, we can get twice the read-ahead size. But if we
>> tell the kernel that we are doing random IO, hence disabling read-ahead,
>> we do get nice 256K requests at the lower level. An application
>> developer will be, rightfully, scratching his head at this point,
>> wondering wtf is going on. A good one will dive into the kernel source,
>> and silently weep.
>>
>> This patch introduces a bdi hint, io_pages. This is the soft max IO size
>> for the lower level, I've hooked it up to the bdev settings here.
>> Read-ahead is modified to issue the maximum of the user request size,
>> and the read-ahead max size, but capped to the max request size on the
>> device side. The latter is done to avoid reading ahead too much, if the
>> application asks for a huge read. With this patch, the kernel behaves
>> like the application expects.
>>
>>
>> diff --git a/block/blk-settings.c b/block/blk-settings.c
>> index f679ae122843..65f16cf4f850 100644
>> --- a/block/blk-settings.c
>> +++ b/block/blk-settings.c
>> @@ -249,6 +249,7 @@ void blk_queue_max_hw_sectors(struct request_queue *q,
>> unsigned int max_hw_secto
>>  	max_sectors = min_not_zero(max_hw_sectors, limits->max_dev_sectors);
>>  	max_sectors = min_t(unsigned int, max_sectors, BLK_DEF_MAX_SECTORS);
>>  	limits->max_sectors = max_sectors;
>> +	q->backing_dev_info.io_pages = max_sectors >> (PAGE_SHIFT - 9);
>
> Could we simply set q->backing_dev_info.ra_pages here? This would
> start the disk out with a less magical readahead setting than the
> current 128k default, while retaining the ability for the user to
> override it in sysfs later on. Plus, one less attribute to juggle.

We could, but then we'd have two places that tweak the same knob. I
think it's perfectly valid to have the read-ahead size be bigger than
the max request size, if you want some pipelining, for instance.

The 128k default is silly, though, that should be smarter. It should
probably default to the max request size.

>> @@ -369,10 +369,18 @@ ondemand_readahead(struct address_space *mapping,
>>  		   bool hit_readahead_marker, pgoff_t offset,
>>  		   unsigned long req_size)
>>  {
>> -	unsigned long max = ra->ra_pages;
>> +	unsigned long max_pages;
>>  	pgoff_t prev_offset;
>>
>>  	/*
>> +	 * Use the max of the read-ahead pages setting and the requested IO
>> +	 * size, and then the min of that and the soft IO size for the
>> +	 * underlying device.
>> +	 */
>> +	max_pages = max_t(unsigned long, ra->ra_pages, req_size);
>> +	max_pages = min_not_zero(inode_to_bdi(mapping->host)->io_pages, max_pages);
>
> This code would then go away, and it would apply the benefit of this
> patch automatically to explicit readahead(2) and FADV_WILLNEED calls
> going through force_page_cache_readahead() as well.

The path from the force actually works, which is why you get the weird
behavior with a file marked as RANDOM getting the full request size, and
not being limited by ra_pages.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
