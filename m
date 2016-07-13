Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0CB6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 07:37:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so33660868wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:37:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ek7si427453wjb.197.2016.07.13.04.37.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 04:37:24 -0700 (PDT)
Subject: Re: [PATCH 0/4] [RFC][v4] Workaround for Xeon Phi PTE A/D bits
 erratum
References: <20160701174658.6ED27E64@viggo.jf.intel.com>
 <1467412092.7422.56.camel@kernel.crashing.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9c09c63c-5c2a-20a4-d68b-a6dc2f88ecaa@suse.cz>
Date: Wed, 13 Jul 2016 13:37:21 +0200
MIME-Version: 1.0
In-Reply-To: <1467412092.7422.56.camel@kernel.crashing.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com

On 07/02/2016 12:28 AM, Benjamin Herrenschmidt wrote:
> On Fri, 2016-07-01 at 10:46 -0700, Dave Hansen wrote:
>> The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
>> Landing) has an erratum where a processor thread setting the Accessed
>> or Dirty bits may not do so atomically against its checks for the
>> Present bit.  This may cause a thread (which is about to page fault)
>> to set A and/or D, even though the Present bit had already been
>> atomically cleared.
>
> Interesting.... I always wondered where in the Intel docs did it specify
> that present was tested atomically with setting of A and D ... I couldn't
> find it.
>
> Isn't there a more fundamental issue however that you may actually lose
> those bits ? For example if we do an munmap, in zap_pte_range()
>
> We first exchange all the PTEs with 0 with ptep_get_and_clear_full()
> and we then transfer D that we just read into the struct page.
>
> We rely on the fact that D will never be set again, what we go it a
> "final" D bit. IE. We rely on the fact that a processor either:
>
>    - Has a cached PTE in its TLB with D set, in which case it can still
> write to the page until we flush the TLB or
>
>    - Doesn't have a cached PTE in its TLB with D set and so will fail
> to do so due to the atomic P check, thus never writing.
>
> With the errata, don't you have a situation where a processor in the second
> category will write and set D despite P having been cleared (due to the
> race) and thus causing us to miss the transfer of that D to the struct
> page and essentially completely miss that the physical page is dirty ?

Seems to me like this is indeed possible, but...

> (Leading to memory corruption).

... what memory corruption, exactly? If a process is writing to its 
memory from one thread and unmapping it from other thread at the same 
time, there are no guarantees anyway? Would anything sensible rely on 
the guarantee that if the write in such racy scenario didn't end up as a 
segfault (i.e. unmapping was faster), then it must hit the disk? Or are 
there any other scenarios where zap_pte_range() is called? Hmm, but how 
does this affect the page migration scenario, can we lose the D bit there?

And maybe related thing that just occured to me, what if page is made 
non-writable during fork() to catch COW? Any race in that one, or just 
the P bit? But maybe the argument would be the same as above...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
