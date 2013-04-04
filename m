Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A04C26B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 14:48:02 -0400 (EDT)
Received: by mail-ve0-f169.google.com with SMTP id d10so2971322vea.28
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 11:48:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1304041120510.26822@eggly.anvils>
References: <alpine.LNX.2.00.1304041120510.26822@eggly.anvils>
Date: Thu, 4 Apr 2013 11:48:01 -0700
Message-ID: <CA+55aFwCG2h1ijWTCJ38LVcUyczDAfk72c4MVSU+_-BiLoMOOw@mail.gmail.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Stancek <jstancek@redhat.com>, Jakub Jelinek <jakub@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ian Lance Taylor <iant@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Apr 4, 2013 at 11:35 AM, Hugh Dickins <hughd@google.com> wrote:
>
> find_vma() can be called by multiple threads with read lock
> held on mm->mmap_sem and any of them can update mm->mmap_cache.
> Prevent compiler from re-fetching mm->mmap_cache, because other
> readers could update it in the meantime:

Ack. I do wonder if we should mark the unlocked update too some way
(also in find_vma()), although it's probably not a problem in practice
since there's no way the compiler can reasonably really do anything
odd with it. We *could* make that an ACCESS_ONCE() write too just to
highlight the fact that it's an unlocked write to this optimistic data
structure.

Anyway, applied.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
