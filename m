Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7DA6B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 13:26:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id u6-v6so1552626eds.10
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 10:26:30 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r4-v6si3656771edy.231.2018.11.02.10.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 10:26:28 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Date: Fri, 2 Nov 2018 17:25:58 +0000
Message-ID: <20181102172547.GA19042@tower.DHCP.thefacebook.com>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102073009.GP23921@dhcp22.suse.cz>
 <20181102154844.GA17619@tower.DHCP.thefacebook.com>
 <20181102161314.GF28039@dhcp22.suse.cz>
 <20181102162237.GB17619@tower.DHCP.thefacebook.com>
 <20181102165147.GG28039@dhcp22.suse.cz>
In-Reply-To: <20181102165147.GG28039@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <DFBA2EC09ED4C44691CFA9FBFB66BF56@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dexuan Cui <decui@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel
 Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 05:51:47PM +0100, Michal Hocko wrote:
> On Fri 02-11-18 16:22:41, Roman Gushchin wrote:
> > On Fri, Nov 02, 2018 at 05:13:14PM +0100, Michal Hocko wrote:
> > > On Fri 02-11-18 15:48:57, Roman Gushchin wrote:
> > > > On Fri, Nov 02, 2018 at 09:03:55AM +0100, Michal Hocko wrote:
> > > > > On Fri 02-11-18 02:45:42, Dexuan Cui wrote:
> > > > > [...]
> > > > > > I totally agree. I'm now just wondering if there is any tempora=
ry workaround,
> > > > > > even if that means we have to run the kernel with some features=
 disabled or
> > > > > > with a suboptimal performance?
> > > > >=20
> > > > > One way would be to disable kmem accounting (cgroup.memory=3Dnokm=
em kernel
> > > > > option). That would reduce the memory isolation because quite a l=
ot of
> > > > > memory will not be accounted for but the primary source of in-fli=
ght and
> > > > > hard to reclaim memory will be gone.
> > > >=20
> > > > In my experience disabling the kmem accounting doesn't really solve=
 the issue
> > > > (without patches), but can lower the rate of the leak.
> > >=20
> > > This is unexpected. 90cbc2508827e was introduced to address offline
> > > memcgs to be reclaim even when they are small. But maybe you mean tha=
t
> > > we still leak in an absence of the memory pressure. Or what does prev=
ent
> > > memcg from going down?
> >=20
> > There are 3 independent issues which are contributing to this leak:
> > 1) Kernel stack accounting weirdness: processes can reuse stack account=
ed to
> > different cgroups. So basically any running process can take a referenc=
e to any
> > cgroup.
>=20
> yes, but kmem accounting should rule that out, right? If not then this
> is a clear bug and easy to backport because that would mean to add a
> missing memcg_kmem_enabled check.

Yes, you're right, disabling kmem accounting should mitigate this problem.

>=20
> > 2) We do forget to scan the last page in the LRU list. So if we ended u=
p with
> > 1-page long LRU, it can stay there basically forever.
>=20
> Why=20
> 		/*
> 		 * If the cgroup's already been deleted, make sure to
> 		 * scrape out the remaining cache.
> 		 */
> 		if (!scan && !mem_cgroup_online(memcg))
> 			scan =3D min(size, SWAP_CLUSTER_MAX);
>=20
> in get_scan_count doesn't work for that case?

No, it doesn't. Let's look at the whole picture:

		size =3D lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
		scan =3D size >> sc->priority;
		/*
		 * If the cgroup's already been deleted, make sure to
		 * scrape out the remaining cache.
		 */
		if (!scan && !mem_cgroup_online(memcg))
			scan =3D min(size, SWAP_CLUSTER_MAX);

If size =3D=3D 1, scan =3D=3D 0 =3D> scan =3D min(1, 32) =3D=3D 1.
And after proportional adjustment we'll have 0.

So, disabling kmem accounting mitigates 2 other issues, but not this one.

Anyway, I'd prefer to wait a bit for test results, and backport the whole
series as a whole.

Thanks!
