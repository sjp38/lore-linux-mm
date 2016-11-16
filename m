Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8E806B026F
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 10:12:14 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g187so48973019itc.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 07:12:14 -0800 (PST)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id j8si19501435iof.9.2016.11.16.07.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 07:12:13 -0800 (PST)
Received: by mail-it0-x235.google.com with SMTP id c20so214447775itb.0
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 07:12:13 -0800 (PST)
Subject: Re: [PATCH] mm: don't cap request size based on read-ahead setting
References: <6e2dec0d-cef5-60ac-2cf6-a89ded82e2f4@kernel.dk>
 <000701d23fd9$805dcdd0$81196970$@alibaba-inc.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <7b150e70-66ef-f42f-a0b9-2ddb7b739076@kernel.dk>
Date: Wed, 16 Nov 2016 08:12:09 -0700
MIME-Version: 1.0
In-Reply-To: <000701d23fd9$805dcdd0$81196970$@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 'Linus Torvalds' <torvalds@linux-foundation.org>

On 11/16/2016 12:17 AM, Hillf Danton wrote:
> On Wednesday, November 16, 2016 12:31 PM Jens Axboe wrote:
>> @@ -369,10 +369,25 @@ ondemand_readahead(struct address_space *mapping,
>>   		   bool hit_readahead_marker, pgoff_t offset,
>>   		   unsigned long req_size)
>>   {
>> -	unsigned long max = ra->ra_pages;
>> +	unsigned long io_pages, max_pages;
>>   	pgoff_t prev_offset;
>>
>>   	/*
>> +	 * If bdi->io_pages is set, that indicates the (soft) max IO size
>> +	 * per command for that device. If we have that available, use
>> +	 * that as the max suitable read-ahead size for this IO. Instead of
>> +	 * capping read-ahead at ra_pages if req_size is larger, we can go
>> +	 * up to io_pages. If io_pages isn't set, fall back to using
>> +	 * ra_pages as a safe max.
>> +	 */
>> +	io_pages = inode_to_bdi(mapping->host)->io_pages;
>> +	if (io_pages) {
>> +		max_pages = max_t(unsigned long, ra->ra_pages, req_size);
>> +		io_pages = min(io_pages, max_pages);
>
> Doubt if you mean
> 		max_pages = min(io_pages, max_pages);

No, that is what I mean. We want the maximum of the RA setting and the
user IO size, but the minimum of that and the device max command size.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
