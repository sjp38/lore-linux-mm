Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m3UMFh7C031314
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 23:15:43 +0100
Received: from fg-out-1718.google.com (fgad23.prod.google.com [10.86.55.23])
	by zps78.corp.google.com with ESMTP id m3UMFKca011535
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:15:41 -0700
Received: by fg-out-1718.google.com with SMTP id d23so338619fga.5
        for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:15:41 -0700 (PDT)
Message-ID: <d43160c70804301515i7e02a3d5ha3b84d4b26ae68bd@mail.gmail.com>
Date: Wed, 30 Apr 2008 18:15:40 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: [RFC/PATH 1/2] MM: Make Page Tables Relocatable -- conditional flush
In-Reply-To: <4818CEDA.8000908@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080429134254.635FEDC683@localhost> <4818B262.5020909@goop.org>
	 <d43160c70804301140q16aed710rcafcab95876de078@mail.gmail.com>
	 <4818CEDA.8000908@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 3:56 PM, Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>>> - How does it deal with migrating the accessed/dirty bits in ptes if
>>>  cpus can be using old versions of the pte for a while after the
>>>  copy?  Losing dirty updates can lose data, so explicitly addressing
>>>  this point in code and/or comments is important.
>>>
>>
>> It doesn't currently.  Although it's easy to fix.  Just before the
>> free, we just have to copy the dirty bits again.  Slow, but not in a
>> critical path.
>>
>
> But the issue I'm concerned about is what happens if a process writes the
> page, causing its cpu to mark the (old, in-limbo) pte dirty.  Meanwhile
> someone else is scanning the pagetables looking for things to evict.  It
> check the (shiny new) pte, finds it not dirty, and decides to evict the
> apparently clean page.
>
> What, for that matter, stops a page from being evicted from under a limboed
> mapping?  Does it get accounted for (I guess the existing tlb flushing
> should be sufficient to keep it under control).

The delimbo functions can be extended to deal with the dirty bit.
They already have to be called to make sure the cpu is looking at the
proper page flags.  The easiest solution to the races is probably to
make the delimbo pte functions flush the tlb cache to make sure the
cpu will also be looking at the correct entry to update flags.
Otherwise the atomic ptep* functions would probably need to be
modified.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
