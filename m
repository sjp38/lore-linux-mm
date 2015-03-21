Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AD4266B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 20:18:34 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so122954521pdb.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 17:18:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e9si11790904pas.150.2015.03.20.17.18.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 17:18:33 -0700 (PDT)
Message-ID: <550CB8D1.9030608@oracle.com>
Date: Fri, 20 Mar 2015 18:18:25 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550C37C9.2060200@oracle.com> <CA+55aFxoVPRuFJGuP_=0-NCiqx_NPeJBv+SAZqbAzeC9AhN+CA@mail.gmail.com> <550CA3F9.9040201@oracle.com>
In-Reply-To: <550CA3F9.9040201@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 3/20/15 4:49 PM, David Ahern wrote:
> On 3/20/15 3:17 PM, Linus Torvalds wrote:
>> In other words, if I read that sparc asm right (and it is very likely
>> that I do *not*), then "objp" is NULL, and that's why you crash.
>
> That does appear to be why. I put a WARN_ON before
> clear_obj_pfmemalloc() if objpp[i] is NULL. I got 2 splats during an
> 'allyesconfig' build and the system stayed up.
>
>>
>> That's odd, because we know that objp cannot be NULL in
>> kmem_slab_free() (even if we allowed it, like with kfree(),
>> remove_vma() cannot possibly have a NULL vma, since ti dereferences it
>> multiple times).
>>
>> So I must be misreading this completely. Somebody with better sparc
>> debugging mojo should double-check my logic. How would objp be NULL?
>
> I'll add checks to higher layers and see if it reveals anything.
>
> I did ask around and apparently this bug is hit only with the new M7
> processors. DaveM: that's why you are not hitting this.

Here's another data point: If I disable NUMA I don't see the problem. 
Performance drops, but no NULL pointer splats which would have been panics.

The 128 cpu ldom with NUMA enabled shows the problem every single time I 
do a kernel compile (-j 128). With NUMA disabled I have done 3 
allyesconfig compiles without hitting the problem. I'll put the compiles 
into a loop while I head out for dinner.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
