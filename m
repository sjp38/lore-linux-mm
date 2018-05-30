Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 725056B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 11:00:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w8-v6so15035690wrn.10
        for <linux-mm@kvack.org>; Wed, 30 May 2018 08:00:42 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g17-v6si3763985edp.145.2018.05.30.08.00.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 08:00:40 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-3-mhocko@kernel.org>
 <93ce964b-e352-1905-c2b6-deedf2ea06f8@oracle.com>
 <c0e447b3-4ba7-239e-6550-64de7721ad28@oracle.com>
 <20180530080212.GA27180@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e7705544-04fe-c382-f6d0-48d0680b46f2@oracle.com>
Date: Wed, 30 May 2018 08:00:29 -0700
MIME-Version: 1.0
In-Reply-To: <20180530080212.GA27180@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, libhugetlbfs@googlegroups.com

On 05/30/2018 01:02 AM, Michal Hocko wrote:
> On Tue 29-05-18 15:21:14, Mike Kravetz wrote:
>> Just a quick heads up.  I noticed a change in libhugetlbfs testing starting
>> with v4.17-rc1.
>>
>> V4.16 libhugetlbfs test results
>> ********** TEST SUMMARY
>> *                      2M            
>> *                      32-bit 64-bit 
>> *     Total testcases:   110    113   
>> *             Skipped:     0      0   
>> *                PASS:   105    111   
>> *                FAIL:     0      0   
>> *    Killed by signal:     4      1   
>> *   Bad configuration:     1      1   
>> *       Expected FAIL:     0      0   
>> *     Unexpected PASS:     0      0   
>> *    Test not present:     0      0   
>> * Strange test result:     0      0   
>> **********
>>
>> v4.17-rc1 (and later) libhugetlbfs test results
>> ********** TEST SUMMARY
>> *                      2M            
>> *                      32-bit 64-bit 
>> *     Total testcases:   110    113   
>> *             Skipped:     0      0   
>> *                PASS:    98    111   
>> *                FAIL:     0      0   
>> *    Killed by signal:    11      1   
>> *   Bad configuration:     1      1   
>> *       Expected FAIL:     0      0   
>> *     Unexpected PASS:     0      0   
>> *    Test not present:     0      0   
>> * Strange test result:     0      0   
>> **********
>>
>> I traced the 7 additional (32-bit) killed by signal results to this
>> commit 4ed28639519c fs, elf: drop MAP_FIXED usage from elf_map.
>>
>> libhugetlbfs does unusual things and even provides custom linker scripts.
>> So, in hindsight this change in behavior does not seem too unexpected.  I
>> JUST discovered this while running libhugetlbfs tests for an unrelated
>> issue/change and, will do some analysis to see exactly what is happening.
> 
> I am definitely interested about further details. Are there any messages
> in the kernel log?
>

Yes, new messages associated with the failures.

[   47.570451] 1368 (xB.linkhuge_nof): Uhuuh, elf segment at 00000000a731413b requested but the memory is mapped already
[   47.606991] 1372 (xB.linkhuge_nof): Uhuuh, elf segment at 00000000a731413b requested but the memory is mapped already
[   47.641351] 1376 (xB.linkhuge_nof): Uhuuh, elf segment at 00000000a731413b requested but the memory is mapped already
[   47.726138] 1384 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
[   47.773169] 1393 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
[   47.817788] 1402 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
[   47.857338] 1406 (xB.linkshare): Uhuuh, elf segment at 0000000018430471 requested but the memory is mapped already
[   47.956355] 1427 (xB.linkshare): Uhuuh, elf segment at 0000000018430471 requested but the memory is mapped already
[   48.054894] 1448 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
[   48.071221] 1451 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already

Just curious, the addresses printed in those messages does not seem correct.
They should be page aligned.  Correct?  I think that %p conversion in the
pr_info() may doing something wrong.

Also, the new failures in question are indeed being built with custom linker
scripts designed for use with binutils older than 2.16 (really old).  So, no
new users should encounter this issue (I think).  It appears that this may
only impact old applications built long ago with pre-2.16 binutils.
-- 
Mike Kravetz
