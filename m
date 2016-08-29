Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 547B2830E7
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 04:53:14 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so256669838pad.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 01:53:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u5si38117210pau.218.2016.08.29.01.53.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 01:53:13 -0700 (PDT)
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
 <57C3F72C.6030405@linux.vnet.ibm.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <3b8deaf7-2e7b-ff22-be72-31b1a7ebb3eb@intel.com>
Date: Mon, 29 Aug 2016 16:53:09 +0800
MIME-Version: 1.0
In-Reply-To: <57C3F72C.6030405@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>
Cc: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On 08/29/2016 04:49 PM, Anshuman Khandual wrote:
> On 08/29/2016 12:01 PM, Aaron Lu wrote:
>> The global zero page is used to satisfy an anonymous read fault. If
>> THP(Transparent HugePage) is enabled then the global huge zero page is used.
>> The global huge zero page uses an atomic counter for reference counting
>> and is allocated/freed dynamically according to its counter value.
>>
>> CPU time spent on that counter will greatly increase if there are
>> a lot of processes doing anonymous read faults. This patch proposes a
>> way to reduce the access to the global counter so that the CPU load
>> can be reduced accordingly.
>>
>> To do this, a new flag of the mm_struct is introduced: MMF_USED_HUGE_ZERO_PAGE.
>> With this flag, the process only need to touch the global counter in
>> two cases:
>> 1 The first time it uses the global huge zero page;
>> 2 The time when mm_user of its mm_struct reaches zero.
>>
>> Note that right now, the huge zero page is eligible to be freed as soon
>> as its last use goes away.  With this patch, the page will not be
>> eligible to be freed until the exit of the last process from which it
>> was ever used.
>>
>> And with the use of mm_user, the kthread is not eligible to use huge
>> zero page either. Since no kthread is using huge zero page today, there
>> is no difference after applying this patch. But if that is not desired,
>> I can change it to when mm_count reaches zero.
>>
>> Case used for test on Haswell EP:
>> usemem -n 72 --readonly -j 0x200000 100G
> 
> Is this benchmark publicly available ? Does not seem to be this one
> https://github.com/gnubert/usemem.git, Does it ?

Sorry, forgot to attach its link.
It's this one:
https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git

And the above mentioned usemem is:
https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git/tree/usemem.c

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
