Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE6EF6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 10:53:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c84so40446941pfj.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 07:53:26 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id yo4si29889012pab.139.2016.09.20.07.53.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 07:53:25 -0700 (PDT)
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <57D83821.4090804@linux.intel.com>
 <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
 <57D97CAF.7080005@linux.intel.com>
 <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
 <57DC1CE0.5070400@linux.intel.com>
 <7e642622-72ee-87f6-ceb0-890ce9c28382@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57E14D64.6090609@linux.intel.com>
Date: Tue, 20 Sep 2016 07:53:24 -0700
MIME-Version: 1.0
In-Reply-To: <7e642622-72ee-87f6-ceb0-890ce9c28382@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 09/20/2016 07:45 AM, Rui Teng wrote:
> On 9/17/16 12:25 AM, Dave Hansen wrote:
>>
>> That's an interesting data point, but it still doesn't quite explain
>> what is going on.
>>
>> It seems like there might be parts of gigantic pages that have
>> PageHuge() set on tail pages, while other parts don't.  If that's true,
>> we have another bug and your patch just papers over the issue.
>>
>> I think you really need to find the root cause before we apply this
>> patch.
>>
> The root cause is the test scripts(tools/testing/selftests/memory-
> hotplug/mem-on-off-test.sh) changes online/offline status on memory
> blocks other than page header. It will *randomly* select 10% memory
> blocks from /sys/devices/system/memory/memory*, and change their
> online/offline status.

Ahh, that does explain it!  Thanks for digging into that!

> That's why we need a PageHead() check now, and why this problem does
> not happened on systems with smaller huge page such as 16M.
> 
> As far as the PageHuge() set, I think PageHuge() will return true for
> all tail pages. Because it will get the compound_head for tail page,
> and then get its huge page flag.
>     page = compound_head(page);
> 
> And as far as the failure message, if one memory block is in use, it
> will return failure when offline it.

That's good, but aren't we still left with a situation where we've
offlined and dissolved the _middle_ of a gigantic huge page while the
head page is still in place and online?

That seems bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
