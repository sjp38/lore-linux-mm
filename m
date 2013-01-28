Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id E566B6B0005
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:26:53 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 28 Jan 2013 12:26:52 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 3E768C9006F
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:26:49 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0SHQmlM293680
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:26:49 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0SHQjKC029773
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:26:45 -0500
Message-ID: <5106B4D3.4000509@linux.vnet.ibm.com>
Date: Mon, 28 Jan 2013 11:26:43 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 7/9] mm: break up swap_writepage() for frontswap backends
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-8-git-send-email-sjenning@linux.vnet.ibm.com> <20130128042202.GG3321@blaptop>
In-Reply-To: <20130128042202.GG3321@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/27/2013 10:22 PM, Minchan Kim wrote:
> On Mon, Jan 07, 2013 at 02:24:38PM -0600, Seth Jennings wrote:
>> swap_writepage() is currently where frontswap hooks into the swap
>> write path to capture pages with the frontswap_store() function.
>> However, if a frontswap backend wants to "resume" the writeback of
>> a page to the swap device, it can't call swap_writepage() as
>> the page will simply reenter the backend.
>>
>> This patch separates swap_writepage() into a top and bottom half, the
>> bottom half named __swap_writepage() to allow a frontswap backend,
>> like zswap, to resume writeback beyond the frontswap_store() hook and
>> by notified when the writeback completes.
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> Looks good to me except few nitpicks.

I broke these changes out from the main zswap patch (patch 8/9) in
response to a request for Dan.  You are right in that there are
changes here unrelated to the commit message.

The other changes are related to allowing zswap to do accounting on
the number of outstanding flushes to the swap device.

If I'm going to break those out though the two resulting patches would be:
1. breakup __swap_writepage() and un-static __add_to_swap_cache() to
allow resuming of swap page writeback
2. change __swap_writepage() signature to include end_write_func and
un-static end_swap_bio_write() for accounting of outstanding flushes

Is that what you'd like to see?

Seth

> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
>> ---
>>  include/linux/swap.h |    4 ++++
>>  mm/page_io.c         |   22 +++++++++++++++++-----
>>  mm/swap_state.c      |    2 +-
>>  3 files changed, 22 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 8c66486..a3da829 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -321,6 +321,9 @@ static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
>>  /* linux/mm/page_io.c */
>>  extern int swap_readpage(struct page *);
>>  extern int swap_writepage(struct page *page, struct writeback_control *wbc);
>> +extern void end_swap_bio_write(struct bio *bio, int err);
>> +extern int __swap_writepage(struct page *page, struct writeback_control *wbc,
>> +	void (*end_write_func)(struct bio *, int));
>>  extern int swap_set_page_dirty(struct page *page);
>>  extern void end_swap_bio_read(struct bio *bio, int err);
>>  
>> @@ -335,6 +338,7 @@ extern struct address_space swapper_space;
>>  extern void show_swap_cache_info(void);
>>  extern int add_to_swap(struct page *);
>>  extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
>> +extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
> 
> What's related __add_to_swap_cache with this patch?
> 
>>  extern void __delete_from_swap_cache(struct page *);
>>  extern void delete_from_swap_cache(struct page *);
>>  extern void free_page_and_swap_cache(struct page *);
>> diff --git a/mm/page_io.c b/mm/page_io.c
>> index c535d39..806085e 100644
>> --- a/mm/page_io.c
>> +++ b/mm/page_io.c
>> @@ -43,7 +43,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>>  	return bio;
>>  }
>>  
>> -static void end_swap_bio_write(struct bio *bio, int err)
>> +void end_swap_bio_write(struct bio *bio, int err)
> 
> Why do you remove static in this patch? It's not related to the patch.
> 
>>  {
>>  	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
>>  	struct page *page = bio->bi_io_vec[0].bv_page;
>> @@ -180,15 +180,16 @@ bad_bmap:
>>  	goto out;
>>  }
>>  
>> +int __swap_writepage(struct page *page, struct writeback_control *wbc,
>> +	void (*end_write_func)(struct bio *, int));
>> +
>>  /*
>>   * We may have stale swap cache pages in memory: notice
>>   * them here and get rid of the unnecessary final write.
>>   */
>>  int swap_writepage(struct page *page, struct writeback_control *wbc)
>>  {
>> -	struct bio *bio;
>> -	int ret = 0, rw = WRITE;
>> -	struct swap_info_struct *sis = page_swap_info(page);
>> +	int ret = 0;
>>  
>>  	if (try_to_free_swap(page)) {
>>  		unlock_page(page);
>> @@ -200,6 +201,17 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>>  		end_page_writeback(page);
>>  		goto out;
>>  	}
>> +	ret = __swap_writepage(page, wbc, end_swap_bio_write);
>> +out:
>> +	return ret;
>> +}
>> +
>> +int __swap_writepage(struct page *page, struct writeback_control *wbc,
>> +	void (*end_write_func)(struct bio *, int))
>> +{
>> +	struct bio *bio;
>> +	int ret = 0, rw = WRITE;
>> +	struct swap_info_struct *sis = page_swap_info(page);
>>  
>>  	if (sis->flags & SWP_FILE) {
>>  		struct kiocb kiocb;
>> @@ -227,7 +239,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>>  		return ret;
>>  	}
>>  
>> -	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
>> +	bio = get_swap_bio(GFP_NOIO, page, end_write_func);
>>  	if (bio == NULL) {
>>  		set_page_dirty(page);
>>  		unlock_page(page);
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index 0cb36fb..7eded9c 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -67,7 +67,7 @@ void show_swap_cache_info(void)
>>   * __add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
>>   * but sets SwapCache flag and private instead of mapping and index.
>>   */
>> -static int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>> +int __add_to_swap_cache(struct page *page, swp_entry_t entry)
> 
> Ditto
> 
>>  {
>>  	int error;
>>  
>> -- 
>> 1.7.9.5
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
