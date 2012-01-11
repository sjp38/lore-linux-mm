Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id D1E656B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 19:01:02 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E426D3EE0BB
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 09:01:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB9DC45DE59
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 09:01:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FDE445DE55
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 09:01:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 94C7E1DB8052
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 09:01:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 436D01DB804A
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 09:01:00 +0900 (JST)
Date: Thu, 12 Jan 2012 08:59:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memcg: add mlock statistic in memory.stat
Message-Id: <20120112085937.ae601869.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1201111512570.1846@eggly.anvils>
References: <1326321668-5422-1-git-send-email-yinghan@google.com>
	<alpine.LSU.2.00.1201111512570.1846@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Wed, 11 Jan 2012 15:17:42 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Wed, 11 Jan 2012, Ying Han wrote:
> 
> > We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
> > patch adds the mlock field into per-memcg memory stat. The stat itself enhances
> > the metrics exported by memcg, especially is used together with "uneivctable"
> > lru stat.
> > 
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -10,6 +10,7 @@ enum {
> >  	/* flags for mem_cgroup and file and I/O status */
> >  	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
> >  	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
> > +	PCG_MLOCK, /* page is accounted as "mlock" */
> >  	/* No lock in page_cgroup */
> >  	PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) */
> >  	__NR_PCG_FLAGS,
> 
> Is this really necessary?  KAMEZAWA-san is engaged in trying to reduce
> the number of PageCgroup flags, and I expect that in due course we shall
> want to merge them in with Page flags, so adding more is unwelcome.
> I'd  have thought that with memcg_ hooks in the right places,
> a separate flag would not be necessary?
> 

Please don't ;)

NR_UNEIVCTABLE_LRU is not enough ?

Following is the patch I posted before to remove PCG_FILE_MAPPED.
Then, I think you can use similar logic and make use of UNEVICTABLE flags.

==
better (lockless) idea is welcomed.
