Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C02A6B0473
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:34:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so267200278pgc.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:34:22 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id d4si9460575pfb.185.2016.11.18.11.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 11:34:21 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id 189so56032037pfz.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:34:21 -0800 (PST)
Subject: Re: [PATCH v4] mm: don't cap request size based on read-ahead setting
References: <e4271a04-35cf-b082-34ea-92649f5111be@kernel.dk>
 <20161118180218.GA6411@cmpxchg.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <2f00c6b4-cef7-3cbc-842f-be8aa614dd21@kernel.dk>
Date: Fri, 18 Nov 2016 12:34:18 -0700
MIME-Version: 1.0
In-Reply-To: <20161118180218.GA6411@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/18/2016 11:02 AM, Johannes Weiner wrote:
> On Thu, Nov 17, 2016 at 02:23:10PM -0700, Jens Axboe wrote:
>> We ran into a funky issue, where someone doing 256K buffered reads saw
>> 128K requests at the device level. Turns out it is read-ahead capping
>> the request size, since we use 128K as the default setting. This doesn't
>> make a lot of sense - if someone is issuing 256K reads, they should see
>> 256K reads, regardless of the read-ahead setting, if the underlying
>> device can support a 256K read in a single command.
>>
>> To make matters more confusing, there's an odd interaction with the
>> fadvise hint setting. If we tell the kernel we're doing sequential IO on
>> this file descriptor, we can get twice the read-ahead size. But if we
>> tell the kernel that we are doing random IO, hence disabling read-ahead,
>> we do get nice 256K requests at the lower level. This is because
>> ondemand and forced read-ahead behave differently, with the latter doing
>> the right thing. An application developer will be, rightfully,
>> scratching his head at this point, wondering wtf is going on. A good one
>> will dive into the kernel source, and silently weep.
>
> With the FADV_RANDOM part of the changelog updated, this looks good to
> me. Just a few nitpicks below.
>
>> This patch introduces a bdi hint, io_pages. This is the soft max IO size
>> for the lower level, I've hooked it up to the bdev settings here.
>> Read-ahead is modified to issue the maximum of the user request size,
>> and the read-ahead max size, but capped to the max request size on the
>> device side. The latter is done to avoid reading ahead too much, if the
>> application asks for a huge read. With this patch, the kernel behaves
>> like the application expects.
>>
>> Signed-off-by: Jens Axboe <axboe@fb.com>
>
>> @@ -207,12 +207,17 @@ int __do_page_cache_readahead(struct address_space
>> *mapping, struct file *filp,
>>   * memory at once.
>>   */
>>  int force_page_cache_readahead(struct address_space *mapping, struct file
>> *filp,
>
> Linewrap (but you already knew that ;))

Yeah, dunno wtf happened there...

>> -		pgoff_t offset, unsigned long nr_to_read)
>> +		               pgoff_t offset, unsigned long nr_to_read)
>>  {
>> +	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
>> +	struct file_ra_state *ra = &filp->f_ra;
>> +	unsigned long max_pages;
>> +
>>  	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
>>  		return -EINVAL;
>>
>> -	nr_to_read = min(nr_to_read, inode_to_bdi(mapping->host)->ra_pages);
>> +	max_pages = max_t(unsigned long, bdi->io_pages, ra->ra_pages);
>> +	nr_to_read = min(nr_to_read, max_pages);
>
> It would be useful to have the comment on not capping below optimal IO
> size from ondemand_readahead() here as well.

Good idea, I'll copy/paste the comment from the ondemand part.

>> @@ -369,10 +374,18 @@ ondemand_readahead(struct address_space *mapping,
>>  		   bool hit_readahead_marker, pgoff_t offset,
>>  		   unsigned long req_size)
>>  {
>> -	unsigned long max = ra->ra_pages;
>> +	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
>> +	unsigned long max_pages = ra->ra_pages;
>>  	pgoff_t prev_offset;
>>
>>  	/*
>> +	 * If the request exceeds the readahead window, allow the read to
>> +	 * be up to the optimal hardware IO size
>> +	 */
>> +	if (req_size > max_pages && bdi->io_pages > max_pages)
>> +		max_pages = min(req_size, bdi->io_pages);
>> +
>> +	/*
>>  	 * start of file
>>  	 */
>>  	if (!offset)
>
> Please feel free to add:
>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
