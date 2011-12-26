Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 6E60A6B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 01:36:54 -0500 (EST)
Date: Mon, 26 Dec 2011 08:36:52 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/6] memcg: fix unused variable warning
Message-ID: <20111226063652.GA13273@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
 <20111226152531.e0335ec4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20111226152531.e0335ec4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Dec 26, 2011 at 03:25:31PM +0900, KAMEZAWA Hiroyuki wrote:
> On Sat, 24 Dec 2011 05:00:14 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>=20
> > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> >=20
> > mm/memcontrol.c: In function =E2=80=98memcg_check_events=E2=80=99:
> > mm/memcontrol.c:784:22: warning: unused variable =E2=80=98do_numainfo=
=E2=80=99 [-Wunused-variable]
> >=20
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>=20
> Hmm ? Doesn't this fix cause a new Warning ?
>=20
> mm/memcontrol.c: In function ?memcg_check_events?:
> mm/memcontrol.c:789: warning: ISO C90 forbids mixed declarations and code

I don't see how. The result code is:

	if (unlikely(mem_cgroup_event_ratelimit(memcg,
						MEM_CGROUP_TARGET_THRESH))) {
		bool do_softlimit;

#if MAX_NUMNODES > 1
		bool do_numainfo;
		do_numainfo =3D mem_cgroup_event_ratelimit(memcg,
						MEM_CGROUP_TARGET_NUMAINFO);
#endif
		do_softlimit =3D mem_cgroup_event_ratelimit(memcg,
						MEM_CGROUP_TARGET_SOFTLIMIT);
		preempt_enable();

		mem_cgroup_threshold(memcg);


>=20
> Thanks,
> -Kame
> > ---
> >  mm/memcontrol.c |    7 ++++---
> >  1 files changed, 4 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index d643bd6..a5e92bd 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -781,14 +781,15 @@ static void memcg_check_events(struct mem_cgroup =
*memcg, struct page *page)
> >  	/* threshold event is triggered in finer grain than soft limit */
> >  	if (unlikely(mem_cgroup_event_ratelimit(memcg,
> >  						MEM_CGROUP_TARGET_THRESH))) {
> > -		bool do_softlimit, do_numainfo;
> > +		bool do_softlimit;
> > =20
> > -		do_softlimit =3D mem_cgroup_event_ratelimit(memcg,
> > -						MEM_CGROUP_TARGET_SOFTLIMIT);
> >  #if MAX_NUMNODES > 1
> > +		bool do_numainfo;
> >  		do_numainfo =3D mem_cgroup_event_ratelimit(memcg,
> >  						MEM_CGROUP_TARGET_NUMAINFO);
> >  #endif
> > +		do_softlimit =3D mem_cgroup_event_ratelimit(memcg,
> > +						MEM_CGROUP_TARGET_SOFTLIMIT);
> >  		preempt_enable();
> > =20
> >  		mem_cgroup_threshold(memcg);
> > --=20
> > 1.7.7.3
> >=20
>=20

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
