Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 6ECF76B00AD
	for <linux-mm@kvack.org>; Wed, 29 May 2013 06:51:12 -0400 (EDT)
Message-ID: <51A5DDCE.509@parallels.com>
Date: Wed, 29 May 2013 14:51:58 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 16/34] xfs: convert buftarg LRU to generic code
References: <1369391368-31562-1-git-send-email-glommer@openvz.org> <1369391368-31562-17-git-send-email-glommer@openvz.org> <20130525002759.GK24543@dastard> <51A4D3B5.6060802@parallels.com> <20130529101519.GA29466@dastard>
In-Reply-To: <20130529101519.GA29466@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Dave Chinner <dchinner@redhat.com>

On 05/29/2013 02:15 PM, Dave Chinner wrote:
> On Tue, May 28, 2013 at 09:26:37PM +0530, Glauber Costa wrote:
>> On 05/25/2013 05:57 AM, Dave Chinner wrote:
>>> On Fri, May 24, 2013 at 03:59:10PM +0530, Glauber Costa wrote:
>>>> From: Dave Chinner <dchinner@redhat.com>
>>>>
>>>> Convert the buftarg LRU to use the new generic LRU list and take
>>>> advantage of the functionality it supplies to make the buffer cache
>>>> shrinker node aware.
>>>>
>>>> * v7: Add NUMA aware flag
>>>
>>> I know what is wrong with this patch that causes the unmount hang -
>>> it's the handling of the _XBF_LRU_DISPOSE flag no longer being
>>> modified atomically with the LRU lock. Hence there is a race where
>>> we can either lose the _XBF_LRU_DISPOSE or not see it and hence we
>>> can end up with code not detecting what list the buffer is on
>>> correctly.
>>>
>>> I haven't had a chance to work out a fix for it yet. If this ends up
>>> likely to hold up the patch set, Glauber, then feel free to drop it
>>> from the series and I'll push a fixed version through the XFS tree
>>> in due course....
>>>
>>> Cheers,
>>>
>>> Dave.
>>>
>> Please let me know what you think about the following two (very coarse)
>> patches. My idea is to expose more of the raw structures so XFS can do
>> the locking itself when needed.
> 
> No, I'd prefer not to do that.  There's a big difference between a
> callback that passes a pointer to an internal lock that protects the
> list that the item being passed is on and exposing the guts of the
> per node list and lock implementation to everyone....
> 
> As it is, the XFS buffer LRU reclaimation is modelled on the
> inode/dentry cache lru reclaimation where the "on dispose list" flag
> is managed by a lock in the inode/dentry and wraps around the
> outside of the LRU locks. The simplest fix to XFS is to add a
> spinlock to the buffer to handle this in the same way as inodes and
> dentries. I think I might be able to do it in a way that avoids
> the spin lock but I just haven't had time to look at it that closely.
> 
> Cheers,
> 
Ok. In the interest of having the series merged - we seem to be running
out of problems - I see two courses of action:

1) Don't convert this to LRU at all, just convert to the new count/ scan
interface,

2) Use a temporary spinlock, and you fix that later.

I would actually prefer 2). Reason is that this patch actually do both,
meaning I would have to rewrite the patch to do this scan / count loop
without the new list_lru aid. Besides being more error-prone, it is of
course a lot more work.

Which one you prefer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
