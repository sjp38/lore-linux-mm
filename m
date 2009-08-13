Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BD8036B005D
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 22:41:39 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so107448rvb.26
        for <linux-mm@kvack.org>; Wed, 12 Aug 2009 19:41:42 -0700 (PDT)
Message-ID: <4A837D5A.3070407@vflare.org>
Date: Thu, 13 Aug 2009 08:11:30 +0530
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

Oh, I missed this one.

This small patch can be considered as first step for merging compcache 
to mainline :)   Actually, it requires callbacks for swapon, swapoff too 
but that, I think, should be done in a separate patches.

BTW, last time compcache was not accepted due to lack of performance 
numbers. Now the project has lot more data for various cases:
http://code.google.com/p/compcache/wiki/Performance
Still need to collect data for worst-case behaviors and such...


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
