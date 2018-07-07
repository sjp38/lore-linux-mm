Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C023F6B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 21:13:11 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t138-v6so14923009oih.5
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 18:13:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a143-v6si5580548oih.126.2018.07.06.18.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 18:13:10 -0700 (PDT)
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup
 problem.
References: <201807050305.w653594Q081552@www262.sakura.ne.jp>
 <20180705071740.GC32658@dhcp22.suse.cz>
 <201807060240.w662e7Q1016058@www262.sakura.ne.jp>
 <CA+55aFz87+iXZ_N5jYgo9UFFJ2Tc9dkMLPxwscriAdDKoyF0CA@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b1b81935-1a71-8742-a04f-5c81e1deace0@i-love.sakura.ne.jp>
Date: Sat, 7 Jul 2018 10:12:57 +0900
MIME-Version: 1.0
In-Reply-To: <CA+55aFz87+iXZ_N5jYgo9UFFJ2Tc9dkMLPxwscriAdDKoyF0CA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On 2018/07/06 11:49, Linus Torvalds wrote:
> On Thu, Jul 5, 2018 at 7:40 PM Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>
>>>
>>> No, direct reclaim is a way to throttle allocations to the reclaim
>>> speed. You would have to achive the same by other means.
>>
>> No. Direct reclaim is a way to lockup the system to unusable level, by not giving
>> enough CPU resources to memory reclaim activities including the owner of oom_lock.
> 
> No. Really.
> 
> Direct reclaim really really does what Michal claims. Yes, it has
> other effects too, and it can be problematic, but direct reclaim is
> important.

I'm saying that even an unprivileged user can make the reclaim speed to
"0 pages per minute".

[PATCH 1/8] is for reducing possibility of hitting "0 pages per minute" whereas
[PATCH 8/8] is for increasing possibility of hitting "0 pages per minute".
They are contradicting directions which should not be made in one patch.

> 
> People have tried to remove it many times, but it's always been a
> disaster. You need to synchronize with _something_ to make sure that
> the thread that is causing a lot of allocations actually pays the
> price, and slows down.

[PATCH 3/8] is for reducing possibility of hitting "0 pages per minute"
by making sure that allocating threads pay some price for reclaiming memory
via doing direct OOM reaping.

> 
> You want to have a balance between direct and indirect reclaim.

While [PATCH 3/8] currently pays the full price, we can improve [PATCH 3/8] to
pay only some price by changing direct OOM reaping to use some threshold.

That is the direction towards the balance between "direct reclaim (by direct
OOM reap by allocating threads)" and "indirect reclaim (by the OOM reaper kernel
thread and exit_mmap())".

> 
> If you think direct reclaim is only a way to lock up the system to
> unusable levels, you should stop doing VM development.

Locking up the system to unusable levels due to things outside of the page
allocator is a different bug.

The page allocator chokes themselves by lack of "direct reclaim" when we are
waiting for the owner of oom_lock to make progress. This series is for getting
rid of the lie

	/*
	 * Acquire the oom lock.  If that fails, somebody else is
	 * making progress for us.
	 */
	if (!mutex_trylock(&oom_lock)) {
		*did_some_progress = 1;
		schedule_timeout_uninterruptible(1);
		return NULL;
	}

caused by lack of "direct reclaim".

> 
>                    Linus
> 

On 2018/07/06 14:56, Michal Hocko wrote:
>>> Yes, there is no need to reclaim all pages. OOM is after freeing _some_
>>> memory after all. But that means further complications down the unmap
>>> path. I do not really see any reason for that.
>>
>> "I do not see reason for that" cannot become a reason direct OOM reaping has to
>> reclaim all pages at once.
> 
> We are not going to polute deep mm guts for unlikely events like oom.

And since Michal is refusing to make changes for having the balance between
"direct reclaim by threads waiting for oom_lock" and "indirect reclaim by
a thread holding oom_lock", we will keep increasing possibility of hitting
"0 pages per minute". Therefore,

> If you are afraid of
> regression and do not want to have your name on the patch then fine. I
> will post the patch myself and also handle any fallouts.

PLEASE PLEASE PLEASE DO SO IMMEDIATELY!!!
