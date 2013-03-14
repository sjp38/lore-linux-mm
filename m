From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] zcache: add pageframes count once compress
 zero-filled pages twice
Date: Thu, 14 Mar 2013 08:20:56 +0800
Message-ID: <5762.91914699158$1363220499@news.gmane.org>
References: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363158321-20790-5-git-send-email-liwanp@linux.vnet.ibm.com>
 <634487ea-fbbd-4eb9-9a18-9206edc4e0d2@default>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UFvvL-0007uq-NW
	for glkm-linux-mm-2@m.gmane.org; Thu, 14 Mar 2013 01:21:36 +0100
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 8CF2A6B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 20:21:10 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 05:48:02 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 0D81E394002D
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 05:51:00 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2E0Ktu729229080
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 05:50:55 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2E0Kvpw005408
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 11:20:58 +1100
Content-Disposition: inline
In-Reply-To: <634487ea-fbbd-4eb9-9a18-9206edc4e0d2@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 13, 2013 at 09:42:16AM -0700, Dan Magenheimer wrote:
>> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
>> Sent: Wednesday, March 13, 2013 1:05 AM
>> To: Andrew Morton
>> Cc: Greg Kroah-Hartman; Dan Magenheimer; Seth Jennings; Konrad Rzeszutek Wilk; Minchan Kim; linux-
>> mm@kvack.org; linux-kernel@vger.kernel.org; Wanpeng Li
>> Subject: [PATCH 4/4] zcache: add pageframes count once compress zero-filled pages twice
>
>Hi Wanpeng --
>
>Thanks for taking on this task from the drivers/staging/zcache TODO list!
>
>> Since zbudpage consist of two zpages, two zero-filled pages compression
>> contribute to one [eph|pers]pageframe count accumulated.
>

Hi Dan,

>I'm not sure why this is necessary.  The [eph|pers]pageframe count
>is supposed to be counting actual pageframes used by zcache.  Since
>your patch eliminates the need to store zero pages, no pageframes
>are needed at all to store zero pages, so it's not necessary
>to increment zcache_[eph|pers]_pageframes when storing zero
>pages.
>

Great point! It seems that we also don't need to caculate 
zcache_[eph|pers]_zpages for zero-filled pages. I will fix 
it in next version. :-)

>Or am I misunderstanding your intent?
>

Regards,
Wanpeng Li 

>Thanks,
>Dan
> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/zcache-main.c |   25 +++++++++++++++++++++++--
>>  1 files changed, 23 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
>> index dd52975..7860ff0 100644
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -544,6 +544,8 @@ static struct page *zcache_evict_eph_pageframe(void);
>>  static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
>>  					struct tmem_handle *th)
>>  {
>> +	static ssize_t second_eph_zero_page;
>> +	static atomic_t second_eph_zero_page_atomic = ATOMIC_INIT(0);
>>  	void *pampd = NULL, *cdata = data;
>>  	unsigned clen = size;
>>  	bool zero_filled = false;
>> @@ -561,7 +563,14 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
>>  		clen = 0;
>>  		zero_filled = true;
>>  		zcache_pages_zero++;
>> -		goto got_pampd;
>> +		second_eph_zero_page = atomic_inc_return(
>> +				&second_eph_zero_page_atomic);
>> +		if (second_eph_zero_page % 2 == 1)
>> +			goto got_pampd;
>> +		else {
>> +			atomic_sub(2, &second_eph_zero_page_atomic);
>> +			goto count_zero_page;
>> +		}
>>  	}
>>  	kunmap_atomic(user_mem);
>> 
>> @@ -597,6 +606,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
>>  create_in_new_page:
>>  	pampd = (void *)zbud_create_prep(th, true, cdata, clen, newpage);
>>  	BUG_ON(pampd == NULL);
>> +count_zero_page:
>>  	zcache_eph_pageframes =
>>  		atomic_inc_return(&zcache_eph_pageframes_atomic);
>>  	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
>> @@ -621,6 +631,8 @@ out:
>>  static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
>>  					struct tmem_handle *th)
>>  {
>> +	static ssize_t second_pers_zero_page;
>> +	static atomic_t second_pers_zero_page_atomic = ATOMIC_INIT(0);
>>  	void *pampd = NULL, *cdata = data;
>>  	unsigned clen = size, zero_filled = 0;
>>  	struct page *page = (struct page *)(data), *newpage;
>> @@ -644,7 +656,15 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
>>  		clen = 0;
>>  		zero_filled = 1;
>>  		zcache_pages_zero++;
>> -		goto got_pampd;
>> +		second_pers_zero_page = atomic_inc_return(
>> +				&second_pers_zero_page_atomic);
>> +		if (second_pers_zero_page % 2 == 1)
>> +			goto got_pampd;
>> +		else {
>> +			atomic_sub(2, &second_pers_zero_page_atomic);
>> +			goto count_zero_page;
>> +		}
>> +
>>  	}
>>  	kunmap_atomic(user_mem);
>> 
>> @@ -698,6 +718,7 @@ create_pampd:
>>  create_in_new_page:
>>  	pampd = (void *)zbud_create_prep(th, false, cdata, clen, newpage);
>>  	BUG_ON(pampd == NULL);
>> +count_zero_page:
>>  	zcache_pers_pageframes =
>>  		atomic_inc_return(&zcache_pers_pageframes_atomic);
>>  	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
>> --
>> 1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
