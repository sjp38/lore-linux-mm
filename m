Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id AF5796B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 19:04:52 -0500 (EST)
Received: by iajr24 with SMTP id r24so3992057iaj.14
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 16:04:52 -0800 (PST)
Date: Fri, 9 Mar 2012 16:04:18 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/7 v2] mm: rework __isolate_lru_page() file/anon
 filter
In-Reply-To: <4F59AE3C.5040200@openvz.org>
Message-ID: <alpine.LSU.2.00.1203091559260.23317@eggly.anvils>
References: <20120229091547.29236.28230.stgit@zurg> <20120303091327.17599.80336.stgit@zurg> <alpine.LSU.2.00.1203061904570.18675@eggly.anvils> <20120308143034.f3521b1e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1203081758490.18195@eggly.anvils>
 <4F59AE3C.5040200@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 9 Mar 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > 
> > I like very much the look of what he's come up with, but I'm still
> > puzzling over why it barely makes any improvement to __isolate_lru_page():
> > seems significantly inferior (in code size terms) to his original (which
> > I imagine Glauber's compromise would be equivalent to).
> > 
> > At some point I ought to give up on niggling about this,
> > but I haven't quite got there yet.
> 
> (with if())
> $ ./scripts/bloat-o-meter built-in.o built-in.o-v1
> add/remove: 0/0 grow/shrink: 2/1 up/down: 32/-20 (12)
> function                                     old     new   delta
> static.shrink_active_list                    837     853     +16
> shrink_inactive_list                        1259    1275     +16
> static.isolate_lru_pages                    1055    1035     -20
> 
> (with switch())
> $ ./scripts/bloat-o-meter built-in.o built-in.o-v2
> add/remove: 0/0 grow/shrink: 4/2 up/down: 111/-23 (88)
> function                                     old     new   delta
> __isolate_lru_page                           301     377     +76
> static.shrink_active_list                    837     853     +16
> shrink_inactive_list                        1259    1275     +16
> page_evictable                               170     173      +3
> __remove_mapping                             322     319      -3
> static.isolate_lru_pages                    1055    1035     -20
> 
> (without __always_inline on page_lru())
> $ ./scripts/bloat-o-meter built-in.o built-in.o-v5-noinline
> add/remove: 0/0 grow/shrink: 5/2 up/down: 93/-23 (70)
> function                                     old     new   delta
> __isolate_lru_page                           301     333     +32
> isolate_lru_page                             359     385     +26
> static.shrink_active_list                    837     853     +16
> putback_inactive_pages                       635     651     +16
> page_evictable                               170     173      +3
> __remove_mapping                             322     319      -3
> static.isolate_lru_pages                    1055    1035     -20
> 
> $ ./scripts/bloat-o-meter built-in.o built-in.o-v5
> add/remove: 0/0 grow/shrink: 3/4 up/down: 35/-67 (-32)
> function                                     old     new   delta
> static.shrink_active_list                    837     853     +16
> __isolate_lru_page                           301     317     +16
> page_evictable                               170     173      +3
> __remove_mapping                             322     319      -3
> mem_cgroup_lru_del                            73      65      -8
> static.isolate_lru_pages                    1055    1035     -20
> __mem_cgroup_commit_charge                   676     640     -36
> 
> Actually __isolate_lru_page() even little bit bigger

I was coming to realize that it must be your page_lru()ing:
although it's dressed up in one line, there's several branches there.

I think you'll find you have a clear winner at last, if you just pass
lru on down as third arg to __isolate_lru_page(), where file used to
be passed, instead of re-evaluating it inside.

shrink callers already have the lru, and compaction works it out
immediately afterwards.

Though we do need to be careful: the lumpy case would then have to
pass page_lru(cursor_page).  Oh, actually no (though it would deserve
a comment): since the lumpy case selects LRU_ALL_EVICTABLE, it's
irrelevant what it passes for lru, so might as well stick with
the one passed down.  Though you may decide I'm being too tricky
there, and prefer to calculate page_lru(cursor_page) anyway, it
not being the hottest path.

Whether you'd still want page_lru(page) __always_inline, I don't know.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
