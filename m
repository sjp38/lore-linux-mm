Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 447216B0038
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 00:29:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g202so100942181pfb.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 21:29:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i127si6955022qkd.319.2016.09.01.21.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 21:29:21 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u824OMbg069264
	for <linux-mm@kvack.org>; Fri, 2 Sep 2016 00:29:21 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2569eedn7x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Sep 2016 00:29:20 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 2 Sep 2016 14:29:18 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id F2D8D2BB0055
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 14:29:15 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u824TFEC7864704
	for <linux-mm@kvack.org>; Fri, 2 Sep 2016 14:29:15 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u824TF6W029737
	for <linux-mm@kvack.org>; Fri, 2 Sep 2016 14:29:15 +1000
Date: Fri, 02 Sep 2016 09:59:12 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: Move definition of 'zone_names' array into mmzone.h
References: <1472613950-16867-1-git-send-email-khandual@linux.vnet.ibm.com> <20160831141033.8f617b6000bf129bbc40bda7@linux-foundation.org>
In-Reply-To: <20160831141033.8f617b6000bf129bbc40bda7@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57C90018.70507@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/01/2016 02:40 AM, Andrew Morton wrote:
> On Wed, 31 Aug 2016 08:55:49 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
> 
>> zone_names[] is used to identify any zone given it's index which
>> can be used in many other places. So moving the definition into
>> include/linux/mmzone.h for broader access.
>>
>> ...
>>
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -341,6 +341,23 @@ enum zone_type {
>>  
>>  };
>>  
>> +static char * const zone_names[__MAX_NR_ZONES] = {
>> +#ifdef CONFIG_ZONE_DMA
>> +	 "DMA",
>> +#endif
>> +#ifdef CONFIG_ZONE_DMA32
>> +	 "DMA32",
>> +#endif
>> +	 "Normal",
>> +#ifdef CONFIG_HIGHMEM
>> +	 "HighMem",
>> +#endif
>> +	 "Movable",
>> +#ifdef CONFIG_ZONE_DEVICE
>> +	 "Device",
>> +#endif
>> +};
>> +
>>  #ifndef __GENERATING_BOUNDS_H
>>  
>>  struct zone {
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3fbe73a..8e2261c 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -207,23 +207,6 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
>>  
>>  EXPORT_SYMBOL(totalram_pages);
>>  
>> -static char * const zone_names[MAX_NR_ZONES] = {
>> -#ifdef CONFIG_ZONE_DMA
>> -	 "DMA",
>> -#endif
>> -#ifdef CONFIG_ZONE_DMA32
>> -	 "DMA32",
>> -#endif
>> -	 "Normal",
>> -#ifdef CONFIG_HIGHMEM
>> -	 "HighMem",
>> -#endif
>> -	 "Movable",
>> -#ifdef CONFIG_ZONE_DEVICE
>> -	 "Device",
>> -#endif
>> -};
>> -
>>  char * const migratetype_names[MIGRATE_TYPES] = {
>>  	"Unmovable",
>>  	"Movable",
> 
> This is worrisome.  On some (ancient) compilers, this will produce a
> copy of that array into each compilation unit which includes mmzone.h.
> 
> On smarter compilers, it will produce a copy of the array in each
> compilation unit which *uses* zone_names[].
> 
> On even smarter compilers (and linkers!), only one copy of zone_names[]
> will exist in vmlinux.
> 
> I don't know if gcc is an "even smarter compiler" and I didn't check,
> and I didn't check which gcc versions are even smarter.  I'd rather not
> have to ;) It is risky.
> 
> So, let's just make it non-static and add a declaration into mmzone.h,
> please.
> 

I understand your concern, will change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
