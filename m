Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 22AA16B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 22:25:19 -0500 (EST)
Received: by iacb35 with SMTP id b35so12246490iac.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 19:25:18 -0800 (PST)
Date: Tue, 20 Dec 2011 19:25:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] memcg: reset to root_mem_cgroup at bypassing
In-Reply-To: <20111221091347.4f1a10d8.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1112201847500.1310@eggly.anvils>
References: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1112191218350.3639@eggly.anvils> <CABEgKgrk4X13V2Ra_g+V5J0echpj2YZfK20zaFRKP-PhWRWiYQ@mail.gmail.com> <20111221091347.4f1a10d8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-472047041-1324437918=:1310"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-472047041-1324437918=:1310
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 21 Dec 2011, KAMEZAWA Hiroyuki wrote:
> On Tue, 20 Dec 2011 09:24:47 +0900
> Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com> wrote:
> > 2011/12/20 Hugh Dickins <hughd@google.com>:
> >=20
> > > I speak from experience: I did *exactly* the same at "bypass" when
> > > I introduced our mem_cgroup_reset_page(), which corresponds to your
> > > mem_cgroup_reset_owner(); it seemed right to me that a successful
> > > (return 0) call to try_charge() should provide a good *ptr.
> > >
> > ok.
> >=20
> > > But others (Ying and Greg) pointed out that it changes the semantics
> > > of __mem_cgroup_try_charge() in this case, so you need to justify the
> > > change to all those places which do something like "if (ret || !memcg=
)"
> > > after calling it. =C2=A0Perhaps it is a good change everywhere, but t=
hat's
> > > not obvious, so we chose caution.
> > >
> > > Doesn't it lead to bypass pages being marked as charged to root, so
> > > they don't get charged to the right owner next time they're touched?
> > >
> > Yes. You're right.
> > Hm. So, it seems I should add reset_owner() to the !memcg path
> > rather than here.
> >=20
> Considering this again..
>=20
> Now, we catch 'charge' event only once in lifetime of anon/file page.
> So, it doesn't depend on that it's marked as PCG_USED or not.

That's an interesting argument, I hadn't been looking at it that way.
It's not true of swapcache, but I guess we don't need to preserve its
peculiarities in this case.

I've not checked the (ret || !memcg) cases yet to see if any change
needed there.

I certainly like that the success return guarantees that memcg is set.

Hugh
--8323584-472047041-1324437918=:1310--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
