Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 935A96B0055
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 22:30:23 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id b17so1353133rvf.6
        for <linux-mm@kvack.org>; Wed, 12 Aug 2009 19:30:22 -0700 (PDT)
Message-ID: <4A837AAF.4050103@vflare.org>
Date: Thu, 13 Aug 2009 08:00:07 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH] swap: send callback when swap slot is freed
References: <200908122007.43522.ngupta@vflare.org> <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/13/2009 04:18 AM, Hugh Dickins wrote:
> On Wed, 12 Aug 2009, Nitin Gupta wrote:
>
>> Currently, we have "swap discard" mechanism which sends a discard bio request
>> when we find a free cluster during scan_swap_map(). This callback can come a
>> long time after swap slots are actually freed.
>>
>> This delay in callback is a great problem when (compressed) RAM [1] is used
>> as a swap device. So, this change adds a callback which is called as
>> soon as a swap slot becomes free. For above mentioned case of swapping
>> over compressed RAM device, this is very useful since we can immediately
>> free memory allocated for this swap page.
>>
>> This callback does not replace swap discard support. It is called with
>> swap_lock held, so it is meant to trigger action that finishes quickly.
>> However, swap discard is an I/O request and can be used for taking longer
>> actions.
>>
>> Links:
>> [1] http://code.google.com/p/compcache/
>
> Please keep this with compcache for the moment (it has no other users).
>
> I don't share Peter's view that it should be using a more general
> notifier interface (but I certainly agree with his EXPORT_SYMBOL_GPL).

Considering that the callback is made under swap_lock, we should not 
have an array of callbacks to do. But what if this callback finds other 
users too? I think we should leave it in its current state till it finds 
more users and probably add BUG() to make sure callback is not already set.

I will make it EXPORT_SYMBOL_GPL.

> There better not be others hooking in here at the same time (a BUG_ON
> could check that): in fact I don't even want you hooking in here where
> swap_lock is held.  Glancing at compcache, I don't see you violating
> lock hierarchy by that, but it is a worry.
>

I tried an approach that allows releasing swap_lock and 'lazily' make
the callback but this turned out to be pretty messy. So, I think just
adding a note that the callback is done under swap_lock should be better.


> The interface to set the notifier, you currently have it by swap type:
> that would better be by bdev, wouldn't it?  with a search for the right
> slot.  There's nowhere else in ramzswap.c that you rely on swp_entry_t
> and page_private(page), let's keep such details out of compcache.
>

Use of bdev instead of swap_entry_t looks better. I will make this change.


> But fundamentally, though I can see how this cutdown communication
> path is useful to compcache, I'd much rather deal with it by the more
> general discard route if we can.  (I'm one of those still puzzled by
> the way swap is mixed up with block device in compcache: probably
> because I never found time to pay attention when you explained.)
>

I tried this too -- make discard bio request as soon as a swap slot 
becomes free (I can send details if you want). However, I could not get 
it to work. Also, allocating bio to issue discard I/O request looks like 
a complete artifact in compcache case.


> You're right to question the utility of the current swap discard
> placement.  That code is almost a year old, written from a position
> of great ignorance, yet only now do we appear to be on the threshold
> of having an SSD which really supports TRIM (ah, the Linux ATA TRIM
> support seems to have gone missing now, but perhaps it's been
> waiting for a reality to check against too - Willy?).
>

> I won't be surprised if we find that we need to move swap discard
> support much closer to swap_free (though I know from trying before
> that it's much messier there): in which case, even if we decided to
> keep your hotline to compcache (to avoid allocating bios etc.), it
> would be better placed alongside.
>

This new callback and discard can actually co-exist: Use callback to 
trigger small actions and discard for longer actions. Depending on use 
case, you might need both or either one of these.


I am not very sure how willing you are to accept this patch but let me 
send another revision with all the suggestions from you all.


Thanks for looking into this.
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
