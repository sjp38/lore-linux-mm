From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] zcache: zero-filled pages awareness
Date: Thu, 14 Mar 2013 07:35:37 +0800
Message-ID: <15559.3328214765$1363217780@news.gmane.org>
References: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363158321-20790-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <9a45f4be-a80c-434d-ae7f-f8faaea5e4d4@default>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UFvDS-0001Qd-NT
	for glkm-linux-mm-2@m.gmane.org; Thu, 14 Mar 2013 00:36:14 +0100
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id D09946B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 19:35:49 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 05:02:39 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 4303F1258023
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 05:06:43 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2DNZaJ023265342
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 05:05:36 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2DNZd3Z010677
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 10:35:39 +1100
Content-Disposition: inline
In-Reply-To: <9a45f4be-a80c-434d-ae7f-f8faaea5e4d4@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 13, 2013 at 09:53:48AM -0700, Dan Magenheimer wrote:
>> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
>> Subject: [PATCH 2/4] zcache: zero-filled pages awareness
>> 
>> Compression of zero-filled pages can unneccessarily cause internal
>> fragmentation, and thus waste memory. This special case can be
>> optimized.
>> 
>> This patch captures zero-filled pages, and marks their corresponding
>> zcache backing page entry as zero-filled. Whenever such zero-filled
>> page is retrieved, we fill the page frame with zero.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/tmem.c        |    4 +-
>>  drivers/staging/zcache/tmem.h        |    5 ++
>>  drivers/staging/zcache/zcache-main.c |   87 ++++++++++++++++++++++++++++++----
>>  3 files changed, 85 insertions(+), 11 deletions(-)
>> 
>> diff --git a/drivers/staging/zcache/tmem.c b/drivers/staging/zcache/tmem.c
>> index a2b7e03..62468ea 100644
>> --- a/drivers/staging/zcache/tmem.c
>> +++ b/drivers/staging/zcache/tmem.c
>> @@ -597,7 +597,9 @@ int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
>>  	if (unlikely(ret == -ENOMEM))
>>  		/* may have partially built objnode tree ("stump") */
>>  		goto delete_and_free;
>> -	(*tmem_pamops.create_finish)(pampd, is_ephemeral(pool));
>> +	if (pampd != (void *)ZERO_FILLED)
>> +		(*tmem_pamops.create_finish)(pampd, is_ephemeral(pool));
>> +
>>  	goto out;
>> 
>>  delete_and_free:
>> diff --git a/drivers/staging/zcache/tmem.h b/drivers/staging/zcache/tmem.h
>> index adbe5a8..6719dbd 100644
>> --- a/drivers/staging/zcache/tmem.h
>> +++ b/drivers/staging/zcache/tmem.h
>> @@ -204,6 +204,11 @@ struct tmem_handle {
>>  	uint16_t client_id;
>>  };
>> 
>> +/*
>> + * mark pampd to special vaule in order that later
>> + * retrieve will identify zero-filled pages
>> + */
>> +#define ZERO_FILLED 0x2
>
>You can avoid changing tmem.[ch] entirely by moving this
>definition into zcache-main.c and by moving the check
>comparing pampd against ZERO_FILLED into zcache_pampd_create_finish()
>I think that would be cleaner...

Great point!

>
>If you change this and make the pageframe counter fix for PATCH 4/4,
>please add my ack for the next version:
>

Thanks Dan. :-)

Regards,
Wanpeng Li 

>Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
