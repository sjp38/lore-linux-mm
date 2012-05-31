Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id A38CE6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 18:59:26 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2415856dak.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 15:59:25 -0700 (PDT)
Date: Thu, 31 May 2012 15:58:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm/memcg: apply add/del_page to lruvec
In-Reply-To: <20120530221707.GA25095@centos-guest>
Message-ID: <alpine.LSU.2.00.1205311544400.4561@eggly.anvils>
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils> <alpine.LSU.2.00.1205132201210.6148@eggly.anvils> <20120530221707.GA25095@centos-guest>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: baozich <baozich@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 31 May 2012, baozich wrote:
> > 
> > In their place, mem_cgroup_page_lruvec() to decide the lruvec,
> > previously a side-effect of add, and mem_cgroup_update_lru_size()
> > to maintain the lru_size stats.
> I have a stupid question. I'm not sure whether there is reduplication
> to put both "page" and "zone" parameter in mem_cgroup_page_lruvec(),
> for I noticed that the "struct zone *zone" parameter are usually from 
> page_zone(page) in most cases. I think that the semantics of this function
> is to grab the lruvec the page belongs to. So will it be ok if we pass
> only "page" as the parameter, which I think would be cleaner? Please
> fix me if I missed something.

I share your dislike for passing down an "unnecessary" argument,
but I do think it's justified here.

If the zone pointer were available simply by page->zone, then yes,
I'd agree with you that it's probably silly to pass zone separately.

But page_zone(page) is never as trivial as that, and on some memory
layouts it can be a lookup that you'd really prefer to avoid repeating.

In every(?) case where we're using mem_cgroup_page_lruvec(), the zone
is already known: it's just been used for spin_lock_irq(&zone->lru_lock).

And when CONFIG_CGROUP_MEM_RES_CTLR is not set, the inline function
mem_cgroup_page_lruvec() uses only zone, not page at all: I wouldn't
want to be slowing down that case with another page_zone(page) lookup.

Also it's somewhat academic (though not for v3.5), in that this function
goes away in the patches I build upon it; and I expect it also to go away
in the patches Konstantin would build upon it - mem_cgroup_page_lruvec()
is a staging point, before we combine memcg/zone lookup with the locking.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
