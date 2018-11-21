Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50DA96B22E8
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 20:08:50 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 89so4725133ple.19
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 17:08:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y40-v6sor53093904pla.26.2018.11.20.17.08.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 17:08:48 -0800 (PST)
Date: Tue, 20 Nov 2018 17:08:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Memory hotplug softlock issue
In-Reply-To: <3f1a82a8-f2aa-ac5e-e6a8-057256162321@suse.cz>
Message-ID: <alpine.LSU.2.11.1811201630360.2061@eggly.anvils>
References: <20181115143204.GV23831@dhcp22.suse.cz> <20181116012433.GU2653@MiWiFi-R3L-srv> <20181116091409.GD14706@dhcp22.suse.cz> <20181119105202.GE18471@MiWiFi-R3L-srv> <20181119124033.GJ22247@dhcp22.suse.cz> <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz> <20181119173312.GV22247@dhcp22.suse.cz> <alpine.LSU.2.11.1811191215290.15640@eggly.anvils> <20181119205907.GW22247@dhcp22.suse.cz> <20181120015644.GA5727@MiWiFi-R3L-srv> <alpine.LSU.2.11.1811192127130.2848@eggly.anvils>
 <3f1a82a8-f2aa-ac5e-e6a8-057256162321@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@kernel.org>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On Tue, 20 Nov 2018, Vlastimil Babka wrote:
> On 11/20/18 6:44 AM, Hugh Dickins wrote:
> > [PATCH] mm: put_and_wait_on_page_locked() while page is migrated
> > 
> > We have all assumed that it is essential to hold a page reference while
> > waiting on a page lock: partly to guarantee that there is still a struct
> > page when MEMORY_HOTREMOVE is configured, but also to protect against
> > reuse of the struct page going to someone who then holds the page locked
> > indefinitely, when the waiter can reasonably expect timely unlocking.
> > 
> > But in fact, so long as wait_on_page_bit_common() does the put_page(),
> > and is careful not to rely on struct page contents thereafter, there is
> > no need to hold a reference to the page while waiting on it.  That does
> 
> So there's still a moment where refcount is elevated, but hopefully
> short enough, right?

Correct: and given page migration's 10 passes, it would have to be very
unlucky to hit one of those transiently elevated refcounts every time:
so I don't think it's a grave drawback at all - certainly much less
grave than how it's done at present.

I admit that doing a get_page_unless_zero() immediately before the
put_and_wait_on_page_locked() looks rather silly, but I think we do
have to hold a reference in order to set PG_waiters. Then for other
future uses (e.g. in find_get_entry() or lock_page_or_retry()),
the reference to be dropped has been taken earlier anyway.

> Let's see if it survives Baoquan's stress testing.
> 
> > mean that this case cannot go back through the loop: but that's fine for
> > the page migration case, and even if used more widely, is limited by the
> > "Stop walking if it's locked" optimization in wake_page_function().
> > 
> > Add interface put_and_wait_on_page_locked() to do this, using negative
> > value of the lock arg to wait_on_page_bit_common() to implement it.
> > No interruptible or killable variant needed yet, but they might follow:
> > I have a vague notion that reporting -EINTR should take precedence over
> > return from wait_on_page_bit_common() without knowing the page state,
> > so arrange it accordingly - but that may be nothing but pedantic.
> > 
> > shrink_page_list()'s __ClearPageLocked(): that was a surprise! this
> > survived a lot of testing before that showed up.  It does raise the
> > question: should is_page_cache_freeable() and __remove_mapping() now
> > treat a PG_waiters page as if an extra reference were held?  Perhaps,
> > but I don't think it matters much, since shrink_page_list() already
> > had to win its trylock_page(), so waiters are not very common there: I
> > noticed no difference when trying the bigger change, and it's surely not
> > needed while put_and_wait_on_page_locked() is only for page migration.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> 
> ...
> 
> > @@ -1100,6 +1111,17 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
> >  			ret = -EINTR;
> >  			break;
> >  		}
> > +
> > +		if (lock < 0) {
> > +			/*
> > +			 * We can no longer safely access page->flags:
> 
> Hmm...
> 
> > +			 * even if CONFIG_MEMORY_HOTREMOVE is not enabled,
> > +			 * there is a risk of waiting forever on a page reused
> > +			 * for something that keeps it locked indefinitely.
> > +			 * But best check for -EINTR above before breaking.
> > +			 */
> > +			break;
> > +		}
> >  	}
> >  
> >  	finish_wait(q, wait);
> 
> ... the code continues by:
> 
>         if (thrashing) {
>                 if (!PageSwapBacked(page))
> 
> So maybe we should not set 'thrashing' true when lock < 0?

Very good catch, thank you Vlastimil: as you might have guessed, the
patch from a pre-PSI kernel applied cleanly, and I just hadn't reviewed
the surrounding context properly before sending out.

I cannot say immediately what the right answer is, I'll have to do some
research first: maybe not enter the block that sets thrashing true when
lock < 0, as you suggest, or maybe force lock < 0 to 0 and put_page()
afterwards, or... 

Hugh
