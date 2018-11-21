Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1F686B26BD
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 12:31:27 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so3335476edb.5
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:31:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si1637936eda.326.2018.11.21.09.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 09:31:25 -0800 (PST)
Date: Wed, 21 Nov 2018 18:31:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181121173123.GS12932@dhcp22.suse.cz>
References: <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv>
 <20181119124033.GJ22247@dhcp22.suse.cz>
 <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
 <20181119173312.GV22247@dhcp22.suse.cz>
 <alpine.LSU.2.11.1811191215290.15640@eggly.anvils>
 <20181119205907.GW22247@dhcp22.suse.cz>
 <20181120015644.GA5727@MiWiFi-R3L-srv>
 <alpine.LSU.2.11.1811192127130.2848@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811192127130.2848@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Baoquan He <bhe@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On Mon 19-11-18 21:44:41, Hugh Dickins wrote:
[...]
> [PATCH] mm: put_and_wait_on_page_locked() while page is migrated
> 
> We have all assumed that it is essential to hold a page reference while
> waiting on a page lock: partly to guarantee that there is still a struct
> page when MEMORY_HOTREMOVE is configured, but also to protect against
> reuse of the struct page going to someone who then holds the page locked
> indefinitely, when the waiter can reasonably expect timely unlocking.

I would add the following for the "problem statement". Feel free to
reuse per your preference:
"
An elevated reference count, however, stands in the way of migration and
forces it to fail with a bad timing. This is especially a problem for
memory offlining which retries for ever (or until the operation is
terminated from userspace) because a heavy refault workload can trigger
essentially an endless loop of migration failures. Therefore
__migration_entry_wait is essentially harmful for the even it is waiting
for.
"

> But in fact, so long as wait_on_page_bit_common() does the put_page(),
> and is careful not to rely on struct page contents thereafter, there is
> no need to hold a reference to the page while waiting on it.  That does
> mean that this case cannot go back through the loop: but that's fine for
> the page migration case, and even if used more widely, is limited by the
> "Stop walking if it's locked" optimization in wake_page_function().

I would appreciate this would be more explicit about the existence of
the elevated-ref-count problem but it reduces it to a tiny time window
compared to the whole time the waiter is blocked. So a great
improvement.

> Add interface put_and_wait_on_page_locked() to do this, using negative
> value of the lock arg to wait_on_page_bit_common() to implement it.
> No interruptible or killable variant needed yet, but they might follow:
> I have a vague notion that reporting -EINTR should take precedence over
> return from wait_on_page_bit_common() without knowing the page state,
> so arrange it accordingly - but that may be nothing but pedantic.
> 
> shrink_page_list()'s __ClearPageLocked(): that was a surprise!

and I can imagine a bad one. Do we really have to be so clever here?
The unlock_page went away in the name of performance (a978d6f521063)
and I would argue that this is a slow path where this is just not worth
it.

> this
> survived a lot of testing before that showed up.  It does raise the
> question: should is_page_cache_freeable() and __remove_mapping() now
> treat a PG_waiters page as if an extra reference were held?  Perhaps,
> but I don't think it matters much, since shrink_page_list() already
> had to win its trylock_page(), so waiters are not very common there: I
> noticed no difference when trying the bigger change, and it's surely not
> needed while put_and_wait_on_page_locked() is only for page migration.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

The patch looks good to me - quite ugly but it doesn't make the existing
code much worse.

With the problem described Vlastimil fixed, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

And thanks for a prompt patch. This is something I've been chasing for
quite some time. __migration_entry_wait came to my radar only recently
because this is an extremely volatile area.
-- 
Michal Hocko
SUSE Labs
