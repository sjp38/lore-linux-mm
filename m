Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 707016B0005
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 07:24:16 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l66so68542967wml.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 04:24:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kq9si39575544wjc.90.2016.02.01.04.24.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Feb 2016 04:24:14 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] proposals for topics
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org> <20160126095022.GC27563@dhcp22.suse.cz>
 <20160128205525.GO6033@dastard> <20160128220422.GG621@dhcp22.suse.cz>
 <20160131232901.GO20456@dastard>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56AF4E6C.7010408@suse.cz>
Date: Mon, 1 Feb 2016 13:24:12 +0100
MIME-Version: 1.0
In-Reply-To: <20160131232901.GO20456@dastard>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 02/01/2016 12:29 AM, Dave Chinner wrote:
> On Thu, Jan 28, 2016 at 11:04:23PM +0100, Michal Hocko wrote:
>> On Fri 29-01-16 07:55:25, Dave Chinner wrote:
>>> On Tue, Jan 26, 2016 at 10:50:23AM +0100, Michal Hocko wrote:
>> [...]
>>>> There have been patches posted during the year to fortify those places
>>>> which cannot cope with allocation failures for ext[34] and testing
>>>> has shown that ext* resp. xfs are quite ready to see NOFS allocation
>>>> failures.
>>>
>>> The XFS situation is compeletely unchanged from last year, and the
>>> fact that you say it handles NOFS allocation failures just fine
>>> makes me seriously question your testing methodology.
>>
>> I am quite confused now. I remember you were the one who complained
>> about the silent nofail behavior of the allocator because that means
>> you cannot implement an appropriate fallback strategy.
>
> I complained about the fact the allocator did not behave as
> documented (or expected) in that it didn't fail allocations we
> expected it to fail.

Yes, I believe this is exactly what Michal was talking about in the 
original e-mail:

> - GFP_NOFS is another one which would be good to discuss. Its primary
>   use is to prevent from reclaim recursion back into FS. This makes
>   such an allocation context weaker and historically we haven't
>   triggered OOM killer and rather hopelessly retry the request and
>   rely on somebody else to make a progress for us. There are two issues
>   here.
>   First we shouldn't retry endlessly and rather fail the allocation and
>   allow the FS to handle the error. As per my experiments most FS cope
>   with that quite reasonably. Btrfs unfortunately handles many of those
>   failures by BUG_ON which is really unfortunate.

So this should address your complain above.

>> That being said, I do understand that allowing GFP_NOFS allocation to
>> fail is not an easy task and nothing to be done tomorrow or in few
>> months, but I believe that a discussion with FS people about what
>> can/should be done in order to make this happen is valuable.
>
> The discussion - from my perspective - is likely to be no different
> to previous years. None of the proposals that FS people have come up
> to address the "need memory allocation guarantees" issue have got
> any traction on the mm side. Unless there's something fundamentally
> new from the MM side that provides filesystems with a replacement
> for __GFP_NOFAIL type behaviour, I don't think further discussion is
> going to change the status quo.

Yeah, the guaranteed reserves as discussed last year didn't happen so 
far. But that's a separate issue than GPF_NOFS *without* __GFP_NOFAIL.
It just got mixed up in this thread.

> Cheers,
>
> Dave.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
