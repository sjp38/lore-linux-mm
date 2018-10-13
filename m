Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 295AD6B0003
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 03:34:16 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id n205-v6so8858202ywc.16
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 00:34:16 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id l139-v6si1350494ywl.276.2018.10.13.00.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Oct 2018 00:34:14 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com> <20181013035516.GA18822@dastard>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
Date: Sat, 13 Oct 2018 00:34:12 -0700
MIME-Version: 1.0
In-Reply-To: <20181013035516.GA18822@dastard>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 10/12/18 8:55 PM, Dave Chinner wrote:
> On Thu, Oct 11, 2018 at 11:00:12PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
[...]
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 5ed8f6292a53..017ab82e36ca 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -78,12 +78,22 @@ struct page {
>>  	 */
>>  	union {
>>  		struct {	/* Page cache and anonymous pages */
>> -			/**
>> -			 * @lru: Pageout list, eg. active_list protected by
>> -			 * zone_lru_lock.  Sometimes used as a generic list
>> -			 * by the page owner.
>> -			 */
>> -			struct list_head lru;
>> +			union {
>> +				/**
>> +				 * @lru: Pageout list, eg. active_list protected
>> +				 * by zone_lru_lock.  Sometimes used as a
>> +				 * generic list by the page owner.
>> +				 */
>> +				struct list_head lru;
>> +				/* Used by get_user_pages*(). Pages may not be
>> +				 * on an LRU while these dma_pinned_* fields
>> +				 * are in use.
>> +				 */
>> +				struct {
>> +					unsigned long dma_pinned_flags;
>> +					atomic_t      dma_pinned_count;
>> +				};
>> +			};
> 
> Isn't this broken for mapped file-backed pages? i.e. they may be
> passed as the user buffer to read/write direct IO and so the pages
> passed to gup will be on the active/inactive LRUs. hence I can't see
> how you can have dual use of the LRU list head like this....
> 
> What am I missing here?

Hi Dave,

In patch 6/6, pin_page_for_dma(), which is called at the end of get_user_pages(),
unceremoniously rips the pages out of the LRU, as a prerequisite to using
either of the page->dma_pinned_* fields. 

The idea is that LRU is not especially useful for this situation anyway,
so we'll just make it one or the other: either a page is dma-pinned, and
just hanging out doing RDMA most likely (and LRU is less meaningful during that
time), or it's possibly on an LRU list.


-- 
thanks,
John Hubbard
NVIDIA
