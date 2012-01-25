Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id D432B6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 06:07:28 -0500 (EST)
Date: Wed, 25 Jan 2012 12:07:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 2/7 v2] memcg: add memory barrier for checking
 account move.
Message-ID: <20120125110725.GD25368@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
 <20120117152635.GA22142@tiehlicka.suse.cz>
 <20120118090656.83268b3e.kamezawa.hiroyu@jp.fujitsu.com>
 <20120118123759.GB31112@tiehlicka.suse.cz>
 <20120119111727.6337bde4.kamezawa.hiroyu@jp.fujitsu.com>
 <CALWz4iz59=-J+cif+XickXBG3zUSy58yHhkX6j3zbJyBXGzpYw@mail.gmail.com>
 <20120123090436.GA12375@tiehlicka.suse.cz>
 <CALWz4iyaWtes=aU79DAbEfBsNUTaHKLK5HZbNfShaxgC8UX_TQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iyaWtes=aU79DAbEfBsNUTaHKLK5HZbNfShaxgC8UX_TQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Tue 24-01-12 11:04:16, Ying Han wrote:
> On Mon, Jan 23, 2012 at 1:04 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Fri 20-01-12 10:08:44, Ying Han wrote:
> >> On Wed, Jan 18, 2012 at 6:17 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
[...]
> >> > I doubt .... If no barrier, this case happens
> >> >
> >> > ==
> >> >        update                  reference
> >> >        CPU A                   CPU B
> >> >        set value
> >> >        synchronize_rcu()       rcu_read_lock()
> >> >                                read_value <= find old value
> >> >                                rcu_read_unlock()
> >> >                                do no lock
> >> > ==
> >>
> >> Hi Kame,
> >>
> >> Can you help to clarify a bit more on the example above? Why
> >> read_value got the old value after synchronize_rcu().
> >
> > AFAIU it is because rcu_read_unlock doesn't force any memory barrier
> > and we synchronize only the updater (with synchronize_rcu), so nothing
> > guarantees that the value set on CPUA is visible to CPUB.
> 
> Thanks, and i might have found similar comment on the
> documentation/rcu/checklist.txt:
> "
> The various RCU read-side primitives do -not- necessarily contain
> memory barriers.
> "
> 
> So, the read barrier here is to make sure no reordering between the
> reader and the rcu_read_lock. The same for the write barrier which
> makes sure no reordering between the updater and synchronize_rcu. The
> the rcu here is to synchronize between the updater and reader. If so,
> why not the change like :
> 
>        for_each_online_cpu(cpu)
>                per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
> +      smp_wmb();

Threre is a data dependency between per_cpu update (the above for look)
and local read of the per-cpu on the read-side and IIUC we need to pair
write barrier with read one before we read the value.

But I might be wrong here (see the SMP BARRIER PAIRING section in
Documentation/memory-barriers.txt).

> Sorry, the use of per-cpu variable MEM_CGROUP_ON_MOVE does confuse me.

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
