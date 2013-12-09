Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 78F156B00E2
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 15:34:45 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id wo20so4337130obc.11
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 12:34:45 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id mx9si8452184obc.145.2013.12.09.12.34.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 12:34:44 -0800 (PST)
Message-ID: <52A6275F.4040007@oracle.com>
Date: Mon, 09 Dec 2013 15:26:07 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com> <52A5F9EE.4010605@suse.cz>
In-Reply-To: <52A5F9EE.4010605@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/09/2013 12:12 PM, Vlastimil Babka wrote:
> On 12/09/2013 06:05 PM, Sasha Levin wrote:
>> On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
>>> Hello, I will look at it, thanks.
>>> Do you have specific reproduction instructions?
>>
>> Not really, the fuzzer hit it once and I've been unable to trigger it again. Looking at
>> the piece of code involved it might have had something to do with hugetlbfs, so I'll crank
>> up testing on that part.
>
> Thanks. Do you have trinity log and the .config file? I'm currently unable to even boot linux-next
> with my config/setup due to a GPF.
> Looking at code I wouldn't expect that it could encounter a tail page, without first encountering a
> head page and skipping the whole huge page. At least in THP case, as TLB pages should be split when
> a vma is split. As for hugetlbfs, it should be skipped for mlock/munlock operations completely. One
> of these assumptions is probably failing here...

If it helps, I've added a dump_page() in case we hit a tail page there and got:

[  980.172299] page:ffffea003e5e8040 count:0 mapcount:1 mapping:          (null) index:0
x0
[  980.173412] page flags: 0x2fffff80008000(tail)

I can also add anything else in there to get other debug output if you think of something else useful.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
