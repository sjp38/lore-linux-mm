Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8586B0031
	for <linux-mm@kvack.org>; Sat,  4 Jan 2014 03:09:22 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id d49so6872348eek.5
        for <linux-mm@kvack.org>; Sat, 04 Jan 2014 00:09:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si74550429eew.201.2014.01.04.00.09.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 00:09:21 -0800 (PST)
Message-ID: <52C7C1AA.2070701@suse.cz>
Date: Sat, 04 Jan 2014 09:09:14 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>	<52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>	<52B11765.8030005@oracle.com>	<52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>	<52B166CF.6080300@suse.cz>	<52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>	<20131218134316.977d5049209d9278e1dad225@linux-foundation.org>	<52C71ACC.20603@oracle.com>	<CA+55aFzDcFyyXwUUu5bLP3fsiuzxU7VPivpTPHgp8smvdTeESg@mail.gmail.com>	<52C74972.6050909@suse.cz> <CA+55aFzq1iQqddGo-m=vutwMYn5CPf65Ergov5svKR4AWC3rUQ@mail.gmail.com>
In-Reply-To: <CA+55aFzq1iQqddGo-m=vutwMYn5CPf65Ergov5svKR4AWC3rUQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 01/04/2014 01:18 AM, Linus Torvalds wrote:
> On Fri, Jan 3, 2014 at 3:36 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> I'm for going with the removal of BUG_ON. The TestSetPageMlocked should provide enough
>> race protection.
> 
> Maybe. But dammit, that's subtle, and I don't think you're even right.
> 
> It basically depends on mlock_vma_page() and munlock_vma_page() being
> able to run CONCURRENTLY on the same page. In particular, you could
> have a mlock_vma_page() set the bit on one CPU, and munlock_vma_page()
> immediately clearing it on another, and then the rest of those
> functions could run with a totally arbitrary interleaving when working
> with the exact same page.
> 
> They both do basically
> 
>     if (!isolate_lru_page(page))
>         putback_lru_page(page);
> 
> but one or the other would randomly win the race (it's internally
> protected by the lru lock), and *if* the munlock_vma_page() wins it,
> it would also do
> 
>     try_to_munlock(page);
> 
> but if mlock_vma_page() wins it, that wouldn't happen. That looks
> entirely broken - you end up with the PageMlocked bit clear, but
> try_to_munlock() was never called on that page, because
> mlock_vma_page() got to the page isolation before the "subsequent"
> munlock_vma_page().

I got the impression (see e.g. munlock_vma_page() comments) that the
whole thing is designed with this possibility in mind. isolate_lru_page()
may fail (presumably also in other scenarios than this) and if
try_to_munlock() was not called here, then yes the page might lose the
PageMlocked bit and go to LRU instead of inevictable list, but
try_to_unmap() should catch and fix this. That would also explain why
mlock_vma_page() is called from try_to_unmap_cluster().
So if I understand correctly, PageMlocked bit is not something that has
to be correctly set 100% of the time, but when it's set correctly most
of the time, then most of these pages will go to inevictable list and spare
vmscan's time.

> And this is very much what the page lock serialization would prevent.
> So no, the PageMlocked in *no* way gives serialization. It's an atomic
> bit op, yes, but that only "serializes" in one direction, not when you
> can have a mix of bit setting and clearing.
> 
> So quite frankly, I think you're wrong. The BUG_ON() is correct, or at
> least enforces some kind of ordering. And try_to_unmap_cluster() is
> just broken in calling that without the page being locked. That's my
> opinion. There may be some *other* reason why it all happens to work,
> but no, "TestSetPageMlocked should provide enough race protection" is
> simply not true, and even if it were, it's way too subtle and odd to
> be a good rule.

Right, it was stupid of me to write such strong statement without any
details. I wanted to review that patch when back at work next week, but
since it came up now, I just wanted to point out that it's in the pipeline
for this bug.

> So I really object to just removing the BUG_ON(). Not with a *lot*
> more explanation as to why these kinds of issues wouldn't matter.
> 
>                  Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
