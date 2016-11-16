Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 338436B0285
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 13:48:13 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o1so60472384ito.7
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 10:48:13 -0800 (PST)
Received: from mail-it0-x22e.google.com (mail-it0-x22e.google.com. [2607:f8b0:4001:c0b::22e])
        by mx.google.com with ESMTPS id 21si6347768itw.74.2016.11.16.10.48.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 10:48:12 -0800 (PST)
Received: by mail-it0-x22e.google.com with SMTP id b123so68785334itb.0
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 10:48:12 -0800 (PST)
Subject: Re: [PATCH/RFC] mm: don't cap request size based on read-ahead
 setting
References: <7d8739c2-09ea-8c1f-cef7-9b8b40766c6a@kernel.dk>
 <20161115222734.GA2300@cmpxchg.org>
 <65f0b407-6fe5-8ba9-4c10-5259e195a038@kernel.dk>
 <20161116174425.GA18090@cmpxchg.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <a5e7b28b-3139-6878-1ca1-d5ef7545aa13@kernel.dk>
Date: Wed, 16 Nov 2016 11:47:56 -0700
MIME-Version: 1.0
In-Reply-To: <20161116174425.GA18090@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 11/16/2016 10:44 AM, Johannes Weiner wrote:
> On Tue, Nov 15, 2016 at 03:41:58PM -0700, Jens Axboe wrote:
>> On 11/15/2016 03:27 PM, Johannes Weiner wrote:
>>> Hi Jens,
>>>
>>> On Thu, Nov 10, 2016 at 10:00:37AM -0700, Jens Axboe wrote:
>>>> Hi,
>>>>
>>>> We ran into a funky issue, where someone doing 256K buffered reads saw
>>>> 128K requests at the device level. Turns out it is read-ahead capping
>>>> the request size, since we use 128K as the default setting. This doesn't
>>>> make a lot of sense - if someone is issuing 256K reads, they should see
>>>> 256K reads, regardless of the read-ahead setting.
>>>>
>>>> To make matters more confusing, there's an odd interaction with the
>>>> fadvise hint setting. If we tell the kernel we're doing sequential IO on
>>>> this file descriptor, we can get twice the read-ahead size. But if we
>>>> tell the kernel that we are doing random IO, hence disabling read-ahead,
>>>> we do get nice 256K requests at the lower level. An application
>>>> developer will be, rightfully, scratching his head at this point,
>>>> wondering wtf is going on. A good one will dive into the kernel source,
>>>> and silently weep.
>>>>
>>>> This patch introduces a bdi hint, io_pages. This is the soft max IO size
>>>> for the lower level, I've hooked it up to the bdev settings here.
>>>> Read-ahead is modified to issue the maximum of the user request size,
>>>> and the read-ahead max size, but capped to the max request size on the
>>>> device side. The latter is done to avoid reading ahead too much, if the
>>>> application asks for a huge read. With this patch, the kernel behaves
>>>> like the application expects.
>>>>
>>>>
>>>> diff --git a/block/blk-settings.c b/block/blk-settings.c
>>>> index f679ae122843..65f16cf4f850 100644
>>>> --- a/block/blk-settings.c
>>>> +++ b/block/blk-settings.c
>>>> @@ -249,6 +249,7 @@ void blk_queue_max_hw_sectors(struct request_queue *q,
>>>> unsigned int max_hw_secto
>>>>  	max_sectors = min_not_zero(max_hw_sectors, limits->max_dev_sectors);
>>>>  	max_sectors = min_t(unsigned int, max_sectors, BLK_DEF_MAX_SECTORS);
>>>>  	limits->max_sectors = max_sectors;
>>>> +	q->backing_dev_info.io_pages = max_sectors >> (PAGE_SHIFT - 9);
>>>
>>> Could we simply set q->backing_dev_info.ra_pages here? This would
>>> start the disk out with a less magical readahead setting than the
>>> current 128k default, while retaining the ability for the user to
>>> override it in sysfs later on. Plus, one less attribute to juggle.
>>
>> We could, but then we'd have two places that tweak the same knob. I
>> think it's perfectly valid to have the read-ahead size be bigger than
>> the max request size, if you want some pipelining, for instance.
>
> I'm not sure I follow. Which would be the two places and which knob?

It's actually three knobs, since I looked:

1) /sys/block/<dev>/queue/read_ahead_kb
2) /sys/class/bdi/<dev>/read_ahead_kb
3) /sys/block/<dev>/queue/max_sectors_kb

The first 2 control the same thing, bdi->ra_pages. If we update ->pages
from max_sectors_kb as well, that'd make three. At least the first two
tell you what they do, don't like having the max_sectors_kb fiddle it
automatically too.

> What I meant how it could work is this: when the queue gets allocated,
> we set ra_pages to the hard-coded 128K, like we do right now. When the
> driver initializes and calls blk_queue_max_hw_sectors() it would set
> ra_pages to the more informed, device-optimized max_sectors >>
> (PAGE_SHIFT - 9). And once it's all initialized, the user can still
> make adjustments to the default we picked in the kernel heuristic.
>
>> The 128k default is silly, though, that should be smarter. It should
>> probably default to the max request size.
>
> Could you clarify the difference between max request size and what
> blk_queue_max_hw_sectors() sets? The way I understood your patch is
> that we want to use a readahead cap that's better suited to the
> underlying IO device than the magic 128K. What am I missing?

This ties in with the above, so I'm just replying here. max_hw_sectors
is a hardware limit, the max size for a single command. max_sectors is a
user setting. For latency reasons, we don't necessarily want to issue
IOs up to the full hardware size, so we cap the kernel initiated size.
Eg for most hardware that can do 32-64MB in a command, we still limit
the default size to 512k.

The limit I added limits us to the user setting, not the hardware
setting.

>>>> @@ -369,10 +369,18 @@ ondemand_readahead(struct address_space *mapping,
>>>>  		   bool hit_readahead_marker, pgoff_t offset,
>>>>  		   unsigned long req_size)
>>>>  {
>>>> -	unsigned long max = ra->ra_pages;
>>>> +	unsigned long max_pages;
>>>>  	pgoff_t prev_offset;
>>>>
>>>>  	/*
>>>> +	 * Use the max of the read-ahead pages setting and the requested IO
>>>> +	 * size, and then the min of that and the soft IO size for the
>>>> +	 * underlying device.
>>>> +	 */
>>>> +	max_pages = max_t(unsigned long, ra->ra_pages, req_size);
>>>> +	max_pages = min_not_zero(inode_to_bdi(mapping->host)->io_pages, max_pages);
>>>
>>> This code would then go away, and it would apply the benefit of this
>>> patch automatically to explicit readahead(2) and FADV_WILLNEED calls
>>> going through force_page_cache_readahead() as well.
>>
>> The path from the force actually works, which is why you get the weird
>> behavior with a file marked as RANDOM getting the full request size, and
>> not being limited by ra_pages.
>
> How so? do_generic_file_read() calls page_cache_sync_readahead(), and
> if the file is marked random it goes to force_page_cache_readahead():
>
> void page_cache_sync_readahead(struct address_space *mapping,
> 			       struct file_ra_state *ra, struct file *filp,
> 			       pgoff_t offset, unsigned long req_size)
> {
> 	/* no read-ahead */
> 	if (!ra->ra_pages)
> 		return;
>
> 	/* be dumb */
> 	if (filp && (filp->f_mode & FMODE_RANDOM)) {
> 		force_page_cache_readahead(mapping, filp, offset, req_size);
> 		return;
> 	}
>
> 	/* do read-ahead */
> 	ondemand_readahead(mapping, ra, filp, false, offset, req_size);
> }
>
> That function in turn still caps the reads to the default 128K ra_pages:
>
> int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
> 		pgoff_t offset, unsigned long nr_to_read)
> {
> 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
> 		return -EINVAL;
>
> 	nr_to_read = min(nr_to_read, inode_to_bdi(mapping->host)->ra_pages);
> 	while (nr_to_read) {
> 		int err;
>
> 		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_SIZE;
>
> 		if (this_chunk > nr_to_read)
> 			this_chunk = nr_to_read;
> 		err = __do_page_cache_readahead(mapping, filp,
> 						offset, this_chunk, 0);
> 		if (err < 0)
> 			return err;
>
> 		offset += this_chunk;
> 		nr_to_read -= this_chunk;
> 	}
> 	return 0;
> }
>
> How could you get IO requests bigger than the 128k ra_pages there?

Sorry, what I meant is that if we mark it random through fadvise, then
read-ahead doesn't get in the way and we get the full size. If we end up
through read-ahead, we get limited. So you are right, I should fix up
force_page_cache_readahead as well.

I'll send out a v3.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
