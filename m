Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 333CE6B0082
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 12:25:19 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id u20so20642998oif.11
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 09:25:19 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z7si256630obw.31.2015.02.28.09.25.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 09:25:18 -0800 (PST)
Message-ID: <54F1F9F3.3060406@oracle.com>
Date: Sat, 28 Feb 2015 09:25:07 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/3] hugetlbfs: coordinate global and subpool reserve accounting
References: <013001d05306$31c8b250$955a16f0$@alibaba-inc.com>
In-Reply-To: <013001d05306$31c8b250$955a16f0$@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davidlohr@hp.com, 'Aneesh Kumar' <aneesh.kumar@linux.vnet.ibm.com>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>

On 02/27/2015 07:25 PM, Hillf Danton wrote:
>> @@ -3444,10 +3445,14 @@ int hugetlb_reserve_pages(struct inode *inode,
>>   	 * Check enough hugepages are available for the reservation.
>>   	 * Hand the pages back to the subpool if there are not
>>   	 */
>
> Better if comment is updated correspondingly.
> Hillf

Thanks Hillf.  I'll also take a look at other comments in the area
of 'accounting'.  As I discovered, it is only a matter of adjusting
the accounting to support reservation of pages for the entire filesystem.
-- 
Mike Kravetz

>> -	ret = hugetlb_acct_memory(h, chg);
>> -	if (ret < 0) {
>> -		hugepage_subpool_put_pages(spool, chg);
>> -		goto out_err;
>> +	if (subpool_reserved(spool))
>> +		ret = 0;
>> +	else {
>> +		ret = hugetlb_acct_memory(h, chg);
>> +		if (ret < 0) {
>> +			hugepage_subpool_put_pages(spool, chg);
>> +			goto out_err;
>> +		}
>>   	}
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
