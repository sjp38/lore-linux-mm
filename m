From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/4] introduce zero-filled page stat count
Date: Sun, 17 Mar 2013 08:13:16 +0800
Message-ID: <2781.87098815597$1363479234@news.gmane.org>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363255697-19674-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130316130638.GB5987@konrad-lan.dumpdata.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UH1EU-0008VL-SX
	for glkm-linux-mm-2@m.gmane.org; Sun, 17 Mar 2013 01:13:51 +0100
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id BFDE06B0005
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 20:13:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 17 Mar 2013 05:40:09 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id D2881125805D
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 05:44:24 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2H0DFeS9109812
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 05:43:15 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2H0DH5e032575
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 00:13:18 GMT
Content-Disposition: inline
In-Reply-To: <20130316130638.GB5987@konrad-lan.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 16, 2013 at 09:06:39AM -0400, Konrad Rzeszutek Wilk wrote:
>On Thu, Mar 14, 2013 at 06:08:16PM +0800, Wanpeng Li wrote:
>> Introduce zero-filled page statistics to monitor the number of
>> zero-filled pages.
>

Hi Konrad,

>Hm, you must be using an older version of the driver. Please
>rebase it against Greg KH's staging tree. This is where most if not
>all of the DebugFS counters got moved to a different file.
>

Sorry, I miss it. I will rebase it. :-)

Regards,
Wanpeng Li 

>> 
>> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/zcache-main.c |    7 +++++++
>>  1 files changed, 7 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
>> index db200b4..2091a4d 100644
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -196,6 +196,7 @@ static ssize_t zcache_eph_nonactive_puts_ignored;
>>  static ssize_t zcache_pers_nonactive_puts_ignored;
>>  static ssize_t zcache_writtenback_pages;
>>  static ssize_t zcache_outstanding_writeback_pages;
>> +static ssize_t zcache_pages_zero;
>>  
>>  #ifdef CONFIG_DEBUG_FS
>>  #include <linux/debugfs.h>
>> @@ -257,6 +258,7 @@ static int zcache_debugfs_init(void)
>>  	zdfs("outstanding_writeback_pages", S_IRUGO, root,
>>  				&zcache_outstanding_writeback_pages);
>>  	zdfs("writtenback_pages", S_IRUGO, root, &zcache_writtenback_pages);
>> +	zdfs("pages_zero", S_IRUGO, root, &zcache_pages_zero);
>>  	return 0;
>>  }
>>  #undef	zdebugfs
>> @@ -326,6 +328,7 @@ void zcache_dump(void)
>>  	pr_info("zcache: outstanding_writeback_pages=%zd\n",
>>  				zcache_outstanding_writeback_pages);
>>  	pr_info("zcache: writtenback_pages=%zd\n", zcache_writtenback_pages);
>> +	pr_info("zcache: pages_zero=%zd\n", zcache_pages_zero);
>>  }
>>  #endif
>>  
>> @@ -562,6 +565,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
>>  		kunmap_atomic(user_mem);
>>  		clen = 0;
>>  		zero_filled = true;
>> +		zcache_pages_zero++;
>>  		goto got_pampd;
>>  	}
>>  	kunmap_atomic(user_mem);
>> @@ -645,6 +649,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
>>  		kunmap_atomic(user_mem);
>>  		clen = 0;
>>  		zero_filled = true;
>> +		zcache_pages_zero++;
>>  		goto got_pampd;
>>  	}
>>  	kunmap_atomic(user_mem);
>> @@ -866,6 +871,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>>  		zpages = 0;
>>  		if (!raw)
>>  			*sizep = PAGE_SIZE;
>> +		zcache_pages_zero--;
>>  		goto zero_fill;
>>  	}
>>  
>> @@ -922,6 +928,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>>  		zero_filled = true;
>>  		zsize = 0;
>>  		zpages = 0;
>> +		zcache_pages_zero--;
>>  	}
>>  
>>  	if (pampd_is_remote(pampd) && !zero_filled) {
>> -- 
>> 1.7.7.6
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
