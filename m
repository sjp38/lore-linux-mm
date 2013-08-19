Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 4436C6B0032
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 23:58:15 -0400 (EDT)
Message-ID: <521197B5.8030409@oracle.com>
Date: Mon, 19 Aug 2013 11:57:41 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
References: <1376459736-7384-1-git-send-email-minchan@kernel.org> <20130814174050.GN2296@suse.de> <20130814185820.GA2753@gmail.com> <20130815171250.GA2296@suse.de> <20130816042641.GA2893@gmail.com> <20130816083347.GD2296@suse.de> <20130819031833.GA26832@bbox>
In-Reply-To: <20130819031833.GA26832@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

Hi Minchan,

On 08/19/2013 11:18 AM, Minchan Kim wrote:
> Hello Mel,
> 
> On Fri, Aug 16, 2013 at 09:33:47AM +0100, Mel Gorman wrote:
>> On Fri, Aug 16, 2013 at 01:26:41PM +0900, Minchan Kim wrote:
>>>>>> <SNIP>
>>>>>> If it's used for something like tmpfs then it becomes much worse. Normal
>>>>>> tmpfs without swap can lockup if tmpfs is allowed to fill memory. In a
>>>>>> sane configuration, lockups will be avoided and deleting a tmpfs file is
>>>>>> guaranteed to free memory. When zram is used to back tmpfs, there is no
>>>>>> guarantee that any memory is freed due to fragmentation of the compressed
>>>>>> pages. The only way to recover the memory may be to kill applications
>>>>>> holding tmpfs files open and then delete them which is fairly drastic
>>>>>> action in a normal server environment.
>>>>>
>>>>> Indeed.
>>>>> Actually, I had a plan to support zsmalloc compaction. The zsmalloc exposes
>>>>> handle instead of pure pointer so it could migrate some zpages to somewhere
>>>>> to pack in. Then, it could help above problem and OOM storm problem.
>>>>> Anyway, it's a totally new feature and requires many changes and experiement.
>>>>> Although we don't have such feature, zram is still good for many people.
>>>>>
>>>>
>>>> And is zsmalloc was pluggable for zswap then it would also benefit.
>>>
>>> But zswap isn't pseudo block device so it couldn't be used for block device.
>>
>> It would not be impossible to write one. Taking a quick look it might even
>> be doable by just providing a zbud_ops that does not have an evict handler
>> and make sure the errors are handled correctly. i.e. does the following
>> patch mean that zswap never writes back and instead just compresses pages
>> in memory?
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index deda2b6..99e41c8 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -819,7 +819,6 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>>  }
>>  
>>  static struct zbud_ops zswap_zbud_ops = {
>> -	.evict = zswap_writeback_entry
>>  };
>>  
>>  static void zswap_frontswap_init(unsigned type)
>>
>> If so, it should be doable to link that up in a sane way so it can be
>> configured at runtime.
>>
>> Did you ever even try something like this?
> 
> Never. Because I didn't have such requirement for zram.
> 
>>
>>> Let say one usecase for using zram-blk.
>>>
>>> 1) Many embedded system don't have swap so although tmpfs can support swapout
>>> it's pointless still so such systems should have sane configuration to limit
>>> memory space so it's not only zram problem.
>>>
>>
>> If zswap was backed by a pseudo device that failed all writes or an an
>> ops with no evict handler then it would be functionally similar.
>>
>>> 2) Many embedded system don't have enough memory. Let's assume short-lived
>>> file growing up until half of system memory once in a while. We don't want
>>> to write it on flash by wear-leveing issue and very slowness so we want to use
>>> in-memory but if we uses tmpfs, it should evict half of working set to cover
>>> them when the size reach peak. zram would be better choice.
>>>
>>
>> Then back it by a pseudo device that fails all writes so it does not have
>> to write to disk.
> 
> You mean "make pseudo block device and register make_request_fn
> and prevent writeback". Bah, yes, it's doable but what is it different with below?
> 
> 1) move zbud into zram
> 2) implement frontswap API in zram
> 3) implement writebazk in zram
> 
> The zram has been for a long time in staging to be promoted and have been
> maintained/deployed. Of course, I have asked the promotion several times
> for above a year.
> 
> Why can't zram include zswap functions if you really want to merge them?
> Is there any problem?

I think merging zram into zswap or merging zswap into zram are the same
thing. It's no difference.
Both way will result in a solution finally with zram block device,
frontswap API etc.

The difference is just the name and the merging patch title, I think
it's unimportant.

I've implemented a series [PATCH 0/4] mm: merge zram into zswap, I can
change the tile to "merge zswap into zram" if you want and rename zswap
to something like zhybrid.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
