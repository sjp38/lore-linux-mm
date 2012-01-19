Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id EE2556B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 04:28:36 -0500 (EST)
Date: Thu, 19 Jan 2012 10:28:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 2/7 v2] memcg: add memory barrier for checking
 account move.
Message-ID: <20120119092833.GA13932@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
 <20120117152635.GA22142@tiehlicka.suse.cz>
 <20120118090656.83268b3e.kamezawa.hiroyu@jp.fujitsu.com>
 <20120118123759.GB31112@tiehlicka.suse.cz>
 <20120119111727.6337bde4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120119111727.6337bde4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Thu 19-01-12 11:17:27, KAMEZAWA Hiroyuki wrote:
> On Wed, 18 Jan 2012 13:37:59 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Wed 18-01-12 09:06:56, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 17 Jan 2012 16:26:35 +0100
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > On Fri 13-01-12 17:33:47, KAMEZAWA Hiroyuki wrote:
> > > > > I think this bugfix is needed before going ahead. thoughts?
> > > > > ==
> > > > > From 2cb491a41782b39aae9f6fe7255b9159ac6c1563 Mon Sep 17 00:00:00 2001
> > > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > Date: Fri, 13 Jan 2012 14:27:20 +0900
> > > > > Subject: [PATCH 2/7] memcg: add memory barrier for checking account move.
> > > > > 
> > > > > At starting move_account(), source memcg's per-cpu variable
> > > > > MEM_CGROUP_ON_MOVE is set. The page status update
> > > > > routine check it under rcu_read_lock(). But there is no memory
> > > > > barrier. This patch adds one.
> > > > 
> > > > OK this would help to enforce that the CPU would see the current value
> > > > but what prevents us from the race with the value update without the
> > > > lock? This is as racy as it was before AFAICS.
> > > > 
> > > 
> > > Hm, do I misunderstand ?
> > > ==
> > >    update                     reference
> > > 
> > >    CPU A                        CPU B
> > >   set value                rcu_read_lock()
> > >   smp_wmb()                smp_rmb()
> > >                            read_value
> > >                            rcu_read_unlock()
> > >   synchronize_rcu().
> > > ==
> > > I expect
> > > If synchronize_rcu() is called before rcu_read_lock() => move_lock_xxx will be held.
> > > If synchronize_rcu() is called after rcu_read_lock() => update will be delayed.
> > 
> > Ahh, OK I can see it now. Readers are not that important because it is
> > actually the updater who is delayed until all preexisting rcu read
> > sections are finished.
> > 
> > In that case. Why do we need both barriers? spin_unlock is a full
> > barrier so maybe we just need smp_rmb before we read value to make sure
> > that we do not get stalled value when we start rcu_read section after
> > synchronize_rcu?
> > 
> 
> I doubt .... If no barrier, this case happens
> 
> ==
> 	update			reference
> 	CPU A			CPU B
> 	set value
> 	synchronize_rcu()	rcu_read_lock()
> 				read_value <= find old value
> 				rcu_read_unlock()
> 				do no lock
> ==

OK, I have looked at Documentation/memory-barriers.txt again and
spin_unlock is not a full barrier so we cannot rely on it.
Anyway you still could do the barrier once after we set all values?
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
