Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9F76B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:48:08 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id p19-v6so10895760plo.14
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:48:08 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s7-v6si14445472pfm.85.2018.05.21.15.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 15:48:07 -0700 (PDT)
Subject: Re: Why do we let munmap fail?
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
 <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
 <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
 <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com>
Date: Mon, 21 May 2018 15:48:05 -0700
MIME-Version: 1.0
In-Reply-To: <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On 05/21/2018 03:35 PM, Daniel Colascione wrote:
>> I know folks use memfd to figure out
>> how much memory pressure we are under.  I guess that would trigger when
>> you consume lots of memory with VMAs.
> 
> I think you're thinking of the VM pressure level special files, not memfd,
> which creates an anonymous tmpfs file.

Yep, you're right.

>> VMAs are probably the most similar to things like page tables that are
>> kernel memory that can't be directly reclaimed, but do get freed at
>> OOM-kill-time.  But, VMAs are a bit harder than page tables because
>> freeing a page worth of VMAs does not necessarily free an entire page.
> 
> I don't understand. We can reclaim memory used by VMAs by killing the
> process or processes attached to the address space that owns those VMAs.
> The OOM killer should Just Work. Why do we have to have some special limit
> of VMA count?

The OOM killer doesn't take the VMA count into consideration as far as I
remember.  I can't think of any reason why not except for the internal
fragmentation problem.

The current VMA limit is ~12MB of VMAs per process, which is quite a
bit.  I think it would be reasonable to start considering that in OOM
decisions, although it's surely inconsequential except on very small
systems.

There are also certainly denial-of-service concerns if you allow
arbitrary numbers of VMAs.  The rbtree, for instance, is O(log(n)), but
I 'd be willing to be there are plenty of things that fall over if you
let the ~65k limit get 10x or 100x larger.
