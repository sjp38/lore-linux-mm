Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id F18E06B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 18:56:52 -0500 (EST)
Received: by ghrr18 with SMTP id r18so2212653ghr.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 15:56:52 -0800 (PST)
Date: Mon, 9 Jan 2012 15:56:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] SHM_UNLOCK: fix Unevictable pages stranded after
 swap
In-Reply-To: <4F0B73AC.7000504@gmail.com>
Message-ID: <alpine.LSU.2.00.1201091546450.1778@eggly.anvils>
References: <alpine.LSU.2.00.1201061303320.12082@eggly.anvils> <alpine.LSU.2.00.1201061310340.12082@eggly.anvils> <4F0B5146.6090200@gmail.com> <alpine.LSU.2.00.1201091342300.1272@eggly.anvils> <4F0B73AC.7000504@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jan 2012, KOSAKI Motohiro wrote:
> (1/9/12 5:25 PM), Hugh Dickins wrote:
> > On Mon, 9 Jan 2012, KOSAKI Motohiro wrote:
> > 
> > > PG_mlocked operation is not protected by LRU lock. So, I think we
> > 
> > Right.  But I don't see that I've made a significant change there.
> > 
> > I may be being lazy, and rushing back to answer you, without giving
> > constructive thought to what the precise race is that you see, and
> > how we might fix it.  If the case you have in mind is easy for you
> > to describe in detail, please do so; but don't hesitate to tell me
> > to my own work for myself!
> 
> Bah! I was moron. I now think your code is right.
> 
> spin_lock(lru_lock)
> if (page_evictable(page))
> 	blah blah blah
> spin_unlock(lru_lock)
> 
> is always safe. Counter part should have following code and
> waiting spin_lock(lru_lock) in isolate_lru_page().
> 
>                 if (!isolate_lru_page(page))
>                         putback_lru_page(page);
> 
> then, even if check_move_unevictable_pages() observed wrong page status,
> putback_lru_page() should put back the page into right lru.
> 
> I'm very sorry for annoying you.

Far from it, thank you again for giving it serious thought.

I am not going to pretend to have thought down these paths myself,
not recently - I was just relying on not changing the behaviour.
But I am reassured to know that you have worked through it again
and are now satisfied.

> 
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thank you.

> 
> Probably, page_evictable() might be needed some additional comments. But
> I have no idea what comment clearly explain this complex rule.....

I don't know any language that can make it clear: when forced to,
one just has to think through it back and forth by oneself; and
even then, it's so quickly forgotten.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
