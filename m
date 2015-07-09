Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id BE96B6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 21:25:38 -0400 (EDT)
Received: by pddu5 with SMTP id u5so67733625pdd.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 18:25:38 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id kl10si6533284pbd.72.2015.07.08.18.25.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Jul 2015 18:25:37 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 9 Jul 2015 06:55:32 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 44AA0E0054
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 06:59:20 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t691PTdX61997140
	for <linux-mm@kvack.org>; Thu, 9 Jul 2015 06:55:29 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t691PSJ9009959
	for <linux-mm@kvack.org>; Thu, 9 Jul 2015 06:55:29 +0530
Date: Thu, 9 Jul 2015 09:25:27 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memblock: WARN_ON when nid differs from overlap region
Message-ID: <20150709012527.GA5958@richard>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1436342488-19851-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1507081750240.16585@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507081750240.16585@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Wed, Jul 08, 2015 at 05:54:18PM -0700, David Rientjes wrote:
>On Wed, 8 Jul 2015, Wei Yang wrote:
>
>> Each memblock_region has nid to indicates the Node ID of this range. For
>> the overlap case, memblock_add_range() inserts the lower part and leave the
>> upper part as indicated in the overlapped region.
>> 
>> If the nid of the new range differs from the overlapped region, the
>> information recorded is not correct.
>> 
>> This patch adds a WARN_ON when the nid of the new range differs from the
>> overlapped region.
>> 
>> ---
>> 
>> I am not familiar with the lower level topology, maybe this case will not
>> happen. 
>> 
>> If current implementation is based on the assumption, that overlapped
>> ranges' nid and flags are the same, I would suggest to add a comment to
>> indicates this background.
>> 
>> If the assumption is not correct, I suggest to add a WARN_ON or BUG_ON to
>> indicates this case.
>> 
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> ---
>>  mm/memblock.c |    3 +++
>>  1 file changed, 3 insertions(+)
>> 
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 9318b56..09efe70 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -540,6 +540,9 @@ repeat:
>>  		 * area, insert that portion.
>>  		 */
>>  		if (rbase > base) {
>> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>> +			WARN_ON(nid != memblock_get_region_node(rgn));
>> +#endif
>>  			nr_new++;
>>  			if (insert)
>>  				memblock_insert_region(type, i++, base,
>
>I think the assertion that nid should match memblock_get_region_node() of 
>the overlapped region is correct.  It only functionally makes a difference 
>if insert == true, but I don't think there's harm in verifying it 
>regardless.
>
>Acked-by: David Rientjes <rientjes@google.com>
>
>I think your supplemental to the changelog suggests that you haven't seen 
>this actually occur, but in the off chance that you have then it would be 
>interesting to see it.

Hi David,

Thanks for your comments.

Yes, I don't see this actually occur. This is a guard to indicates if the
lower level hardware is not functioning well.

Also, as the supplemental in the change log mentioned, the flags of the
overlapped region needs to be checked too. If you think this is proper, I
would like to form a patch to have the assertion on the flags. 

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
