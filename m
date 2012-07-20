Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id ECE896B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 11:46:00 -0400 (EDT)
Message-ID: <1342799140.2583.6.camel@twins>
Subject: Re: [PATCH] cgroup: Don't drop the cgroup_mutex in cgroup_rmdir
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 20 Jul 2012 17:45:40 +0200
In-Reply-To: <20120719165046.GO24336@google.com>
References: <87ipdjc15j.fsf@skywalker.in.ibm.com>
	 <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20120719165046.GO24336@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, glommer@parallels.com

On Thu, 2012-07-19 at 09:50 -0700, Tejun Heo wrote:
> On Thu, Jul 19, 2012 at 07:39:32PM +0530, Aneesh Kumar K.V wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >=20
> > We dropped cgroup mutex, because of a deadlock between memcg and cpuset=
.
> > cpuset took hotplug lock followed by cgroup_mutex, where as memcg pre_d=
estroy
> > did lru_add_drain_all() which took hotplug lock while already holding
> > cgroup_mutex. The deadlock is explained in 3fa59dfbc3b223f02c26593be69c=
e6fc9a940405
> > But dropping cgroup_mutex in cgroup_rmdir also means tasks could get
> > added to cgroup while we are in pre_destroy. This makes error handling =
in
> > pre_destroy complex. So move the unlock/lock to memcg pre_destroy callb=
ack.
> > Core cgroup will now call pre_destroy with cgroup_mutex held.
> >=20
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>=20
> I generally think cgroup_mutex shouldn't be dropped across any cgroup
> hierarchy changing operation and thus agree with the cgroup core
> change.
>=20
> >  static int mem_cgroup_pre_destroy(struct cgroup *cont)
> >  {
> > +	int ret;
> >  	struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cont);
> > =20
> > -	return mem_cgroup_force_empty(memcg, false);
> > +	cgroup_unlock();
> > +	/*
> > +	 * we call lru_add_drain_all, which end up taking
> > +	 * mutex_lock(&cpu_hotplug.lock), But cpuset have
> > +	 * the reverse order. So drop the cgroup lock
> > +	 */
> > +	ret =3D mem_cgroup_force_empty(memcg, false);
> > +	cgroup_lock();
> > +	return ret;
> >  }
>=20
> This reverse dependency from cpuset is the same problem Glauber
> reported a while ago.  I don't know why / how cgroup_mutex got
> exported to outside world but this is asking for trouble.  cgroup
> mutex protects cgroup hierarchies.  There are many core subsystems
> which implement cgroup controllers.  Controller callbacks for
> hierarchy changing oeprations need to synchronize with the rest of the
> core subsystems.  So, by design, in locking hierarchy, cgroup_mutex
> has to be one of the outermost locks.  If somebody tries to grab it
> from inside other core subsystem locks, there of course will be
> circular locking dependencies.
>=20
> So, Peter, why does cpuset mangle with cgroup_mutex?  What guarantees
> does it need?  Why can't it work on "changed" notification while
> caching the current css like blkcg does?

I've no clue sorry.. /me goes stare at this stuff.. Looks like something
Paul Menage did when he created cgroups. I'll have to have a hard look
at all that to untangle this. Not something obvious to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
