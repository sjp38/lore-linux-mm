Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFC76B0038
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 23:15:47 -0400 (EDT)
Received: by pasz6 with SMTP id z6so6328562pas.2
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 20:15:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id gl10si1608803pbc.104.2015.10.19.20.15.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 20:15:46 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm/hugetlb: Setup hugetlb_falloc during fallocate
 hole punch
References: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
 <1445033310-13155-3-git-send-email-mike.kravetz@oracle.com>
 <20151019161642.68e787103cacb613d372b5c4@linux-foundation.org>
 <56259BD0.7060307@oracle.com>
 <alpine.LSU.2.11.1510191852460.5432@eggly.anvils>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5625B11A.7030609@oracle.com>
Date: Mon, 19 Oct 2015 20:12:26 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510191852460.5432@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On 10/19/2015 07:22 PM, Hugh Dickins wrote:
> On Mon, 19 Oct 2015, Mike Kravetz wrote:
>> On 10/19/2015 04:16 PM, Andrew Morton wrote:
>>> On Fri, 16 Oct 2015 15:08:29 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>
>>>>  		mutex_lock(&inode->i_mutex);
>>>> +
>>>> +		spin_lock(&inode->i_lock);
>>>> +		inode->i_private = &hugetlb_falloc;
>>>> +		spin_unlock(&inode->i_lock);
>>>
>>> Locking around a single atomic assignment is a bit peculiar.  I can
>>> kinda see that it kinda protects the logic in hugetlb_fault(), but I
>>> would like to hear (in comment form) your description of how this logic
>>> works?
>>
>> To be honest, this code/scheme was copied from shmem as it addresses
>> the same situation there.  I did not notice how strange this looks until
>> you pointed it out.  At first glance, the locking does appear to be
>> unnecessary.  The fault code initially checks this value outside the
>> lock.  However, the fault code (on another CPU) will take the lock
>> and access values within the structure.  Without the locking or some other
>> type of memory barrier here, there is no guarantee that the structure
>> will be initialized before setting i_private.  So, the faulting code
>> could see invalid values in the structure.
>>
>> Hugh, is that accurate?  You provided the shmem code.
> 
> Yes, I think that's accurate; but confess I'm replying now for the
> sake of replying in a rare timely fashion, before having spent any
> time looking through your hugetlbfs reimplementation of the same.
> 
> The peculiar thing in the shmem case, was that the structure being
> pointed to is on the kernel stack of the fallocating task (with
> i_mutex guaranteeing only one at a time per file could be doing this):
> so the faulting end has to be careful that it's not accessing the
> stale memory after the fallocator has retreated back up its stack.

I used the same code/scheme for hugetlbfs.

> And in the shmem case, this "temporary inode extension" also had to
> communicate to shmem_writepage(), the swapout end of things.  Which
> is not a complication you have with hugetlbfs: perhaps it could be
> simpler if just between fallocate and fault, or perhaps not.

Yes, I think it is simpler.  At first I was excited because hugetlbfs
already has a table of mutex'es to synchronize page faults. and I
thought about using those.  If the hole being punched is small this
works fine.  But, for large holes you could end up taking all mutexes
and prevent all huge page faults. :(  So, I went back to the scheme
employed by shmem.

> Whilst it does all work for tmpfs, it looks as if tmpfs was ahead of
> the pack (or trinity was attacking tmpfs before other filesystems),
> and the issue of faulting versus holepunching (and DAX) has captured
> wider interest recently, with Dave Chinner formulating answers in XFS,
> and hoping to set an example for other filesystems.
> 
> If that work were further along, and if I had had time to digest any
> of what he is doing about it, I would point you in his direction rather
> than this; but since this does work for tmpfs, I shouldn't discourage you.
> 
> I'll try to take a look through yours in the coming days, but there's
> several other patchsets I need to look through too, plus a few more
> patches from me, if I can find time to send them in: juggling priorities.
> 
> Hugh

Thanks, and no hurry.  I need to add a little more code to this this patch
set to completely handle the race.  A new patch will be out in a day or two.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
