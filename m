Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25EA06B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 06:15:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c5so1505636pfn.17
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 03:15:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b9-v6si738777pll.117.2018.03.09.03.15.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Mar 2018 03:15:01 -0800 (PST)
Subject: Re: Removing GFP_NOFS
References: <20180308234618.GE29073@bombadil.infradead.org>
 <20180309013535.GU7000@dastard> <20180309040650.GV7000@dastard>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <5340fdd1-a6ea-0464-84a0-27b4dd1460c9@i-love.sakura.ne.jp>
Date: Fri, 9 Mar 2018 20:14:13 +0900
MIME-Version: 1.0
In-Reply-To: <20180309040650.GV7000@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, rgoldwyn@suse.de, neilb@suse.com, James.Bottomley@HansenPartnership.com, Michal Hocko <mhocko@kernel.org>

On 2018/03/09 13:06, Dave Chinner wrote:
> On Fri, Mar 09, 2018 at 12:35:35PM +1100, Dave Chinner wrote:
>> On Thu, Mar 08, 2018 at 03:46:18PM -0800, Matthew Wilcox wrote:
>>>
>>> Do we have a strategy for eliminating GFP_NOFS?
>>>
>>> As I understand it, our intent is to mark the areas in individual
>>> filesystems that can't be reentered with memalloc_nofs_save()/restore()
>>> pairs.A  Once they're all done, then we can replace all the GFP_NOFS
>>> users with GFP_KERNEL.
>>
>> Won't be that easy, I think.A  We recently came across user-reported
>> allocation deadlocks in XFS where we were doing allocation with
>> pages held in the writeback state that lockdep has never triggered
>> on.
>>
>> https://www.spinics.net/lists/linux-xfs/msg16154.html
>>
>> IOWs, GFP_NOFS isn't a solid guide to where
>> memalloc_nofs_save/restore need to cover in the filesystems because
>> there's a surprising amount of code that isn't covered by existing
>> lockdep annotations to warning us about un-intended recursion
>> problems.
>>
>> I think we need to start with some documentation of all the generic
>> rules for where these will need to be set, then the per-filesystem
>> rules can be added on top of that...
>
> So thinking a bit further here:
>
> * page writeback state gets set and held:
> A A A  ->writepage should be under memalloc_nofs_save
> A A A  ->writepages should be under memalloc_nofs_save
> * page cache write path is often under AOP_FLAG_NOFS
> A A A  - should probably be under memalloc_nofs_save
> * metadata writeback that uses page cache and page writeback flags
>A A  should probably be under memalloc_nofs_save
>
> What other generic code paths are susceptible to allocation
> deadlocks?
>
> Cheers,
>
> Dave.

Goldwyn Rodrigues is thinking "[LSF/MM ATTEND] memory allocation scope".
But I think that getting rid of direct reclaim, assigning dedicated kernel
thread for each reclaim routine, and using multiple watermark levels based
on purpose of memory allocation request is the better. OOM situation is
wasting CPU resources by unthrottled direct reclaim attempts without making
progress, and we are loosing performance when memory allocation for memory
reclaim activities are failing, and happily diving into the lockdep
labyrinth which is too hard to test, and we are unable to give up upon
SIGKILL (i.e. unable to implement __GFP_KILLABLE) due to unkillable locks
within direct reclaim attempts.
