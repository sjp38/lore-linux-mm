Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81ABE6B0005
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 00:33:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id u6-v6so58936eds.10
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 21:33:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g17-v6sor3332161ejs.30.2018.10.25.21.33.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 21:33:33 -0700 (PDT)
Date: Fri, 26 Oct 2018 04:33:30 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/3] mm, slub: not retrieve cpu_slub again in
 new_slab_objects()
Message-ID: <20181026043330.se7heqwuswule3zw@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181025094437.18951-1-richard.weiyang@gmail.com>
 <01000166ab7a489c-a877d05e-957c-45b1-8b62-9ede88db40a3-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000166ab7a489c-a877d05e-957c-45b1-8b62-9ede88db40a3-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

Hi, Christopher

I got one confusion on understanding one case in __slab_free().

The case is     : (new.frozen && !was_frozen)
My confusion is : Is it possible for the page to be on the full list?

This case (new.frozen && !was_frozen) happens when (!prior && !was_frozen).

  * !prior means this page is full
  * !was_frozen means this page is not in cpu_slab->page/partial

There are two cases to lead to (!prior && !was_frozen):

  * in get_freelist(), when page is full
  * in deactivate_slab(), when page is full

The first case will have a page in no list.
The second case will have a page in no list, or the page is put into
full list if SLUB_DEBUG is configured.

Do I miss something?

On Thu, Oct 25, 2018 at 01:46:49PM +0000, Christopher Lameter wrote:
>On Thu, 25 Oct 2018, Wei Yang wrote:
>
>> In current code, the following context always meets:
>>
>>   local_irq_save/disable()
>>     ___slab_alloc()
>>       new_slab_objects()
>>   local_irq_restore/enable()
>>
>> This context ensures cpu will continue running until it finish this job
>> before yield its control, which means the cpu_slab retrieved in
>> new_slab_objects() is the same as passed in.
>
>Interrupts can be switched on in new_slab() since it goes to the page
>allocator. See allocate_slab().
>
>This means that the percpu slab may change.

-- 
Wei Yang
Help you, Help me
