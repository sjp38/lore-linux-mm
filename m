Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 983DD6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 04:04:41 -0500 (EST)
Date: Mon, 23 Jan 2012 10:04:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 2/7 v2] memcg: add memory barrier for checking
 account move.
Message-ID: <20120123090436.GA12375@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
 <20120117152635.GA22142@tiehlicka.suse.cz>
 <20120118090656.83268b3e.kamezawa.hiroyu@jp.fujitsu.com>
 <20120118123759.GB31112@tiehlicka.suse.cz>
 <20120119111727.6337bde4.kamezawa.hiroyu@jp.fujitsu.com>
 <CALWz4iz59=-J+cif+XickXBG3zUSy58yHhkX6j3zbJyBXGzpYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iz59=-J+cif+XickXBG3zUSy58yHhkX6j3zbJyBXGzpYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri 20-01-12 10:08:44, Ying Han wrote:
> On Wed, Jan 18, 2012 at 6:17 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 18 Jan 2012 13:37:59 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> >
> >> On Wed 18-01-12 09:06:56, KAMEZAWA Hiroyuki wrote:
> >> > On Tue, 17 Jan 2012 16:26:35 +0100
> >> > Michal Hocko <mhocko@suse.cz> wrote:
> >> >
> >> > > On Fri 13-01-12 17:33:47, KAMEZAWA Hiroyuki wrote:
> >> > > > I think this bugfix is needed before going ahead. thoughts?
> >> > > > ==
> >> > > > From 2cb491a41782b39aae9f6fe7255b9159ac6c1563 Mon Sep 17 00:00:00 2001
> >> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > > > Date: Fri, 13 Jan 2012 14:27:20 +0900
> >> > > > Subject: [PATCH 2/7] memcg: add memory barrier for checking account move.
> >> > > >
> >> > > > At starting move_account(), source memcg's per-cpu variable
> >> > > > MEM_CGROUP_ON_MOVE is set. The page status update
> >> > > > routine check it under rcu_read_lock(). But there is no memory
> >> > > > barrier. This patch adds one.
> >> > >
> >> > > OK this would help to enforce that the CPU would see the current value
> >> > > but what prevents us from the race with the value update without the
> >> > > lock? This is as racy as it was before AFAICS.
> >> > >
> >> >
> >> > Hm, do I misunderstand ?
> >> > ==
> >> >    update                     reference
> >> >
> >> >    CPU A                        CPU B
> >> >   set value                rcu_read_lock()
> >> >   smp_wmb()                smp_rmb()
> >> >                            read_value
> >> >                            rcu_read_unlock()
> >> >   synchronize_rcu().
> >> > ==
> >> > I expect
> >> > If synchronize_rcu() is called before rcu_read_lock() => move_lock_xxx will be held.
> >> > If synchronize_rcu() is called after rcu_read_lock() => update will be delayed.
> >>
> >> Ahh, OK I can see it now. Readers are not that important because it is
> >> actually the updater who is delayed until all preexisting rcu read
> >> sections are finished.
> >>
> >> In that case. Why do we need both barriers? spin_unlock is a full
> >> barrier so maybe we just need smp_rmb before we read value to make sure
> >> that we do not get stalled value when we start rcu_read section after
> >> synchronize_rcu?
> >>
> >
> > I doubt .... If no barrier, this case happens
> >
> > ==
> >        update                  reference
> >        CPU A                   CPU B
> >        set value
> >        synchronize_rcu()       rcu_read_lock()
> >                                read_value <= find old value
> >                                rcu_read_unlock()
> >                                do no lock
> > ==
> 
> Hi Kame,
> 
> Can you help to clarify a bit more on the example above? Why
> read_value got the old value after synchronize_rcu().

AFAIU it is because rcu_read_unlock doesn't force any memory barrier
and we synchronize only the updater (with synchronize_rcu), so nothing
guarantees that the value set on CPUA is visible to CPUB.

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
