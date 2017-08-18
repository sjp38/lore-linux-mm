Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8220B6B02C3
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 12:36:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 63so5903867pgc.12
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:36:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o9si1382341pgn.823.2017.08.18.09.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 09:36:12 -0700 (PDT)
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <e876c71a-702d-adc5-e043-658de3b462c3@linux.intel.com>
Date: Fri, 18 Aug 2017 09:36:10 -0700
MIME-Version: 1.0
In-Reply-To: <20170818144622.oabozle26hasg5yo@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, "Liang, Kan" <kan.liang@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/18/2017 07:46 AM, Mel Gorman wrote:
> On Fri, Aug 18, 2017 at 02:20:38PM +0000, Liang, Kan wrote:
>>> Nothing fancy other than needing a comment if it works.
>>>
>>
>> No, the patch doesn't work.
>>
> 
> That indicates that it may be a hot page and it's possible that the page is
> locked for a short time but waiters accumulate.  What happens if you leave
> NUMA balancing enabled but disable THP?  Waiting on migration entries also
> uses wait_on_page_locked so it would be interesting to know if the problem
> is specific to THP.
> 
> Can you tell me what this workload is doing? I want to see if it's something
> like many threads pounding on a limited number of pages very quickly. If

It is a customer workload so we have limited visibility.  But we believe there are
some pages that are frequently accessed by all threads.

> it's many threads working on private data, it would also be important to
> know how each buffers threads are aligned, particularly if the buffers
> are smaller than a THP or base page size. For example, if each thread is
> operating on a base page sized buffer then disabling THP would side-step
> the problem but THP would be false sharing between multiple threads.
> 

Still, I don't think this problem is THP specific.  If there is a hot
regular page getting migrated, we'll also see many threads get
queued up quickly.  THP may have made the problem worse as migrating
it takes a longer time, meaning more threads could get queued up.

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
