Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id F12356B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:04:41 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id h30so24837668uaf.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:04:41 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c4si2226469vkh.3.2016.12.16.06.04.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:04:41 -0800 (PST)
Subject: Re: crash during oom reaper
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
 <aaa788c2-7233-005d-ae7b-170cdcafc5ec@oracle.com>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <353d5304-d178-a6eb-05ab-e5a8c1ff8326@oracle.com>
Date: Fri, 16 Dec 2016 15:04:08 +0100
MIME-Version: 1.0
In-Reply-To: <aaa788c2-7233-005d-ae7b-170cdcafc5ec@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 12/16/2016 02:14 PM, Vegard Nossum wrote:
> On 12/16/2016 11:11 AM, Michal Hocko wrote:
>> On Fri 16-12-16 10:43:52, Vegard Nossum wrote:
>> [...]
>>> I don't think it's a bug in the OOM reaper itself, but either of the
>>> following two patches will fix the problem (without my understand how or
>>> why):
>>>
>> What is the atual crash?
>
> Annoyingly it doesn't seem to reproduce with the very latest
> linus/master, so maybe it's been fixed recently after all and I missed it.
>
> I've started a bisect to see what fixed it. Just in case, I added 4
> different crashes I saw with various kernels. I think there may have
> been a few others too (I remember seeing one in a page fault path), but
> these were the most frequent ones.

The bisect points to:

commit 6b94780e45c17b83e3e75f8aaca5a328db583c74
Author: Vincent Guittot <vincent.guittot@linaro.org>
Date:   Thu Dec 8 17:56:54 2016 +0100

     sched/core: Use load_avg for selecting idlest group

as fixing the crash, which seems odd to me. The only bit that sticks out
from the changelog to me:

"""
For use case like hackbench, this enable the scheduler to select
different CPUs during the fork sequence and to spread tasks across the
system.
"""

Reverting it from linus/master doesn't reintroduce the crash, but the
commit just before (6b94780e4^) does crash, so I'm not sure what's going
on. Maybe the crash is just really sensitive to scheduling decisions or
something.


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
