Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75ADB6B0006
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 10:43:51 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x204-v6so11876846qka.6
        for <linux-mm@kvack.org>; Sat, 21 Jul 2018 07:43:51 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g36-v6si362364qte.134.2018.07.21.07.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Jul 2018 07:43:50 -0700 (PDT)
Subject: Re: [Bug 200105] High paging activity as soon as the swap is touched
 (with steps and code to reproduce it)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
References: <bug-200105-8545@https.bugzilla.kernel.org/>
 <bug-200105-8545-FomWhXSVhq@https.bugzilla.kernel.org/>
 <191624267.262238.1532074743289@mail.yahoo.com>
 <f20b1529-fcb9-8d0a-6259-fe76977e00d6@gmail.com>
Message-ID: <1586f636-a2d3-4e9f-76f9-b4abe2d6eb82@oracle.com>
Date: Sat, 21 Jul 2018 10:43:42 -0400
MIME-Version: 1.0
In-Reply-To: <f20b1529-fcb9-8d0a-6259-fe76977e00d6@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john terragon <terragonjohn@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Michal Hocko <mhocko@kernel.org>



On 07/21/2018 10:39 AM, Daniel Jordan wrote:
> On 07/20/2018 04:19 AM, john terragon wrote:
>>
>> On Friday, July 20, 2018, 2:03:48 AM GMT+2, bugzilla-daemon@bugzilla.kernel.org <bugzilla-daemon@bugzilla.kernel.org> wrote:
>> A >
>> A >https://bugzilla.kernel.org/show_bug.cgi?id=200105 <https://bugzilla.kernel.org/show_bug.cgi?id=200105>
>> A >
>> A >--- Comment #42 from Andrew Morton (akpm@linux-foundation.org <mailto:akpm@linux-foundation.org>) ---
>> A >Sorry, but nobody reads bugzilla.A  I tried to switch this discussion to an
>> A >email thread for a reason!
>> A >
>> A >Please resend all this (useful) info in reply to the email thread which I
>> A >created for this purpose.
>>
>> I'll resend the last message and attachments. Anyone interested on the previous "episodes" go read
>> https://bugzilla.kernel.org/show_bug.cgi?id=200105
> 
> The summary is that John has put together a reliable reproducer for a problem he's seeing where on high memory usage any of his desktop systems with SSDs hang for around a minute, completely unresponsive, and swaps out 2-3x more memory than the system is allocating.
> 
> John's issue only happens using a LUKS encrypted swap partition, unencrypted swap or swap encrypted without LUKS works fine.
> 
> In one test (out5.txt) where most system memory is taken by anon pages beforehand, the heavy direct reclaim that Michal noticed lasts for 24 seconds, during which on average if I've crunched my numbers right, John's test program was allocating at 4MiB/s, the system overall (pgalloc_normal) was allocating at 235MiB/s, and the system was swapping out (pswpout) at 673MiB/s.A  pgalloc_normal and pswpout stay roughly the same each second, no big swings.
> 
> Is the disparity between allocation and swapout rate expected?
> 
> John ran perf during another test right before the last test program was started (this doesn't include the initial large allocation bringing the system close to swapping).A  The top five allocators (kmem:mm_page_alloc):
> 
> # OverheadA A A A A  Pid:Command
> # ........A  .......................
> #
>  A A A  48.45%A A A A  2005:memeaterA A A A  # the test program
>  A A A  32.08%A A A A A A  73:kswapd0
>  A A A A  3.16%A A A A  1957:perf_4.17
>  A A A A  1.41%A A A A  1748:watch
>  A A A A  1.16%A A A A  2043:free
> 
> So it seems to be just reclaim activity, but why so much when the test program only allocates at 4MiB/s?

Should add that during the 24 seconds, reclaim efficiency for both kswapd and direct (pgsteal/pgscan) hovered around 1%, which seems low.

The 24 seconds cover =S 1530092789 to =S 1530092812 in out5.txt from bugzilla.
