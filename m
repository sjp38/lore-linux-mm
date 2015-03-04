Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id EA8576B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 03:51:02 -0500 (EST)
Received: by wgha1 with SMTP id a1so45103750wgh.12
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 00:51:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11si28257173wiw.57.2015.03.04.00.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 00:51:01 -0800 (PST)
Message-ID: <54F6C772.3050806@suse.cz>
Date: Wed, 04 Mar 2015 09:50:58 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: How to handle TIF_MEMDIE stalls?
References: <20150217225430.GJ4251@dastard> <20150219102431.GA15569@phnom.home.cmpxchg.org> <20150219225217.GY12722@dastard> <20150221235227.GA25079@phnom.home.cmpxchg.org> <20150223004521.GK12722@dastard> <20150222172930.6586516d.akpm@linux-foundation.org> <20150223073235.GT4251@dastard> <54F42FEA.1020404@suse.cz> <20150302223154.GJ18360@dastard> <54F57B20.3090803@suse.cz> <20150304013346.GP18360@dastard>
In-Reply-To: <20150304013346.GP18360@dastard>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On 03/04/2015 02:33 AM, Dave Chinner wrote:
> On Tue, Mar 03, 2015 at 10:13:04AM +0100, Vlastimil Babka wrote:
>>>
>>> Preallocated reserves do not allow for unbound demand paging of
>>> reclaimable objects within reserved allocation contexts.
>>
>> OK I think I get the point now.
>>
>> So, lots of the concerns by me and others were about the wasted memory due to
>> reservations, and increased pressure on the rest of the system. I was thinking,
>> are you able, at the beginning of the transaction (for this purposes, I think of
>> transaction as the work that starts with the memory reservation, then it cannot
>> rollback and relies on the reserves, until it commits and frees the memory),
>> determine whether the transaction cannot be blocked in its progress by any other
>> transaction, and the only thing that would block it would be inability to
>> allocate memory during its course?
>
> No. e.g. any transaction that requires allocation or freeing of an
> inode or extent can get stuck behind any other transaction that is
> allocating/freeing and inode/extent. And this will happen when
> holding inode locks, which means other transactions on that inode
> will then get stuck on the inode lock, and so on. Blocking
> dependencies within transactions are everywhere and cannot be
> avoided.

Hm, I see. I thought that perhaps to avoid deadlocks between 
transactions (which you already have to do somehow), either the 
dependencies have to be structured in a way that there's always some 
transaction that can't block on others. Or you have a way to detect 
potential deadlocks before they happen, and stall somebody who tries to 
lock. Both should (at least theoretically) mean that you would be able 
to point to such transaction, although I can imagine the cost of being 
able to do that could be prohibitive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
