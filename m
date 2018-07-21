Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 562756B0003
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 10:39:09 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v80-v6so8181389ywc.13
        for <linux-mm@kvack.org>; Sat, 21 Jul 2018 07:39:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w190-v6sor1183154ybg.115.2018.07.21.07.39.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Jul 2018 07:39:07 -0700 (PDT)
Subject: Re: [Bug 200105] High paging activity as soon as the swap is touched
 (with steps and code to reproduce it)
References: <bug-200105-8545@https.bugzilla.kernel.org/>
 <bug-200105-8545-FomWhXSVhq@https.bugzilla.kernel.org/>
 <191624267.262238.1532074743289@mail.yahoo.com>
From: Daniel Jordan <lkmldmj@gmail.com>
Message-ID: <f20b1529-fcb9-8d0a-6259-fe76977e00d6@gmail.com>
Date: Sat, 21 Jul 2018 10:39:05 -0400
MIME-Version: 1.0
In-Reply-To: <191624267.262238.1532074743289@mail.yahoo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john terragon <terragonjohn@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Michal Hocko <mhocko@kernel.org>

On 07/20/2018 04:19 AM, john terragon wrote:
> 
> On Friday, July 20, 2018, 2:03:48 AM GMT+2, bugzilla-daemon@bugzilla.kernel.org <bugzilla-daemon@bugzilla.kernel.org> wrote:
>  >
>  >https://bugzilla.kernel.org/show_bug.cgi?id=200105 <https://bugzilla.kernel.org/show_bug.cgi?id=200105>
>  >
>  >--- Comment #42 from Andrew Morton (akpm@linux-foundation.org <mailto:akpm@linux-foundation.org>) ---
>  >Sorry, but nobody reads bugzilla.A  I tried to switch this discussion to an
>  >email thread for a reason!
>  >
>  >Please resend all this (useful) info in reply to the email thread which I
>  >created for this purpose.
> 
> I'll resend the last message and attachments. Anyone interested on the previous "episodes" go read
> https://bugzilla.kernel.org/show_bug.cgi?id=200105

The summary is that John has put together a reliable reproducer for a problem he's seeing where on high memory usage any of his desktop systems with SSDs hang for around a minute, completely unresponsive, and swaps out 2-3x more memory than the system is allocating.

John's issue only happens using a LUKS encrypted swap partition, unencrypted swap or swap encrypted without LUKS works fine.

In one test (out5.txt) where most system memory is taken by anon pages beforehand, the heavy direct reclaim that Michal noticed lasts for 24 seconds, during which on average if I've crunched my numbers right, John's test program was allocating at 4MiB/s, the system overall (pgalloc_normal) was allocating at 235MiB/s, and the system was swapping out (pswpout) at 673MiB/s.  pgalloc_normal and pswpout stay roughly the same each second, no big swings.

Is the disparity between allocation and swapout rate expected?

John ran perf during another test right before the last test program was started (this doesn't include the initial large allocation bringing the system close to swapping).  The top five allocators (kmem:mm_page_alloc):

# Overhead      Pid:Command
# ........  .......................
#
     48.45%     2005:memeater     # the test program
     32.08%       73:kswapd0
      3.16%     1957:perf_4.17
      1.41%     1748:watch
      1.16%     2043:free

So it seems to be just reclaim activity, but why so much when the test program only allocates at 4MiB/s?

John, adding -g to perf record would show call stacks.


I'll be away for 2.5 weeks so won't be able to get back to this until then.
