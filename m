Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0116B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:32:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 44so1819676wry.5
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 02:32:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i24si902211wrc.170.2017.04.28.02.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 02:32:39 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3S9T0LW096137
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:32:38 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a3jv3j284-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:32:37 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 28 Apr 2017 10:32:36 +0100
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493171698.4828.1.camel@gmail.com>
 <20170426023410.GA11619@hori1.linux.bs1.fc.nec.co.jp>
 <1493178300.4828.5.camel@gmail.com>
 <20170426044608.GA32451@hori1.linux.bs1.fc.nec.co.jp>
 <1493197141.16329.1.camel@gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 28 Apr 2017 11:32:31 +0200
MIME-Version: 1.0
In-Reply-To: <1493197141.16329.1.camel@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <f3dce7ae-1209-a6ec-d4ec-49325471fd59@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 26/04/2017 10:59, Balbir Singh wrote:
> On Wed, 2017-04-26 at 04:46 +0000, Naoya Horiguchi wrote:
>> On Wed, Apr 26, 2017 at 01:45:00PM +1000, Balbir Singh wrote:
>>>>>>  static int delete_from_lru_cache(struct page *p)
>>>>>>  {
>>>>>> +	if (memcg_kmem_enabled())
>>>>>> +		memcg_kmem_uncharge(p, 0);
>>>>>> +
>>>>>
>>>>> The changelog is not quite clear, so we are uncharging a page using
>>>>> memcg_kmem_uncharge for a page in swap cache/page cache?
>>>>
>>>> Hi Balbir,
>>>>
>>>> Yes, in the normal page lifecycle, uncharge is done in page free time.
>>>> But in memory error handling case, in-use pages (i.e. swap cache and page
>>>> cache) are removed from normal path and they don't pass page freeing code.
>>>> So I think that this change is to keep the consistent charging for such a case.
>>>
>>> I agree we should uncharge, but looking at the API name, it seems to
>>> be for kmem pages, why are we not using mem_cgroup_uncharge()? Am I missing
>>> something?
>>
>> Thank you for pointing out.
>> Actually I had the same question and this surely looks strange.
>> But simply calling mem_cgroup_uncharge() here doesn't work because it
>> assumes that page_refcount(p) == 0, which is not true in hwpoison context.
>> We need some other clearer way or at least some justifying comment about
>> why this is ok.
>>
> 
> We should call mem_cgroup_uncharge() after isolate_lru_page()/put_page().

Thanks for the review Naoya and Balbir,

I changed the patch to call mem_cgroup_uncharge() once
isolate_lru_page() succeeded, but before calling put_page().
It seems to work fine.

> We could check if page_count() is 0 or force if required (!MF_RECOVERED &&
> !MF_DELAYED). We could even skip the VM_BUG_ON if the page is poisoned.

This doesn't seem to be needed. Am I still missing something here ?

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
