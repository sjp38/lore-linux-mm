Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 13E6D6B0253
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:52:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w84so20226280wmg.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 08:52:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i9si26888656wjw.275.2016.09.20.08.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 08:52:40 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8KFmqDj103524
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:52:38 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25jkn4ych5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:52:38 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rui.teng@linux.vnet.ibm.com>;
	Tue, 20 Sep 2016 09:52:37 -0600
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <57D83821.4090804@linux.intel.com>
 <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
 <57D97CAF.7080005@linux.intel.com>
 <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
 <57DC1CE0.5070400@linux.intel.com>
 <7e642622-72ee-87f6-ceb0-890ce9c28382@linux.vnet.ibm.com>
 <57E14D64.6090609@linux.intel.com>
From: Rui Teng <rui.teng@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2016 23:52:25 +0800
MIME-Version: 1.0
In-Reply-To: <57E14D64.6090609@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <fc05ee3c-097f-709b-7484-1cadc9f3ce22@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 9/20/16 10:53 PM, Dave Hansen wrote:
> On 09/20/2016 07:45 AM, Rui Teng wrote:
>> On 9/17/16 12:25 AM, Dave Hansen wrote:
>>>
>>> That's an interesting data point, but it still doesn't quite explain
>>> what is going on.
>>>
>>> It seems like there might be parts of gigantic pages that have
>>> PageHuge() set on tail pages, while other parts don't.  If that's true,
>>> we have another bug and your patch just papers over the issue.
>>>
>>> I think you really need to find the root cause before we apply this
>>> patch.
>>>
>> The root cause is the test scripts(tools/testing/selftests/memory-
>> hotplug/mem-on-off-test.sh) changes online/offline status on memory
>> blocks other than page header. It will *randomly* select 10% memory
>> blocks from /sys/devices/system/memory/memory*, and change their
>> online/offline status.
>
> Ahh, that does explain it!  Thanks for digging into that!
>
>> That's why we need a PageHead() check now, and why this problem does
>> not happened on systems with smaller huge page such as 16M.
>>
>> As far as the PageHuge() set, I think PageHuge() will return true for
>> all tail pages. Because it will get the compound_head for tail page,
>> and then get its huge page flag.
>>     page = compound_head(page);
>>
>> And as far as the failure message, if one memory block is in use, it
>> will return failure when offline it.
>
> That's good, but aren't we still left with a situation where we've
> offlined and dissolved the _middle_ of a gigantic huge page while the
> head page is still in place and online?
>
> That seems bad.
>
What about refusing to change the status for such memory block, if it
contains a huge page which larger than itself? (function
memory_block_action())

I think it will not affect the hot-plug function too much. We can
change the nr_hugepages to zero first, if we really want to hot-plug a
memory.

And I also found that the __test_page_isolated_in_pageblock() function
can not handle a gigantic page well. It will cause a device busy error
later. I am still investigating on that.

Any suggestion?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
