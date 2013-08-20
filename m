Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 4DE1F6B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 19:39:56 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 21 Aug 2013 09:36:33 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 030BA2CE8054
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 09:39:41 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7KNdQcB8716570
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 09:39:30 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7KNdaFs015587
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 09:39:37 +1000
Date: Wed, 21 Aug 2013 07:39:35 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/4] mm/pgtable: Fix continue to preallocate pmds even
 if failure occurrence
Message-ID: <20130820233935.GA1298@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130820160418.5639c4f9975b84dc8dede014@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130820160418.5639c4f9975b84dc8dede014@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 20, 2013 at 04:04:18PM -0700, Andrew Morton wrote:
>On Tue, 20 Aug 2013 14:54:53 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>
>> preallocate_pmds will continue to preallocate pmds even if failure
>> occurrence, and then free all the preallocate pmds if there is
>> failure, this patch fix it by stop preallocate if failure occurrence
>> and go to free path.
>>
>> ...
>>
>> --- a/arch/x86/mm/pgtable.c
>> +++ b/arch/x86/mm/pgtable.c
>> @@ -196,21 +196,18 @@ static void free_pmds(pmd_t *pmds[])
>>  static int preallocate_pmds(pmd_t *pmds[])
>>  {
>>  	int i;
>> -	bool failed = false;
>>  
>>  	for(i = 0; i < PREALLOCATED_PMDS; i++) {
>>  		pmd_t *pmd = (pmd_t *)__get_free_page(PGALLOC_GFP);
>>  		if (pmd == NULL)
>> -			failed = true;
>> +			goto err;
>>  		pmds[i] = pmd;
>>  	}
>>  
>> -	if (failed) {
>> -		free_pmds(pmds);
>> -		return -ENOMEM;
>> -	}
>> -
>>  	return 0;
>> +err:
>> +	free_pmds(pmds);
>> +	return -ENOMEM;
>>  }
>

Hi Andrew,

>Nope.  If the error path is taken, free_pmds() will free uninitialised
>items from pmds[], which is a local in pgd_alloc() and contains random
>stack junk.  The kernel will crash.
>
>You could pass an nr_pmds argument to free_pmds(), or zero out the
>remaining items on the error path.  However, although the current code
>is a bit kooky, I don't see that it is harmful in any way.
>

There is a check in free_pmds():

if (pmds[i])
	free_page((unsigned long)pmds[i]);

which will avoid the issue you mentioned.

In addition, the codes in pgd_alloc will skip free pmds if preallocate pmds 
failure which will avoid free pmds twice. Am I miss something? ;-)

Regards,
Wanpeng Li 

>> Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
>
>Ahem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
