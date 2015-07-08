Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4FE6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 03:34:32 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so157447258qkh.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 00:34:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i35si1915796qgd.126.2015.07.08.00.34.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 00:34:31 -0700 (PDT)
Subject: Re: [dm-devel] [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com>
 <20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
From: Zdenek Kabelac <zkabelac@redhat.com>
Message-ID: <559CD283.4020605@redhat.com>
Date: Wed, 8 Jul 2015 09:34:27 +0200
MIME-Version: 1.0
In-Reply-To: <20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: device-mapper development <dm-devel@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <msnitzer@redhat.com>, Edward Thornber <thornber@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Alasdair G. Kergon" <agk@redhat.com>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vivek Goyal <vgoyal@redhat.com>

Dne 7.7.2015 v 23:41 Andrew Morton napsal(a):
> On Tue, 7 Jul 2015 11:10:09 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:
>
>> Introduce the functions kvmalloc and kvmalloc_node. These functions
>> provide reliable allocation of object of arbitrary size. They attempt to
>> do allocation with kmalloc and if it fails, use vmalloc. Memory allocated
>> with these functions should be freed with kvfree.
>
> Sigh.  We've resisted doing this because vmalloc() is somewhat of a bad
> thing, and we don't want to make it easy for people to do bad things.
>
> And vmalloc is bad because a) it's slow and b) it does GFP_KERNEL
> allocations for page tables and c) it is susceptible to arena
> fragmentation.
>
> We'd prefer that people fix their junk so it doesn't depend upon large
> contiguous allocations.  This isn't userspace - kernel space is hostile
> and kernel code should be robust.
>
> So I dunno.  Should we continue to make it a bit more awkward to use
> vmalloc()?  Probably that tactic isn't being very successful - people
> will just go ahead and open-code it.  And given the surprising amount
> of stuff you've placed in kvmalloc_node(), they'll implement it
> incorrectly...

Hi

 From my naive view:  4K-128K were nice restriction in the age of 16MB Pentium 
machines - but the time has changed and now users need to work with TB of memory.

So if the kernel driver is going to maintain such a huge chunk - it could 
hardly fit its resources into KB blocks.

So there are options - you could make complex code inside the driver to 
address every little kmalloc-ed chunk (and have a lot of potential for bugs) 
or you could always use vmalloc() and leave it on 'slow/GFP_KERNEL'.

So IMHO it's quite right to have the 'middle' road here - if there is enough 
memory to proceed with kmalloc - fine and if not - then driver will be 
somewhat slower but the coder will not have to spend months of coding 
reinvention of the wheel...

Personally I even find 128K pretty small if this limit comes from MB era and 
we are in the age of commonly available 32G laptops...

IMHO also it's kind of weird when kernel is not able to satisfy  128K 
allocation if there are gigabytes of free RAM in my system - there should be 
some defrag process running behind if there is such constrained kmalloc 
interface...

Zdenek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
