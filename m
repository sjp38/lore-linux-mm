Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB30B6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 10:00:30 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n4so73106286lfb.3
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 07:00:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w7si5134481wjg.48.2016.09.16.07.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 07:00:29 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8GDwRgD132321
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 10:00:28 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25ghv7ryyh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 10:00:27 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rui.teng@linux.vnet.ibm.com>;
	Fri, 16 Sep 2016 07:58:56 -0600
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <57D83821.4090804@linux.intel.com>
 <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
 <57D97CAF.7080005@linux.intel.com>
From: Rui Teng <rui.teng@linux.vnet.ibm.com>
Date: Fri, 16 Sep 2016 21:58:48 +0800
MIME-Version: 1.0
In-Reply-To: <57D97CAF.7080005@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 9/15/16 12:37 AM, Dave Hansen wrote:
> On 09/14/2016 09:33 AM, Rui Teng wrote:
>>
>> How about return the size of page freed from dissolve_free_huge_page(),
>> and jump such step on pfn?
>
> That would be a nice improvement.
>
> But, as far as describing the initial problem, can you explain how the
> tail pages still ended up being PageHuge()?  Seems like dissolving the
> huge page should have cleared that.
>
I use the scripts of tools/testing/selftests/memory-hotplug/mem-on-
off-test.sh to test and reproduce this bug. And I printed the pfn range
on dissolve_free_huge_pages(). The sizes of the pfn range are always
4096, and the ranges are separated.
[   72.362427] start_pfn: 204800, end_pfn: 208896
[   72.371677] start_pfn: 2162688, end_pfn: 2166784
[   72.373945] start_pfn: 217088, end_pfn: 221184
[   72.383218] start_pfn: 2170880, end_pfn: 2174976
[   72.385918] start_pfn: 2306048, end_pfn: 2310144
[   72.388254] start_pfn: 2326528, end_pfn: 2330624

Sometimes, it will report a failure:
[   72.371690] memory offlining [mem 0x2100000000-0x210fffffff] failed

And sometimes, it will report following:
[   72.373956] Offlined Pages 4096

Whether the start_pfn and end_pfn of dissolve_free_huge_pages could be
*random*? If so, the range may not include any page head and start from
tail page, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
