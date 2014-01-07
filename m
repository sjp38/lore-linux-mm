Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 601F26B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 00:27:32 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fb1so19526168pad.4
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 21:27:32 -0800 (PST)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id rt6si1528851pbc.228.2014.01.06.21.27.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 21:27:31 -0800 (PST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 10:57:27 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 34BA73940023
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 10:57:25 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s075RLLq53543006
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 10:57:22 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s075RMVw026618
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 10:57:23 +0530
Date: Tue, 7 Jan 2014 13:27:21 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
Message-ID: <52cb9043.a6e2440a.162c.0b69SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52B11765.8030005@oracle.com>
 <52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>
 <52B166CF.6080300@suse.cz>
 <52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>
 <20131218134316.977d5049209d9278e1dad225@linux-foundation.org>
 <52C71ACC.20603@oracle.com>
 <CA+55aFzDcFyyXwUUu5bLP3fsiuzxU7VPivpTPHgp8smvdTeESg@mail.gmail.com>
 <52C74972.6050909@suse.cz>
 <CA+55aFzq1iQqddGo-m=vutwMYn5CPf65Ergov5svKR4AWC3rUQ@mail.gmail.com>
 <6B2BA408B38BA1478B473C31C3D2074E2BF812BC82@SV-EXCHANGE1.Corp.FC.LOCAL>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6B2BA408B38BA1478B473C31C3D2074E2BF812BC82@SV-EXCHANGE1.Corp.FC.LOCAL>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, Nick Piggin <npiggin@suse.de>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Motohiro,
On Mon, Jan 06, 2014 at 08:47:23AM -0800, Motohiro Kosaki wrote:
>
>
>> -----Original Message-----
>> From: linus971@gmail.com [mailto:linus971@gmail.com] On Behalf Of Linus
>> Torvalds
>> Sent: Friday, January 03, 2014 7:18 PM
>> To: Vlastimil Babka
>> Cc: Sasha Levin; Andrew Morton; Wanpeng Li; Michel Lespinasse; Bob Liu;
>> Nick Piggin; Motohiro Kosaki JP; Rik van Riel; David Rientjes; Mel Gorman;
>> Minchan Kim; Hugh Dickins; Johannes Weiner; linux-mm; Linux Kernel Mailing
>> List
>> Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear
>> VMAs
>> 
>> On Fri, Jan 3, 2014 at 3:36 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> >
>> > I'm for going with the removal of BUG_ON. The TestSetPageMlocked
>> > should provide enough race protection.
>> 
>> Maybe. But dammit, that's subtle, and I don't think you're even right.
>> 
>> It basically depends on mlock_vma_page() and munlock_vma_page() being
>> able to run CONCURRENTLY on the same page. In particular, you could have a
>> mlock_vma_page() set the bit on one CPU, and munlock_vma_page()
>> immediately clearing it on another, and then the rest of those functions
>> could run with a totally arbitrary interleaving when working with the exact
>> same page.
>> 
>> They both do basically
>> 
>>     if (!isolate_lru_page(page))
>>         putback_lru_page(page);
>> 
>> but one or the other would randomly win the race (it's internally protected
>> by the lru lock), and *if* the munlock_vma_page() wins it, it would also do
>> 
>>     try_to_munlock(page);
>> 
>> but if mlock_vma_page() wins it, that wouldn't happen. That looks entirely
>> broken - you end up with the PageMlocked bit clear, but
>> try_to_munlock() was never called on that page, because
>> mlock_vma_page() got to the page isolation before the "subsequent"
>> munlock_vma_page().
>> 
>> And this is very much what the page lock serialization would prevent.
>> So no, the PageMlocked in *no* way gives serialization. It's an atomic bit op,
>> yes, but that only "serializes" in one direction, not when you can have a mix
>> of bit setting and clearing.
>> 
>> So quite frankly, I think you're wrong. The BUG_ON() is correct, or at least
>> enforces some kind of ordering. And try_to_unmap_cluster() is just broken
>> in calling that without the page being locked. That's my opinion. There may
>> be some *other* reason why it all happens to work, but no,
>> "TestSetPageMlocked should provide enough race protection" is simply not
>> true, and even if it were, it's way too subtle and odd to be a good rule.
>> 
>> So I really object to just removing the BUG_ON(). Not with a *lot* more
>> explanation as to why these kinds of issues wouldn't matter.
>
>I don't have a perfect answer. But I can explain a bit history. Let's me try.
>
>First off, 5 years ago, Lee's original putback_lru_page() implementation required
>page-lock, but I removed the restriction months later. That's why we can see 
>strange BUG_ON here. 
>
>5 years ago, both mlock(2) and munlock(2) called do_mlock() and it was protected  by 
>mmap_sem (write mdoe). Then, mlock and munlock had no race. 
>Now, __mm_populate() (called by mlock(2)) is only protected by mmap_sem read-mode. However it is enough to
>protect against munlock.
>
>Next, In case of mlock vs reclaim, the key is that mlock(2) has two step operation. 1) turn on VM_LOCKED under
>mmap_sem write-mode, 2) turn on Page_Mlocked under mmap_sem read-mode. 

| If reclaim race against step (1), reclaim must lose because it uses trylock. 

Could you point out when page is locked during 1)? 

Regards,
Wanpeng Li 

>On the other hand, if reclaim race against step (2), reclaim must detect
>VM_LOCKED because both VM_LOCKED modifier and observer take mmap-sem.
>
>By the way, page isolation is still necessary because we need to protect another page modification like page migration.
>
>
>My memory was alomostly flushed and I might lost some technical concern and past discussion. Please point me out,
>If I am overlooking something.
>
>Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
