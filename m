Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2B9C86B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 11:04:58 -0400 (EDT)
Date: Wed, 8 Jun 2011 17:04:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
Message-ID: <20110608145002.GB9936@tiehlicka.suse.cz>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
 <BANLkTinHs7OCkpRf8=dYO0ObH5sndZ4__g@mail.gmail.com>
 <20110602142408.GB28684@cmpxchg.org>
 <BANLkTikjjH3vCiwpKrs=+vbaaACC67H7Og@mail.gmail.com>
 <20110602175702.GI28684@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602175702.GI28684@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 02-06-11 19:57:02, Johannes Weiner wrote:
> On Fri, Jun 03, 2011 at 12:54:39AM +0900, Hiroyuki Kamezawa wrote:
> > 2011/6/2 Johannes Weiner <hannes@cmpxchg.org>:
> > > On Thu, Jun 02, 2011 at 10:16:59PM +0900, Hiroyuki Kamezawa wrote:
[...]
> 
> > But it may put a page onto wrong memcgs if we do link a page to
> > another page's page->lru
> > because 2 pages may be in different cgroup each other.
> 
> Yes, I noticed that.  If it splits a huge page, it does not just add
> the tailpages to the lru head, but it links them next to the head
> page.
> 
> But I don't see how those pages could ever be in different memcgs?
> pages with page->mapping pointing to the same anon_vma are always in
> the same memcg, AFAIU.

Process can be moved to other memcg and without move_charge_at_immigrate
all previously faulted pages stay in the original group while all new
(not faulted yet) get into the new group while mapping doesn't change.
I guess this might happen with thp tailpages as well. But I do not think
this is a problem. The original group already got charged for the huge
page so we can keep all tail pages in it.

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
