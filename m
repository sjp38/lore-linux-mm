Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B15396B28C3
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 20:53:38 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g12-v6so12059942plo.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:53:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a96sor12464389pla.29.2018.11.21.17.53.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 17:53:36 -0800 (PST)
Date: Wed, 21 Nov 2018 17:53:33 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Memory hotplug softlock issue
In-Reply-To: <20181121173123.GS12932@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1811211726080.5557@eggly.anvils>
References: <20181116091409.GD14706@dhcp22.suse.cz> <20181119105202.GE18471@MiWiFi-R3L-srv> <20181119124033.GJ22247@dhcp22.suse.cz> <20181119125121.GK22247@dhcp22.suse.cz> <20181119141016.GO22247@dhcp22.suse.cz> <20181119173312.GV22247@dhcp22.suse.cz>
 <alpine.LSU.2.11.1811191215290.15640@eggly.anvils> <20181119205907.GW22247@dhcp22.suse.cz> <20181120015644.GA5727@MiWiFi-R3L-srv> <alpine.LSU.2.11.1811192127130.2848@eggly.anvils> <20181121173123.GS12932@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Baoquan He <bhe@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On Wed, 21 Nov 2018, Michal Hocko wrote:
> On Mon 19-11-18 21:44:41, Hugh Dickins wrote:
> [...]
> > [PATCH] mm: put_and_wait_on_page_locked() while page is migrated
> > 
> > We have all assumed that it is essential to hold a page reference while
> > waiting on a page lock: partly to guarantee that there is still a struct
> > page when MEMORY_HOTREMOVE is configured, but also to protect against
> > reuse of the struct page going to someone who then holds the page locked
> > indefinitely, when the waiter can reasonably expect timely unlocking.
> 
> I would add the following for the "problem statement". Feel free to
> reuse per your preference:
> "
> An elevated reference count, however, stands in the way of migration and
> forces it to fail with a bad timing. This is especially a problem for
> memory offlining which retries for ever (or until the operation is
> terminated from userspace) because a heavy refault workload can trigger
> essentially an endless loop of migration failures. Therefore
> __migration_entry_wait is essentially harmful for the even it is waiting
> for.
> "

Okay, I do have a lot written from way back when I prepared the
now-abandoned migration_waitqueue patch internally, but I'll factor in
what you say above when I get there - in particular, you highlight the
memory offlining aspect, as in this mailthread: which is very helpful,
because it's outside my experience so I won't have mentioned it - thanks.

I just know that there's some important linkage to do, to the August 2017
WQ_FLAG_BOOKMARK discussion: so it's a research and editing job I have to
work myself up to at the right moment.

> 
> > But in fact, so long as wait_on_page_bit_common() does the put_page(),
> > and is careful not to rely on struct page contents thereafter, there is
> > no need to hold a reference to the page while waiting on it.  That does
> > mean that this case cannot go back through the loop: but that's fine for
> > the page migration case, and even if used more widely, is limited by the
> > "Stop walking if it's locked" optimization in wake_page_function().
> 
> I would appreciate this would be more explicit about the existence of
> the elevated-ref-count problem but it reduces it to a tiny time window
> compared to the whole time the waiter is blocked. So a great
> improvement.

Fair enough, I'll do so. (But that's a bit like when we say we've attached
something and then forget to do so: please check that I've been honest
when I do post.)

> 
> > Add interface put_and_wait_on_page_locked() to do this, using negative
> > value of the lock arg to wait_on_page_bit_common() to implement it.
> > No interruptible or killable variant needed yet, but they might follow:
> > I have a vague notion that reporting -EINTR should take precedence over
> > return from wait_on_page_bit_common() without knowing the page state,
> > so arrange it accordingly - but that may be nothing but pedantic.
> > 
> > shrink_page_list()'s __ClearPageLocked(): that was a surprise!
> 
> and I can imagine a bad one. Do we really have to be so clever here?
> The unlock_page went away in the name of performance (a978d6f521063)
> and I would argue that this is a slow path where this is just not worth
> it.

Do we really have to be so clever here? That's a good question: now we
have PG_waiters, we probably do not need to bother with this cleverness,
and it would save me from having to expand on that comment as I was asked.
I'll try going back to a simple unlock_page() there: and can always restore
the __ClearPageLocked if a reviewer demands, or 0-day notices regression,

> 
> > this
> > survived a lot of testing before that showed up.  It does raise the
> > question: should is_page_cache_freeable() and __remove_mapping() now
> > treat a PG_waiters page as if an extra reference were held?  Perhaps,
> > but I don't think it matters much, since shrink_page_list() already
> > had to win its trylock_page(), so waiters are not very common there: I
> > noticed no difference when trying the bigger change, and it's surely not
> > needed while put_and_wait_on_page_locked() is only for page migration.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> The patch looks good to me - quite ugly but it doesn't make the existing
> code much worse.
> 
> With the problem described Vlastimil fixed, feel free to add
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> 
> And thanks for a prompt patch. This is something I've been chasing for
> quite some time. __migration_entry_wait came to my radar only recently
> because this is an extremely volatile area.

You are very gracious to describe a patch promised six months ago as
"prompt".  But it does help me a lot to have it fixing a real problem
for someone (thank you Baoquan) - well, it fixed a real problem for us
internally too, but very nice to gather more backing for it like this.

Hugh
