Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B19286B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 12:25:06 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id mi5so159544668pab.2
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 09:25:06 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y27si46072866pfd.227.2016.09.16.09.25.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Sep 2016 09:25:05 -0700 (PDT)
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <57D83821.4090804@linux.intel.com>
 <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
 <57D97CAF.7080005@linux.intel.com>
 <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57DC1CE0.5070400@linux.intel.com>
Date: Fri, 16 Sep 2016 09:25:04 -0700
MIME-Version: 1.0
In-Reply-To: <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 09/16/2016 06:58 AM, Rui Teng wrote:
> On 9/15/16 12:37 AM, Dave Hansen wrote:
>> On 09/14/2016 09:33 AM, Rui Teng wrote:
>> But, as far as describing the initial problem, can you explain how the
>> tail pages still ended up being PageHuge()?  Seems like dissolving the
>> huge page should have cleared that.
>>
> I use the scripts of tools/testing/selftests/memory-hotplug/mem-on-
> off-test.sh to test and reproduce this bug. And I printed the pfn range
> on dissolve_free_huge_pages(). The sizes of the pfn range are always
> 4096, and the ranges are separated.
> [   72.362427] start_pfn: 204800, end_pfn: 208896
> [   72.371677] start_pfn: 2162688, end_pfn: 2166784
> [   72.373945] start_pfn: 217088, end_pfn: 221184
> [   72.383218] start_pfn: 2170880, end_pfn: 2174976
> [   72.385918] start_pfn: 2306048, end_pfn: 2310144
> [   72.388254] start_pfn: 2326528, end_pfn: 2330624
> 
> Sometimes, it will report a failure:
> [   72.371690] memory offlining [mem 0x2100000000-0x210fffffff] failed
> 
> And sometimes, it will report following:
> [   72.373956] Offlined Pages 4096
> 
> Whether the start_pfn and end_pfn of dissolve_free_huge_pages could be
> *random*? If so, the range may not include any page head and start from
> tail page, right?

That's an interesting data point, but it still doesn't quite explain
what is going on.

It seems like there might be parts of gigantic pages that have
PageHuge() set on tail pages, while other parts don't.  If that's true,
we have another bug and your patch just papers over the issue.

I think you really need to find the root cause before we apply this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
