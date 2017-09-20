Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A574D6B0253
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:05:57 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k101so4755101iod.1
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:05:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t21sor860116ioi.364.2017.09.20.08.05.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:05:56 -0700 (PDT)
Subject: Re: [PATCH 5/6] fs-writeback: move nr_pages == 0 logic to one
 location
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-6-git-send-email-axboe@kernel.dk>
 <20170920144159.GF11106@quack2.suse.cz>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <33ba51dc-cb93-ad8c-d973-41ac12cb9e90@kernel.dk>
Date: Wed, 20 Sep 2017 09:05:51 -0600
MIME-Version: 1.0
In-Reply-To: <20170920144159.GF11106@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com

On 09/20/2017 08:41 AM, Jan Kara wrote:
> On Tue 19-09-17 13:53:06, Jens Axboe wrote:
>> Now that we have no external callers of wb_start_writeback(),
>> we can move the nr_pages == 0 logic into that function.
>>
>> Signed-off-by: Jens Axboe <axboe@kernel.dk>
> 
> ...
> 
>> +static unsigned long get_nr_dirty_pages(void)
>> +{
>> +	return global_node_page_state(NR_FILE_DIRTY) +
>> +		global_node_page_state(NR_UNSTABLE_NFS) +
>> +		get_nr_dirty_inodes();
>> +}
>> +
>>  static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>>  			       bool range_cyclic, enum wb_reason reason)
>>  {
>> @@ -942,6 +953,12 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>>  		return;
>>  
>>  	/*
>> +	 * If someone asked for zero pages, we write out the WORLD
>> +	 */
>> +	if (!nr_pages)
>> +		nr_pages = get_nr_dirty_pages();
>> +
> 
> So for 'wb' we have a better estimate of the amount we should write - use
> wb_stat_sum(wb, WB_RECLAIMABLE) statistics - that is essentially dirty +
> unstable_nfs broken down to bdi_writeback.

I don't mind making that change, but I think that should be a separate
patch. We're using get_nr_dirty_pages() in existing locations where
we have the 'wb', like in wb_check_old_data_flush().

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
