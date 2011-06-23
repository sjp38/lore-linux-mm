Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 43C96900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:23:16 -0400 (EDT)
Date: Thu, 23 Jun 2011 15:23:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: preallocate page before lock_page at filemap COW.
 (WasRe: [PATCH V2] mm: Do not keep page locked during page fault while
 charging it for memcg
Message-ID: <20110623132312.GI31593@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
 <20110622121516.GA28359@infradead.org>
 <20110622123204.GC14343@tiehlicka.suse.cz>
 <20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110623074133.GA31593@tiehlicka.suse.cz>
 <20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com>
 <20110623090204.GE31593@tiehlicka.suse.cz>
 <20110623190157.1bc8cbb9.kamezawa.hiroyu@jp.fujitsu.com>
 <20110623115855.GF31593@tiehlicka.suse.cz>
 <BANLkTimshUCY5Yq5g9dnY0gi2TRneGscug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimshUCY5Yq5g9dnY0gi2TRneGscug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Lutz Vieweg <lvml@5t9.de>

On Thu 23-06-11 22:01:40, Hiroyuki Kamezawa wrote:
> 2011/6/23 Michal Hocko <mhocko@suse.cz>:
> > On Thu 23-06-11 19:01:57, KAMEZAWA Hiroyuki wrote:
> >> On Thu, 23 Jun 2011 11:02:04 +0200
> >> Michal Hocko <mhocko@suse.cz> wrote:
> >>
> >> > On Thu 23-06-11 17:08:11, KAMEZAWA Hiroyuki wrote:
> >> > > On Thu, 23 Jun 2011 09:41:33 +0200
> >> > > Michal Hocko <mhocko@suse.cz> wrote:
> >> > [...]
> >> > > > Other than that:
> >> > > > Reviewed-by: Michal Hocko <mhocko@suse.cz>
> >> > > >
> >> > >
> >> > > I found the page is added to LRU before charging. (In this case,
> >> > > memcg's LRU is ignored.) I'll post a new version with a fix.
> >> >
> >> > Yes, you are right. I have missed that.
> >> > This means that we might race with reclaim which could evict the COWed
> >> > page wich in turn would uncharge that page even though we haven't
> >> > charged it yet.
> >> >
> >> > Can we postpone page_add_new_anon_rmap to the charging path or it would
> >> > just race somewhere else?
> >> >
> >>
> >> I got a different idea. How about this ?
> >> I think this will have benefit for non-memcg users under OOM, too.
> >
> > Could you be more specific? I do not see how preallocation which might
> > turn out to be pointless could help under OOM.
> >
> 
> We'll have no page allocation under lock_page() held in this path.
> I think it is good.

But it can also cause that the page, we are about to fault in, is evicted
due to allocation so we would have to do a major fault... This is
probably not that serious, though.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
