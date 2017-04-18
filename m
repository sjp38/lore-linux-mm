Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 142EB6B0038
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 22:47:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x61so17402529wrb.8
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 19:47:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 59si18630651wrs.18.2017.04.17.19.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 19:47:02 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I2hYJw018880
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 22:47:01 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29vvwwe3py-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 22:47:00 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 18 Apr 2017 08:16:57 +0530
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3I2knP517432592
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 08:16:49 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3I2ksCE028864
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 08:16:54 +0530
Subject: Re: [PATCH V2] mm/madvise: Move up the behavior parameter validation
References: <20170413092008.5437-1-khandual@linux.vnet.ibm.com>
 <20170414135141.15340-1-khandual@linux.vnet.ibm.com>
 <20170417052729.GA23423@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 18 Apr 2017 08:16:53 +0530
MIME-Version: 1.0
In-Reply-To: <20170417052729.GA23423@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <c9428299-543c-128f-b7c6-71669a1aa20e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 04/17/2017 10:57 AM, Naoya Horiguchi wrote:
> On Fri, Apr 14, 2017 at 07:21:41PM +0530, Anshuman Khandual wrote:
>> The madvise_behavior_valid() function should be called before
>> acting upon the behavior parameter. Hence move up the function.
>> This also includes MADV_SOFT_OFFLINE and MADV_HWPOISON options
>> as valid behavior parameter for the system call madvise().
>>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>> Changes in V2:
>>
>> Added CONFIG_MEMORY_FAILURE check before using MADV_SOFT_OFFLINE
>> and MADV_HWPOISONE constants.
>>
>>  mm/madvise.c | 9 +++++++--
>>  1 file changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index efd4721..ccff186 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -694,6 +694,10 @@ static int madvise_inject_error(int behavior,
>>  #endif
>>  	case MADV_DONTDUMP:
>>  	case MADV_DODUMP:
>> +#ifdef CONFIG_MEMORY_FAILURE
>> +	case MADV_SOFT_OFFLINE:
>> +	case MADV_HWPOISON:
>> +#endif
>>  		return true;
>>  
>>  	default:
>> @@ -767,12 +771,13 @@ static int madvise_inject_error(int behavior,
>>  	size_t len;
>>  	struct blk_plug plug;
>>  
>> +	if (!madvise_behavior_valid(behavior))
>> +		return error;
>> +
>>  #ifdef CONFIG_MEMORY_FAILURE
>>  	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
>>  		return madvise_inject_error(behavior, start, start + len_in);
>>  #endif
>> -	if (!madvise_behavior_valid(behavior))
>> -		return error;
> 
> Hi Anshuman,
> 
> I'm wondering why current code calls madvise_inject_error() at the beginning
> of SYSCALL_DEFINE3(madvise), without any boundary checks of address or length.
> I agree to checking madvise_behavior_valid for MADV_{HWPOISON,SOFT_OFFLINE},
> but checking boundary of other arguments is also helpful, so how about moving
> down the existing #ifdef block like below?

Sure, will fold both the patches together and send it out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
