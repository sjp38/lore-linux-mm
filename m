Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 462E66B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 03:32:59 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so114576655wjb.7
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 00:32:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h194si76854193wmd.115.2017.01.04.00.32.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 00:32:57 -0800 (PST)
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <bba4c707-c470-296c-edbe-b8a6d21152ad@suse.cz>
 <alpine.DEB.2.10.1701031431120.139238@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <75bf7af0-76e8-2d8e-cb00-745fd06c42ef@suse.cz>
Date: Wed, 4 Jan 2017 09:32:55 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1701031431120.139238@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/03/2017 11:44 PM, David Rientjes wrote:
> On Mon, 2 Jan 2017, Vlastimil Babka wrote:
> 
>> I'm late to the thread (I did read it fully though), so instead of
>> multiple responses, I'll just list my observations here:
>>
>> - "defer", e.g. background kswapd+compaction is not a silver bullet, it
>> will also affect the system. Mel already mentioned extra reclaim.
>> Compaction also has CPU costs, just hides the accounting to a kernel
>> thread so it's not visible as latency. It also increases zone/node
>> lru_lock and lock pressure.
>>
>> For the same reasons, admin might want to limit direct compaction for
>> THP, even for madvise() apps. It's also likely that "defer" might have
>> lower system overhead than "madvise", as with "defer",
>> reclaim/compaction is done by one per-node thread at a time, but there
>> might be multiple madvise() threads. So there might be sense in not
>> allowing madvise() apps to do direct reclaim/compaction on "defer".
>>
> 
> Hmm, is there a significant benefit to setting "defer" rather than "never" 
> if you can rely on khugepaged to trigger compaction when it tries to 
> allocate.  I suppose if there is nothing to collapse that this won't do 
> compaction, but is this not intended for users who always want to defer 
> when not immediately available?

I guess two things
- khugepaged is quite sleepy and will not respond to demand quickly, so
it won't compact that much than kcompactd triggered by "defer"
- thus with "defer" it's more likely that although some THP faults will
fail, others in near future will succeed and benefit from THP
immediately. Again, khugepaged is much slower. But it may recover
long-running processes that were unlucky in the initial faults, so it's
not useless.

> "Defer" in it's current setting is useless, in my opinion, other than 
> providing it as a simple workaround to users when their applications are 
> doing MADV_HUGEPAGE without allowing them to configure it.

I don't think the primary motivation for "defer" was to restrict
MADV_HUGEPAGE apps, but rather to prevent latency to the majority of
apps oblivious to THP when the default was "always". On the other hand,
setting "madvise" would make performance needlessly worse in some
scenarios, so "defer" is a compromise that tries to provide THP's but
without the latency, and still much more timely than khugepaged.

But that's just my POV, Mel probably has/had also the MADV_HUGEPAGE
restriction in mind. I'd expect that the "you have to disable THP"
cargo-cult originated around apps (databases?) that did not use
MADV_HUGEPAGE, though.

> We would love 
> to use "defer" if it didn't completely break MADV_HUGEPAGE, though.

Right.

>> - for overriding specific apps such as QEMU (including their madvise()
>> usage, AFAICS), we have PR_SET_THP_DISABLE prctl(), so no need to
>> LD_PRELOAD stuff IMO.
>>
> 
> Very good point, and I think it's also worthwhile to allow users to 
> suppress the MADV_HUGEPAGE when allocating a translation buffer in qemu if 
> they choose to do so; it's a very trivial patch to qemu to allow this to 
> be configurable.  I haven't proposed it because I don't personally have a 
> need for it, and haven't been pointed to anyone who has a need for it.
> 
>> - I have wondered about exactly the issue here when Mel proposed the
>> defer option [1]. Mel responded that it doesn't seem needed at that
>> point. Now it seems it is. Too bad you didn't raise it then, but to be
>> fair you were not CC'd.
>>
> 
> My understanding is that the defer option is available to users who cannot 
> modify their binary to suppress an madvise(MADV_HUGEPAGE) and are unaware 
> that PR_SET_THP_DISABLE exists.  The prctl was added specifically when you 
> cannot control your binary.

Yeah, it's easier than LD_PRELOAD, but still not system-wide transparent.

>> So would something like this be possible?
>>
>>> echo "defer madvise" > /sys/kernel/mm/transparent_hugepage/defrag
>>> cat /sys/kernel/mm/transparent_hugepage/defrag
>> always [defer] [madvise] never
>>
>> I'm not sure about the analogous kernel boot option though, I guess
>> those can't use spaces, so maybe comma-separated?

No opinion on the above? I think it could be somewhat more elegant than
a fifth-option that Mel said he would prefer, and deliver the same
flexibility.

>> If that's not acceptable, then I would probably rather be for changing
>> "madvise" to include "defer", than the other way around. When we augment
>> kcompactd to be more proactive, it might easily be that it will
>> effectively act as "defer", even when defrag=none is set, anyway.
>>
> 
> The concern I have with changing the behavior of "madvise" is that it 
> changes long standing behavior that people have correctly implemented 
> userspace applications with.  I suggest doing this only with "defer" since 
> it's an option that is new, nobody appears to be deploying with, and makes 
> it much more powerful.  I think we could make the kernel default as 
> "defer" later as well and not break userspace that has been setting 
> "madvise" ever since the 2.6 kernel.
> 
> My position is this: userspace that does MADV_HUGEPAGES knows what it's 
> doing.  Let it stall if it wants to stall.  If users don't want it to be 
> done, allow them to configure it.  If a binary has forced you into using 
> it, use the prctl.  Otherwise, I think "defer" doing background compaction 
> for everybody and direct compaction for users who really want hugepages is 
> appropriate and is precisely what I need.

I'm not completely against this. But we haven't really ruled out the
most flexible option yet...

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
