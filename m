Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id A82596B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 01:10:14 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id na2so6843403lbb.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 22:10:14 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id x67si2429475wma.77.2016.06.17.22.10.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 22:10:13 -0700 (PDT)
Message-ID: <5764D72B.2080800@huawei.com>
Date: Sat, 18 Jun 2016 13:07:55 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix account pmd page to the process
References: <1466076971-24609-1-git-send-email-zhongjiang@huawei.com> <20160616154214.GA12284@dhcp22.suse.cz> <20160616154324.GN6836@dhcp22.suse.cz> <71df66ac-df29-9542-bfa9-7c94f374df5b@oracle.com> <20160616163119.GP6836@dhcp22.suse.cz> <bf76cc6c-a0da-98f9-4a89-0bb6161f5adf@oracle.com> <20160617122506.GC6534@node.shutemov.name> <8141c2df-5643-4ba9-42a5-5b536517cdee@oracle.com>
In-Reply-To: <8141c2df-5643-4ba9-42a5-5b536517cdee@oracle.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/6/17 23:39, Mike Kravetz wrote:
> On 06/17/2016 05:25 AM, Kirill A. Shutemov wrote:
>> From fd22922e7b4664e83653a84331f0a95b985bff0c Mon Sep 17 00:00:00 2001
>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Date: Fri, 17 Jun 2016 15:07:03 +0300
>> Subject: [PATCH] hugetlb: fix nr_pmds accounting with shared page tables
>>
>> We account HugeTLB's shared page table to all processes who share it.
>> The accounting happens during huge_pmd_share().
>>
>> If somebody populates pud entry under us, we should decrease pagetable's
>> refcount and decrease nr_pmds of the process.
>>
>> By mistake, I increase nr_pmds again in this case. :-/
>> It will lead to "BUG: non-zero nr_pmds on freeing mm: 2" on process'
>> exit.
>>
>> Let's fix this by increasing nr_pmds only when we're sure that the page
>> table will be used.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Nice,
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
>
> I agree that we do not necessarily need a back port.  I have not seen
> reports of people experiencing this race and seeing the BUG (on mm
> tear-down).
>
> zhongjiang, did someone actually hit the BUG?  Or, did you find it by
> code examination?
>
  just code examination.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
