From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 3/5] handle zcache_[eph|pers]_zpages for zero-filled
 page
Date: Sun, 17 Mar 2013 08:05:32 +0800
Message-ID: <19970.6218824305$1363478820@news.gmane.org>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363314860-22731-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130316131104.GE5987@konrad-lan.dumpdata.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UH17o-00027t-Q5
	for glkm-linux-mm-2@m.gmane.org; Sun, 17 Mar 2013 01:06:57 +0100
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C07F86B0005
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 20:06:31 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 17 Mar 2013 09:58:28 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C6BDF357804A
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:06:25 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2GNqa2x22151300
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 10:52:36 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2H05XDM011258
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:05:34 +1100
Content-Disposition: inline
In-Reply-To: <20130316131104.GE5987@konrad-lan.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 16, 2013 at 09:11:06AM -0400, Konrad Rzeszutek Wilk wrote:
>On Fri, Mar 15, 2013 at 10:34:18AM +0800, Wanpeng Li wrote:
>> Increment/decrement zcache_[eph|pers]_zpages for zero-filled pages,
>> the main point of the counters for zpages and pageframes is to be 
>> able to calculate density == zpages/pageframes. A zero-filled page 
>> becomes a zpage that "compresses" to zero bytes and, as a result, 
>> requires zero pageframes for storage. So the zpages counter should 
>> be increased but the pageframes counter should not.
>> 
>> [Dan Magenheimer <dan.magenheimer@oracle.com>: patch description]
>> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>
>Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Thanks for your review Konrad. :-)

>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/zcache-main.c |    7 ++++++-
>>  1 files changed, 6 insertions(+), 1 deletions(-)
>> 
>> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
>> index 6c35c7d..ef8c960 100644
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -863,6 +863,8 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>>  	if (pampd == (void *)ZERO_FILLED) {
>>  		handle_zero_filled_page(data);
>>  		zero_filled = true;
>> +		zsize = 0;
>> +		zpages = 1;
>>  		if (!raw)
>>  			*sizep = PAGE_SIZE;
>>  		goto zero_fill;
>> @@ -917,8 +919,11 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>>  
>>  	BUG_ON(preemptible());
>>  
>> -	if (pampd == (void *)ZERO_FILLED)
>> +	if (pampd == (void *)ZERO_FILLED) {
>>  		zero_filled = true;
>> +		zsize = 0;
>> +		zpages = 1;
>> +	}
>>  
>>  	if (pampd_is_remote(pampd) && !zero_filled) {
>>  
>> -- 
>> 1.7.7.6
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
