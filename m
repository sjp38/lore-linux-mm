Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE7CD6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:16:06 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k14so13395704pga.5
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:16:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y12si18930398pgo.307.2017.04.24.06.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:16:06 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ODEn4U134945
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:16:05 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a02g3c7g1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:16:05 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 24 Apr 2017 14:16:03 +0100
Subject: Re: [RFC 1/2] mm: Uncharge poisoned pages
References: <1492680362-24941-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1492680362-24941-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170424090530.GA31900@hori1.linux.bs1.fc.nec.co.jp>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 24 Apr 2017 15:15:59 +0200
MIME-Version: 1.0
In-Reply-To: <20170424090530.GA31900@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <bd92f14f-e438-030d-3a7c-98994dab2035@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 24/04/2017 11:05, Naoya Horiguchi wrote:
> On Thu, Apr 20, 2017 at 11:26:01AM +0200, Laurent Dufour wrote:
>> When page are poisoned, they should be uncharged from the root memory
>> cgroup.
> 
> Could you include some information about what problem this patch tries
> to solve?
> # I know that you already explain it in patch 0/2, so you can simply
> # copy from it.

Thanks for the review, I will add the BUG's output in the next version.

> 
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  mm/memory-failure.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 27f7210e7fab..00bd39d3d4cb 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -530,6 +530,7 @@ static const char * const action_page_types[] = {
>>  static int delete_from_lru_cache(struct page *p)
>>  {
>>  	if (!isolate_lru_page(p)) {
>> +		memcg_kmem_uncharge(p, 0);
> 
> This function is supposed to be called with if (memcg_kmem_enabled()) check,
> so could you do like below?
> 
> +		if (memcg_kmem_enabled())
> +			memcg_kmem_uncharge(p, 0);
> 
> 
> And I feel that we can call this function outside if (!isolate_lru_page(p))
> block, because isolate_lru_page could fail and then the error page is left
> incompletely isolated. Such error page has PageHWPoison set, so I guess that
> the reported bug still triggers on such case.

I move the call to memcg_kmem_uncharge() outside if
(!isolate_lru_page(p)) and it seems to work as well.

I'll wait a bit for any other review to come and I'll send a new version.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
