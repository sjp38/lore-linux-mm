Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A280A6B0068
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 05:17:57 -0500 (EST)
Message-ID: <50D43757.3000604@parallels.com>
Date: Fri, 21 Dec 2012 14:17:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/19] shrinker: convert superblock shrinkers to new API
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <1354058086-27937-6-git-send-email-david@fromorbit.com> <50D2F142.401@parallels.com> <20121221014647.GA15182@dastard>
In-Reply-To: <20121221014647.GA15182@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On 12/21/2012 05:46 AM, Dave Chinner wrote:
> On Thu, Dec 20, 2012 at 03:06:42PM +0400, Glauber Costa wrote:
>> On 11/28/2012 03:14 AM, Dave Chinner wrote:
>>> +static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc)
>>> +{
>>> +	struct super_block *sb;
>>> +	long	total_objects = 0;
>>> +
>>> +	sb = container_of(shrink, struct super_block, s_shrink);
>>> +
>>> +	if (!grab_super_passive(sb))
>>> +		return -1;
>>> +
>>
>>
>> You're missing the GFP_FS check here. This leads to us doing all the
>> counting only to find out later, in the scanner, that we won't be able
>> to free it. Better exit early.
> 
> No, I did that intentionally.
> 
> The shrinker has a method of deferring work from one invocation to
> another - the shrinker->nr_in_batch variable. This is intended to be
> used to ensure that a shrinker does the work it is supposed to, even
> if it can't do the work immediately due to something like a GFP
> context mismatch.
> 
> The problem with that mechanism right now is that it is not applied
> consistently across the shrinkers. Some shrinkers will return a
> count whenever nr_to_scan == 0, regardless of the gfp_mask, while
> others will immediately return -1.
> 
> What this patch set does is make the shrinkers *always* return the
> count of objects so the scan count can be calculated, and then let
> the actually scanner determine whether progress can be made. The
> result of doing this is that if the scanner cannot make progress,
> the work is correctly deferred to the next shrinker invocation that
> may be made under a different GFP context.
> 
> This is important because when you have a workload that involves a
> lot of filesytsem modifications, the number of GFP_NOFS allocations
> greatly outweights GFP_KERNEL allocations. Hence the majority of the
> time we try to shrink the filesystem caches, they cannot do any
> work. Hence we need the work to be deferred to the next GFP_KERNEL
> shrinker invocation so the reclaim of the caches remains in balance.
> 
> This is also the reason for "We need to avoid excessive windup on
> filesystem shrinkers" limiting of total_scan, so that we don't allow
> this deferal to completely trash the caches when so much deferal
> happens that the scan count grows to exceed the size of the cache
> and we get a GFP_KERNEL reclaim context...
> 
> IOWs, for this deferal mechanism to work consistently, we always
> need to calculate the amount of work we are supposed to do when the
> shrinker is invoked. That means we always need to return the current
> count of objects iand calculate the amount of scanning we need to
> do. The check in the scan context determines if the work then gets
> deferred or not....
> 


While it makes sense, and it is clear to me now, could you document that
to the benefit of future less gifted readers as myself?

Otherwise, should you be bitten by a giant poisonous spider and turn
into a spider-zombie, this knowledge disappears. And you live in
Australia, mate, this is totally possible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
