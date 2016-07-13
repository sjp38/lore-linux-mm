Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19BC06B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 10:04:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so82841356pap.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 07:04:34 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id k4si3167018pfj.91.2016.07.13.07.04.32
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 07:04:32 -0700 (PDT)
Subject: Re: [PATCH 0/4] [RFC][v4] Workaround for Xeon Phi PTE A/D bits
 erratum
References: <20160701174658.6ED27E64@viggo.jf.intel.com>
 <1467412092.7422.56.camel@kernel.crashing.org>
 <9c09c63c-5c2a-20a4-d68b-a6dc2f88ecaa@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <57864A6F.6070202@sr71.net>
Date: Wed, 13 Jul 2016 07:04:31 -0700
MIME-Version: 1.0
In-Reply-To: <9c09c63c-5c2a-20a4-d68b-a6dc2f88ecaa@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com

On 07/13/2016 04:37 AM, Vlastimil Babka wrote:
> On 07/02/2016 12:28 AM, Benjamin Herrenschmidt wrote:
>> With the errata, don't you have a situation where a processor in
>> the second category will write and set D despite P having been
>> cleared (due to the race) and thus causing us to miss the transfer
>> of that D to the struct
>> page and essentially completely miss that the physical page is dirty ?
> 
> Seems to me like this is indeed possible, but...

No, this isn't possible with the erratum.

I had some off-list follow up with Ben, and included this description in
the later post of the patch:
> These bits are truly "stray".  In the case of the Dirty bit, the
> thread associated with the stray set was *not* allowed to write to
> the page.  This means that we do not have to launder the bit(s); we
> can simply ignore them.


>> (Leading to memory corruption).
> 
> ... what memory corruption, exactly?

In this (non-existent) scenario, we would lose writes to mmap()'d files
because we did not see the dirty bit during the "get" part of
ptep_get_and_clear().

> If a process is writing to its
> memory from one thread and unmapping it from other thread at the same
> time, there are no guarantees anyway?

It's not just unmapping, it's also swap, NUMA migration, etc...  We
clear the PTE, flush, then re-populate it.

> Would anything sensible rely on
> the guarantee that if the write in such racy scenario didn't end up as a
> segfault (i.e. unmapping was faster), then it must hit the disk? Or are
> there any other scenarios where zap_pte_range() is called? Hmm, but how
> does this affect the page migration scenario, can we lose the D bit there?

Yeah, it's not just zap_pte_range(), it's everywhere that we change a
present PTE.

> And maybe related thing that just occured to me, what if page is made
> non-writable during fork() to catch COW? Any race in that one, or just
> the P bit? But maybe the argument would be the same as above...

Yeah, the argument is the same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
