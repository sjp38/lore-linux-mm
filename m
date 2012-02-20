Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3142B6B004D
	for <linux-mm@kvack.org>; Sun, 19 Feb 2012 19:33:40 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B18B83EE0B5
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:33:38 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 98DA745DE5F
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:33:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CFCF45DE59
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:33:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 667FCE08006
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:33:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B6201DB804C
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:33:38 +0900 (JST)
Date: Mon, 20 Feb 2012 09:32:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock
 splitting
Message-Id: <20120220093217.764e49f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202172312030.14811@eggly.anvils>
References: <20120215224221.22050.80605.stgit@zurg>
	<alpine.LSU.2.00.1202151815180.19722@eggly.anvils>
	<4F3C8B67.6090500@openvz.org>
	<alpine.LSU.2.00.1202161235430.2269@eggly.anvils>
	<alpine.LSU.2.00.1202171803380.25191@eggly.anvils>
	<4F3F46B7.40100@openvz.org>
	<alpine.LSU.2.00.1202172312030.14811@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 17 Feb 2012 23:14:01 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Sat, 18 Feb 2012, Konstantin Khlebnikov wrote:
> > Hugh Dickins wrote:
> > > On Thu, 16 Feb 2012, Hugh Dickins wrote:
> > > > 
> > > > Yours are not the only patches I was testing in that tree, I tried to
> > > > gather several other series which I should be reviewing if I ever have
> > > > time: Kamezawa-san's page cgroup diet 6, Xiao Guangrong's 4 prio_tree
> > > > cleanups, your 3 radix_tree changes, your 6 shmem changes, your 4 memcg
> > > > miscellaneous, and then your 15 books.
> > > > 
> > > > The tree before your final 15 did well under pressure, until I tried to
> > > > rmdir one of the cgroups afterwards: then it crashed nastily, I'll have
> > > > to bisect into that, probably either Kamezawa's or your memcg changes.
> > > 
> > > So far I haven't succeeded in reproducing that at all: it was real,
> > > but obviously harder to get than I assumed - indeed, no good reason
> > > to associate it with any of those patches, might even be in 3.3-rc.
> > > 
> > > It did involve a NULL pointer dereference in mem_cgroup_page_lruvec(),
> > > somewhere below compact_zone() - but repercussions were causing the
> > > stacktrace to scroll offscreen, so I didn't get good details.
> > 
> > There some stupid bugs in my v1 patchset, it shouldn't works at all.
> > I did not expect that someone will try to use it. I sent it just to discuss.
> 
> Yes, but as I said, that bug appeared before I put your patchset (the 15) on.
> 

Hm, NULL pointer dereference in mem_cgroup_page_lruvec() via comaction tend to
mean pc->mem_cgroup was NULL... 

IIUC,

- compaction get pages from LRU list and isolate/migrate them. So, When pages
  on LRU were migrated by compact_zone(), pc->mem_cgroup never be NULL..
- All newly allocated pages for migration will be reset by mem_cgroup_reset_owner().

Hm, something unexpected happens..

Regards,
-Kame
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
