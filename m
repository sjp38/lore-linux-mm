Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3E546900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 05:02:10 -0400 (EDT)
Date: Thu, 23 Jun 2011 11:02:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: unlock page before charging it. (WasRe: [PATCH
 V2] mm: Do not keep page locked during page fault while charging it for
 memcg
Message-ID: <20110623090204.GE31593@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
 <20110622121516.GA28359@infradead.org>
 <20110622123204.GC14343@tiehlicka.suse.cz>
 <20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110623074133.GA31593@tiehlicka.suse.cz>
 <20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Lutz Vieweg <lvml@5t9.de>

On Thu 23-06-11 17:08:11, KAMEZAWA Hiroyuki wrote:
> On Thu, 23 Jun 2011 09:41:33 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > Other than that:
> > Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > 
> 
> I found the page is added to LRU before charging. (In this case,
> memcg's LRU is ignored.) I'll post a new version with a fix.

Yes, you are right. I have missed that.
This means that we might race with reclaim which could evict the COWed
page wich in turn would uncharge that page even though we haven't
charged it yet.

Can we postpone page_add_new_anon_rmap to the charging path or it would
just race somewhere else?

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
