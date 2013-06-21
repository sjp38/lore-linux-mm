Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 5CA816B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:01:03 -0400 (EDT)
Message-ID: <51C397B7.2080202@oracle.com>
Date: Fri, 21 Jun 2013 08:00:55 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] zswap: limit pool fragment
References: <1371739102-11436-1-git-send-email-bob.liu@oracle.com> <20130620151859.GC9461@cerebellum>
In-Reply-To: <20130620151859.GC9461@cerebellum>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, konrad.wilk@oracle.com

Hi Seth,

On 06/20/2013 11:18 PM, Seth Jennings wrote:
> On Thu, Jun 20, 2013 at 10:38:22PM +0800, Bob Liu wrote:
>> If zswap pool fragment is heavy, it's meanless to store more pages to zswap.
>> So refuse allocate page to zswap pool to limit the fragmentation.
> 
> This is a little light on specifics.
> 
> From looking at the code it would seem that you are preventing further
> growth of the zswap pool if the overall compression ratio achieved in the
> pool doesn't reach a certain threshold; in this case an arbitrary 70%.
> 

Thanks for the review.
Yes.

> So there are some issues:
> 
> 1. If the first few pages that come into zswap don't compress well this logic
> makes a horrible assumption that all future page will also not compress well
> and effectively disables zswap until those poorly-compressed pages are removed

Not exactly, future pages can still use zswap if they can find a space.
But without allocate new physical pages.

> from the pool.  So that's a huge problem.
> 
> 2. It mucks up the allocator API with a change to zbud_alloc's signature
> 
> 3. It introduces yet another (should be) tunable in the form of the compression
> threshold and really just reimplements the per-page compression threshold that
> was removed from the code during development (the per-page check was better
> than this because it doesn't suffer from issue #1).  It was decided that the

Yes, but it's a bit different. The per-page compression limit the
compression ratio of a single page, but here it's limit the the
compression ratio of the whole pool.
poorly-compressed pages can still be stored depends on the overall
compression ratio.

That's what I observed while testing memcached, the overall compression
ratio is always low. With this patch the performance is better.
(It still takes time to summarize the results since there is an problem
of my testing machine currently.)

> decisions about whether the page can be (efficiently) stored should be the job
> of the allocator.

So maybe we should limit the fragmentation in zbud.

> 
> Seth
> 
>>
>> Signed-off-by: Bob Liu <bob.liu@oracle.com>
>> ---
>>  include/linux/zbud.h |    2 +-
>>  mm/zbud.c            |    4 +++-
>>  mm/zswap.c           |   15 +++++++++++++--
>>  3 files changed, 17 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
>> index 2571a5c..71a61be 100644
>> --- a/include/linux/zbud.h
>> +++ b/include/linux/zbud.h
>> @@ -12,7 +12,7 @@ struct zbud_ops {
>>  struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
>>  void zbud_destroy_pool(struct zbud_pool *pool);
>>  int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>> -	unsigned long *handle);
>> +	unsigned long *handle, bool dis_pagealloc);
>>  void zbud_free(struct zbud_pool *pool, unsigned long handle);
>>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
>>  void *zbud_map(struct zbud_pool *pool, unsigned long handle);
>> diff --git a/mm/zbud.c b/mm/zbud.c
>> index 9bb4710..5ace447 100644
>> --- a/mm/zbud.c
>> +++ b/mm/zbud.c
>> @@ -248,7 +248,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
>>   * a new page.
>>   */
>>  int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>> -			unsigned long *handle)
>> +			unsigned long *handle, bool dis_pagealloc)
>>  {
>>  	int chunks, i, freechunks;
>>  	struct zbud_header *zhdr = NULL;
>> @@ -279,6 +279,8 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>>
>>  	/* Couldn't find unbuddied zbud page, create new one */
>>  	spin_unlock(&pool->lock);
>> +	if (dis_pagealloc)
>> +		return -ENOSPC;
>>  	page = alloc_page(gfp);
>>  	if (!page)
>>  		return -ENOMEM;
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index deda2b6..7fe2b1b 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -607,10 +607,12 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>  	struct zswap_entry *entry, *dupentry;
>>  	int ret;
>>  	unsigned int dlen = PAGE_SIZE, len;
>> -	unsigned long handle;
>> +	unsigned long handle, stored_pages;
>>  	char *buf;
>>  	u8 *src, *dst;
>>  	struct zswap_header *zhdr;
>> +	u64 tmp;
>> +	bool dis_pagealloc = false;
>>
>>  	if (!tree) {
>>  		ret = -ENODEV;
>> @@ -645,10 +647,19 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>  		goto freepage;
>>  	}
>>
>> +	/* If the fragment of zswap pool is heavy, don't alloc new page to
>> +	 * zswap pool anymore. The limitation of fragment is 70% percent currently
>> +	 */
>> +	stored_pages = atomic_read(&zswap_stored_pages);
>> +	tmp = zswap_pool_pages * 100;
>> +	do_div(tmp, stored_pages + 1);
>> +	if (tmp > 70)
>> +		dis_pagealloc = true;
>> +
>>  	/* store */
>>  	len = dlen + sizeof(struct zswap_header);
>>  	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
>> -		&handle);
>> +		&handle, dis_pagealloc);
>>  	if (ret == -ENOSPC) {
>>  		zswap_reject_compress_poor++;
>>  		goto freepage;
>> -- 
>> 1.7.10.4
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
