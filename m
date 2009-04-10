Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06CBB5F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 13:56:25 -0400 (EDT)
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id n3AHvFCW003427
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 18:57:15 +0100
Received: from rv-out-0506.google.com (rvbf6.prod.google.com [10.140.82.6])
	by zps76.corp.google.com with ESMTP id n3AHvDUG018261
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 10:57:13 -0700
Received: by rv-out-0506.google.com with SMTP id f6so962707rvb.5
        for <linux-mm@kvack.org>; Fri, 10 Apr 2009 10:57:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.0904100835150.4583@localhost.localdomain>
References: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com>
	 <20090409230205.310c68a7.akpm@linux-foundation.org>
	 <20090410073042.GB21149@localhost>
	 <alpine.LFD.2.00.0904100835150.4583@localhost.localdomain>
Date: Fri, 10 Apr 2009 10:57:12 -0700
Message-ID: <604427e00904101057o78868d84y58e3531ac8334505@mail.gmail.com>
Subject: Re: [PATCH][1/2]page_fault retry with NOPAGE_RETRY
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

2009/4/10 Linus Torvalds <torvalds@linux-foundation.org>:
>
>
> On Fri, 10 Apr 2009, Wu Fengguang wrote:
>
>> On Fri, Apr 10, 2009 at 02:02:05PM +0800, Andrew Morton wrote:
>>
>> > Can we please redo this as:
>> >
>> >
>> >     int write;
>> >     unsigned int flags;
>> >
>> >     /*
>> >      * Big fat comment explaining the next three lines goes here
>> >      */
>>
>> Basically it's doing a
>>         (is_write_access  | FAULT_FLAG_RETRY) =>
>>         (FAULT_FLAG_WRITE | FAULT_FLAG_RETRY)
>> by extracting the bool part:
>> >     write = write_access & ~FAULT_FLAG_RETRY;
>> convert bool to a bit flag:
>> >     unsigned int flags = (write ? FAULT_FLAG_WRITE : 0);

Fengguang: thank you for your comments. i agree this is confusing...
>
> The point is, we shouldn't do that.
>
> Your code is confused, because it uses "write_access" as if it had the old
> behaviour (boolean to say "write") _plus_ the new behavior (bitmask to say
> "retry"), and that's just wrong.
>
> Just get rid of "write_access" entirely, and switch it over to something
> that is a pure bitmask.
>
> Yes, it means a couple of new preliminary patches that switch all callers
> of handle_mm_fault() over to using the VM_FLAGS, but that's not a big
> deal.
>
> I'm following up this email with two _example_ patches. They are untested,
> but they look sane. I'd like the series to _start_ with these, and then
> you can pass FAULT_FLAGS_WRITE | FAULT_FLAGS_RETRY down to
> handle_mm_fault() cleanly.
>
> Hmm? Note the _untested_ part on the patches to follow. It was done very
> mechanically, and the patches look sane, but .. !!!

Thanks Linus for your comments. I will take Peter Zijlstra's patches
(the _untested_ part)
which basically replaces the write_access as a flag as you mentioned
and start from there.

My next step is to cleanup the patch with comments in the thread so
far and post the new version.
Anything else i missed, please let me know. thanks

--Ying
>
>                        Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
