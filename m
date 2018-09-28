Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5B0F8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 18:43:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i6-v6so8597103pfo.18
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 15:43:21 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id b61-v6si2794884plc.276.2018.09.28.15.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 15:43:20 -0700 (PDT)
Subject: Re: [PATCH] mm: enforce THP for VM_NOHUGEPAGE dax mappings
References: <1538173916-95849-1-git-send-email-yang.shi@linux.alibaba.com>
 <CAPcyv4jdTWoJMSPuxso=8fu8nGOrmbBPYxkJvsuEDfJSYvsDWg@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <def53b95-804d-d3c5-179c-e1862a5d8e8c@linux.alibaba.com>
Date: Fri, 28 Sep 2018 15:43:04 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jdTWoJMSPuxso=8fu8nGOrmbBPYxkJvsuEDfJSYvsDWg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 9/28/18 3:36 PM, Dan Williams wrote:
> On Fri, Sep 28, 2018 at 3:34 PM <yang.shi@linux.alibaba.com> wrote:
>> commit baabda261424517110ea98c6651f632ebf2561e3 ("mm: always enable thp
>> for dax mappings") says madvise hguepage policy makes less sense for
>> dax, and force enabling thp for dax mappings in all cases, even though
>> THP is set to "never".
>>
>> However, transparent_hugepage_enabled() may return false if
>> VM_NOHUGEPAGE is set even though the mapping is dax.
>>
>> So, move is_vma_dax() check to the very beginning to enforce THP for dax
>> mappings in all cases.
>>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>> I didn't find anyone mention the check should be before VM_NOHUGEPAGE in
>> the review for Dan's original patch. And, that patch commit log states
>> clearly that THP for dax mapping for all cases even though THP is never.
>> So, I'm supposed it should behave in this way.
> No, if someone explicitly does MADV_NOHUGEPAGE then the kernel should
> honor that, even if the mapping is DAX.

Thanks for confirming this. Actually, I had the same question before I 
came up with this patch. "all cases" sounds a little bit misleading.
