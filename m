Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 842386B0002
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 10:31:09 -0500 (EST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 28 Jan 2013 08:31:06 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B25383E40039
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 08:30:54 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0SFUukn226878
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 08:30:58 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0SFVGcH009483
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 08:31:17 -0700
Message-ID: <510698F5.5060205@linux.vnet.ibm.com>
Date: Mon, 28 Jan 2013 09:27:49 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 8/9] zswap: add to mm/
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-9-git-send-email-sjenning@linux.vnet.ibm.com> <51030ADA.8030403@redhat.com>
In-Reply-To: <51030ADA.8030403@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/25/2013 04:44 PM, Rik van Riel wrote:
> On 01/07/2013 03:24 PM, Seth Jennings wrote:
>> zswap is a thin compression backend for frontswap. It receives
>> pages from frontswap and attempts to store them in a compressed
>> memory pool, resulting in an effective partial memory reclaim and
>> dramatically reduced swap device I/O.
>>
>> Additional, in most cases, pages can be retrieved from this
>> compressed store much more quickly than reading from tradition
>> swap devices resulting in faster performance for many workloads.
>>
>> This patch adds the zswap driver to mm/
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> I like the approach of flushing pages into actual disk based
> swap when compressed swap is full.  I would like it if that
> was advertised more prominently in the changelog :)

Thanks so much for the review!

> The code looks mostly good, complaints are at the nitpick level.
> 
> One worry is that the pool can grow to whatever maximum was
> decided, and there is no way to shrink it when memory is
> required for something else.
> 
> Would it be an idea to add a shrinker for the zcache pool,
> that can also shrink the zcache pool when required?
> 
> Of course, that does lead to the question of how to balance
> the pressure from that shrinker, with the new memory entering
> zcache from the swap side. I have no clear answers here, just
> something to think about...

Yes, I prototyped a shrinker interface for zswap, but, as we both
figured, it shrinks the zswap compressed pool too aggressively to the
point of being useless.

Right now I'm working on a zswap thread that will "leak" pages out to
the swap device on an LRU basis over time.  That way if the page is a
rarely accessed page, it will eventually be written out to the swap
device and it's memory freed, even if the zswap pool isn't full.

Would this address your concerns?

>> +static void zswap_flush_entries(unsigned type, int nr)
>> +{
>> +    struct zswap_tree *tree = zswap_trees[type];
>> +    struct zswap_entry *entry;
>> +    int i, ret;
>> +
>> +/*
>> + * This limits is arbitrary for now until a better
>> + * policy can be implemented. This is so we don't
>> + * eat all of RAM decompressing pages for writeback.
>> + */
>> +#define ZSWAP_MAX_OUTSTANDING_FLUSHES 64
>> +    if (atomic_read(&zswap_outstanding_flushes) >
>> +        ZSWAP_MAX_OUTSTANDING_FLUSHES)
>> +        return;
> 
> Having this #define right in the middle of the function is
> rather ugly.  Might be worth moving it to the top.

Yes. In my mind, this policy was going to be replaced by a better one
soon. Checking may_write_to_queue() was my idea.  I didn't spend too
much time making that part pretty.

>> +static int __init zswap_debugfs_init(void)
>> +{
>> +    if (!debugfs_initialized())
>> +        return -ENODEV;
>> +
>> +    zswap_debugfs_root = debugfs_create_dir("zswap", NULL);
>> +    if (!zswap_debugfs_root)
>> +        return -ENOMEM;
>> +
>> +    debugfs_create_u64("saved_by_flush", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_saved_by_flush);
>> +    debugfs_create_u64("pool_limit_hit", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_pool_limit_hit);
>> +    debugfs_create_u64("reject_flush_attempted", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_flush_attempted);
>> +    debugfs_create_u64("reject_tmppage_fail", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_reject_tmppage_fail);
>> +    debugfs_create_u64("reject_flush_fail", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_reject_flush_fail);
>> +    debugfs_create_u64("reject_zsmalloc_fail", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_reject_zsmalloc_fail);
>> +    debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_reject_kmemcache_fail);
>> +    debugfs_create_u64("reject_compress_poor", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_reject_compress_poor);
>> +    debugfs_create_u64("flushed_pages", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_flushed_pages);
>> +    debugfs_create_u64("duplicate_entry", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_duplicate_entry);
>> +    debugfs_create_atomic_t("pool_pages", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_pool_pages);
>> +    debugfs_create_atomic_t("stored_pages", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_stored_pages);
>> +    debugfs_create_atomic_t("outstanding_flushes", S_IRUGO,
>> +            zswap_debugfs_root, &zswap_outstanding_flushes);
>> +
> 
> Some of these statistics would be very useful to system
> administrators, who will not be mounting debugfs on
> production systems.
> 
> Would it make sense to export some of these statistics
> through sysfs?

That's fine.  Which of these stats do you think should be in sysfs?

Thanks again for taking time to look at this!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
