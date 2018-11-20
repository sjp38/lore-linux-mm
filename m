Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 15F576B2034
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:38:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so1265163edb.22
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 05:38:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d14si3992230edq.144.2018.11.20.05.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 05:38:25 -0800 (PST)
Subject: Re: Memory hotplug softlock issue
References: <20181115143204.GV23831@dhcp22.suse.cz>
 <20181116012433.GU2653@MiWiFi-R3L-srv>
 <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv>
 <20181119124033.GJ22247@dhcp22.suse.cz>
 <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
 <20181119173312.GV22247@dhcp22.suse.cz>
 <alpine.LSU.2.11.1811191215290.15640@eggly.anvils>
 <20181119205907.GW22247@dhcp22.suse.cz>
 <20181120015644.GA5727@MiWiFi-R3L-srv>
 <alpine.LSU.2.11.1811192127130.2848@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3f1a82a8-f2aa-ac5e-e6a8-057256162321@suse.cz>
Date: Tue, 20 Nov 2018 14:38:23 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1811192127130.2848@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Baoquan He <bhe@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On 11/20/18 6:44 AM, Hugh Dickins wrote:
> [PATCH] mm: put_and_wait_on_page_locked() while page is migrated
> 
> We have all assumed that it is essential to hold a page reference while
> waiting on a page lock: partly to guarantee that there is still a struct
> page when MEMORY_HOTREMOVE is configured, but also to protect against
> reuse of the struct page going to someone who then holds the page locked
> indefinitely, when the waiter can reasonably expect timely unlocking.
> 
> But in fact, so long as wait_on_page_bit_common() does the put_page(),
> and is careful not to rely on struct page contents thereafter, there is
> no need to hold a reference to the page while waiting on it.  That does

So there's still a moment where refcount is elevated, but hopefully
short enough, right? Let's see if it survives Baoquan's stress testing.

> mean that this case cannot go back through the loop: but that's fine for
> the page migration case, and even if used more widely, is limited by the
> "Stop walking if it's locked" optimization in wake_page_function().
> 
> Add interface put_and_wait_on_page_locked() to do this, using negative
> value of the lock arg to wait_on_page_bit_common() to implement it.
> No interruptible or killable variant needed yet, but they might follow:
> I have a vague notion that reporting -EINTR should take precedence over
> return from wait_on_page_bit_common() without knowing the page state,
> so arrange it accordingly - but that may be nothing but pedantic.
> 
> shrink_page_list()'s __ClearPageLocked(): that was a surprise! this
> survived a lot of testing before that showed up.  It does raise the
> question: should is_page_cache_freeable() and __remove_mapping() now
> treat a PG_waiters page as if an extra reference were held?  Perhaps,
> but I don't think it matters much, since shrink_page_list() already
> had to win its trylock_page(), so waiters are not very common there: I
> noticed no difference when trying the bigger change, and it's surely not
> needed while put_and_wait_on_page_locked() is only for page migration.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---

...

> @@ -1100,6 +1111,17 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
>  			ret = -EINTR;
>  			break;
>  		}
> +
> +		if (lock < 0) {
> +			/*
> +			 * We can no longer safely access page->flags:

Hmm...

> +			 * even if CONFIG_MEMORY_HOTREMOVE is not enabled,
> +			 * there is a risk of waiting forever on a page reused
> +			 * for something that keeps it locked indefinitely.
> +			 * But best check for -EINTR above before breaking.
> +			 */
> +			break;
> +		}
>  	}
>  
>  	finish_wait(q, wait);

... the code continues by:

        if (thrashing) {
                if (!PageSwapBacked(page))

So maybe we should not set 'thrashing' true when lock < 0?

Thanks!
Vlastimil
