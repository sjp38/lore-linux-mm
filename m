Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4C726B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 12:25:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k18-v6so15180494wrm.6
        for <linux-mm@kvack.org>; Wed, 30 May 2018 09:25:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s12-v6si5908212edb.332.2018.05.30.09.25.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 09:25:02 -0700 (PDT)
Date: Wed, 30 May 2018 18:25:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
Message-ID: <20180530162501.GB15278@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-3-mhocko@kernel.org>
 <93ce964b-e352-1905-c2b6-deedf2ea06f8@oracle.com>
 <c0e447b3-4ba7-239e-6550-64de7721ad28@oracle.com>
 <20180530080212.GA27180@dhcp22.suse.cz>
 <e7705544-04fe-c382-f6d0-48d0680b46f2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7705544-04fe-c382-f6d0-48d0680b46f2@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, libhugetlbfs@googlegroups.com

On Wed 30-05-18 08:00:29, Mike Kravetz wrote:
> On 05/30/2018 01:02 AM, Michal Hocko wrote:
> > On Tue 29-05-18 15:21:14, Mike Kravetz wrote:
> >> Just a quick heads up.  I noticed a change in libhugetlbfs testing starting
> >> with v4.17-rc1.
> >>
> >> V4.16 libhugetlbfs test results
> >> ********** TEST SUMMARY
> >> *                      2M            
> >> *                      32-bit 64-bit 
> >> *     Total testcases:   110    113   
> >> *             Skipped:     0      0   
> >> *                PASS:   105    111   
> >> *                FAIL:     0      0   
> >> *    Killed by signal:     4      1   
> >> *   Bad configuration:     1      1   
> >> *       Expected FAIL:     0      0   
> >> *     Unexpected PASS:     0      0   
> >> *    Test not present:     0      0   
> >> * Strange test result:     0      0   
> >> **********
> >>
> >> v4.17-rc1 (and later) libhugetlbfs test results
> >> ********** TEST SUMMARY
> >> *                      2M            
> >> *                      32-bit 64-bit 
> >> *     Total testcases:   110    113   
> >> *             Skipped:     0      0   
> >> *                PASS:    98    111   
> >> *                FAIL:     0      0   
> >> *    Killed by signal:    11      1   
> >> *   Bad configuration:     1      1   
> >> *       Expected FAIL:     0      0   
> >> *     Unexpected PASS:     0      0   
> >> *    Test not present:     0      0   
> >> * Strange test result:     0      0   
> >> **********
> >>
> >> I traced the 7 additional (32-bit) killed by signal results to this
> >> commit 4ed28639519c fs, elf: drop MAP_FIXED usage from elf_map.
> >>
> >> libhugetlbfs does unusual things and even provides custom linker scripts.
> >> So, in hindsight this change in behavior does not seem too unexpected.  I
> >> JUST discovered this while running libhugetlbfs tests for an unrelated
> >> issue/change and, will do some analysis to see exactly what is happening.
> > 
> > I am definitely interested about further details. Are there any messages
> > in the kernel log?
> >
> 
> Yes, new messages associated with the failures.
> 
> [   47.570451] 1368 (xB.linkhuge_nof): Uhuuh, elf segment at 00000000a731413b requested but the memory is mapped already
> [   47.606991] 1372 (xB.linkhuge_nof): Uhuuh, elf segment at 00000000a731413b requested but the memory is mapped already
> [   47.641351] 1376 (xB.linkhuge_nof): Uhuuh, elf segment at 00000000a731413b requested but the memory is mapped already
> [   47.726138] 1384 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
> [   47.773169] 1393 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
> [   47.817788] 1402 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
> [   47.857338] 1406 (xB.linkshare): Uhuuh, elf segment at 0000000018430471 requested but the memory is mapped already
> [   47.956355] 1427 (xB.linkshare): Uhuuh, elf segment at 0000000018430471 requested but the memory is mapped already
> [   48.054894] 1448 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
> [   48.071221] 1451 (xB.linkhuge): Uhuuh, elf segment at 0000000090b9eaf6 requested but the memory is mapped already
> 
> Just curious, the addresses printed in those messages does not seem correct.
> They should be page aligned.  Correct?

I have no idea what the loader actually does here.

> I think that %p conversion in the pr_info() may doing something wrong.

Well, we are using %px and that shouldn't do any tricks to the given
address.

> Also, the new failures in question are indeed being built with custom linker
> scripts designed for use with binutils older than 2.16 (really old).  So, no
> new users should encounter this issue (I think).  It appears that this may
> only impact old applications built long ago with pre-2.16 binutils.

Could you add a debugging data to dump the VMA which overlaps the
requested adress and who requested that? E.g. hook into do_mmap and dump
all requests from the linker.
-- 
Michal Hocko
SUSE Labs
