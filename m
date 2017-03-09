Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1657F831FE
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 01:46:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id x63so97520903pfx.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:46:49 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id t19si5526460plj.305.2017.03.08.22.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 22:46:48 -0800 (PST)
Subject: Re: [RFC 08/11] mm: make ttu's return boolean
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-9-git-send-email-minchan@kernel.org>
 <70f60783-e098-c1a9-11b4-544530bcd809@nvidia.com> <20170309063721.GC854@bbox>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <49da6c96-387f-5931-eddb-cb6414631877@nvidia.com>
Date: Wed, 8 Mar 2017 22:46:40 -0800
MIME-Version: 1.0
In-Reply-To: <20170309063721.GC854@bbox>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 03/08/2017 10:37 PM, Minchan Kim wrote:
 >[...]
>
> I think it's the matter of taste.
>
>         if (try_to_unmap(xxx))
>                 something
>         else
>                 something
>
> It's perfectly understandable to me. IOW, if try_to_unmap returns true,
> it means it did unmap successfully. Otherwise, failed.
>
> IMHO, SWAP_SUCCESS or TTU_RESULT_* seems to be an over-engineering.
> If the user want it, user can do it by introducing right variable name
> in his context. See below.

I'm OK with that approach. Just something to avoid the "what does !ret mean in this 
function call" is what I was looking for...


>> [...]
>>> 	forcekill = PageDirty(hpage) || (flags & MF_MUST_KILL);
>>> -	kill_procs(&tokill, forcekill, trapno,
>>> -		      ret != SWAP_SUCCESS, p, pfn, flags);
>>> +	kill_procs(&tokill, forcekill, trapno, !ret , p, pfn, flags);
>>
>> The kill_procs() invocation was a little more readable before.
>
> Indeed but I think it's not a problem of try_to_unmap but ret variable name
> isn't good any more. How about this?
>
>         bool unmap_success;
>
>         unmap_success = try_to_unmap(hpage, ttu);
>
>         ..
>
>         kill_procs(&tokill, forcekill, trapno, !unmap_success , p, pfn, flags);
>
>         ..
>
>         return unmap_success;
>
> My point is user can introduce whatever variable name depends on his
> context. No need to make return variable complicated, IMHO.

Yes, the local variable basically achieves what I was hoping for, so sure, works for 
me.

>> [...]
>>> -			case SWAP_FAIL:
>>
>> Again: the SWAP_FAIL makes it crystal clear which case we're in.
>
> To me, I don't feel it.
> To me, below is perfectly understandable.
>
>         if (try_to_unmap())
>                 do something
>
> That's why I think it's matter of taste. Okay, I admit I might be
> biased, too so I will consider what you suggested if others votes
> it.

Yes, if it's really just a matter of taste, then not worth debating. Your change 
above is fine I think.

thanks
john h

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
