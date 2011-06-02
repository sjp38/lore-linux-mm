Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F37E56B0078
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:24:29 -0400 (EDT)
Date: Thu, 2 Jun 2011 16:24:08 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
Message-ID: <20110602142408.GB28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
 <BANLkTinHs7OCkpRf8=dYO0ObH5sndZ4__g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTinHs7OCkpRf8=dYO0ObH5sndZ4__g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2011 at 10:16:59PM +0900, Hiroyuki Kamezawa wrote:
> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> > All lru list walkers have been converted to operate on per-memcg
> > lists, the global per-zone lists are no longer required.
> >
> > This patch makes the per-memcg lists exclusive and removes the global
> > lists from memcg-enabled kernels.
> >
> > The per-memcg lists now string up page descriptors directly, which
> > unifies/simplifies the list isolation code of page reclaim as well as
> > it saves a full double-linked list head for each page in the system.
> >
> > At the core of this change is the introduction of the lruvec
> > structure, an array of all lru list heads.  It exists for each zone
> > globally, and for each zone per memcg.  All lru list operations are
> > now done in generic code against lruvecs, with the memcg lru list
> > primitives only doing accounting and returning the proper lruvec for
> > the currently scanned memcg on isolation, or for the respective page
> > on putback.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> 
> could you divide this into
>   - introduce lruvec
>   - don't record section? information into pc->flags because we see
> "page" on memcg LRU
>     and there is no requirement to get page from "pc".
>   - remove pc->lru completely

Yes, that makes sense.  It shall be fixed in the next version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
