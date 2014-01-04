Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5AF6B0031
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 19:18:41 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so7006156eek.1
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 16:18:40 -0800 (PST)
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
        by mx.google.com with ESMTPS id h45si73504391eeo.67.2014.01.03.16.18.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 16:18:40 -0800 (PST)
Received: by mail-ee0-f47.google.com with SMTP id e51so5899441eek.20
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 16:18:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52C74972.6050909@suse.cz>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
	<52B11765.8030005@oracle.com>
	<52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>
	<52B166CF.6080300@suse.cz>
	<52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>
	<20131218134316.977d5049209d9278e1dad225@linux-foundation.org>
	<52C71ACC.20603@oracle.com>
	<CA+55aFzDcFyyXwUUu5bLP3fsiuzxU7VPivpTPHgp8smvdTeESg@mail.gmail.com>
	<52C74972.6050909@suse.cz>
Date: Fri, 3 Jan 2014 16:18:05 -0800
Message-ID: <CA+55aFzq1iQqddGo-m=vutwMYn5CPf65Ergov5svKR4AWC3rUQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Jan 3, 2014 at 3:36 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> I'm for going with the removal of BUG_ON. The TestSetPageMlocked should provide enough
> race protection.

Maybe. But dammit, that's subtle, and I don't think you're even right.

It basically depends on mlock_vma_page() and munlock_vma_page() being
able to run CONCURRENTLY on the same page. In particular, you could
have a mlock_vma_page() set the bit on one CPU, and munlock_vma_page()
immediately clearing it on another, and then the rest of those
functions could run with a totally arbitrary interleaving when working
with the exact same page.

They both do basically

    if (!isolate_lru_page(page))
        putback_lru_page(page);

but one or the other would randomly win the race (it's internally
protected by the lru lock), and *if* the munlock_vma_page() wins it,
it would also do

    try_to_munlock(page);

but if mlock_vma_page() wins it, that wouldn't happen. That looks
entirely broken - you end up with the PageMlocked bit clear, but
try_to_munlock() was never called on that page, because
mlock_vma_page() got to the page isolation before the "subsequent"
munlock_vma_page().

And this is very much what the page lock serialization would prevent.
So no, the PageMlocked in *no* way gives serialization. It's an atomic
bit op, yes, but that only "serializes" in one direction, not when you
can have a mix of bit setting and clearing.

So quite frankly, I think you're wrong. The BUG_ON() is correct, or at
least enforces some kind of ordering. And try_to_unmap_cluster() is
just broken in calling that without the page being locked. That's my
opinion. There may be some *other* reason why it all happens to work,
but no, "TestSetPageMlocked should provide enough race protection" is
simply not true, and even if it were, it's way too subtle and odd to
be a good rule.

So I really object to just removing the BUG_ON(). Not with a *lot*
more explanation as to why these kinds of issues wouldn't matter.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
