Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05998C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:37:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8563720B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:37:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="OiLr8mXL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8563720B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D6346B0005; Mon,  5 Aug 2019 13:37:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 085B16B0006; Mon,  5 Aug 2019 13:37:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8F766B0007; Mon,  5 Aug 2019 13:37:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C72786B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:37:13 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id m26so93018265ioh.17
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:37:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hT6KvXWHsB1KFIxDjmguE5kZ2emdManS6SuK/ap0TkI=;
        b=fj5JBrnsai2pSedtuBBYTBHY49hd3us0Ch+tnd1bbFnAZk0ixzOHpw7J/sX/sYVh6X
         YPugmU6NtAPujN8kBxCB1fBjHsCBHlgnEoNVixvVEmqFcggxua/EEMFcOxWHaeFa7Ej8
         TW5WyjuSWZAAPO0pAgmlPVYVF6cMA5hr0u5V2CaUWC8I4YCx8/DnvHIghifAE1/Izc9E
         UC2Tvvqf8/vHzXfOa5W+V6mj9iEScmrlsgjOUbrCqt9kyRp8qhgdA6zihVUjAGbjmnec
         +Hxj+Tz3GMJNu1r4Q5GgLCpMC+fxd0YzukM18dbBfhl0GfYZvJD1nIBWDw0FW7mRCL4k
         tv1w==
X-Gm-Message-State: APjAAAVzEc1dpR5VGAkYqeyLunuhcFFlqpqykhypp25JEVUnhEcTAch5
	mGEvA6CXdomL75nzJzSYN50Z0jYRD8Cw3TZHxC9v3Vu0OwJ7kUihj6jkFgx1/t5RGa2QOPZhefQ
	UW+QjgBfAFwVXjHIo9rYGZAAIIPpSdvUZM8WJ6VWGHi7eYqh2PGHojgBK65t/1X+aOg==
X-Received: by 2002:a6b:c9d8:: with SMTP id z207mr135880507iof.184.1565026633514;
        Mon, 05 Aug 2019 10:37:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOPYZjx73ZsYBy/jA6nxAqQJAKvOJydE8VUeXXYG9mNUkZc6R6xdkKNbf7NoFbIlR/FmqR
X-Received: by 2002:a6b:c9d8:: with SMTP id z207mr135880425iof.184.1565026632446;
        Mon, 05 Aug 2019 10:37:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565026632; cv=none;
        d=google.com; s=arc-20160816;
        b=nQhzDB8N2c3VbZ2XkOyfOdthsBU7/AVfF24vh0ATmxRUwC1UwhO7qGqPXZwhvtsBq/
         swrN4vlnd3Q0YAOzNukzK7D/Y9MQCe2/LbWmC1nFXYmF0qD4tnAL+01f4gtqiF2u+DWO
         9tjhOVECStGC7elvcNZmFz2rafqWeNQ2Os5MvKf8dEoiD4Ai3kx/NzXTPwoo4AwhVWvU
         J+WwxzUrRGzekObDEEnvmWtilv5y9EBEW6HCluzy9l/bN7ksC+RZwV0pegP3K3nVvtL2
         Y4U8+GTVOD+2wWVK9RtJPxU1oGQq5TnYxHvV7ogb/R/BjEZxwvs9J0MWqLPGdxnduHtB
         H06g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=hT6KvXWHsB1KFIxDjmguE5kZ2emdManS6SuK/ap0TkI=;
        b=J6gbKUkJgUMSACPT3mzmM/IbO7L75gim5BLx7P5qjkZyFoUAIXEJ+BC01fdiaMGC2Q
         trUceFVy9M75TTff/Sy+Q/B9eYbj4ySAQf2Y4941gS3BM6Xzl6Qa0WjF/xgZJPkhaKuT
         h6WW76oN9jMIPdDEnxahBPWDRXFkdjqKjm8swZsmfcYdfoq7s6Q7c0vKzt54GGPfODOS
         boWVtCJWc/Lz1/Qetdb41ubtZghKQwDDeaeIxUBFuIHmLUjHcKg1t1Qaq55GjjQaTTfs
         JWuJx/uSmM7jHjuODL7PqdMZ9SSL4lK1vi7Icvr3ob1hWZPjCqiryAuO3xz4lw2lidmh
         FOPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OiLr8mXL;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i8si97236327ioh.19.2019.08.05.10.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 10:37:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OiLr8mXL;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75HNUZP152617;
	Mon, 5 Aug 2019 17:37:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=hT6KvXWHsB1KFIxDjmguE5kZ2emdManS6SuK/ap0TkI=;
 b=OiLr8mXLp9u31cORyoaaREIyIKORwjH13EN6bFCVbvclkkezmlDizBdBEBu80X0kZjPU
 6mdIL2E/cEOnc3TE/qhc12FFff7EJdbvMBpF5ksrqkiJ9R0ZZ9mFkHlo4ZNFHTzsOivK
 FgsDPX6yJI57BsElVQA6iGSPDLeQDZMQsXRw1+SDeHaGs1h33GOXnio164dS2DHbtcwd
 wfJidCKwoYcPLiY5RHvmdUKJcbXU+/NzQXxkXYbZjL9DebV+0i27Gr7zaipblc4Okx3Z
 pBlVaXQtentfLeoD93kLiCyCOUrJIrSTQcmhF8yWbRR1EJqCl1JVq8V5QmOBZCw2MNyL OQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u527pgnch-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 17:37:03 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75HR43h045369;
	Mon, 5 Aug 2019 17:37:03 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2u50abyfq1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 17:37:03 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x75Havpg013594;
	Mon, 5 Aug 2019 17:36:57 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 10:36:56 -0700
Subject: =?UTF-8?Q?Re=3a_=5bMM_Bug=3f=5d_mmap=28=29_triggers_SIGBUS_while_do?=
 =?UTF-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQgaHVn?=
 =?UTF-8?Q?epage_in_background?=
To: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Li Wang <liwang@redhat.com>,
        Linux-MM <linux-mm@kvack.org>, LTP List <ltp@lists.linux.it>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        Cyril Hrubis <chrubis@suse.cz>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
 <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
 <20190802041557.GA16274@hori.linux.bs1.fc.nec.co.jp>
 <54a5c9f5-eade-0d8f-24f9-bff6f19d4905@oracle.com>
 <20190805085740.GC7597@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <7d78f6b9-afb8-79d1-003e-56de58fded00@oracle.com>
Date: Mon, 5 Aug 2019 10:36:55 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190805085740.GC7597@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908050186
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908050186
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 1:57 AM, Michal Hocko wrote:
> On Fri 02-08-19 10:42:33, Mike Kravetz wrote:
>> On 8/1/19 9:15 PM, Naoya Horiguchi wrote:
>>> On Thu, Aug 01, 2019 at 05:19:41PM -0700, Mike Kravetz wrote:
>>>> There appears to be a race with hugetlb_fault and try_to_unmap_one of
>>>> the migration path.
>>>>
>>>> Can you try this patch in your environment?  I am not sure if it will
>>>> be the final fix, but just wanted to see if it addresses issue for you.
>>>>
>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>>> index ede7e7f5d1ab..f3156c5432e3 100644
>>>> --- a/mm/hugetlb.c
>>>> +++ b/mm/hugetlb.c
>>>> @@ -3856,6 +3856,20 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>>>>  
>>>>  		page = alloc_huge_page(vma, haddr, 0);
>>>>  		if (IS_ERR(page)) {
>>>> +			/*
>>>> +			 * We could race with page migration (try_to_unmap_one)
>>>> +			 * which is modifying page table with lock.  However,
>>>> +			 * we are not holding lock here.  Before returning
>>>> +			 * error that will SIGBUS caller, get ptl and make
>>>> +			 * sure there really is no entry.
>>>> +			 */
>>>> +			ptl = huge_pte_lock(h, mm, ptep);
>>>> +			if (!huge_pte_none(huge_ptep_get(ptep))) {
>>>> +				ret = 0;
>>>> +				spin_unlock(ptl);
>>>> +				goto out;
>>>> +			}
>>>> +			spin_unlock(ptl);
>>>
>>> Thanks you for investigation, Mike.
>>> I tried this change and found no SIGBUS, so it works well.
>>>
>>> I'm still not clear about how !huge_pte_none() becomes true here,
>>> because we enter hugetlb_no_page() only when huge_pte_none() is non-null
>>> and (racy) try_to_unmap_one() from page migration should convert the
>>> huge_pte into a migration entry, not null.
>>
>> Thanks for taking a look Naoya.
>>
>> In try_to_unmap_one(), there is this code block:
>>
>> 		/* Nuke the page table entry. */
>> 		flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
>> 		if (should_defer_flush(mm, flags)) {
>> 			/*
>> 			 * We clear the PTE but do not flush so potentially
>> 			 * a remote CPU could still be writing to the page.
>> 			 * If the entry was previously clean then the
>> 			 * architecture must guarantee that a clear->dirty
>> 			 * transition on a cached TLB entry is written through
>> 			 * and traps if the PTE is unmapped.
>> 			 */
>> 			pteval = ptep_get_and_clear(mm, address, pvmw.pte);
>>
>> 			set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
>> 		} else {
>> 			pteval = ptep_clear_flush(vma, address, pvmw.pte);
>> 		}
>>
>> That happens before setting the migration entry.  Therefore, for a period
>> of time the pte is NULL (huge_pte_none() returns true).
>>
>> try_to_unmap_one holds the page table lock, but hugetlb_fault does not take
>> the lock to 'optimistically' check huge_pte_none().  When huge_pte_none
>> returns true, it calls hugetlb_no_page which is where we try to allocate
>> a page and fails.
>>
>> Does that make sense, or am I missing something?
>>
>> The patch checks for this specific condition: someone changing the pte
>> from NULL to non-NULL while holding the lock.  I am not sure if this is
>> the best way to fix.  But, it may be the easiest.
> 
> Please add a comment to explain this because this is quite subtle and
> tricky. Unlike the regular page fault hugetlb_no_page is protected by a
> large lock so a retry check seems unexpected.

Will do.

Fixing up hugetlbfs locking is still 'on my list'.  There are known issues.
The last RFC/attempt was this:
http://lkml.kernel.org/r/20190201221705.15622-1-mike.kravetz@oracle.com
I believe that patch would have handled this issue.

However, as mentioned above it may better to just patch this issue exposed
by LTP and work on the more comprehensive change in the background.
-- 
Mike Kravetz

