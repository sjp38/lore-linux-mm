Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2285F6B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 09:48:42 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id v8so4018269pgs.9
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 06:48:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q84si952167pfa.358.2018.03.09.06.48.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Mar 2018 06:48:40 -0800 (PST)
Subject: Re: Removing GFP_NOFS
References: <20180308234618.GE29073@bombadil.infradead.org>
 <20180309013535.GU7000@dastard> <20180309040650.GV7000@dastard>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <e461128e-6724-3c7f-0f62-860ac4071357@suse.de>
Date: Fri, 9 Mar 2018 08:48:32 -0600
MIME-Version: 1.0
In-Reply-To: <20180309040650.GV7000@dastard>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, penguin-kernel@i-love.sakura.ne.jp



On 03/08/2018 10:06 PM, Dave Chinner wrote:
> On Fri, Mar 09, 2018 at 12:35:35PM +1100, Dave Chinner wrote:
>> On Thu, Mar 08, 2018 at 03:46:18PM -0800, Matthew Wilcox wrote:
>>>
>>> Do we have a strategy for eliminating GFP_NOFS?
>>>
>>> As I understand it, our intent is to mark the areas in individual
>>> filesystems that can't be reentered with memalloc_nofs_save()/restore()
>>> pairs.  Once they're all done, then we can replace all the GFP_NOFS
>>> users with GFP_KERNEL.
>>
>> Won't be that easy, I think.  We recently came across user-reported
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
> 	->writepage should be under memalloc_nofs_save
> 	->writepages should be under memalloc_nofs_save
> * page cache write path is often under AOP_FLAG_NOFS
> 	- should probably be under memalloc_nofs_save
> * metadata writeback that uses page cache and page writeback flags
>   should probably be under memalloc_nofs_save
> 
> What other generic code paths are susceptible to allocation
> deadlocks?
> 

AFAIU, these are callbacks into the filesystem from the mm code which
are executed in case of low memory. So, the calls of memory allocation
from filesystem code are the ones that should be the one under
memalloc_nofs_save() in order to save from recursion.

OTOH (contradicting myself here), writepages, in essence writebacks, are
performed by per-BDI flusher threads which are kicked by the mm code in
low memory situations, as opposed to the thread performing the allocation.

As Tetsuo pointed out, direct reclaims are the real problematic scenarios.

Also the shrinkers registered by filesystem code. However, there are no
shrinkers that I know of, which allocate memory or perform locking.
Thanks to smartly swapping into a temporary local list variable.


-- 
Goldwyn
