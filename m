Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDB96B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 18:21:24 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id x24-v6so10502080ual.21
        for <linux-mm@kvack.org>; Tue, 29 May 2018 15:21:24 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id p196-v6si1757418vka.0.2018.05.29.15.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 15:21:23 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-3-mhocko@kernel.org>
 <93ce964b-e352-1905-c2b6-deedf2ea06f8@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c0e447b3-4ba7-239e-6550-64de7721ad28@oracle.com>
Date: Tue, 29 May 2018 15:21:14 -0700
MIME-Version: 1.0
In-Reply-To: <93ce964b-e352-1905-c2b6-deedf2ea06f8@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, libhugetlbfs@googlegroups.com

Just a quick heads up.  I noticed a change in libhugetlbfs testing starting
with v4.17-rc1.

V4.16 libhugetlbfs test results
********** TEST SUMMARY
*                      2M            
*                      32-bit 64-bit 
*     Total testcases:   110    113   
*             Skipped:     0      0   
*                PASS:   105    111   
*                FAIL:     0      0   
*    Killed by signal:     4      1   
*   Bad configuration:     1      1   
*       Expected FAIL:     0      0   
*     Unexpected PASS:     0      0   
*    Test not present:     0      0   
* Strange test result:     0      0   
**********

v4.17-rc1 (and later) libhugetlbfs test results
********** TEST SUMMARY
*                      2M            
*                      32-bit 64-bit 
*     Total testcases:   110    113   
*             Skipped:     0      0   
*                PASS:    98    111   
*                FAIL:     0      0   
*    Killed by signal:    11      1   
*   Bad configuration:     1      1   
*       Expected FAIL:     0      0   
*     Unexpected PASS:     0      0   
*    Test not present:     0      0   
* Strange test result:     0      0   
**********

I traced the 7 additional (32-bit) killed by signal results to this
commit 4ed28639519c fs, elf: drop MAP_FIXED usage from elf_map.

libhugetlbfs does unusual things and even provides custom linker scripts.
So, in hindsight this change in behavior does not seem too unexpected.  I
JUST discovered this while running libhugetlbfs tests for an unrelated
issue/change and, will do some analysis to see exactly what is happening.

Also, will take it upon myself to run libhugetlbfs test suite on a
regular (at least weekly) basis.
-- 
Mike Kravetz
