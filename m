From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 2/8] staging: zcache: zero-filled pages awareness
Date: Wed, 20 Mar 2013 18:43:49 +0800
Message-ID: <41677.2850011059$1363776299@news.gmane.org>
References: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363685150-18303-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <51498FCE.60603@oracle.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UIGVr-0000nj-Uh
	for glkm-linux-mm-2@m.gmane.org; Wed, 20 Mar 2013 11:44:56 +0100
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id DA6C56B0005
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 06:44:29 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 20 Mar 2013 20:39:13 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C0BE83578051
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 21:44:22 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2KAUnEs9961970
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 21:30:50 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2KAhpZp013810
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 21:43:51 +1100
Content-Disposition: inline
In-Reply-To: <51498FCE.60603@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 20, 2013 at 06:30:38PM +0800, Bob Liu wrote:
>
>> @@ -641,16 +691,22 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>>  {
>>  	struct page *page = NULL;
>>  	unsigned int zsize, zpages;
>> +	bool zero_filled = false;
>>  
>>  	BUG_ON(preemptible());
>> -	if (pampd_is_remote(pampd)) {
>> +
>> +	if (pampd == (void *)ZERO_FILLED)
>> +		zero_filled = true;
>> +
>> +	if (pampd_is_remote(pampd) && !zero_filled) {
>>  		BUG_ON(!ramster_enabled);
>>  		pampd = ramster_pampd_free(pampd, pool, oid, index, acct);
>>  		if (pampd == NULL)
>>  			return;
>>  	}
>>  	if (is_ephemeral(pool)) {
>> -		page = zbud_free_and_delist((struct zbudref *)pampd,
>> +		if (!zero_filled)
>> +			page = zbud_free_and_delist((struct zbudref *)pampd,
>>  						true, &zsize, &zpages);
>
>This check should also apply for !is_ephemeral(pool).

Good catch, fixed.

>
>>  		if (page)
>>  			dec_zcache_eph_pageframes();
>> @@ -667,7 +723,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>>  	}
>>  	if (!is_local_client(pool->client))
>>  		ramster_count_foreign_pages(is_ephemeral(pool), -1);
>> -	if (page)
>> +	if (page && !zero_filled)
>>  		zcache_free_page(page);
>>  }
>>  
>> 
>
>-- 
>Regards,
>-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
