Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 945536B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 08:01:04 -0500 (EST)
Date: Wed, 18 Jan 2012 14:01:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 1/7 v2] memcg: remove unnecessary check in
 mem_cgroup_update_page_stat()
Message-ID: <20120118130102.GC31112@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113173227.df2baae3.kamezawa.hiroyu@jp.fujitsu.com>
 <20120117151619.GA21348@tiehlicka.suse.cz>
 <20120118085558.6ed1a988.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120118085558.6ed1a988.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Wed 18-01-12 08:55:58, KAMEZAWA Hiroyuki wrote:
> On Tue, 17 Jan 2012 16:16:20 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Fri 13-01-12 17:32:27, KAMEZAWA Hiroyuki wrote:
> > > 
> > > From 788aebf15f3fa37940e0745cab72547e20683bf2 Mon Sep 17 00:00:00 2001
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Date: Thu, 12 Jan 2012 16:08:33 +0900
> > > Subject: [PATCH 1/7] memcg: remove unnecessary check in mem_cgroup_update_page_stat()
> > > 
> > > commit 10ea69f1182b removes move_lock_page_cgroup() in thp-split path.
> > > So, this PageTransHuge() check is unnecessary, too.
> > 
> > I do not see commit like that in the tree. I guess you meant
> > memcg: make mem_cgroup_split_huge_fixup() more efficient which is not
> > merged yet, right?
> > 
> 
> This commit in the linux-next.

Referring to commits from linux-next is tricky as it changes all the
time. I guess that the full commit subject should be sufficient.

> > > Note:
> > >  - considering when mem_cgroup_update_page_stat() is called,
> > >    there will be no race between split_huge_page() and update_page_stat().
> > >    All required locks are held in higher level.
> > 
> > We should never have THP page in this path in the first place. So why
> > not changing this to VM_BUG_ON(PageTransHuge).
> > 
> 
> Ying Han considers to support mlock stat.

OK, got it. What about the following updated changelog instead?

===
We do not have to check PageTransHuge in mem_cgroup_update_page_stat
and fallback into the locked accounting because both move charge and thp
split up are done with compound_lock so they cannot race. update vs.
move is protected by the mem_cgroup_stealed sufficiently.

PageTransHuge pages shouldn't appear in this code path currently because
we are tracking only file pages at the moment but later we are planning
to track also other pages (e.g. mlocked ones).
===

> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

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
