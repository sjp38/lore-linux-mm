From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/4] introduce zero filled pages handler
Date: Sun, 17 Mar 2013 08:11:38 +0800
Message-ID: <29667.5151134425$1363479136@news.gmane.org>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363255697-19674-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130316130302.GA5987@konrad-lan.dumpdata.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UH1Cu-0006x6-Br
	for glkm-linux-mm-2@m.gmane.org; Sun, 17 Mar 2013 01:12:12 +0100
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 6745B6B0005
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 20:11:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 17 Mar 2013 10:05:25 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id EBE692CE804A
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:11:39 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2GNwgr1983346
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 10:58:42 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2H0BdIw016069
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:11:39 +1100
Content-Disposition: inline
In-Reply-To: <20130316130302.GA5987@konrad-lan.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 16, 2013 at 09:03:04AM -0400, Konrad Rzeszutek Wilk wrote:
>On Thu, Mar 14, 2013 at 06:08:14PM +0800, Wanpeng Li wrote:
>> Introduce zero-filled pages handler to capture and handle zero pages.
>> 
>> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/zcache-main.c |   26 ++++++++++++++++++++++++++
>>  1 files changed, 26 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
>> index 328898e..b71e033 100644
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -460,6 +460,32 @@ static void zcache_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
>>  	kmem_cache_free(zcache_obj_cache, obj);
>>  }
>>  
>> +static bool page_zero_filled(void *ptr)
>
>Shouldn't this be 'struct page *p' ?
>> +{
>> +	unsigned int pos;
>> +	unsigned long *page;
>> +
>> +	page = (unsigned long *)ptr;
>
>That way you can avoid this casting.

Great point! I will also clean it in zram implementation.

>> +
>> +	for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++) {
>> +		if (page[pos])
>> +			return false;
>
>Perhaps allocate a static page filled with zeros and just do memcmp?
>> +	}
>> +
>> +	return true;
>> +}
>> +
>> +static void handle_zero_page(void *page)
>> +{
>> +	void *user_mem;
>> +
>> +	user_mem = kmap_atomic(page);
>> +	memset(user_mem, 0, PAGE_SIZE);
>> +	kunmap_atomic(user_mem);
>> +
>> +	flush_dcache_page(page);

To make sure kernel store is visiable to user space mappings of that page.

>
>This is new. Could you kindly explain why it is needed? Thanks.
>> +}
>> +
>>  static struct tmem_hostops zcache_hostops = {
>>  	.obj_alloc = zcache_obj_alloc,
>>  	.obj_free = zcache_obj_free,
>> -- 
>> 1.7.7.6
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
